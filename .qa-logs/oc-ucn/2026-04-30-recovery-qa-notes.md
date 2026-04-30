# Recovery QA notes — rebuilt artifact normal-open baseline

**Date:** 2026-04-30  
**Bead:** `oc-ucn`  
**Artifact:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`

## Goal

Verify that the rebuilt artifact is back in a trustworthy clean normal-open state after the Xwayland reset, using the truthful desktop-control workflow, and confirm it can be closed cleanly through the normal titlebar close path.

## References used

- Plan: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix.md`
- Session reset notes: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-session-reset-notes.md`
- Desktop-control skill: `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md`
- Desktop-control prereqs: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/desktop-control-prereqs/2026-04-30-prereq-notes.md`

## Evidence folder

- Case directory: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/`

Key artifacts inside that folder:

- `01-open.png` — fresh host-local screenshot with the rebuilt artifact visibly open
- `open-window-state.txt` — X11-visible window evidence (`IsViewable`, visible IDs)
- `selector-close-step*.json` — screenshot-region-selector narrowing for the titlebar close target
- `atspi-close-action.json` — successful semantic click on the titlebar `Close` button
- `final-close-verification.txt` — post-close process/window/log verification
- `03-after-atspi-close.png` — post-close screenshot showing the artifact gone

## What I verified

### 1) Normal open/render state is restored

I launched `./GodotClosePathMinimal.x86_64` from the rebuilt artifact folder after the Xwayland reset baseline from Task 2.

Observed open-state evidence:

- App log reached:
  - `[MinimalCloseRepro] READY pid=79454 title=GodotClosePathMinimal`
- `xdotool search --onlyvisible --name 'GodotClosePathMinimal'` returned visible windows
- `xwininfo` on the primary visible frame reported:
  - `Map State: IsViewable`
- Fresh screenshot `01-open.png` shows the artifact rendered normally with its expected single-screen content:
  - `Minimal Linux Close Repro`
  - `Window active`
  - expected behavior instructions visible in the window body

This is enough to say the rebuilt artifact is back in a truthful visible normal-open state after the recovery/reset.

### 2) Screenshot-first desktop-control workflow was used

I followed the skill’s screenshot-first observability loop for verification:

1. Took a fresh host-local screenshot with `gnome-screenshot --include-pointer`.
2. Used that screenshot as ground truth for target confirmation.
3. Narrowed the titlebar close target via `screenshot_region_selector.py`:
   - root `A3`
   - nested `C2`
   - nested `C1`
4. Preserved selector JSON artifacts in the case folder.
5. Took a fresh post-close screenshot after actuation.

### 3) Interactable / close-path verification

Important honesty note: the canonical GRD blind-click helper was present and guardrails passed in dry-run mode, but the live GRD click path could not authenticate in this shell because `OC_GRD_PASSWORD` was not available at runtime:

- `password is required via --password or OC_GRD_PASSWORD`

I therefore used the cleaner semantic control plane that the desktop-control skill explicitly prefers when an accessible action already exists.

AT-SPI inspection on the live `mutter-x11-frames` titlebar exposed a real close control:

- app: `mutter-x11-frames`
- path: `/0/1/0/0/0/2/0/2`
- role: `push button`
- name: `Close`
- action: `click`

I invoked that semantic `click` action and verified a clean close:

- `atspi-close-action.json` recorded `ok: true` / `invoked_action: click`
- the target became defunct immediately after invocation
- app log recorded:
  - `[MinimalCloseRepro] WM_CLOSE_REQUEST uptime_ms=239523 frames=14309`
- post-close checks showed:
  - no live `GodotClosePathMinimal.x86_64` process
  - no visible `GodotClosePathMinimal` windows via `xdotool`
  - no matching `wmctrl` entries
- `03-after-atspi-close.png` shows the artifact window gone from the desktop

This is a truthful confirmation that the rebuilt artifact can be closed cleanly through the normal titlebar close control after recovery.

## Verdict

**PASS** — the rebuilt artifact is back in a trustworthy clean baseline for the focused close-method matrix.

What is now confirmed:

- it opens visibly and renders normally again after the Xwayland recovery/reset
- it is in a usable/interactable desktop state
- the normal titlebar close route works cleanly and logs `WM_CLOSE_REQUEST`
- the app exits immediately after the normal close request, with no leftover visible window/process residue

## Caveats

- I attempted a screenshot-derived X11 coordinate click first as a bounded fallback, but it did not actuate the close button. I did not count that as success.
- I did **not** claim a successful live GRD blind click because authentication was unavailable in this shell.
- The successful close proof here is the AT-SPI semantic action on the actual titlebar `Close` button, plus post-close screenshot/process/log verification.
