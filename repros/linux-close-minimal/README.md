# Linux Minimal Close Repro

This folder contains a brand-new standalone Godot project used to isolate the exported Linux window-close path.

## Why it exists

The repo already showed the close hang with a direct trivial scene inside the main AeroBeat project. This repro strips the test down further so QA can compare behavior without any AeroBeat bootstrap path, addons, or feature-scene switching involved.

## Contents

- `project.godot` - standalone project entry
- `scenes/main.tscn` - only scene
- `scripts/main.gd` - ready + WM_CLOSE logging
- `build-linux-bundle.sh` - exports and assembles a QA bundle

## Build

```bash
cd repros/linux-close-minimal
./build-linux-bundle.sh
```

## QA flow

```bash
cd repros/linux-close-minimal/dist/GodotClosePathMinimal-Linux
./run.sh
```

Expected terminal output on launch:

```text
[MinimalCloseRepro] READY pid=... title=GodotClosePathMinimal
```

Expected terminal output when the close button is pressed:

```text
[MinimalCloseRepro] WM_CLOSE_REQUEST uptime_ms=... frames=...
```

If the process still hangs after that log line, the repro supports the upstream/runtime/window-manager hypothesis while staying completely outside the AeroBeat app/bootstrap flow.
