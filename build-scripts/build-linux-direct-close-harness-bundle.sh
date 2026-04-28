#!/bin/bash
# build-linux-direct-close-harness-bundle.sh - Build a direct-entry Linux harness bundle for AeroBeat Assembly.
#
# This temporary export rewrites the project's main scene only for the export run
# so the bundle boots straight into a trivial scene instead of routing through
# scenes/main.tscn -> src/main.gd feature-switch/bootstrap logic.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build/linux-direct-close-harness"
DIST_DIR="${PROJECT_ROOT}/dist"
BUNDLE_NAME="AeroBeatDirectCloseHarness-Linux"
BUNDLE_DIR="${DIST_DIR}/${BUNDLE_NAME}"
EXPORT_NAME="AeroBeatDirectCloseHarness.x86_64"
EXPORT_PRESET="Linux Direct Close Harness"
EXPORT_LOG="${PROJECT_ROOT}/.qa-logs/oc-6wn-export-direct-close-harness.log"
BUNDLE_LOG="${PROJECT_ROOT}/.qa-logs/oc-6wn-bundle-direct-close-harness.log"
PROJECT_FILE="${PROJECT_ROOT}/project.godot"
PROJECT_BACKUP="${PROJECT_ROOT}/.qa-logs/project.godot.oc-6wn.backup"
HARNESS_SCENE="res://scenes/direct_close_harness.tscn"

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

restore_project_file() {
    if [ -f "${PROJECT_BACKUP}" ]; then
        mv "${PROJECT_BACKUP}" "${PROJECT_FILE}"
    fi
}

trap restore_project_file EXIT

log_info "Checking prerequisites..."
check_command godot
check_command python3
check_command tar

mkdir -p "${PROJECT_ROOT}/.qa-logs" "${BUILD_DIR}" "${DIST_DIR}"
rm -rf "${BUNDLE_DIR}" "${DIST_DIR}/${BUNDLE_NAME}.tar.gz"
rm -f "${PROJECT_BACKUP}"

if [ ! -f "${PROJECT_FILE}" ]; then
    log_error "project.godot is missing from the project root"
    exit 1
fi

if [ ! -f "${PROJECT_ROOT}/export_presets.cfg" ]; then
    log_error "export_presets.cfg is missing from the project root"
    exit 1
fi

if [ ! -f "${PROJECT_ROOT}/scenes/direct_close_harness.tscn" ]; then
    log_error "Missing harness scene at ${HARNESS_SCENE}"
    exit 1
fi

cp "${PROJECT_FILE}" "${PROJECT_BACKUP}"

log_info "Temporarily rewriting run/main_scene to ${HARNESS_SCENE} for export..."
python3 - "${PROJECT_FILE}" "${HARNESS_SCENE}" <<'PY'
from pathlib import Path
import sys

project_file = Path(sys.argv[1])
harness_scene = sys.argv[2]
text = project_file.read_text()
old = 'run/main_scene="res://scenes/main.tscn"'
new = f'run/main_scene="{harness_scene}"'
if old not in text:
    raise SystemExit(f"Expected main scene entry not found in {project_file}")
project_file.write_text(text.replace(old, new, 1))
PY

log_info "Exporting Godot project with preset '${EXPORT_PRESET}'..."
(
    cd "${PROJECT_ROOT}"
    godot --headless --path . --export-release "${EXPORT_PRESET}" "${BUILD_DIR}/${EXPORT_NAME}"
) >"${EXPORT_LOG}" 2>&1 || {
    tail -n 200 "${EXPORT_LOG}" >&2 || true
    log_error "Godot export failed; see ${EXPORT_LOG}"
    exit 1
}

restore_project_file
trap - EXIT

log_success "Direct harness export finished"

EXPORT_PCK="${BUILD_DIR}/${EXPORT_NAME%.x86_64}.pck"
if [ ! -f "${BUILD_DIR}/${EXPORT_NAME}" ]; then
    log_error "Expected export executable missing: ${BUILD_DIR}/${EXPORT_NAME}"
    exit 1
fi
if [ ! -f "${EXPORT_PCK}" ]; then
    log_warn "Expected external PCK missing at ${EXPORT_PCK}; continuing in case Godot embedded it"
fi

log_info "Assembling direct harness bundle..."
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
rm -f "${BUNDLE_DIR}/icon.svg.import"

cat > "${BUNDLE_DIR}/run-direct-close-harness.sh" <<'SCRIPT'
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
chmod +x ./AeroBeatDirectCloseHarness.x86_64
exec ./AeroBeatDirectCloseHarness.x86_64 "$@"
SCRIPT
chmod +x "${BUNDLE_DIR}/run-direct-close-harness.sh"

cat > "${BUNDLE_DIR}/AeroBeat.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=AeroBeat
Comment=AeroBeat direct close harness build
Exec=AeroBeatDirectCloseHarness.x86_64
Icon=icon.svg
Terminal=false
Categories=Game;
StartupNotify=true
StartupWMClass=AeroBeat
EOF
chmod +x "${BUNDLE_DIR}/AeroBeat.desktop"

cat > "${BUNDLE_DIR}/README.txt" <<'EOF'
AeroBeat Direct Close Harness Bundle
===================================

This temporary harness exists only to isolate the close-path behavior.
It boots directly into a trivial scene by temporarily rewriting the export's
run/main_scene during build time.

It intentionally skips:
- scenes/main.tscn
- src/main.gd
- feature-based scene switching
- MediaPipe/provider startup
- proof/control shell bootstrap

Desktop integration:
- AeroBeat.desktop                    Linux launcher with Name=AeroBeat
- StartupWMClass=AeroBeat             Matches the exported project window class/title

Files of interest:
- AeroBeatDirectCloseHarness.x86_64   Direct-entry export binary
- AeroBeatDirectCloseHarness.pck      Exported project data (if not embedded)
- run-direct-close-harness.sh         Convenience launcher

Launch:
  ./run-direct-close-harness.sh

Optional smoke run:
  ./AeroBeatDirectCloseHarness.x86_64 --quit-after 300
EOF

(
    cd "${DIST_DIR}"
    tar -czf "${BUNDLE_NAME}.tar.gz" "${BUNDLE_NAME}"
) >"${BUNDLE_LOG}" 2>&1

log_success "Direct harness bundle ready at ${BUNDLE_DIR}"
log_success "Archive ready at ${DIST_DIR}/${BUNDLE_NAME}.tar.gz"
