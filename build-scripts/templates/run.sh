#!/bin/bash
# run.sh - Launcher script for AeroBeat Linux bundle
#
# This script:
#   - Sets up PYTHONPATH for bundled Python
#   - Checks for camera devices
#   - Starts Python sidecar (MediaPipe server)
#   - Launches Godot game
#   - Cleans up sidecar on exit
#
# Usage: ./run.sh [options]
#   --mock          Use mock server instead of real MediaPipe
#   --camera N      Use camera device N (default: 0)
#   --no-camera     Skip camera check (not recommended)

set -e

# Colors for status messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="$SCRIPT_DIR"

# Default configuration
USE_MOCK=false
CAMERA_ID=0
SKIP_CAMERA_CHECK=false
SIDECAR_PID=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mock)
            USE_MOCK=true
            shift
            ;;
        --camera)
            CAMERA_ID="$2"
            shift 2
            ;;
        --no-camera)
            SKIP_CAMERA_CHECK=true
            shift
            ;;
        --help|-h)
            echo "AeroBeat Launcher"
            echo ""
            echo "Usage: ./run.sh [options]"
            echo ""
            echo "Options:"
            echo "  --mock          Use mock server for testing (no camera needed)"
            echo "  --camera N      Use camera device N (default: 0)"
            echo "  --no-camera     Skip camera detection (not recommended)"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  AEROBEAT_CAMERA    Camera device ID (default: 0)"
            echo "  AEROBEAT_MOCK      Set to 1 to use mock server"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run './run.sh --help' for usage information."
            exit 1
            ;;
    esac
done

# Check environment variables
[ -n "$AEROBEAT_CAMERA" ] && CAMERA_ID="$AEROBEAT_CAMERA"
[ "$AEROBEAT_MOCK" = "1" ] && USE_MOCK=true

# Helper functions for colored output
status_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

status_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

status_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

status_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

status_step() {
    echo -e "${CYAN}➜${NC} ${BOLD}$1${NC}"
}

# Cleanup function
cleanup() {
    if [ -n "$SIDECAR_PID" ] && kill -0 "$SIDECAR_PID" 2>/dev/null; then
        status_info "Stopping sidecar (PID: $SIDECAR_PID)..."
        kill "$SIDECAR_PID" 2>/dev/null || true
        wait "$SIDECAR_PID" 2>/dev/null || true
    fi
}

# Set up trap for cleanup on exit
trap cleanup EXIT INT TERM

# Print banner
echo -e "${CYAN}"
echo "    ___                   ____            _   "
echo "   /   |  _______  ______/ __ )________ _| |_"
echo "  / /| | / ___/ / / / __  / __/ ___/ _  / __/"
echo " / ___ |/ /  / /_/ / /_/ / /_/ /  /  __/ /_  "
echo "/_/  |_/_/   \__, /_____/_____/   \___/\__/  "
echo "           /____/                            "
echo -e "${NC}"
echo -e "${BOLD}Air Drumming Game - Linux Bundle${NC}"
echo ""

# Step 1: Set up Python environment
status_step "Setting up Python environment..."

PYTHON_DIR="${BUNDLE_DIR}/sidecar"
if [ -d "${PYTHON_DIR}/python" ]; then
    # Set PYTHONPATH to use bundled packages
    export PYTHONPATH="${PYTHON_DIR}/python:${PYTHON_DIR}/lib/python3.10:${PYTHONPATH:-}"
    
    # Find Python executable
    if [ -f "${PYTHON_DIR}/bin/python3" ]; then
        PYTHON_EXEC="${PYTHON_DIR}/bin/python3"
    elif [ -f "${PYTHON_DIR}/bin/python" ]; then
        PYTHON_EXEC="${PYTHON_DIR}/bin/python"
    else
        # Fall back to system python
        PYTHON_EXEC=$(which python3)
        status_warn "Using system Python: $PYTHON_EXEC"
    fi
else
    # No bundled Python, use system
    PYTHON_EXEC=$(which python3)
    status_warn "No bundled Python found, using system: $PYTHON_EXEC"
fi

