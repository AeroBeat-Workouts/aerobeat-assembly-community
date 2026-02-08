#!/bin/bash
# build-windows-bundle.sh - Build Windows distribution bundle for AeroBeat
# 
# Usage:
#   ./build-windows-bundle.sh [--skip-export]
#
# Options:
#   --skip-export   Skip Godot export (useful for testing)
#
# Output:
#   Creates AeroBeat-Windows.zip with full self-contained bundle

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADDON_ROOT="$(cd "${PROJECT_ROOT}/../aerobeat-input-mediapipe-python" && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
DIST_DIR="${PROJECT_ROOT}/dist"
BUNDLE_NAME="AeroBeat-Windows"
BUNDLE_DIR="${DIST_DIR}/${BUNDLE_NAME}"

# Python version for Windows embeddable
PYTHON_VERSION="3.11.8"
PYTHON_ZIP="python-${PYTHON_VERSION}-embed-amd64.zip"
PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_ZIP}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AeroBeat Windows Bundle Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Parse arguments
SKIP_EXPORT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-export)
            SKIP_EXPORT=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-export   Skip Godot export"
            echo "  --help, -h      Show this help"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check for Godot
if ! command -v godot &> /dev/null; then
    echo -e "${RED}Error: Godot not found in PATH${NC}"
    echo "Please install Godot 4.6 and add it to PATH"
    exit 1
fi

GODOT_VERSION=$(godot --version 2>/dev/null | head -1)
echo -e "${BLUE}Godot version: ${GODOT_VERSION}${NC}"

# Create directories
mkdir -p "${BUILD_DIR}"
mkdir -p "${DIST_DIR}"
mkdir -p "${BUNDLE_DIR}"

