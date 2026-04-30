# QA notes — rebuilt artifact desktop close test

**Date:** 2026-04-30  
**Bead:** `oc-4a4`  
**Artifact folder:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`

## Scope

Goal: test the rebuilt exported artifact with a human-equivalent GUI close interaction while preserving truthful stdout/stderr and process evidence, then compare that behavior against the earlier terminal / forced-backend runs.

## What I actually tested

### Launch path
- Launched the rebuilt stock wrapper:
  - `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/GodotClosePathMinimal.sh`
- Preserved stdout/stderr to repo-local logs.
- Confirmed the app presented as an X11-discoverable window on a Wayland session:
  - session env: `XDG_SESSION_TYPE=wayland`, `DISPLAY=:0`, `WAYLAND_DISPLAY=wayland-0`
  - live app window: `GodotClosePathMinimal (DEBUG)` / `WINDOW_ID 25165826`

### Desktop-control path used
- I **could not** use the skill's canonical blind RDP click helper as the primary click transport because this shell did not have `OC_GRD_PASSWORD`, and the helper requires either `--password` or `OC_GRD_PASSWORD`.
- I **did** follow the desktop-control screenshot-first workflow honestly:
  1. captured a fresh host-local screenshot with `gnome-screenshot --include-pointer`
  2. derived the close-target candidate from the current screenshot using the selector
  3. moved the pointer to that selector-derived target
  4. captured a pointer screenshot at the candidate point
  5. sent one bounded click
  6. captured post-click screenshots and process/window state
- Because the rebuilt app was clearly X11-discoverable, I used the skill's X11 control path (`xdotool`) for the live pointer move/click instead of inventing a fake fallback backend.

### Selector narrowing used for the titlebar close target
From the current live screenshot, I narrowed the top-right titlebar area to a dense-target-ready cell:
- step 1: `3x3 -> A3`
- step 2: `3x3 -> B1`
- final step: `4x4 -> D3`
- final selected cell:
  - bounds: `left=1386 top=210 right=1439 bottom=240`
  - size: `53x30`
  - target point: `x=1412 y=225`
  - selector guardrail state: `dense_target_ready`

This was intentionally derived from the current screenshot rather than from remembered coordinates.

## Main run evidence

Primary durable harness:
- script: `.qa-logs/oc-4a4/run_rebuilt_gui_close_xdotool.sh`
- case: `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-*`

Important files:
- meta: `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-meta.txt`
- app log: `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool.log`
- pre-click screenshot: `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-before.png`
- pointer-on-target screenshot: `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-pointer-on-close.png`
- post-click screenshots:
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-after-click-3s.png`
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-after-click-13s.png`
- selector JSON:
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-selector-step1.json`
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-selector-step2.json`
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-selector-final.json`
- window geometry / frame extents:
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-window-geometry.txt`
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-xwininfo.txt`
  - `.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-xprop-frame.txt`

### Observed result
- Pointer landed at the intended close-target point before click:
  - `X=1412`
  - `Y=225`
  - `WINDOW=25165826`
- The click produced a real app-side close event:
  - log contains exactly one `WM_CLOSE_REQUEST`
- No `BadWindow` spam appeared:
  - `BadWindow` count: `0`
- No forced kill was needed:
  - `FORCED_KILL_USED 0`
- Wrapper exit was clean:
  - `LAUNCHER_EXIT_CODE 0`
- By the 3-second and 13-second post-click checks, there was no remaining visible `GodotClosePathMinimal` window and no surviving tracked wrapper/app processes in the recorded `ps` snapshots.

### Minor harness caveat
- `CHILD_EXIT_CODE 127` in the xdotool harness metadata is **not** evidence of an app failure.
- It came from shell child bookkeeping drift: the wrapper shell spawns the real export process, and the app also self-reports a different READY PID in its own log. The meaningful truth signals are:
  - wrapper exit `0`
  - no forced kill
  - `WM_CLOSE_REQUEST` logged once
  - no `BadWindow`
  - no surviving visible window/process in the post-click checks

## Earlier ad hoc confirmation run

Before packaging the durable harness, I also did an ad hoc screenshot-first move/click pass on the same rebuilt artifact and saw the same result:
- log: `.qa-logs/oc-4a4/rebuilt-default-wrapper.log`
- metadata: `.qa-logs/oc-4a4/rebuilt-default-wrapper-launch-meta.txt`
- screenshots:
  - `.qa-logs/oc-4a4/rebuilt-before-close.png`
  - `.qa-logs/oc-4a4/rebuilt-pointer-on-close.png`
  - `.qa-logs/oc-4a4/rebuilt-after-click-3s.png`
  - `.qa-logs/oc-4a4/rebuilt-after-click-13s.png`

That run also logged one `WM_CLOSE_REQUEST`, showed zero `BadWindow`, and the app disappeared by the 3-second post-click check.

## Comparison against earlier terminal / forced-backend findings

### Compared against prior controlled default/X11-style runs
Earlier controlled QA on Derrick's stock manual export and earlier repro paths showed:
- default or explicit X11-discoverable runs could reproduce the bad family:
  - massive `BadWindow`
  - forced kill required
  - launcher exit `143`
- forced native Wayland closed cleanly:
  - `WM_CLOSE_REQUEST`
  - no `BadWindow`
  - exit `0`

### What is different here
This rebuilt QA artifact, when closed via a real titlebar close click, **did not** reproduce the earlier bad close behavior.

Instead, on the default stock wrapper path it behaved like the earlier clean path:
- one `WM_CLOSE_REQUEST`
- zero `BadWindow`
- clean wrapper exit `0`
- no forced kill

That means this rebuilt artifact's result under a human-equivalent close interaction is materially different from the earlier `windowclose`/forced-X11 failure evidence.

## Verdict

### Straight answer
- **Did the GUI close reproduce the bad behavior?** No, not in this test.
- **Did the process actually exit?** Yes, to the extent this QA can truthfully show: wrapper exit `0`, no forced kill, no surviving visible window/process in post-click checks.
- **Does this differ from earlier terminal / forced-backend runs?** Yes. This rebuilt artifact closed cleanly under the screenshot-driven titlebar click test, unlike the earlier default/X11-discoverable failure family.

### What Derrick should expect
Derrick should **not** expect this rebuilt QA artifact to obviously reproduce the issue under normal human titlebar-close behavior, at least not from the test path I was able to execute here. The rebuilt artifact looked clean under two screenshot-driven click-close passes.

## Honesty / caveats
- The canonical GRD blind-click helper was **not** usable in this shell because the required GRD password was unavailable (`OC_GRD_PASSWORD` unset).
- So this is **not** a proof that the canonical GRD blind helper itself would have produced the same outcome.
- It **is** still a truthful desktop-control test of a human-equivalent GUI close interaction using the skill's screenshot-first flow and the X11 branch that matched the live app surface actually present on screen.
- Because the result differs from earlier forced-X11 / `windowclose` findings, the close-path mechanism itself now looks like a serious variable, not just backend selection.