# Verify Python works
if ! $PYTHON_EXEC --version &>/dev/null; then
    status_error "Python is not available. Please install Python 3."
    exit 1
fi

status_ok "Python ready: $($PYTHON_EXEC --version 2>&1 | cut -d' ' -f2)"

# Step 2: Check for camera devices
if [ "$SKIP_CAMERA_CHECK" = false ] && [ "$USE_MOCK" = false ]; then
    status_step "Checking camera devices..."
    
    # Check for video devices
    if [ -d "/dev" ]; then
        VIDEO_DEVICES=$(ls /dev/video* 2>/dev/null | wc -l)
        if [ "$VIDEO_DEVICES" -gt 0 ]; then
            status_ok "Found $VIDEO_DEVICES camera device(s)"
            # List available cameras
            for dev in /dev/video*; do
                if [ -c "$dev" ]; then
                    echo "       $dev"
                fi
            done
        else
            status_warn "No camera devices found at /dev/video*"
            status_warn "You can use --mock flag to run without a camera"
            echo ""
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        status_warn "Cannot check for cameras (no /dev directory)"
    fi
else
    if [ "$USE_MOCK" = true ]; then
        status_info "Using mock server (no camera needed)"
    else
        status_warn "Skipping camera check (--no-camera)"
    fi
fi

# Step 3: Start Python sidecar
status_step "Starting MediaPipe sidecar..."

SIDECAR_DIR="${BUNDLE_DIR}/sidecar/mediapipe_server"
SIDECAR_LOG="${BUNDLE_DIR}/sidecar.log"

if [ "$USE_MOCK" = true ]; then
    # Use mock server
    if [ -f "${SIDECAR_DIR}/mock_server.py" ]; then
        status_info "Starting mock server..."
        $PYTHON_EXEC "${SIDECAR_DIR}/mock_server.py" > "$SIDECAR_LOG" 2>&1 &
        SIDECAR_PID=$!
    else
        status_error "Mock server not found at ${SIDECAR_DIR}/mock_server.py"
        exit 1
    fi
else
    # Use real MediaPipe server
    if [ -f "${SIDECAR_DIR}/main.py" ]; then
        status_info "Starting MediaPipe server (camera: $CAMERA_ID)..."
        $PYTHON_EXEC "${SIDECAR_DIR}/main.py" --camera "$CAMERA_ID" > "$SIDECAR_LOG" 2>&1 &
        SIDECAR_PID=$!
    else
        status_error "MediaPipe server not found at ${SIDECAR_DIR}/main.py"
        exit 1
    fi
fi

# Wait for sidecar to start
sleep 2

# Check if sidecar is running
if ! kill -0 "$SIDECAR_PID" 2>/dev/null; then
    status_error "Sidecar failed to start. Check ${SIDECAR_LOG} for details."
    cat "$SIDECAR_LOG" 2>/dev/null || true
    exit 1
fi

status_ok "Sidecar running (PID: $SIDECAR_PID)"

# Show recent logs
if [ -f "$SIDECAR_LOG" ]; then
    tail -n 3 "$SIDECAR_LOG" | while read line; do
        echo "       $line"
    done
fi

# Step 4: Launch Godot game
status_step "Starting AeroBeat..."
echo ""

GAME_EXEC="${BUNDLE_DIR}/AeroBeat.x86_64"

if [ ! -f "$GAME_EXEC" ]; then
    status_error "Game executable not found: $GAME_EXEC"
    exit 1
fi

# Make executable
chmod +x "$GAME_EXEC"

# Launch the game
status_info "Launching game... (press Ctrl+C to quit)"
echo ""

# Run game and capture exit code
"$GAME_EXEC" "$@"
GAME_EXIT=$?

echo ""

# Handle exit
if [ $GAME_EXIT -eq 0 ]; then
    status_ok "Game exited normally"
elif [ $GAME_EXIT -eq 130 ]; then
    status_info "Game interrupted (Ctrl+C)"
else
    status_warn "Game exited with code $GAME_EXIT"
fi

# Cleanup happens automatically via trap
status_info "Cleaning up..."

exit $GAME_EXIT