# Clean previous build
if [ -d "${BUNDLE_DIR}" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf "${BUNDLE_DIR}"
fi

mkdir -p "${BUNDLE_DIR}"

# Step 1: Godot Export
echo ""
echo -e "${BLUE}[1/6] Exporting Godot project for Windows...${NC}"

if [ "$SKIP_EXPORT" = false ]; then
    cd "${PROJECT_ROOT}"
    
    # Check export preset exists
    if ! grep -q "Windows Desktop" export_presets.cfg 2>/dev/null; then
        echo -e "${YELLOW}Creating Windows export preset...${NC}"
        cat >> export_presets.cfg << 'EOF'

[preset.1]

name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.1.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
codesign/identity_type=0
codesign/identity=""
codesign/password=""
codesign/timestamp=true
codesign/timestamp_server_url=""
codesign/digest_algorithm=1
codesign/description=""
codesign/custom_options=PackedStringArray()
application/modify_resources=true
application/icon=""
application/console_wrapper_icon=""
application/icon_interpolation=4
application/file_version=""
application/product_version=""
application/company_name="AeroBeat"
application/product_name="AeroBeat"
application/file_description="Air Drumming Game"
application/copyright=""
application/trademarks=""
application/export_angle=0
ssh_remote_deploy/enabled=false
ssh_remote_deploy/host=""
ssh_remote_deploy/port="22"
ssh_remote_deploy/extra_args_ssh=""
ssh_remote_deploy/extra_args_scp=""
ssh_remote_deploy/run_script="Expand-Archive -LiteralPath '{temp_dir}/{archive_name}' -DestinationPath '{temp_dir}'
Start-Process -FilePath '{temp_dir}/{exe_name}'"
ssh_remote_deploy/cleanup_script="Stop-Process -Name '{exe_name}' -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force '{temp_dir}'"
EOF
    fi
    
    # Export for Windows
    godot --headless --path "${PROJECT_ROOT}" --export-release "Windows Desktop" "${BUNDLE_DIR}/AeroBeat.exe"
    
    if [ ! -f "${BUNDLE_DIR}/AeroBeat.exe" ]; then
        echo -e "${RED}Error: Godot export failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Godot export complete${NC}"
else
    echo -e "${YELLOW}Skipping Godot export${NC}"
fi

# Step 2: Download Python embeddable
echo ""
echo -e "${BLUE}[2/6] Downloading Windows embeddable Python...${NC}"

PYTHON_DIR="${BUNDLE_DIR}/python"
mkdir -p "${PYTHON_DIR}"

if [ ! -f "${BUILD_DIR}/${PYTHON_ZIP}" ]; then
    echo "Downloading Python ${PYTHON_VERSION}..."
    wget -q --show-progress -O "${BUILD_DIR}/${PYTHON_ZIP}" "${PYTHON_URL}"
    echo -e "${GREEN}✓ Python download complete${NC}"
else
    echo -e "${YELLOW}Using cached Python zip${NC}"
fi

echo "Extracting Python..."
unzip -q -o "${BUILD_DIR}/${PYTHON_ZIP}" -d "${PYTHON_DIR}"
echo -e "${GREEN}✓ Python extraction complete${NC}"

# Step 3: Install pip and dependencies
echo ""
echo -e "${BLUE}[3/6] Installing Python dependencies...${NC}"

# Download get-pip.py
if [ ! -f "${BUILD_DIR}/get-pip.py" ]; then
    wget -q --show-progress -O "${BUILD_DIR}/get-pip.py" "https://bootstrap.pypa.io/get-pip.py"
fi

# Install pip
cd "${PYTHON_DIR}"
"${PYTHON_DIR}/python.exe" "${BUILD_DIR}/get-pip.py" --no-warn-script-location

# Install dependencies
"${PYTHON_DIR}/python.exe" -m pip install --no-warn-script-location \
    mediapipe opencv-python numpy

echo -e "${GREEN}✓ Dependencies installed${NC}"

# Step 4: Copy MediaPipe server files
echo ""
echo -e "${BLUE}[4/6] Copying MediaPipe server...${NC}"

SERVER_DIR="${BUNDLE_DIR}/python_mediapipe"
mkdir -p "${SERVER_DIR}"

# Copy Python files
cp "${ADDON_ROOT}/python_mediapipe/main.py" "${SERVER_DIR}/"
cp "${ADDON_ROOT}/python_mediapipe/args.py" "${SERVER_DIR}/"
cp "${ADDON_ROOT}/python_mediapipe/roi_tracker.py" "${SERVER_DIR}/"
cp "${ADDON_ROOT}/python_mediapipe/one_euro_filter.py" "${SERVER_DIR}/"
cp "${ADDON_ROOT}/python_mediapipe/platform_utils.py" "${SERVER_DIR}/"
cp "${ADDON_ROOT}/python_mediapipe/mock_server.py" "${SERVER_DIR}/"

# Copy model files
if [ -f "${ADDON_ROOT}/pose_landmarker_lite.task" ]; then
    cp "${ADDON_ROOT}/pose_landmarker_lite.task" "${SERVER_DIR}/"
fi

# Copy requirements.txt
cp "${ADDON_ROOT}/requirements.txt" "${SERVER_DIR}/"

echo -e "${GREEN}✓ MediaPipe server files copied${NC}"

# Step 5: Copy launcher script
echo ""
echo -e "${BLUE}[5/6] Setting up launcher...${NC}"

cp "${PROJECT_ROOT}/build-scripts/templates/run.bat" "${BUNDLE_DIR}/run.bat"

# Create README
cat > "${BUNDLE_DIR}/README.txt" << 'EOF'
AeroBeat - Air Drumming Game (Windows)
======================================

Quick Start:
1. Double-click run.bat to start the game
2. Allow camera access when prompted
3. Start drumming in the air!

Command Line Options:
  run.bat --mock          # Test without camera
  run.bat --camera 1      # Use camera device 1
  run.bat --help          # Show all options

Requirements:
- Windows 10 or 11 (64-bit)
- Webcam or camera device
- DirectX 11 compatible GPU (optional)

Troubleshooting:
- If camera not detected, check Windows privacy settings
- If game won't start, install Visual C++ Redistributables
- For performance issues, close other applications

For more help: https://github.com/AeroBeat/docs
EOF

echo -e "${GREEN}✓ Launcher and README created${NC}"

# Step 6: Create distribution archive
echo ""
echo -e "${BLUE}[6/6] Creating distribution archive...${NC}"

cd "${DIST_DIR}"

# Create zip file (Windows-friendly)
if command -v zip &> /dev/null; then
    zip -r -q "${BUNDLE_NAME}.zip" "${BUNDLE_NAME}"
    echo -e "${GREEN}✓ Created ${BUNDLE_NAME}.zip${NC}"
else
    # Fallback to tar.gz
    tar -czf "${BUNDLE_NAME}.tar.gz" "${BUNDLE_NAME}"
    echo -e "${YELLOW}Created ${BUNDLE_NAME}.tar.gz (zip not available)${NC}"
fi

# Get file size
if [ -f "${BUNDLE_NAME}.zip" ]; then
    BUNDLE_SIZE=$(du -h "${BUNDLE_NAME}.zip" | cut -f1)
else
    BUNDLE_SIZE=$(du -h "${BUNDLE_NAME}.tar.gz" | cut -f1)
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Bundle: ${DIST_DIR}/${BUNDLE_NAME}.zip (or .tar.gz)"
echo "Size: ${BUNDLE_SIZE}"
echo ""
echo "Contents:"
echo "  - AeroBeat.exe (game executable)"
echo "  - run.bat (launcher script)"
echo "  - python/ (embedded Python)"
echo "  - python_mediapipe/ (MediaPipe server)"
echo ""
echo -e "${YELLOW}Note: This bundle was built on Linux.${NC}"
echo -e "${YELLOW}For full Windows compatibility, test on actual Windows machine.${NC}"
echo ""
