#!/bin/bash
# AeroBeat Linux Launcher
# Usage: ./run.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAME_EXE="${SCRIPT_DIR}/aerobeat"
SIDECAR_DIR="${SCRIPT_DIR}/sidecar"
PYTHON_DIR="${SIDECAR_DIR}/python"
PYTHON_EXE="${PYTHON_DIR}/bin/python3"
SERVER_SCRIPT="${SIDECAR_DIR}/mediapipe_server/main.py"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[AeroBeat]${NC} $1"; }
success() { echo -e "${GREEN}[AeroBeat]${NC} $1"; }
warn() { echo -e "${YELLOW}[AeroBeat]${NC} $1"; }
error() { echo -e "${RED}[AeroBeat]${NC} $1"; }

# Cleanup function
cleanup() {
    if [ -n "${SIDECAR_PID:-}" ]; then
        log "Stopping sidecar..."
        kill $SIDECAR_PID 2>/dev/null || true
    fi
}
trap cleanup EXIT

log "Starting AeroBeat..."

# Check for camera
if ls /dev/video* 1>/dev/null 2>&1; then
    success "Camera detected"
else
    warn "No camera found at /dev/video*"
fi

# Verify bundled Python
if [ ! -f "${PYTHON_EXE}" ]; then
    error "Bundled Python not found!"
    exit 1
fi

# Setup Python environment
export PYTHONHOME="${PYTHON_DIR}"
export PYTHONPATH="${PYTHON_DIR}/lib/python3.11/site-packages:${PYTHON_DIR}/lib/python3.12/site-packages"

success "Python ready: $(${PYTHON_EXE} --version)"

# Download models if needed
if [ ! -d "${SIDECAR_DIR}/models" ] || [ -z "$(ls -A ${SIDECAR_DIR}/models 2>/dev/null)" ]; then
    log "Downloading MediaPipe models..."
    "${PYTHON_EXE}" "${SIDECAR_DIR}/download_models.py" || warn "Model download failed (will retry on first run)"
fi

# Start Python sidecar
if [ -f "${SERVER_SCRIPT}" ]; then
    log "Starting MediaPipe sidecar..."
    "${PYTHON_EXE}" "${SERVER_SCRIPT}" &
    SIDECAR_PID=$!
    sleep 2
    
    if kill -0 $SIDECAR_PID 2>/dev/null; then
        success "Sidecar running (PID: $SIDECAR_PID)"
    else
        error "Failed to start sidecar!"
        exit 1
    fi
else
    warn "Server script not found at ${SERVER_SCRIPT}"
fi

# Launch game
if [ -f "${GAME_EXE}" ]; then
    log "Launching AeroBeat..."
    "${GAME_EXE}" "$@"
else
    error "Game executable not found at ${GAME_EXE}"
    error "Run build-linux-bundle.sh first to export the project."
    exit 1
fi
