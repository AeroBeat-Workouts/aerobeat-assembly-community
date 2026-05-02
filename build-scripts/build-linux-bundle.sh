#!/bin/bash
# build-linux-bundle.sh - Build a truthful Linux proof bundle for AeroBeat Assembly.
#
# This script exports the Godot project with the dedicated MediaPipe proof preset,
# rewrites the installed addon runtime manifest to release mode, and copies the
# loose Python sidecar payload required by the exported binary.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADDON_ROOT="${PROJECT_ROOT}/addons/aerobeat-input-mediapipe"
PYTHON_MEDIAPIPE_DIR="${ADDON_ROOT}/python_mediapipe"
PREPARE_RUNTIME_SCRIPT="${PYTHON_MEDIAPIPE_DIR}/prepare_runtime.py"
LAUNCHER_INCLUDE="${PROJECT_ROOT}/build-scripts/templates/godot-linux-launch.inc.sh"
BUILD_DIR="${PROJECT_ROOT}/build/linux-proof"
DIST_DIR="${PROJECT_ROOT}/dist"
BUNDLE_NAME="AeroBeatAssemblyProof-Linux"
BUNDLE_DIR="${DIST_DIR}/${BUNDLE_NAME}"
EXPORT_NAME="AeroBeatAssemblyProof.x86_64"
EXPORT_PRESET="Linux Proof"
RUNTIME_PLATFORM="linux-x64"
RELEASE_RUNTIME_LOG="${PROJECT_ROOT}/.qa-logs/oc-dx7-prepare-release-runtime.json"
EXPORT_LOG="${PROJECT_ROOT}/.qa-logs/oc-dx7-export.log"
BUNDLE_LOG="${PROJECT_ROOT}/.qa-logs/oc-dx7-bundle.log"

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
check_command python3
check_command tar

if [ ! -d "${ADDON_ROOT}" ]; then
    log_error "Installed MediaPipe addon is missing at ${ADDON_ROOT}. Run './scripts/restore-addons.sh' from the repo root first."
    exit 1
fi

if [ ! -f "${PREPARE_RUNTIME_SCRIPT}" ]; then
    log_error "Missing runtime preparation helper at ${PREPARE_RUNTIME_SCRIPT}"
    exit 1
fi

if [ ! -f "${LAUNCHER_INCLUDE}" ]; then
    log_error "Missing launcher helper template at ${LAUNCHER_INCLUDE}"
    exit 1
fi

mkdir -p "${PROJECT_ROOT}/.qa-logs" "${BUILD_DIR}" "${DIST_DIR}"
rm -rf "${BUNDLE_DIR}" "${DIST_DIR}/${BUNDLE_NAME}.tar.gz"

log_info "Rewriting the prepared Linux runtime manifest to release mode..."
(
    cd "${ADDON_ROOT}"
    python3 "${PREPARE_RUNTIME_SCRIPT}" --platform "${RUNTIME_PLATFORM}" --mode release --validate --json
) | tee "${RELEASE_RUNTIME_LOG}"

if [ ! -f "${PROJECT_ROOT}/export_presets.cfg" ]; then
    log_error "export_presets.cfg is missing from the project root"
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

log_success "Export finished"

EXPORT_PCK="${BUILD_DIR}/${EXPORT_NAME%.x86_64}.pck"
if [ ! -f "${BUILD_DIR}/${EXPORT_NAME}" ]; then
    log_error "Expected export executable missing: ${BUILD_DIR}/${EXPORT_NAME}"
    exit 1
fi
if [ ! -f "${EXPORT_PCK}" ]; then
    log_warn "Expected external PCK missing at ${EXPORT_PCK}; continuing in case Godot embedded it"
fi

log_info "Assembling proof bundle..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${BUNDLE_DIR}/addons/aerobeat-input-mediapipe"
cp "${BUILD_DIR}/${EXPORT_NAME}" "${BUNDLE_DIR}/"
chmod +x "${BUNDLE_DIR}/${EXPORT_NAME}"
if [ -f "${EXPORT_PCK}" ]; then
    cp "${EXPORT_PCK}" "${BUNDLE_DIR}/"
