# Review-only upstream issue draft

**Title:** Linux exported app hangs on close with repeated `BadWindow` on the X11/Xwayland path, but closes cleanly on native Wayland

> Internal draft only. Do not file upstream from this document as-is without Derrick review and MRP ZIP attachment prep.

## Tested versions

- **Reproducible:** `4.6.2.stable.official.71f334935` on Linux exported app default runtime path from a Wayland desktop session, where the exported binary still ends up on the X11/Xwayland path.
- **Reproducible:** `4.7.beta1.official.1c8cc9e7e` on the same exported default runtime path (`run.sh` with no forced display-driver), again hitting the X11/Xwayland path.
- **Not reproducible in this comparison:** `4.7.beta1.official.1c8cc9e7e` when the same exported minimal repro is run with `--display-driver wayland`, which exercises the native Wayland path instead.
- **Important scope note:** the non-reproducing case above looks like a backend-path split, not proof that the underlying engine issue is fully fixed in `4.7.beta1` for Linux exports in general.

## System information

- OS: Zorin OS 18 Pro (Linux)
- Desktop session during repro: `XDG_SESSION_TYPE=wayland`
- Desktop environment: `zorin:GNOME`
- CPU: AMD Ryzen Z1 Extreme
- GPU: AMD Ryzen Z1 Extreme / RADV PHOENIX
- Renderer shown by Godot on the clean Wayland-native comparison run: `Vulkan 1.4.318 - Forward+ - Using Device #0: AMD - AMD Ryzen Z1 Extreme (RADV PHOENIX)`
- Display/backend context that matters for this report:
  - On the failing exported default path, the app is launched from a Wayland desktop session but still presents an X11-manageable window and hits `platform/linuxbsd/x11/display_server_x11.cpp` error spam, which appears to mean the exported runtime is on the X11/Xwayland path.
  - On the clean comparison run, the same exported app is launched with `--display-driver wayland`, shows native Wayland protocol traffic, and does not expose an X11-manageable window.

## Issue description

### In Plain English

- A minimal exported Linux Godot app hangs when I close the window on the default exported path I get on my machine.
- The failing path looks specifically tied to X11/Xwayland, not to Linux in general.
- The same minimal exported project closes normally when I force native Wayland with `--display-driver wayland`.
- I have a local launcher workaround that prefers Wayland on Wayland sessions, but that is only a packaging-side mitigation and not an engine fix.

I reduced this to a standalone minimal reproduction project outside my main game project.

Expected behavior: an exported Linux app should process the window-manager close request and exit normally.

Actual behavior on the failing path: after closing the window, the exported app hangs and repeatedly prints `BadWindow` errors from `platform/linuxbsd/x11/display_server_x11.cpp` until I force-kill it.

This currently looks narrower than a generic “Linux close bug”:

- The bug reproduces on `4.6.2.stable.official.71f334935` and on `4.7.beta1.official.1c8cc9e7e` when I use the exported app's default runtime path.
- On my machine, those failing runs happen from a Wayland desktop session, but the exported app still appears to be using the X11/Xwayland path.
- The same exported minimal repro closes cleanly on `4.7.beta1.official.1c8cc9e7e` when launched with `--display-driver wayland`.

Concise evidence from my local runs:

- `4.6.2` default exported path: window close required forced kill, exit code `143`, repeated `BadWindow` from `display_server_x11.cpp:1310`.
- `4.7.beta1` default exported path: same hang behavior, forced kill, exit code `143`, repeated `BadWindow` from `display_server_x11.cpp:1335`.
- `4.7.beta1 --display-driver wayland`: `WM_CLOSE_REQUEST` logged once, exit code `0`, no `BadWindow`.

Representative failing excerpt:

```text
ERROR: Unhandled XServer error: BadWindow (invalid Window parameter)
   Major opcode of failed request: 20
   Current serial number in output stream: 472
   at: default_window_error_handler (platform/linuxbsd/x11/display_server_x11.cpp:1335)
```

Representative clean comparison excerpt:

```text
Godot Engine v4.7.beta1.official.1c8cc9e7e - https://godotengine.org
Vulkan 1.4.318 - Forward+ - Using Device #0: AMD - AMD Ryzen Z1 Extreme (RADV PHOENIX)
[MinimalCloseRepro] READY pid=4101033 title=GodotClosePathMinimal
[MinimalCloseRepro] WM_CLOSE_REQUEST uptime_ms=30429 frames=1816
```

## Steps to reproduce

1. Open the attached/exported minimal reproduction project on Linux.
2. Export it for Linux/X11 using the normal desktop export flow.
3. Start the exported app on a Wayland desktop session using the default launcher/runtime path (no forced `--display-driver wayland`).
4. Close the window using the window manager close button.
5. Observe that the process does not exit cleanly and instead hangs with repeated `BadWindow` errors until it is force-killed.
6. For comparison, run the same exported app again with `--display-driver wayland`.
7. Close the window the same way.
8. Observe that this Wayland-native comparison run closes cleanly, logs one `WM_CLOSE_REQUEST`, and exits normally.

## Minimal reproduction project (MRP)

- Source project used for this report: `repros/linux-close-minimal/` in this repo.
- It is a standalone Godot project with one scene and simple logging for startup and `NOTIFICATION_WM_CLOSE_REQUEST`.
- For upstream filing, attach a ZIP of that project **without** the `.godot` folder.
- For this internal review draft, the MRP is not attached yet; it still needs the final submission ZIP prepared from `repros/linux-close-minimal/`.
