#!/bin/bash
# build-linux-bundle.sh - Build Linux distribution bundle for AeroBeat
# 
# Usage:
#   ./build-linux-bundle.sh [--skip-export] [--skip-venv]
#
# Options:
#   --skip-export   Skip Godot export (useful for testing)
#   --skip-venv     Skip Python venv creation (useful for re-runs)
#
# Output:
#   Creates AeroBeat-Linux.tar.gz with full self-contained bundle

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
BUNDLE_NAME="AeroBeat-Linux"
BUNDLE_DIR="${DIST_DIR}/${BUNDLE_NAME}"

# Parse arguments
SKIP_EXPORT=false
SKIP_VENV=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-export)
            SKIP_EXPORT=true
            shift
            ;;
        --skip-venv)
            SKIP_VENV=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Pre-flight checks
log_info "Checking prerequisites..."
check_command "godot"
check_command "python3"
check_command "tar"

# Verify Godot version (needs 4.x)
GODOT_VERSION=$(godot --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' || echo "unknown")
log_info "Godot version: $GODOT_VERSION"

# Clean and create directories
log_info "Setting up build directories..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${BUNDLE_DIR}/sidecar/python"
mkdir -p "${BUNDLE_DIR}/sidecar/mediapipe_server"
mkdir -p "${BUILD_DIR}"
mkdir -p "${DIST_DIR}"

# Step 1: Create Python virtual environment with MediaPipe + OpenCV
if [ "$SKIP_VENV" = false ]; then
    log_info "Creating Python virtual environment..."
    VENV_DIR="${BUILD_DIR}/.venv"
    
    # Clean previous venv
    rm -rf "$VENV_DIR"
    
    # Create new venv
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
    
    # Install requirements
    log_info "Installing MediaPipe and OpenCV..."
    pip install mediapipe opencv-python
    
    # Create .pth file for bundled python to find packages
    cat > "${BUILD_DIR}/aerobeat.pth" << 'EOF'
import sys
import os
bundle_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(bundle_dir, 'sidecar', 'python', 'site-packages'))
EOF
    
    log_success "Virtual environment created"
else
    log_info "Skipping venv creation (--skip-venv)"
    VENV_DIR="${BUILD_DIR}/.venv"
    source "$VENV_DIR/bin/activate"
fi

# Step 2: Export Godot project
if [ "$SKIP_EXPORT" = false ]; then
    log_info "Exporting Godot project for Linux..."
    cd "$PROJECT_ROOT"
    
    # Create export preset if it doesn't exist
    if ! godot --headless --export-release "Linux/X11" "${BUILD_DIR}/AeroBeat.x86_64" 2>&1; then
        log_warn "Export preset not found or export failed. Creating preset..."
        
        # Check if export_presets.cfg exists
        if [ ! -f "${PROJECT_ROOT}/export_presets.cfg" ]; then
            cat > "${PROJECT_ROOT}/export_presets.cfg" << 'EOF'
[preset.0]

name="Linux/X11"
platform="Linux/X11"
features=PackedStringArray("4.6", "Forward Plus")

[preset.0.options]
export/distribution/include_debug_symbols=false
export/distribution/embargo=false
export/distribution/export_console_wrapper=false
texture_format/s3tc=true
texture_format/etc=true
texture_format/etc2=false
binary_format/architecture="x86_64"
EOF
        fi
        
        # Try export again
        godot --headless --export-release "Linux/X11" "${BUILD_DIR}/AeroBeat.x86_64" || {
            log_error "Godot export failed. Please check your export settings."
            exit 1
        }
    fi
    
    log_success "Godot export complete"
else
    log_info "Skipping Godot export (--skip-export)"
fi

# Step 3: Copy Python environment to bundle
log_info "Copying Python environment..."

# Copy Python binary and required libraries
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
VENV_PYTHON_DIR="$VENV_DIR/lib/python${PYTHON_VERSION}"

