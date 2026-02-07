# Build Distribution Investigation

This document outlines the build and distribution process for AeroBeat across different platforms.

## Table of Contents
- [Linux Bundle](#linux-bundle)
- [Windows Bundle (Future)](#windows-bundle-future)
- [macOS Bundle (Future)](#macos-bundle-future)

---

## Linux Bundle

### Overview

The Linux bundle is a self-contained distribution that includes:
- Godot 4.6 game executable
- Embedded Python environment with MediaPipe + OpenCV
- MediaPipe sidecar server for pose tracking
- Launcher script with camera detection
- Model download helper

### Directory Structure

```
AeroBeat-Linux/
├── run.sh                      # Main launcher script
├── AeroBeat.x86_64            # Godot game executable
├── AeroBeat.pck               # Godot resources (if exported separately)
├── icon.svg                   # Application icon
├── README.txt                 # Quick start guide
├── download_models.sh         # Pre-download MediaPipe models
└── sidecar/
    ├── bin/
    │   └── python3            # Python interpreter
    ├── lib/
    │   └── python3.10/        # Python standard library
    ├── python/                # Site-packages (mediapipe, opencv, etc.)
    └── mediapipe_server/
        ├── main.py            # MediaPipe server entry point
        ├── args.py            # Argument parser
        └── mock_server.py     # Mock server for testing
```

### Build Process

#### Prerequisites
- Godot 4.x (with export templates installed)
- Python 3.10+
- tar, bash

#### Building the Bundle

```bash
cd ~/Documents/GitHub/AeroBeat/aerobeat-assembly-community
./build-scripts/build-linux-bundle.sh
```

Options:
- `--skip-export` - Skip Godot export (useful for testing build scripts)
- `--skip-venv` - Skip Python venv creation (faster rebuilds)

Output: `dist/AeroBeat-Linux.tar.gz`

#### Manual Build Steps

If you need to customize the build:

1. **Create Python venv with dependencies:**
   ```bash
   python3 -m venv build/.venv
   source build/.venv/bin/activate
   pip install mediapipe opencv-python
   ```

2. **Export Godot project:**
   ```bash
   godot --headless --export-release "Linux/X11" build/AeroBeat.x86_64
   ```

3. **Assemble bundle:**
   ```bash
   mkdir -p dist/AeroBeat-Linux/sidecar/{python,mediapipe_server}
   cp -r build/.venv/lib/python*/site-packages/* dist/AeroBeat-Linux/sidecar/python/
   cp python_mediapipe/*.py dist/AeroBeat-Linux/sidecar/mediapipe_server/
   cp build/AeroBeat.x86_64 dist/AeroBeat-Linux/
   cp build-scripts/templates/run.sh dist/AeroBeat-Linux/
   ```

### Running the Bundle

#### Quick Start
```bash
tar -xzf AeroBeat-Linux.tar.gz
cd AeroBeat-Linux
./run.sh
```

#### Launcher Options
```bash
./run.sh --help          # Show help
./run.sh --mock          # Use mock server (no camera)
./run.sh --camera 1      # Use camera device 1
./run.sh --no-camera     # Skip camera detection
```

#### Environment Variables
- `AEROBEAT_CAMERA` - Camera device ID (default: 0)
- `AEROBEAT_MOCK` - Set to `1` to use mock server

### Troubleshooting

#### "No camera devices found"
- Ensure your webcam is connected and recognized by the system
- Check with: `ls /dev/video*`
- Use `--mock` flag to run without a camera
- Check permissions: user may need to be in `video` group

#### "Sidecar failed to start"
- Check `sidecar.log` in the bundle directory for errors
- Verify Python dependencies: `python3 -c "import mediapipe; import cv2"`
- Try running the sidecar manually:
  ```bash
  cd sidecar/mediapipe_server
  python3 main.py --camera 0
  ```

#### "Godot export failed"
- Ensure export templates are installed: `godot --headless --version`
- Check export_presets.cfg exists or create one via Godot editor
- Verify export preset name matches: "Linux/X11"

#### Permission Denied
```bash
chmod +x run.sh AeroBeat.x86_64
```

### Distribution

The `AeroBeat-Linux.tar.gz` archive can be distributed directly. Users only need to:
1. Extract the archive
2. Run `./run.sh`

No additional dependencies are required (Python and libraries are bundled).

### File Sizes (Approximate)

- Bundle: ~150-200 MB
  - Godot executable + resources: ~50 MB
  - Python + MediaPipe + OpenCV: ~100-150 MB

### Security Considerations

- The launcher script runs with user permissions
- Camera access requires user to be in `video` group
- No root privileges required
- Sandboxed execution recommended for distribution platforms

---

## Windows Bundle (Future)

*Planned: Self-contained Windows executable with embedded Python*

### Approach
- Use PyInstaller or similar to bundle Python
- Create .exe launcher that manages sidecar
- Windows installer (NSIS or MSI)

### Challenges
- Python environment bundling
- Windows Defender false positives
- Camera permission handling

---

## macOS Bundle (Future)

*Planned: macOS .app bundle with embedded Python*

### Approach
- Create .app bundle structure
- Sign and notarize for distribution
- Handle camera permissions (TCC)

### Challenges
- Code signing requirements
- Notarization process
- Apple Silicon (arm64) support
- Camera permission prompts

---

## Appendix: Build Script Reference

### build-linux-bundle.sh

Main build script. Creates the complete Linux bundle.

**Location:** `build-scripts/build-linux-bundle.sh`

**Key Functions:**
- `check_command()` - Verify prerequisites
- `log_info/success/warn/error()` - Colored output
- Python venv creation and package installation
- Godot export execution
- Bundle assembly and packaging

### run.sh

Launcher script template. Copied into the bundle.

**Location:** `build-scripts/templates/run.sh`

**Key Functions:**
- `status_info/ok/warn/error/step()` - Colored status messages
- Python environment setup
- Camera device detection
- Sidecar process management
- Cleanup on exit

### download_models.sh

Helper script to pre-download MediaPipe models.

**Location:** Generated in bundle root

**Purpose:** Allows offline use after first model download
