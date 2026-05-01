# Build Distribution Notes

This document tracks the current build/distribution work for the **PC community assembly**.

It is intentionally scoped to the locked AeroBeat v1 truth:

- camera-first gameplay runtime
- Boxing and Flow as the retained official gameplay slice
- PC community release first
- mobile and VR still meaningful later, but not equal-status current release promises

## Table of Contents
- [Linux bundle](#linux-bundle)
- [Windows bundle experiment](#windows-bundle-experiment)
- [macOS bundle experiment](#macos-bundle-experiment)

---

## Linux bundle

### Overview

The Linux bundle is a self-contained PC-community distribution experiment that includes:
- Godot 4.6 game executable
- embedded Python environment with MediaPipe + OpenCV
- MediaPipe sidecar server for camera tracking
- launcher script with camera detection
- model download helper

### Directory structure

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

### Build process

#### Prerequisites
- Godot 4.x (with export templates installed)
- Python 3.10+
- tar, bash

#### Building the bundle

```bash
cd /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community
./build-scripts/build-linux-bundle.sh
```

Options:
- `--skip-export` - Skip Godot export (useful for testing build scripts)
- `--skip-venv` - Skip Python venv creation (faster rebuilds)

Output: `dist/AeroBeat-Linux.tar.gz`

#### Manual build steps

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
   cp addons/aerobeat-input-mediapipe/python_mediapipe/*.py dist/AeroBeat-Linux/sidecar/mediapipe_server/
   cp build/AeroBeat.x86_64 dist/AeroBeat-Linux/
   cp build-scripts/templates/run.sh dist/AeroBeat-Linux/
   ```

### Running the bundle

#### Quick start
```bash
tar -xzf AeroBeat-Linux.tar.gz
cd AeroBeat-Linux
./run.sh
```

#### Launcher options
```bash
./run.sh --help          # Show help
./run.sh --mock          # Use mock server (no camera)
./run.sh --camera 1      # Use camera device 1
./run.sh --no-camera     # Skip camera detection
```

#### Environment variables
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
- Check export presets exist or create them via the Godot editor
- Verify export preset name matches the target platform

#### Permission denied
```bash
chmod +x run.sh AeroBeat.x86_64
```

### Distribution notes

The `AeroBeat-Linux.tar.gz` archive can be distributed directly for PC-community testing. Users only need to:
1. Extract the archive
2. Run `./run.sh`

No additional dependencies are required because Python and camera-sidecar packages are bundled.

### File sizes (approximate)

- Bundle: ~150-200 MB
  - Godot executable + resources: ~50 MB
  - Python + MediaPipe + OpenCV: ~100-150 MB

### Security considerations

- The launcher script runs with user permissions
- Camera access requires user access to the video device
- No root privileges required
- Sandboxed execution is still preferable for distribution platforms

---

## Windows bundle experiment

This repo still contains a Windows bundle script because Windows remains part of the broader PC community path. Treat it as an **experiment/runtime packaging path**, not a fully locked release promise.

### Current intent
- bundle the Godot executable
- bundle Python + MediaPipe runtime
- start the camera sidecar from `run.bat`

### Known cautions
- built from Linux, so real Windows validation still matters
- camera permission behavior must be tested on actual Windows machines
- packaging quality should not be described as equivalent to the main Linux path until validated

---

## macOS bundle experiment

This repo still contains a macOS bundle script for future desktop validation, but macOS is not the primary proof point for this repo's current PC-community slice.

### Current intent
- create a `.app` bundle
- include the camera-sidecar runtime
- wire camera permission prompts through `Info.plist`

### Known cautions
- real macOS validation is still required
- signing/notarization is future distribution work
- keep wording truthful: present implementation exists, but it is not the lead validated path

---

## Appendix: build script reference

### `build-linux-bundle.sh`

Main build script for the current Linux packaging path.

**Location:** `build-scripts/build-linux-bundle.sh`

**Key functions:**
- prerequisite checks
- Python venv creation and package installation
- Godot export execution
- bundle assembly and packaging

### `run.sh`

Launcher script template copied into the Linux bundle.

**Location:** `build-scripts/templates/run.sh`

**Key functions:**
- Python environment setup
- camera device detection
- sidecar process management
- cleanup on exit

### `build-windows-bundle.sh`

Windows packaging experiment.

**Location:** `build-scripts/build-windows-bundle.sh`

### `run.bat`

Windows launcher template.

**Location:** `build-scripts/templates/run.bat`

### `build-macos-bundle.sh`

macOS packaging experiment.

**Location:** `build-scripts/build-macos-bundle.sh`
