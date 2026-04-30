# Manual export vs earlier known-bad Linux close-path repro export

**Date:** 2026-04-30  
**Bead:** `oc-mcg`

## Compared artifacts

### A. Derrick manual export
Path:
- `/home/derrick/Documents/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-reproducible/`

Observed layout:
- `GodotClosePathMinimal.x86_64`
- `GodotClosePathMinimal.pck`
- `GodotClosePathMinimal.sh`

Launcher contents:
```sh
#!/bin/sh
printf '\033c\033]0;%s\a' GodotClosePathMinimal
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GodotClosePathMinimal.x86_64" "$@"
```

Key evidence:
- Binary size is `73560408` bytes.
- That exactly matches `~/.local/share/godot/export_templates/4.7.beta1/templates/linux_debug.x86_64`.
- `strings` on the binary shows `Godot Engine v4.7.beta1.official`.

Interpretation:
- This is a **plain Godot editor export** with the stock generated `.sh` wrapper.
- It is a **4.7-beta1 debug export**, not a custom packaged bundle.

### B. Earlier known-bad repro export path
Source/project:
- `repros/linux-close-minimal/`

Known-bad executed path from QA artifacts:
- `repros/linux-close-minimal/dist/GodotClosePathMinimal-Linux/run.sh`
- See `.qa-logs/oc-6q7/proof-minimal-wm-close-meta.txt`
- See `.qa-logs/oc-my4/proof-minimal-wm-close-beta1-meta.txt`

Original bundle generator at commit `cffaa52`:
- `repros/linux-close-minimal/build-linux-bundle.sh`
- Export command: `godot --headless --path . --export-release "Linux Minimal Close Repro" ...`

Original generated launcher:
```sh
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
exec ./GodotClosePathMinimal.x86_64 "$@"
```

Observed known-bad behavior:
- `oc-6q7` on the earlier path: X11-discoverable window, `BadWindow` spam, forced kill, exit `143`.
- `oc-my4` on 4.7-beta1 default path: still X11-discoverable, still `BadWindow`, forced kill, exit `143`.

## What is actually different

### 1. File layout / packaging
Manual export:
- plain 3-file Godot export in a build folder
- stock Godot-generated `.sh`
- no README, no extra wrapper include, no tarball/bundle structure

Earlier repro export:
- repo-built `dist/GodotClosePathMinimal-Linux/` bundle
- custom `run.sh`
- README + tarball packaging
- later revisions of the bundle also gained `godot-linux-launch.inc.sh` and Wayland-selection logic

Important nuance:
- The **earliest known-bad** bundle wrapper was still extremely thin. It did **not** force X11, did **not** force Wayland, and did **not** add logging tricks; it just `exec`'d the binary.
- So the original failure does **not** appear to depend on a special custom launcher.

### 2. Export mode / template assumptions
Manual export:
- **4.7-beta1 debug template** (`linux_debug.x86_64`)

Earlier known-bad path:
- built via `--export-release`
- first known-bad repro path was on stable 4.6.2 release export (`oc-6q7`)
- later comparable beta repro (`oc-my4`) was still a **4.7-beta1 release export**, and it still failed on the default path

This is the biggest apples-to-oranges difference I found.

### 3. Backend selection behavior
Manual export wrapper:
- no explicit `--display-driver`
- no built-in Wayland/X11 preference logic

Earlier known-bad bundle wrapper at `cffaa52`:
- also no explicit `--display-driver`
- also no backend preference logic

Later workaround bundle wrapper at `436104c`:
- **does** add `--display-driver wayland` automatically on Wayland sessions unless opted out

Implication:
- If Derrick manually exported and ran the stock 3-file export, that artifact itself provides **no evidence** of a forced-Wayland path.
- Structurally, it is closer to the **old bad default-path bundle** than to the newer workaround bundle.

### 4. Stdout / visibility differences
Manual export:
- if launched outside a terminal, stdout/stderr may have been easy to miss entirely
- even when launched from a terminal, the stock `.sh` is not doing anything special besides execing the binary

Earlier known-bad QA path:
- always launched under a capture harness with preserved stdout/stderr and metadata
- produced explicit evidence files for window IDs, exit codes, kill timing, and `BadWindow` spam

Implication:
- “It looked like it closed cleanly” is weaker evidence than the earlier harnessed runs, because the harness was explicitly checking for hidden hang/error conditions.

### 5. Close method / automation differences
Earlier known-bad default-path runs (`oc-6q7`, `oc-my4`):
- used X11-oriented automation (`xdotool windowclose`, then `wmctrl -c` retry)
- window was X11-discoverable (`WINDOW_ID` present)
- app then hung and needed forced kill

Known-clean forced-Wayland run (`oc-7wx`):
- used compositor-visible `uinput` `Alt+F4`
- no X11 window was discoverable
- app closed cleanly with exit `0`

Implication:
- The older failing evidence definitely involved a different close mechanism than Derrick’s likely manual titlebar close.
- But the stronger split in the repo evidence is still **backend path**, not simply “automation vs manual click”: once the app is truly on native Wayland, the failure disappears; on default/X11 paths it remains reproducible.

## Best explanation of the discrepancy

Most likely causes, in order:

1. **The manual export was not an apples-to-apples build.**  
   It is a **4.7-beta1 debug export**, while the earlier known-bad repro path was validated from **release exports**.

2. **The manual export did not include any explicit backend-selection evidence.**  
   Its stock `.sh` wrapper does not force Wayland or X11. So the artifact itself does not explain a clean close by packaging alone.

3. **The earlier failing path was observed under a much stricter harness.**  
   The repo QA runs captured stdout/stderr, window IDs, exit code `143`, and forced-kill timing. A casual manual run can easily miss whether the process stayed alive briefly, spammed stderr somewhere unseen, or differed only by invocation context.

4. **Backend/path selection remains the strongest repo-supported root cause.**  
   The project already proved: default/X11-style exported runs can hang with `BadWindow`, while forced native Wayland closes cleanly. The manual export does not contain any launcher logic proving it used native Wayland, so the clean manual observation is more likely a test-context discrepancy than evidence that the original X11/Xwayland close-path bug vanished.

## Bottom line

- The earlier known-bad export path did **not** depend on a custom launcher forcing X11 or doing anything exotic; its original `run.sh` was basically just `exec ./GodotClosePathMinimal.x86_64 "$@"`.
- The manual export is a **plain stock Godot export**, but importantly it appears to be a **4.7-beta1 debug export**, which is already a meaningful build-mode mismatch.
- The most likely explanation is **not** “the bundle wrapper caused the bug.”
- The most likely explanation is a combination of:
  - **debug vs release mismatch**,
  - **uncontrolled runtime/backend evidence in the manual run**,
  - **less strict observation/log capture**, and
  - the already-established fact that **native Wayland vs X11/Xwayland** changes the close result materially.
