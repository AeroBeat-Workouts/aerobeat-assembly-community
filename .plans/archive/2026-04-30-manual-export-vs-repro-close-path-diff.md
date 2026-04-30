# AeroBeat Assembly Community

**Date:** 2026-04-30  
**Status:** ✅ Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Explain why Derrick’s manually exported `godot-close-path-minimal-reproducible` build appears to close cleanly while the earlier repro/export path produced the `BadWindow` hang, and identify whether the difference is backend/path selection, export settings, close method, logging visibility, or some other material packaging/runtime difference.

---

## Overview

We already have strong evidence that the standalone minimal exported repro can fail on the X11/Xwayland path while closing cleanly on forced native Wayland. Derrick’s latest report introduces a new discrepancy: a manual export from the sanitized MRP opened and closed without any visible failure. That does not necessarily invalidate the earlier repro evidence, but it does mean we need a careful apples-to-apples comparison.

This investigation should stay narrow and forensic. First, compare the manually exported build Derrick produced against the earlier known-bad export/build path: export presets, packaged files, launcher behavior, bundle structure, and any backend-selection differences. Then reproduce the manual build under controlled logging so we can determine whether the issue is absent, only visible in stdout/stderr, or only triggered under a specific close path or runtime invocation. Finally, independently audit the comparison so we can truthfully update the upstream issue draft if needed.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Prior backend-split validation plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-4-7-close-hang-check.md` |
| `REF-02` | Prior Wayland workaround plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-linux-wayland-workaround-path.md` |
| `REF-03` | Prior upstream issue drafting/audit chain | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-upstream-issue-draft.md` |
| `REF-04` | Standalone repro source project | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/` |
| `REF-05` | Derrick’s manually exported build path to compare | `/home/derrick/Documents/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-reproducible` |
| `REF-06` | Sanitized source-project MRP ZIP | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip` |

---

## Tasks

### Task 1: Compare the manual export output against the earlier known-bad export path

**Bead ID:** `oc-mcg`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Claim the assigned bead and compare Derrick’s manual export output at `REF-05` against the earlier known-bad exported repro/build path from `REF-01`/`REF-04`. Identify differences in launcher behavior, included files, export preset usage, runtime invocation assumptions, and anything that would affect X11/Xwayland vs native Wayland selection or whether a close-path failure is visible.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/`
- `/home/derrick/Documents/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-notes.md`

**Status:** ✅ Complete

**Results:** Wrote comparison notes to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-notes.md`. Key findings: Derrick’s manual export is a plain stock Godot export and appears to be a **4.7-beta1 debug export** (`linux_debug.x86_64` size/signature), while the earlier known-bad repro path was exercised as a repo-built **release export bundle**. The original failing repro did **not** depend on a custom launcher forcing X11 or Wayland—the earliest `run.sh` was only a thin `exec` wrapper. The strongest discrepancy drivers are therefore build-mode mismatch, lack of explicit backend-selection evidence in the manual run, and the stricter QA harness used on the failing path (captured X11-discoverable windows, exit-code `143`, and forced-kill evidence). Best explanation: the manual observation is not an apples-to-apples contradiction of the earlier repro; it is more likely a different build/run/observation context than evidence that the X11/Xwayland close-path bug disappeared.

---

### Task 2: Reproduce and instrument Derrick’s manual export under controlled logging

**Bead ID:** `oc-b2r`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and run Derrick’s manual export from `REF-05` under controlled logging. Determine whether the close-path issue is actually absent, only present in stdout/stderr, only visible when force-running on X11, or only triggered by a specific launcher/run method. Capture exact exit codes, relevant logs, and backend/path evidence.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/summary.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/run_manual_export_case.sh`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-default-wrapper-rerun-meta.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-default-wrapper-rerun.log`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-force-x11-meta.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-force-x11.log`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-force-wayland-meta.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-force-wayland.log`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/manual-export-force-wayland-wayland-debug.log`

**Status:** ✅ Complete

**Results:** QA ran Derrick’s stock manual export under a controlled harness and wrote findings to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-b2r/summary.md`. The manual export binary was confirmed to be the stock `4.7-beta1` debug template. On the **default stock wrapper path** (`./GodotClosePathMinimal.sh`), the app still presented as an **X11-discoverable window**, emitted massive `BadWindow` spam from `platform/linuxbsd/x11/display_server_x11.cpp:1335`, and only terminated after forced kill, with launcher exit `143`. On the cleaner **explicit X11** run (`--display-driver x11`), the same failure family reproduced again: `WINDOW_ID 27262978`, `91574` `BadWindow` entries, no `WM_CLOSE_REQUEST`, forced kill required, exit `143`. On the **explicit native Wayland** run (`--display-driver wayland`), the app closed cleanly with launcher exit `0`, a single `WM_CLOSE_REQUEST`, no `BadWindow`, `WINDOW_ID none`, and Wayland protocol evidence (`wl_registry`, `xdg_wm_base`) in the `WAYLAND_DEBUG` capture. Conclusion: Derrick’s manual export does **not** disprove the earlier repro; it behaves consistently with the earlier backend split, and the earlier discrepancy was primarily **execution-context / observability drift**, not the bug disappearing.

---

### Task 3: Audit the explanation and decide whether the upstream draft needs revision

**Bead ID:** `oc-4zh`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead and independently audit the comparison/reproduction findings. Decide whether the discrepancy is fully explained, whether the upstream issue draft remains truthful as written, and whether any wording or evidence in the draft should be updated before posting.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-audit.md`

**Status:** ✅ Complete

**Results:** Independent audit notes were written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-audit.md`. Verdict: the manual-export discrepancy **reinforces** the existing upstream draft rather than contradicting it. Controlled reruns of Derrick's stock `4.7-beta1` manual export still reproduced the bad close behavior on the default/X11-discoverable path (`BadWindow`, forced kill, exit `143`) and still closed cleanly on forced native Wayland (`WM_CLOSE_REQUEST`, exit `0`, no `BadWindow`). That means the earlier apparent contradiction came from observation-context drift, not from the bug disappearing. No mandatory wording change is required before posting the upstream draft; at most, Derrick could optionally add one corroborating sentence about the audited manual-export rerun.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Comparison, controlled QA evidence, and an independent audit for Derrick’s manual export path. The discrepancy is now explained: the manually exported stock `4.7-beta1` build still reproduces the bad close behavior on the default/X11-discoverable path and still closes cleanly on forced native Wayland, so the earlier casual clean-close observation was an observability/context mismatch rather than a contradiction.

**Reference Check:** `REF-01` and `REF-02` remain consistent with the new QA evidence and the independent audit: the manual export findings strengthen the backend-split story already used in `REF-03`. `REF-05` turned out not to undermine the upstream draft; it simply needed controlled rerun evidence.

**Commits:**
- None yet.

**Lessons Learned:** A repro that is truthful enough for upstream still has to survive independent re-export/re-run checks, especially when backend selection and launcher behavior are part of the bug surface. Stock Godot wrappers that do not `exec` the game binary also make casual manual observation less trustworthy unless PID/exit behavior is captured carefully.

---

*Completed on 2026-04-30*
