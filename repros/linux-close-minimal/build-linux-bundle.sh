#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Missing required command: $1"
        exit 1
    fi
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build/linux"
DIST_DIR="${PROJECT_ROOT}/dist/GodotClosePathMinimal-Linux"
LAUNCHER_INCLUDE="${PROJECT_ROOT}/../../build-scripts/templates/godot-linux-launch.inc.sh"
LOG_DIR="${PROJECT_ROOT}/.qa-logs"
EXPORT_LOG="${LOG_DIR}/export.log"
BUNDLE_LOG="${LOG_DIR}/bundle.log"
EXPORT_PRESET="Linux Minimal Close Repro"
EXPORT_NAME="GodotClosePathMinimal.x86_64"
PCK_NAME="GodotClosePathMinimal.pck"
ARCHIVE_PATH="${PROJECT_ROOT}/dist/GodotClosePathMinimal-Linux.tar.gz"

require_cmd godot
require_cmd tar
if [ ! -f "${LAUNCHER_INCLUDE}" ]; then
    log_error "Missing launcher helper template: ${LAUNCHER_INCLUDE}"
    exit 1
fi
mkdir -p "${BUILD_DIR}" "${DIST_DIR}" "${LOG_DIR}"
rm -rf "${DIST_DIR}" "${ARCHIVE_PATH}"
mkdir -p "${DIST_DIR}"

log_info "Exporting preset '${EXPORT_PRESET}'"
(
    cd "${PROJECT_ROOT}"
    godot --headless --path . --export-release "${EXPORT_PRESET}" "${BUILD_DIR}/${EXPORT_NAME}"
) >"${EXPORT_LOG}" 2>&1 || {
    tail -n 200 "${EXPORT_LOG}" >&2 || true
    log_error "Export failed; see ${EXPORT_LOG}"
    exit 1
}

cp "${BUILD_DIR}/${EXPORT_NAME}" "${DIST_DIR}/"
chmod +x "${DIST_DIR}/${EXPORT_NAME}"
if [ -f "${BUILD_DIR}/${PCK_NAME}" ]; then
    cp "${BUILD_DIR}/${PCK_NAME}" "${DIST_DIR}/"
fi
cp "${PROJECT_ROOT}/icon.svg" "${DIST_DIR}/"
cp "${LAUNCHER_INCLUDE}" "${DIST_DIR}/godot-linux-launch.inc.sh"

cat > "${DIST_DIR}/run.sh" <<'SCRIPT'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/godot-linux-launch.inc.sh"
launcher_select_display_driver "$@"
exec ./GodotClosePathMinimal.x86_64 "${LAUNCHER_DISPLAY_ARGS[@]}" "${LAUNCHER_PASSTHROUGH_ARGS[@]}"
SCRIPT
chmod +x "${DIST_DIR}/run.sh"

cat > "${DIST_DIR}/README.txt" <<'EOF'
GodotClosePathMinimal Linux Bundle
=================================

Purpose:
- brand-new standalone Godot project for Linux close-path QA
- zero AeroBeat bootstrap, addons, or feature switching
- one scene, one script, WM_CLOSE_REQUEST stdout logging

Launch:
  ./run.sh

Fast smoke check:
  ./run.sh --quit-after 300

Wayland workaround behavior:
- On Wayland sessions, ./run.sh prefers native Wayland by adding:
    --display-driver wayland
- On X11-only systems, the launcher leaves the export's default path unchanged
- Disable/rollback for one launch with:
    AEROBEAT_FORCE_X11=1 ./run.sh
    ./run.sh --x11
- Force Wayland explicitly with:
    ./run.sh --wayland

Manual close-path QA:
1. Launch ./run.sh from a terminal.
2. Wait for the window titled "GodotClosePathMinimal".
3. Click the window close button once.
4. Confirm terminal output includes:
     [MinimalCloseRepro] WM_CLOSE_REQUEST ...
5. Confirm the process exits immediately after that log line.
EOF

(
    cd "${PROJECT_ROOT}/dist"
    tar -czf "$(basename "${ARCHIVE_PATH}")" "$(basename "${DIST_DIR}")"
) >"${BUNDLE_LOG}" 2>&1

log_success "Bundle ready at ${DIST_DIR}"
log_success "Archive ready at ${ARCHIVE_PATH}"
log_success "Logs: ${EXPORT_LOG}, ${BUNDLE_LOG}"
