#!/bin/bash
# build-macos-bundle.sh - Build macOS distribution bundle for AeroBeat
# 
# Usage:
#   ./build-macos-bundle.sh [--skip-export] [--skip-sign]
#
# Options:
#   --skip-export   Skip Godot export (useful for testing)
#   --skip-sign     Skip code signing
#
# Output:
#   Creates AeroBeat.app bundle and AeroBeat-macOS.dmg

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
APP_NAME="AeroBeat"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"

# Python version
PYTHON_VERSION="3.11.8"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AeroBeat macOS Bundle Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Parse arguments
SKIP_EXPORT=false
SKIP_SIGN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-export)
            SKIP_EXPORT=true
            shift
            ;;
        --skip-sign)
            SKIP_SIGN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-export   Skip Godot export"
            echo "  --skip-sign     Skip code signing"
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

# Check for macOS tools
if ! command -v codesign &> /dev/null; then
    echo -e "${YELLOW}Warning: codesign not found (macOS tool)${NC}"
    echo -e "${YELLOW}Will create bundle but cannot sign it${NC}"
    SKIP_SIGN=true
fi

# Create directories
mkdir -p "${BUILD_DIR}"
mkdir -p "${DIST_DIR}"

# Clean previous build
if [ -d "${APP_BUNDLE}" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf "${APP_BUNDLE}"
fi

# Step 1: Godot Export
echo ""
echo -e "${BLUE}[1/6] Exporting Godot project for macOS...${NC}"

if [ "$SKIP_EXPORT" = false ]; then
    cd "${PROJECT_ROOT}"
    
    # Check export preset exists
    if ! grep -q "macOS" export_presets.cfg 2>/dev/null; then
        echo -e "${YELLOW}Creating macOS export preset...${NC}"
        cat >> export_presets.cfg << 'EOF'

[preset.2]

name="macOS"
platform="macOS"
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

[preset.2.options]

export/distribution_type=1
binary_format/architecture="universal"
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
application/icon=""
application/icon_interpolation=4
application/bundle_identifier="com.aerobeat.game"
application/signature="aerobeat"
application/app_category="Games"
application/short_version=""
application/version=""
application/copyright=""
application/copyright_localized={}
application/min_macos_version="10.12"
application/export_angle=0
display/high_res=true
xcode/platform_build="14C18"
xcode/sdk_version="13.1"
xcode/sdk_build="22C55"
xcode/sdk_name="macosx13.1"
xcode/xcode_version="1420"
xcode/xcode_build="14C18"
codesign/codesign=1
codesign/installer_identity=""
codesign/apple_team_id=""
application/icon_16x16=""
application/icon_16x16_dark=""
application/icon_32x32=""
application/icon_32x32_dark=""
application/icon_64x64=""
application/icon_64x64_dark=""
application/icon_128x128=""
application/icon_128x128_dark=""
application/icon_256x256=""
application/icon_256x256_dark=""
application/icon_512x512=""
application/icon_512x512_dark=""
application/icon_1024x1024=""
application/icon_1024x1024_dark=""
notarization/notarization=0
EOF
    fi
    
    # Export for macOS
    godot --headless --path "${PROJECT_ROOT}" --export-release "macOS" "${APP_BUNDLE}"
    
    if [ ! -d "${APP_BUNDLE}" ]; then
        echo -e "${RED}Error: Godot export failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Godot export complete${NC}"
else
    echo -e "${YELLOW}Skipping Godot export${NC}"
    
    # Create minimal app structure if skipping
    if [ ! -d "${APP_BUNDLE}" ]; then
        mkdir -p "${APP_BUNDLE}/Contents/MacOS"
        mkdir -p "${APP_BUNDLE}/Contents/Resources"
    fi
fi

# Step 2: Create Info.plist
echo ""
echo -e "${BLUE}[2/6] Creating Info.plist...${NC}"

cat > "${APP_BUNDLE}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>AeroBeat</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.aerobeat.game</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>AeroBeat</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>MacOSX</string>
    </array>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSCameraUsageDescription</key>
    <string>AeroBeat needs camera access to track your body movements for air drumming. No video is recorded or sent anywhere.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>AeroBeat does not use the microphone.</string>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ Info.plist created${NC}"

# Step 3: Setup Python environment
echo ""
echo -e "${BLUE}[3/6] Setting up Python environment...${NC}"

SIDECAR_DIR="${APP_BUNDLE}/Contents/Resources/sidecar"
mkdir -p "${SIDECAR_DIR}"

# Create Python virtual environment
cd "${BUILD_DIR}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

# Install dependencies
pip install -q mediapipe opencv-python numpy

echo -e "${GREEN}✓ Python environment ready${NC}"

# Step 4: Copy MediaPipe server
echo ""
echo -e "${BLUE}[4/6] Copying MediaPipe server...${NC}"

SERVER_DIR="${SIDECAR_DIR}/mediapipe_server"
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

# Copy Python libraries from venv
PYTHON_LIB="${SIDECAR_DIR}/python"
mkdir -p "${PYTHON_LIB}"

# Copy site-packages
cp -r "${BUILD_DIR}/venv/lib/python3."*/site-packages/* "${PYTHON_LIB}/" 2>/dev/null || true

echo -e "${GREEN}✓ MediaPipe server copied${NC}"

# Step 5: Create launcher script
echo ""
echo -e "${BLUE}[5/6] Creating launcher...${NC}"

cat > "${APP_BUNDLE}/Contents/MacOS/launcher" << 'EOF'
#!/bin/bash
# AeroBeat Launcher for macOS

# Get app bundle path
BUNDLE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RESOURCES_DIR="${BUNDLE_DIR}/Resources"
SIDECAR_DIR="${RESOURCES_DIR}/sidecar"

# Disable App Nap
caffeinate -disu -w $$ &

# Start Python sidecar
cd "${SIDECAR_DIR}"
export PYTHONPATH="${SIDECAR_DIR}/python"

# Start MediaPipe server
python3 mediapipe_server/main.py &
SIDECAR_PID=$!

# Wait for server to start
sleep 2

# Launch Godot game
"${BUNDLE_DIR}/MacOS/AeroBeat"

# Cleanup on exit
trap "kill $SIDECAR_PID 2>/dev/null; exit" EXIT

wait
EOF

chmod +x "${APP_BUNDLE}/Contents/MacOS/launcher"

# Create README
cat > "${DIST_DIR}/README-macOS.txt" << 'EOF'
AeroBeat - Air Drumming Game (macOS)
=====================================

Quick Start:
1. Right-click AeroBeat.app and select "Open"
2. Click "Open" in the security dialog (first time only)
3. Grant camera access when prompted
4. Start drumming in the air!

If you see "AeroBeat can't be opened":
- Go to System Settings → Privacy & Security
- Scroll down and click "Open Anyway"
- This is normal for apps not from the Mac App Store

Command Line:
  open AeroBeat.app
  
Or from Terminal:
  ./AeroBeat.app/Contents/MacOS/launcher

Requirements:
- macOS 10.12 or later
- Camera access
- Apple Silicon or Intel Mac

Troubleshooting:
- If camera not detected: Check System Settings → Camera
- If game won't start: Check Console app for errors
- For performance: Close other applications

For help: https://github.com/AeroBeat/docs
EOF

echo -e "${GREEN}✓ Launcher and README created${NC}"

# Step 6: Code signing
echo ""
echo -e "${BLUE}[6/6] Code signing...${NC}"

if [ "$SKIP_SIGN" = false ]; then
    # Ad-hoc signing (no Developer ID needed)
    codesign --force --deep --sign - "${APP_BUNDLE}"
    echo -e "${GREEN}✓ App bundle signed (ad-hoc)${NC}"
else
    echo -e "${YELLOW}Skipping code signing${NC}"
fi

# Create DMG (optional)
echo ""
echo -e "${BLUE}[Bonus] Creating DMG...${NC}"

if command -v hdiutil &> /dev/null; then
    DMG_NAME="${DIST_DIR}/AeroBeat-macOS.dmg"
    
    # Remove old DMG
    rm -f "${DMG_NAME}"
    
    # Create temporary directory for DMG contents
    DMG_TEMP=$(mktemp -d)
    cp -r "${APP_BUNDLE}" "${DMG_TEMP}/"
    cp "${DIST_DIR}/README-macOS.txt" "${DMG_TEMP}/README.txt"
    
    # Create DMG
    hdiutil create -volname "AeroBeat" -srcfolder "${DMG_TEMP}" -ov -format UDZO "${DMG_NAME}"
    
    # Cleanup
    rm -rf "${DMG_TEMP}"
    
    DMG_SIZE=$(du -h "${DMG_NAME}" | cut -f1)
    echo -e "${GREEN}✓ DMG created: ${DMG_SIZE}${NC}"
else
    echo -e "${YELLOW}hdiutil not available (macOS only), skipping DMG creation${NC}"
fi

# Get app size
APP_SIZE=$(du -sh "${APP_BUNDLE}" | cut -f1)

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "App Bundle: ${APP_BUNDLE}"
echo "Size: ${APP_SIZE}"
if [ -f "${DMG_NAME}" ]; then
    echo "DMG: ${DMG_NAME}"
    echo "Size: ${DMG_SIZE}"
fi
echo ""
echo "Contents:"
echo "  - AeroBeat.app (macOS application)"
echo "  - Camera permissions configured"
echo "  - Python sidecar embedded"
echo "  - MediaPipe server included"
echo ""
echo -e "${YELLOW}Note: This bundle requires macOS for full testing.${NC}"
echo -e "${YELLOW}For distribution without Developer ID, users must right-click → Open.${NC}"
echo ""