fi
if [ -f "${PROJECT_ROOT}/icon.svg" ]; then
    cp "${PROJECT_ROOT}/icon.svg" "${BUNDLE_DIR}/"
fi
cp -a "${PYTHON_MEDIAPIPE_DIR}" "${BUNDLE_DIR}/addons/aerobeat-input-mediapipe/"
find "${BUNDLE_DIR}/addons/aerobeat-input-mediapipe/python_mediapipe" -depth -type d -name '__pycache__' -exec rm -rf {} +
find "${BUNDLE_DIR}/addons/aerobeat-input-mediapipe/python_mediapipe" -type f -name '*.pyc' -delete
cp "${LAUNCHER_INCLUDE}" "${BUNDLE_DIR}/godot-linux-launch.inc.sh"
rm -f "${BUNDLE_DIR}/icon.svg.import"

cat > "${BUNDLE_DIR}/run-proof.sh" <<'SCRIPT'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/godot-linux-launch.inc.sh"
launcher_select_display_driver "$@"
chmod +x ./AeroBeatAssemblyProof.x86_64
exec ./AeroBeatAssemblyProof.x86_64 "${LAUNCHER_DISPLAY_ARGS[@]}" "${LAUNCHER_PASSTHROUGH_ARGS[@]}"
SCRIPT
chmod +x "${BUNDLE_DIR}/run-proof.sh"

cat > "${BUNDLE_DIR}/AeroBeat.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AeroBeat
Comment=AeroBeat camera-first Linux proof build
Exec=run-proof.sh
Icon=icon.svg
Terminal=false
Categories=Game;
StartupNotify=true
StartupWMClass=AeroBeat
EOF
chmod +x "${BUNDLE_DIR}/AeroBeat.desktop"

cat > "${BUNDLE_DIR}/README.txt" <<'EOF'
AeroBeat PC Community Camera Proof Bundle
=========================================

This temporary proof bundle boots into the duplicated MediaPipe validation scene
via the export preset feature flag `mediapipe_proof`.

Product scope reminder:
- Camera-first gameplay runtime
- Boxing and Flow are the retained official v1 gameplay slice
- PC community is the current release-first path
- This proof is for current assembly/runtime validation, not polished distribution

Desktop integration:
- AeroBeat.desktop              Linux launcher with Name=AeroBeat
- StartupWMClass=AeroBeat       Matches the exported project window class/title

Files of interest:
- AeroBeatAssemblyProof.x86_64  Godot export binary
- AeroBeatAssemblyProof.pck     Exported project data (if not embedded)
- run-proof.sh                  Convenience launcher with Wayland preference logic
- godot-linux-launch.inc.sh     Shared Linux launcher helper used by the wrapper
- addons/aerobeat-input-mediapipe/python_mediapipe/
                                Loose Python sidecar payload required by the proof

Runtime requirements and limitations:
- Linux x86_64 only
- Godot export templates for 4.6.2 must exist on the build host
- The exported proof still depends on the prepared installed-addon runtime under
  addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/
- Webcam or camera access is still required for the live preview path
- This is a temporary proof artifact, not a polished end-user distribution
- The first WM_CLASS string remains engine-owned (`Godot_Engine`)

Launch:
  ./run-proof.sh

Wayland workaround behavior:
- On Wayland sessions, ./run-proof.sh prefers native Wayland by adding:
    --display-driver wayland
- On X11-only systems, the launcher leaves the export's default path unchanged
- Disable/rollback for one launch with:
    AEROBEAT_FORCE_X11=1 ./run-proof.sh
    ./run-proof.sh --x11
- Force Wayland explicitly with:
    ./run-proof.sh --wayland

Optional smoke run:
  ./run-proof.sh --quit-after 300

For help, visit: https://github.com/AeroBeat-Workouts/aerobeat-assembly-community
EOF

(
    cd "${DIST_DIR}"
    tar -czf "${BUNDLE_NAME}.tar.gz" "${BUNDLE_NAME}"
) >"${BUNDLE_LOG}" 2>&1

log_success "Bundle ready at ${BUNDLE_DIR}"
log_success "Archive ready at ${DIST_DIR}/${BUNDLE_NAME}.tar.gz"
