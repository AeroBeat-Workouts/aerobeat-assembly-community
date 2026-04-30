# Rebuilt artifact post-BadWindow fallout recovery notes

**Date:** 2026-04-30  
**Bead:** `oc-d7x`  
**Artifact:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`

## Scope

Diagnose what state is left behind after reproducing the rebuilt artifact's `xdotool windowclose` / `BadWindow` failure family, determine what clears it, and identify the smallest truthful recovery step for later QA.

## What I reproduced

Using the earlier controlled X11 close harness shape on the rebuilt artifact, I reproduced the bad family enough to inspect the aftermath:

- wrapper launcher exited `143`
- harness-recorded child bookkeeping drifted (`CHILD_EXIT_CODE 127`), but the app self-reported a later real READY pid
- the actual Godot export process survived after the wrapper exited
- the surviving process was reparented to `systemd --user` (`PPid: 1122`)
- the surviving X11 window remained present in `wmctrl`/`xdotool`, but was **not viewable**

Key observed survivor:

- process: `GodotClosePathMinimal.x86_64`
- example PID after failure: `61881`
- parent after wrapper exit: `/usr/lib/systemd/systemd --user --deserialize=72`
- X11 window state: `WM_STATE = Iconic`, `Map State = IsUnMapped`

This means the immediate fallout is **not** just shell/job drift. The failure leaves behind a real orphaned app process plus an iconified/unmapped X11 window object.

## What definitely clears part of the fallout

Sending `TERM` to the orphaned export process clears the surviving-process residue immediately.

Example successful cleanup:

- `kill 61881`
- result: no remaining `GodotClosePathMinimal` process, no remaining matching `wmctrl` entry

This is the smallest reliable cleanup for the **orphaned-process** part of the fallout.

## What did *not* fully restore a good default X11 normal-open state

After clearing the orphan and relaunching the default export path, follow-up shell-launched opens still came back in a degraded X11/WM state:

- process launched and logged `READY`
- `wmctrl` and non-`--onlyvisible` `xdotool search` could still find a window
- but `xdotool search --onlyvisible` found nothing
- `xprop` showed `WM_STATE: Iconic`
- `xwininfo` showed `Map State: IsUnMapped`

Tried and **did not** clear that iconified/unmapped follow-up state:

- killing only the wrapper / relaunching wrapper
- launching the direct binary instead of the shell wrapper
- launching from a PTY-backed shell instead of the non-PTY harness
- one clean forced-Wayland run followed by a default relaunch
- `wmctrl -R/-a` and `xdotool windowmap/windowactivate/windowraise`
- raw `python-xlib` map / `_NET_ACTIVE_WINDOW` / `WM_CHANGE_STATE` attempts

## Diagnosis

Most truthful split:

1. **Primary immediate fallout:** a surviving orphaned Godot child process remains alive after `windowclose` / forced-kill handling. This is the clearest concrete thing that must be cleaned.
2. **Broader broken follow-up state:** later default X11 launches are stuck as `Iconic` / `IsUnMapped` windows even after the orphan is killed. That points to persistent **X11/window-manager state** rather than just wrapper-shell state.
3. **What it is not:** this does not look like a plain stale shell job or wrapper-only problem. The wrapper is gone; the real export binary survives/relaunches and the remaining failure surface is in window visibility/state.

## Smallest truthful recovery procedure

### Minimal internal cleanup I could safely apply

```bash
ART=/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048
pkill -TERM -f "$ART/GodotClosePathMinimal.x86_64"
sleep 2
pkill -9 -f "$ART/GodotClosePathMinimal.x86_64" || true
```

That returns the artifact to a **clean at-rest** state with no surviving export process.

### Full recovery to a trustworthy normal-open default-X11 baseline

I did **not** find a smaller in-session X11/window-manager reset that reliably returns later default launches to a visible normal-open state. Based on what I observed, the next truthful recovery escalation is:

- clear any surviving `GodotClosePathMinimal.x86_64` process as above, then
- perform a fresh desktop/X11 session reset before continuing default-X11 QA (for example: new desktop login / equivalent session reset)

I did **not** apply a desktop-session restart here because it is more invasive than the repo-local/process-local cleanup and could disrupt Derrick's active session.

## Final state I left behind

I cleaned up all live `GodotClosePathMinimal` processes before stopping.

So the artifact is currently:

- **clean at rest:** yes
- **proven restored to good visible default-X11 normal-open state in this same session:** no

## Useful artifacts

- reproduction harness copy: `.qa-logs/oc-d7x/run_rebuilt_badwindow_case.sh`
- bad-fallout case: `.qa-logs/oc-d7x/rebuilt-badwindow-windowclose-*`
- stale-relaunch probe: `.qa-logs/oc-d7x/relaunch-with-stale-abs-*`
- open-only / state probes: `.qa-logs/oc-d7x/open-only-after-recovery-*`, `.qa-logs/oc-d7x/state-probe.log`
- recovery cleanup log: `.qa-logs/oc-d7x/recovery-kill-orphan.txt`
