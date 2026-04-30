# Rebuilt artifact fallout recovery/session reset notes

**Date:** 2026-04-30  
**Bead:** `oc-21x`  
**Artifact:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`

## Goal

Try the least-disruptive truthful reset that restores a trustworthy default-X11 normal-open baseline after the dirty `BadWindow` fallout, without requiring Derrick to do an in-person terminal reset.

## Starting state

Before this task, the rebuilt artifact was clean at rest after orphan cleanup, but a fresh default-X11 launch still came back as an X11 window object in a bad state:

- `xdotool search --onlyvisible --name GodotClosePathMinimal` returned nothing
- `xdotool search --name GodotClosePathMinimal` still found a window
- `xwininfo` reported `Map State: IsUnMapped`
- `xprop` reported `WM_STATE = Iconic`

I re-confirmed that bad baseline at the start of this task with:

- `.qa-logs/oc-21x/fresh-default-x11-open-probe.log`
- `.qa-logs/oc-21x/fresh-default-x11-open-probe-meta.txt`
- `.qa-logs/oc-21x/fresh-default-x11-open-probe-xwininfo.txt`
- `.qa-logs/oc-21x/fresh-default-x11-open-probe-xprop.txt`

## Least-disruptive reset that worked

### Reset applied

I restarted the per-session `Xwayland` process only.

Procedure used:

```bash
OLD_PID=$(pgrep -xo Xwayland)
kill -TERM "$OLD_PID"
# GNOME Wayland leaves Xwayland on-demand; it respawned on the next X11 launch.
```

### Desktop/session impact

- **Impact scope:** X11/Xwayland clients in the current GNOME Wayland session
- **What this does not do:** does not log out GNOME, restart the full desktop session, or require local terminal intervention
- **What it can disrupt:** any currently running X11 apps may lose their X server connection and need relaunching
- **Observed here:** GNOME Shell stayed up; `gnome-remote-desktop` stayed active; a new `Xwayland` instance came back automatically when the artifact was launched again

## Verification after reset

The very first launch immediately after the restart was noisy/inconclusive because I launched while Xwayland was respawning, but the follow-up clean probe showed the recovered baseline clearly.

Final clean probe artifacts:

- `.qa-logs/oc-21x/final-baseline-probe.log`
- `.qa-logs/oc-21x/final-baseline-probe-meta.txt`
- `.qa-logs/oc-21x/final-baseline-probe-xwininfo.txt`
- `.qa-logs/oc-21x/final-baseline-probe-xprop.txt`
- `.qa-logs/oc-21x/final-baseline-probe.png`

Recovered evidence from that final probe:

- Godot reached `READY pid=70102`
- `xdotool search --onlyvisible --name GodotClosePathMinimal` returned visible IDs again
- primary visible window `0x400039` / `4194361`
- `xwininfo` reported `Map State: IsViewable`
- after process cleanup, `wmctrl` and visible `xdotool` results were empty again

That is enough to say the rebuilt artifact is back to a **truthful clean normal-open default-X11 baseline** for the next QA step.

## Verdict

The smallest reset I found that truthfully restored the default-X11 normal-open baseline was:

1. clean any leftover `GodotClosePathMinimal.x86_64` processes
2. restart **`Xwayland` only** inside the live GNOME Wayland session
3. relaunch the artifact normally

I did **not** need a full desktop logout/login reset.

## Final state left behind

- no live `GodotClosePathMinimal.x86_64` process left running
- no lingering visible `GodotClosePathMinimal` windows after cleanup
- Xwayland is running again under a fresh PID
- baseline appears ready for the planned QA recovery verification step