# Copy entire site-packages
cp -r "${VENV_DIR}/lib/python${PYTHON_VERSION}/site-packages"/* "${BUNDLE_DIR}/sidecar/python/" 2>/dev/null || true

# Copy Python interpreter and libraries
mkdir -p "${BUNDLE_DIR}/sidecar/bin"
cp "${VENV_DIR}/bin/python"* "${BUNDLE_DIR}/sidecar/bin/" 2>/dev/null || cp "${VENV_DIR}/bin/python3" "${BUNDLE_DIR}/sidecar/bin/" 2>/dev/null || true

# Copy python standard library (minimal)
log_info "Copying Python standard library..."
mkdir -p "${BUNDLE_DIR}/sidecar/lib"
cp -r "${VENV_DIR}/lib/python${PYTHON_VERSION}" "${BUNDLE_DIR}/sidecar/lib/" 2>/dev/null || {
    # Fallback: copy system Python lib
    SYSTEM_PYTHON_LIB=$(python3 -c "import sys; print(sys.prefix)")
    cp -r "${SYSTEM_PYTHON_LIB}/lib/python${PYTHON_VERSION}" "${BUNDLE_DIR}/sidecar/lib/" 2>/dev/null || log_warn "Could not copy standard library"
}

log_success "Python environment copied"

# Step 4: Copy MediaPipe server files
log_info "Copying MediaPipe server files..."

cp "${ADDON_ROOT}/python_mediapipe/main.py" "${BUNDLE_DIR}/sidecar/mediapipe_server/"
cp "${ADDON_ROOT}/python_mediapipe/args.py" "${BUNDLE_DIR}/sidecar/mediapipe_server/"

# Copy mock server if it exists
if [ -f "${ADDON_ROOT}/python_mediapipe/mock_server.py" ]; then
    cp "${ADDON_ROOT}/python_mediapipe/mock_server.py" "${BUNDLE_DIR}/sidecar/mediapipe_server/"
fi

log_success "MediaPipe server files copied"

# Step 5: Create model download helper script
cat > "${BUNDLE_DIR}/download_models.sh" << 'SCRIPT'
#!/bin/bash
# download_models.sh - Download MediaPipe models
# This script downloads the required MediaPipe models on first run

echo "Downloading MediaPipe pose detection model..."

MODEL_DIR="$(dirname "$0")/sidecar/models"
mkdir -p "$MODEL_DIR"

# MediaPipe models are automatically downloaded on first use by the mediapipe package
# This script ensures they're pre-downloaded for offline use

python3 << 'PYTHON'
import mediapipe as mp
import os

# Trigger model download by initializing pose
mp_pose = mp.solutions.pose
pose = mp_pose.Pose()
pose.close()

print("Models downloaded successfully!")
PYTHON

echo "Models are ready."
SCRIPT

chmod +x "${BUNDLE_DIR}/download_models.sh"

# Step 6: Copy launcher script
cp "${PROJECT_ROOT}/build-scripts/templates/run.sh" "${BUNDLE_DIR}/run.sh"
chmod +x "${BUNDLE_DIR}/run.sh"

# Step 7: Copy Godot executable and resources
log_info "Copying game files..."
cp "${BUILD_DIR}/AeroBeat.x86_64" "${BUNDLE_DIR}/" 2>/dev/null || {
    log_warn "Could not find Godot export. Place your export manually."
    touch "${BUNDLE_DIR}/AeroBeat.x86_64"
}

# Copy any .pck files
for pck in "${BUILD_DIR}"/*.pck; do
    if [ -f "$pck" ]; then
        cp "$pck" "${BUNDLE_DIR}/"
    fi
done

# Copy project icon if available
if [ -f "${PROJECT_ROOT}/icon.svg" ]; then
    cp "${PROJECT_ROOT}/icon.svg" "${BUNDLE_DIR}/"
fi

# Create README
cat > "${BUNDLE_DIR}/README.txt" << 'EOF'
AeroBeat - Air Drumming Game
============================

Quick Start:
1. Ensure you have a webcam connected
2. Run: ./run.sh
3. Allow camera access when prompted

Requirements:
- Linux x86_64
- Webcam (for hand tracking)
- OpenGL 3.3 compatible GPU

Files:
- run.sh              - Launch script (use this to start)
- AeroBeat.x86_64     - Main game executable
- sidecar/            - Python environment and MediaPipe
- download_models.sh  - Pre-download models (optional)

For help, visit: https://github.com/aerobeat/aerobeat-assembly-community
EOF

log_success "Bundle assembly complete"

# Step 8: Create tarball
log_info "Creating distribution archive..."
cd "$DIST_DIR"
tar -czf "${BUNDLE_NAME}.tar.gz" "$BUNDLE_NAME"

BUNDLE_SIZE=$(du -h "${BUNDLE_NAME}.tar.gz" | cut -f1)
log_success "Bundle created: ${BUNDLE_NAME}.tar.gz (${BUNDLE_SIZE})"

# Summary
echo ""
echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""
echo "Bundle location:"
echo "  ${DIST_DIR}/${BUNDLE_NAME}.tar.gz"
echo ""
echo "To test the bundle:"
echo "  cd ${BUNDLE_DIR}"
echo "  ./run.sh"
echo ""
echo "To distribute:"
echo "  Upload ${BUNDLE_NAME}.tar.gz"
echo ""
