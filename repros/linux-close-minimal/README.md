# Godot Linux Close-Path Minimal Reproduction Project

This folder contains a minimal standalone Godot project for reproducing a Linux exported-app close-path issue.

## Purpose

Use this project to compare exported Linux close behavior with a stripped-down project:

- one scene
- one script
- stdout logging for startup and window-close handling
- no project-specific game code, addons, or extra content

## Project files

- `project.godot` - project entry point
- `export_presets.cfg` - Linux export preset used during testing
- `scenes/main.tscn` - only scene
- `scripts/main.gd` - startup and `WM_CLOSE_REQUEST` logging

## Open the project

Open the folder in Godot and run or export the project normally.

## Expected output

On launch:

```text
[MinimalCloseRepro] READY pid=... title=GodotClosePathMinimal
```

When the window close button is pressed:

```text
[MinimalCloseRepro] WM_CLOSE_REQUEST uptime_ms=... frames=...
```

## Expected behavior

After the `WM_CLOSE_REQUEST` log line is printed, the process should exit immediately.

If the process remains alive after that point, the reproduction has succeeded.
