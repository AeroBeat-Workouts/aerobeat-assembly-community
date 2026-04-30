# Focused close-method matrix — recovered rebuilt artifact

**Date:** 2026-04-30  
**Bead:** `oc-a1e`  
**Artifact:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`

## Goal

Run the narrowed close-method matrix on the recovered rebuilt artifact from a truthful clean baseline and capture whether the split is between ordinary window-manager close routes and the specific `xdotool windowclose` path.

## References used

- Plan: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix.md`
- Recovery QA baseline: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/2026-04-30-recovery-qa-notes.md`
- Session reset notes: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-session-reset-notes.md`
- Manual export / close-path context: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-diff.md`
- Desktop-control skill: `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md`

## Evidence folder

- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-a1e/focused-close-matrix-20260430-142039/`

Key files:

- `wmctrl-result.txt`
- `wmctrl-open.log`
- `wmctrl-next-launch-summary.txt`
- `xdotool-windowclose-result.txt`
- `xdotool-windowclose-open.log`
- `xdotool-windowclose-next-launch-summary.txt`
- paired screenshots / xwininfo / xprop files for both runs

## Baseline / ordering

I preserved the recovered clean baseline by:

1. reusing the already-verified normal titlebar-close result from `oc-ucn` instead of re-dirtying the session unnecessarily
2. running `wmctrl -c` first as the likely-clean X11 window-manager route
3. running `xdotool windowclose` last as the known dirty route

All fresh runs here used the recovered rebuilt artifact directly from `REF-05` and started from a no-leftover-process state.

## Matrix result

| Close method | Rendered normally before close? | `WM_CLOSE_REQUEST` logged? | `BadWindow`? | Forced kill needed? | Process survived after close? | Next launch degraded/blanked? |
| --- | --- | --- | --- | --- | --- | --- |
| Normal human-equivalent titlebar close | Yes | Yes | No | No | No | No |
| `wmctrl -c` | Yes | Yes | No | No | No | No |
| `xdotool windowclose` | Yes | No | Yes | Yes | No (after forced cleanup) | No in this isolated recovered rerun |

## Per-method notes

### 1) Normal titlebar close — referenced prior clean baseline

I did **not** duplicate this run because it was already freshly verified during recovery QA and the plan explicitly allowed reference instead of duplication.

Referenced evidence from `oc-ucn`:

- window rendered normally and was visibly open
- titlebar `Close` control was actuated semantically through AT-SPI on the live titlebar frame
- app logged:
  - `[MinimalCloseRepro] WM_CLOSE_REQUEST ...`
- no `BadWindow`
- no leftover process/window
- post-close screenshot confirmed disappearance
- recovery notes reported no degraded follow-up launch

Reference path:

- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/2026-04-30-recovery-qa-notes.md`

### 2) `wmctrl -c` — clean

Fresh run evidence:

- open-state screenshot/log/xwininfo artifacts under `wmctrl-open*`
- app rendered normally before close
- `wmctrl-result.txt` recorded:
  - `RENDERED_BEFORE_CLOSE yes`
  - `WM_CLOSE_REQUEST_LOGGED yes`
  - `BADWINDOW no`
  - `FORCED_KILL_NEEDED no`
  - `PROCESS_SURVIVED_AFTER_CLOSE no`
  - `NEXT_LAUNCH_DEGRADED_OR_BLANKED no`
- `wmctrl-open.log` contains exactly one clean close notification:
  - `[MinimalCloseRepro] WM_CLOSE_REQUEST uptime_ms=1151 frames=72`
- no `BadWindow` lines were present in the run log
- next-launch probe rendered normally again and `wmctrl-next-launch-xwininfo.txt` remained `Map State: IsViewable`

Verdict: `wmctrl -c` behaves like the ordinary clean close family on this recovered artifact.

### 3) `xdotool windowclose` — dirty / bug-triggering

Fresh run evidence:

- open-state screenshot/log/xwininfo artifacts under `xdotool-windowclose-open*`
- app rendered normally before close
- `xdotool-windowclose-result.txt` recorded:
  - `RENDERED_BEFORE_CLOSE yes`
  - `WM_CLOSE_REQUEST_LOGGED no`
  - `BADWINDOW yes`
  - `FORCED_KILL_NEEDED yes`
  - `PROCESS_SURVIVED_AFTER_CLOSE no`
  - `NEXT_LAUNCH_DEGRADED_OR_BLANKED no`
- `xdotool-windowclose-open.log` contains `53943` `BadWindow` lines and **no** `WM_CLOSE_REQUEST`
- the process did not exit on its own after `xdotool windowclose`; I had to terminate it explicitly

Important nuance versus the earlier broader fallout investigation:

- In this **single isolated recovered rerun**, once I force-cleaned the dirty process, the **very next relaunch still rendered normally**.
- `xdotool-windowclose-next-launch-summary.txt` recorded `NEXT_LAUNCH_RENDERED yes` and `NEXT_LAUNCH_DEGRADED_OR_BLANKED no`.
- `xdotool-windowclose-next-launch-xwininfo.txt` showed `Map State: IsViewable`.

So the dirty split reproduced again, but the earlier stronger “next launch comes back blank/degraded” fallout did **not** recur immediately in this focused rerun.

## Exact close-method split observed

The close-method split on the recovered rebuilt artifact is:

- **Clean family:**
  - normal human-equivalent titlebar close
  - `wmctrl -c`
- **Dirty family:**
  - `xdotool windowclose`

More precisely:

- the clean family routes deliver a normal close request (`WM_CLOSE_REQUEST`), exit without `BadWindow`, and do not need forced cleanup
- the dirty `xdotool windowclose` route bypasses that clean path, produces heavy `BadWindow` spam, never logs `WM_CLOSE_REQUEST`, and requires forced termination

## Verdict

**PASS / narrowed split confirmed.**

The recovered rebuilt artifact still shows a clear method-sensitive close split:

- ordinary titlebar-equivalent close behavior is clean
- `wmctrl -c` is also clean
- `xdotool windowclose` is the bug-triggering route

The only meaningful change from the earlier fallout story is scope: in this focused isolated rerun, the `xdotool windowclose` path still reproduced the core failure, but it did **not** immediately poison the next relaunch after explicit process cleanup.
