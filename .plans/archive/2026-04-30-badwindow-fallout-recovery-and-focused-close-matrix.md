# AeroBeat Assembly Community

**Date:** 2026-04-30  
**Status:** ✅ Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Restore the rebuilt Godot close-path repro artifact to a clean normal-open state after the `BadWindow` fallout, verify that recovery through desktop-control, and then run a focused close-method matrix that distinguishes normal human close routes from the specific automation route that triggers the bug.

---

## Overview

The broad question is no longer “does a Linux/X11 export always fail on close?” The latest evidence is narrower and more actionable: normal human titlebar close looks clean, while at least one automation close route (`xdotool windowclose`) reproduces the original `BadWindow` spam and leaves the app in a degraded follow-up state where later launches can open blank/broken.

That means the immediate priority is recovery, not more breakage. First we need to identify what clears the bad aftermath and gets the rebuilt artifact back to a good normal-open state. Then we need QA to verify that recovery with desktop-control so we know the app truly opens and closes normally again. Only after that should we run the focused matrix comparing `xdotool windowclose`, `wmctrl -c`, titlebar close, and any other close methods worth keeping.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Rebuilt QA artifact plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-qa-rebuild-and-desktop-control-close-test.md` |
| `REF-02` | Rebuilt artifact notes | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-qa-rebuild-artifact-notes.md` |
| `REF-03` | Manual export discrepancy investigation | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-diff.md` |
| `REF-04` | Desktop-control skill guidance | `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md` |
| `REF-05` | Rebuilt artifact folder | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/` |

---

## Tasks

### Task 1: Diagnose and clear the post-BadWindow fallout state

**Bead ID:** `oc-d7x`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`  
**Prompt:** Claim the assigned bead and identify what clears the bad aftermath after the `xdotool windowclose`/`BadWindow` failure on the rebuilt artifact. Determine whether the broken follow-up state is caused by a surviving process, stale wrapper child, X11 window/resource state, shell/job state, or something else. Recommend the smallest truthful recovery procedure that returns the artifact to a good normal-open state.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-d7x/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-notes.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-d7x/run_rebuilt_badwindow_case.sh`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-d7x/rebuilt-badwindow-windowclose-*`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-d7x/relaunch-with-stale-abs-*`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-d7x/open-only-after-recovery-*`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-d7x/recovery-kill-orphan.txt`

**Status:** ✅ Complete

**Results:** Wrote diagnostic notes to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-notes.md`. The clearest immediate fallout from the rebuilt artifact's `windowclose` / `BadWindow` path is a surviving orphaned `GodotClosePathMinimal.x86_64` process that outlives the wrapper, gets reparented to `systemd --user`, and keeps an X11 window object around in `WM_STATE=Iconic` / `Map State=IsUnMapped`. Killing that orphan is the smallest reliable cleanup for the process residue. However, later default-X11 relaunches in the same desktop session still came back as iconified/unmapped windows even after orphan cleanup, and wrapper-vs-direct-binary, PTY-vs-non-PTY, forced-Wayland-reset, `wmctrl`/`xdotool`, and raw `python-xlib` deiconify attempts did not restore a visible normal-open state. Most truthful diagnosis: the aftermath is **not** just shell/job drift or wrapper-child bookkeeping; it is an orphaned surviving process plus persistent X11/window-manager state. I safely applied the minimal internal cleanup by terminating all live `GodotClosePathMinimal.x86_64` processes so the artifact is clean at rest, but I did **not** prove a full in-session return to a good visible default-X11 normal-open baseline. The next truthful escalation is a fresh desktop/X11 session reset before continuing default-X11 QA.

---

### Task 2: Restore a trustworthy desktop baseline after the dirty close fallout

**Bead ID:** `oc-21x`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and attempt the least-disruptive truthful desktop/session reset needed to restore a good default-X11 normal-open baseline for the rebuilt artifact after the dirty `BadWindow` fallout. Prefer the smallest safe recovery first; escalate only if needed and document exactly what changed and why.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-session-reset-notes.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/fresh-default-x11-open-probe.log`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/fresh-default-x11-open-probe-meta.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/fresh-default-x11-open-probe-xwininfo.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/fresh-default-x11-open-probe-xprop.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/xwayland-restart-meta.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/final-baseline-probe.log`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/final-baseline-probe-meta.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/final-baseline-probe-xwininfo.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/final-baseline-probe-xprop.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-21x/final-baseline-probe.png`

