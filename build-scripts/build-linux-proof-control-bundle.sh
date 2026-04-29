#!/bin/bash
# build-linux-proof-control-bundle.sh - Build a no-sidecar Linux control bundle for AeroBeat Assembly.
#
# This exports the same proof shell with a dedicated control feature flag that
# avoids launching the MediaPipe sidecar, autostart manager, camera stream, and
# tracking provider path.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build/linux-proof-control"
DIST_DIR="${PROJECT_ROOT}/dist"
LAUNCHER_INCLUDE="${PROJECT_ROOT}/build-scripts/templates/godot-linux-launch.inc.sh"
BUNDLE_NAME="AeroBeatAssemblyProofControl-Linux"
BUNDLE_DIR="${DIST_DIR}/${BUNDLE_NAME}"
EXPORT_NAME="AeroBeatAssemblyProofControl.x86_64"
EXPORT_PRESET="Linux Proof Control"
EXPORT_LOG="${PROJECT_ROOT}/.qa-logs/oc-bnp-export-control.log"
BUNDLE_LOG="${PROJECT_ROOT}/.qa-logs/oc-bnp-bundle-control.log"

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
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "$1 is not installed"
        exit 1
    fi
}

log_info "Checking prerequisites..."
check_command godot
check_command tar

mkdir -p "${PROJECT_ROOT}/.qa-logs" "${BUILD_DIR}" "${DIST_DIR}"
rm -rf "${BUNDLE_DIR}" "${DIST_DIR}/${BUNDLE_NAME}.tar.gz"

if [ ! -f "${PROJECT_ROOT}/export_presets.cfg" ]; then
    log_error "export_presets.cfg is missing from the project root"
    exit 1
fi

if [ ! -f "${LAUNCHER_INCLUDE}" ]; then
    log_error "Missing launcher helper template at ${LAUNCHER_INCLUDE}"
    exit 1
fi

log_info "Exporting Godot project with preset '${EXPORT_PRESET}'..."
(
    cd "${PROJECT_ROOT}"
    godot --headless --path . --export-release "${EXPORT_PRESET}" "${BUILD_DIR}/${EXPORT_NAME}"
) >"${EXPORT_LOG}" 2>&1 || {
    tail -n 200 "${EXPORT_LOG}" >&2 || true
    log_error "Godot export failed; see ${EXPORT_LOG}"
    exit 1
}

log_success "Control export finished"

EXPORT_PCK="${BUILD_DIR}/${EXPORT_NAME%.x86_64}.pck"
if [ ! -f "${BUILD_DIR}/${EXPORT_NAME}" ]; then
    log_error "Expected export executable missing: ${BUILD_DIR}/${EXPORT_NAME}"
    exit 1
fi
if [ ! -f "${EXPORT_PCK}" ]; then
    log_warn "Expected external PCK missing at ${EXPORT_PCK}; continuing in case Godot embedded it"
fi

log_info "Assembling control bundle..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${BUNDLE_DIR}"
cp "${BUILD_DIR}/${EXPORT_NAME}" "${BUNDLE_DIR}/"
chmod +x "${BUNDLE_DIR}/${EXPORT_NAME}"
if [ -f "${EXPORT_PCK}" ]; then
    cp "${EXPORT_PCK}" "${BUNDLE_DIR}/"
fi
if [ -f "${PROJECT_ROOT}/icon.svg" ]; then
    cp "${PROJECT_ROOT}/icon.svg" "${BUNDLE_DIR}/"
fi
cp "${LAUNCHER_INCLUDE}" "${BUNDLE_DIR}/godot-linux-launch.inc.sh"
rm -f "${BUNDLE_DIR}/icon.svg.import"

cat > "${BUNDLE_DIR}/run-proof-control.sh" <<'SCRIPT'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/godot-linux-launch.inc.sh"
launcher_select_display_driver "$@"
chmod +x ./AeroBeatAssemblyProofControl.x86_64
exec ./AeroBeatAssemblyProofControl.x86_64 "${LAUNCHER_DISPLAY_ARGS[@]}" "${LAUNCHER_PASSTHROUGH_ARGS[@]}"
SCRIPT
chmod +x "${BUNDLE_DIR}/run-proof-control.sh"

cat > "${BUNDLE_DIR}/AeroBeat.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AeroBeat
Comment=AeroBeat MediaPipe Linux proof control build
Exec=run-proof-control.sh
Icon=icon.svg
Terminal=false
Categories=Game;
StartupNotify=true
StartupWMClass=AeroBeat
EOF
chmod +x "${BUNDLE_DIR}/AeroBeat.desktop"

cat > "${BUNDLE_DIR}/README.txt" <<'EOF'
AeroBeat MediaPipe Linux Proof Control Bundle
============================================

This temporary control bundle exists only to isolate the close-crash behavior.
It keeps the proof export shell/layout comparable, but intentionally avoids:
- AutoStartManager creation
- MediaPipe sidecar launch
- camera preview startup
- tracking/provider startup

Desktop integration:
- AeroBeat.desktop                    Linux launcher with Name=AeroBeat
- StartupWMClass=AeroBeat             Matches the exported project window class/title

Files of interest:
- AeroBeatAssemblyProofControl.x86_64 Control export binary
- AeroBeatAssemblyProofControl.pck    Exported project data (if not embedded)
- run-proof-control.sh                Convenience launcher with Wayland preference logic
- godot-linux-launch.inc.sh           Shared Linux launcher helper used by the wrapper

Launch:
  ./run-proof-control.sh

Wayland workaround behavior:
- On Wayland sessions, ./run-proof-control.sh prefers native Wayland by adding:
    --display-driver wayland
- On X11-only systems, the launcher leaves the export's default path unchanged
- Disable/rollback for one launch with:
    AEROBEAT_FORCE_X11=1 ./run-proof-control.sh
    ./run-proof-control.sh --x11
- Force Wayland explicitly with:
    ./run-proof-control.sh --wayland
EOF

(
    cd "${DIST_DIR}"
    tar -czf "${BUNDLE_NAME}.tar.gz" "${BUNDLE_NAME}"
) >"${BUNDLE_LOG}" 2>&1

log_success "Control bundle ready at ${BUNDLE_DIR}"
log_success "Archive ready at ${DIST_DIR}/${BUNDLE_NAME}.tar.gz"
