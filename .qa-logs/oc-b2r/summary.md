# oc-b2r — manual export close-path QA for Derrick's stock Godot export

## Result
- **Artifact tested:** `/home/derrick/Documents/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-reproducible`
- **Binary identity:** stock Godot **4.7-beta1 debug export** (`linux_debug.x86_64`), matching `~/.local/share/godot/export_templates/4.7.beta1/templates/linux_debug.x86_64`
- **Default stock export run (`./GodotClosePathMinimal.sh`):** close hang **reproduced** on the X11/Xwayland path; forced kill required; launcher exited **143**
- **Explicit X11 run (`./GodotClosePathMinimal.x86_64 --display-driver x11`):** close hang **reproduced**; forced kill required; exit **143**; massive `BadWindow` spam
- **Explicit Wayland run (`./GodotClosePathMinimal.x86_64 --display-driver wayland`):** app **closed cleanly**; no forced kill; exit **0**; `WM_CLOSE_REQUEST` logged once; no `BadWindow`

## Backend/path evidence
### Default stock export path
- Launched from the stock editor-generated wrapper `GodotClosePathMinimal.sh`.
- Session env stayed `XDG_SESSION_TYPE=wayland`, `DISPLAY=:0`, `WAYLAND_DISPLAY=wayland-0`.
- The window was X11-discoverable (`WINDOW_ID 25165826` in `manual-export-default-wrapper-rerun-meta.txt`), which is the same shape as the earlier X11/Xwayland failure path.
- The captured stdout/stderr log contains **233,848** `BadWindow` entries from `platform/linuxbsd/x11/display_server_x11.cpp:1335`.
- The app did **not** process a normal close request and required forced kill (`FORCED_KILL_AT ...`; launcher exit `143`).
- Important wrapper nuance: the stock `.sh` launcher does **not** `exec` the binary, so wrapper-level PID tracking is messy; that is why the explicit X11 direct-binary run below is the cleanest exit-code/backend control case.

### Explicit X11 path
- Command line: `./GodotClosePathMinimal.x86_64 --display-driver x11`
- `WINDOW_ID 27262978` proves the app was on an X11-discoverable path.
- The log contains **91,574** `BadWindow` entries from `platform/linuxbsd/x11/display_server_x11.cpp:1335`.
- No `WM_CLOSE_REQUEST` was observed.
- Forced kill was needed; launcher exit code was **143**.

### Explicit native Wayland path
- Command line: `./GodotClosePathMinimal.x86_64 --display-driver wayland`
- `WINDOW_ID none` plus empty `wmctrl` / `xdotool` snapshots show no X11-discoverable app window.
- `WAYLAND_DEBUG=1` captured native Wayland protocol traffic, including `wl_display.get_registry`, `wl_registry`, and `xdg_wm_base` activity.
- App log shows `[MinimalCloseRepro] WM_CLOSE_REQUEST ...` once.
- No `BadWindow` appears in either app log or Wayland debug log.
- No forced kill was needed; launcher exit code was **0**.

## Verdict
Derrick's manual export does **not** contradict the earlier repro. It behaves the same way once tested under controlled logging:
- **default / X11-like path:** bad close behavior persists
- **forced native Wayland path:** clean close persists

The discrepancy came from **execution context and observability**, not from the bug disappearing. The stock manual export can look fine during casual use because the earlier manual observation did not preserve backend/path evidence or strict exit-state logging. Under a controlled harness, the same manual export still reproduces the earlier X11/Xwayland close-path failure family.

## Most relevant artifacts
- `manual-export-default-wrapper-rerun-meta.txt`
- `manual-export-default-wrapper-rerun.log`
- `manual-export-force-x11-meta.txt`
- `manual-export-force-x11.log`
- `manual-export-force-wayland-meta.txt`
- `manual-export-force-wayland.log`
- `manual-export-force-wayland-wayland-debug.log`