**Status:** ✅ Complete

**Results:** Reconfirmed the broken starting point first: after orphan cleanup alone, a fresh default-X11 launch still came up as an X11 window object with no visible surface (`xdotool --onlyvisible` empty, `xwininfo Map State=IsUnMapped`, `xprop WM_STATE=Iconic`). I then escalated to the smallest plausible component reset short of logging out the desktop: restarting the per-session `Xwayland` process only. Impact is limited to X11 clients in the live GNOME Wayland session; GNOME Shell itself stayed up and `gnome-remote-desktop` remained active. After the on-demand Xwayland respawn, a clean follow-up launch restored a visible normal-open baseline: the artifact reached `READY`, `xdotool search --onlyvisible` returned visible IDs again, and `xwininfo` on the primary visible window reported `Map State: IsViewable`. After cleanup, no live artifact process or visible artifact windows remained. Concise notes were written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-session-reset-notes.md`. Verdict: the minimal truthful reset that worked was **kill leftover artifact processes, then restart Xwayland only**; a full desktop logout/login was not needed. This looks good enough for Task 3 QA to verify a clean normal-open baseline.

---

### Task 3: Verify recovery to a clean normal-open state using desktop-control

**Bead ID:** `oc-ucn`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and use the truthful desktop-control workflow to verify that the rebuilt artifact is back in a good normal-open state after the recovery/reset procedure. Confirm that the window renders normally, is interactable, and can be cleanly closed through a normal human-equivalent titlebar close path before any new bug-triggering tests proceed.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/2026-04-30-recovery-qa-notes.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/01-open.png`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/open-window-state.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/selector-close-step*.json`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/atspi-close-action.json`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/final-close-verification.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/recovery-qa-20260430-140813/03-after-atspi-close.png`

**Status:** ✅ Complete

**Results:** Recovery verification passed. I launched the rebuilt artifact after the Xwayland-only reset from Task 2 and confirmed a truthful visible normal-open state using the desktop-control screenshot-first workflow: host-local screenshot `01-open.png`, visible `xdotool` IDs, and `xwininfo` reporting `Map State: IsViewable` on the live frame. The window rendered its expected single-screen `Minimal Linux Close Repro` content and the app log reached `READY`. For the close step, the canonical GRD blind-click helper was available and selector guardrails passed in dry-run, but live GRD click delivery could not authenticate in this shell because `OC_GRD_PASSWORD` was unavailable. Per `REF-04`, I used the cleaner semantic control path instead: AT-SPI exposed the real titlebar `Close` button on the live `mutter-x11-frames` window frame (`/0/1/0/0/0/2/0/2`) with a `click` action, and invoking it cleanly closed the app. Post-close evidence showed `WM_CLOSE_REQUEST` in the app log, no remaining `GodotClosePathMinimal.x86_64` process, no visible matching windows, and `03-after-atspi-close.png` with the artifact gone. Notes written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-ucn/2026-04-30-recovery-qa-notes.md`. Verdict: the rebuilt artifact is back to a trustworthy clean baseline for the focused close-method matrix.

---

### Task 4: Run a focused close-method matrix on the recovered artifact

**Bead ID:** `oc-a1e`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and run the narrowed close-method matrix only after Task 2 confirms a good normal-open state. Compare at least: titlebar close, `wmctrl -c`, and `xdotool windowclose`, keeping logs and fallout behavior separate for each run. Capture whether the bad state reappears and whether subsequent launches degrade again.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-a1e/2026-04-30-focused-close-matrix-notes.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-a1e/run_focused_close_matrix.sh`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-a1e/focused-close-matrix-20260430-142039/`

**Status:** ✅ Complete

**Results:** Wrote focused matrix notes to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-a1e/2026-04-30-focused-close-matrix-notes.md`. I preserved the truthful recovered baseline by reusing the already-fresh titlebar-close verification from Task 3 instead of duplicating it, then ran fresh isolated direct-binary reruns for `wmctrl -c` and `xdotool windowclose` in that order. The split held cleanly: the titlebar-equivalent route and `wmctrl -c` both logged `WM_CLOSE_REQUEST`, produced no `BadWindow`, needed no forced kill, and left the very next launch normal/visible. `xdotool windowclose` again reproduced the dirty path on the recovered artifact: the app rendered normally first, then emitted `53943` `BadWindow` lines, logged **no** `WM_CLOSE_REQUEST`, and required forced termination. Important scope update versus the earlier broader fallout notes: in this tightly isolated recovered rerun, the immediate next launch after forced cleanup was still normal/visible (`Map State: IsViewable`), so the close-method split reproduced but the stronger “next launch comes back blank/degraded” fallout did **not** recur immediately here. Truthful narrowed verdict: the bug remains specifically sensitive to the `xdotool windowclose` route, while ordinary titlebar-equivalent close and `wmctrl -c` sit in the clean family.

---

### Task 4: Audit the recovery procedure and narrowed bug framing

**Bead ID:** `oc-0z0`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and independently audit the recovery procedure plus the focused close-method matrix. Decide what the truthful narrowed bug statement is, what Derrick should do manually next, and whether the upstream draft should pivot toward an automation-close-route-sensitive bug.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix-audit.md`

**Status:** ✅ Complete

**Results:** Independent audit notes were written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix-audit.md`. I spot-checked the raw recovery and matrix artifacts instead of relying only on the summaries. Audit verdict: the recovery procedure is real and verified (`kill leftover artifact processes` + `restart Xwayland` + relaunch/re-verify visible state), and the focused close-method split is also real. Titlebar close and `wmctrl -c` both sit in the clean family: they render normally, log `WM_CLOSE_REQUEST`, produce no `BadWindow`, need no forced kill, and leave the next launch normal. `xdotool windowclose` sits in the dirty family: it reproduces heavy `BadWindow` spam (`53943` lines in the audited log sample), logs no `WM_CLOSE_REQUEST`, and requires forced termination. Important narrowing: the stronger earlier fallout claim that the next launch reliably comes back degraded/blank is **not** the current primary truth after the isolated recovered rerun; the next launch after explicit cleanup was still visible/normal. Recommendation: **hold and rewrite/narrow** the current upstream draft before any posting, because its present “close the window with the titlebar/button and it hangs” framing is no longer supported by the audited evidence. If Derrick still wants an upstream report, it should be rewritten around the **`xdotool windowclose` / automation-close-route-sensitive X11 path** rather than an ordinary titlebar-close failure.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** A verified recovery procedure plus an independently audited focused close-route matrix for the rebuilt Godot repro artifact. The audited truth is now narrower than the earlier broad Linux-close story: after recovery, ordinary titlebar close and `wmctrl -c` are clean, while `xdotool windowclose` is the specific reproduced dirty route.

**Reference Check:** `REF-01` and `REF-03` remain useful historical context, but the decisive current evidence is the recovered-baseline verification and focused matrix. Recovery was independently confirmed through `.qa-logs/oc-ucn/2026-04-30-recovery-qa-notes.md` and `.plans/2026-04-30-badwindow-fallout-session-reset-notes.md`; the route split was independently confirmed through `.qa-logs/oc-a1e/2026-04-30-focused-close-matrix-notes.md` and the raw evidence folder `.qa-logs/oc-a1e/focused-close-matrix-20260430-142039/`; the audit itself is recorded at `.plans/2026-04-30-badwindow-fallout-recovery-and-focused-close-matrix-audit.md`.

**Commits:**
- None yet.

**Lessons Learned:** Once a bug story narrows, the wording has to narrow with it. Recovery state mattered, but so did close-route specificity: “Linux exported app hangs on close” was too broad, and “titlebar close hangs” is no longer supported. The truthful framing now depends on the exact route: titlebar close vs `wmctrl -c` vs `xdotool windowclose`.

---

*Completed on 2026-04-30*
