# AeroBeat Assembly Community

**Date:** 2026-04-30  
**Status:** ✅ Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Rebuild the QA-style exported repro artifact from the current `repros/linux-close-minimal/` source project, then use the desktop-control path to perform a human-equivalent close test before Derrick manually reviews the rebuilt artifact.

---

## Overview

The earlier QA-built `dist/` path no longer exists because the MRP sanitization pass intentionally removed generated export artifacts from the repo. Derrick wants option 1: recreate that QA-style export artifact, then have the agent use the desktop-control path to exercise the rebuilt app with click-style close interactions before he reviews it manually.

This needs two linked tracks. First, rebuild a fresh exported Linux artifact from the current source project and record the exact artifact paths/hashes so we know what Derrick is testing. Second, use the desktop-control capability on this host to establish whether a real GUI close interaction reproduces the bad behavior on the rebuilt artifact, while keeping backend/logging evidence and process-exit evidence. Finally, independently audit the rebuilt artifact plus the desktop-control test outcome so we can truthfully say what Derrick should expect before he manually reviews.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current source repro project | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/` |
| `REF-02` | Manual export discrepancy investigation | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-manual-export-vs-repro-close-path-diff.md` |
| `REF-03` | Prior backend-split validation | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-4-7-close-hang-check.md` |
| `REF-04` | Desktop-control skill guidance | `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md` |

---

## Tasks

### Task 1: Rebuild a fresh QA-style Linux export artifact from the current repro source

**Bead ID:** `oc-k52`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** Claim the assigned bead and rebuild a fresh QA-style Linux export artifact from the current `repros/linux-close-minimal/` source project. Record exact output paths, file hashes/sizes, and any meaningful export flavor details (debug/release, wrapper/binary shape). Update the plan with the rebuilt artifact paths and findings.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-k52/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-qa-rebuild-artifact-notes.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-k52/export-command.txt`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-k52/export.log`

**Status:** ✅ Complete

**Results:** Rebuilt a fresh stock-style Linux export artifact from `REF-01` into `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048/` using `/home/derrick/.local/bin/godot-4.7-beta1` (`4.7.beta1.official.1c8cc9e7e`) with `--export-debug "Linux Minimal Close Repro"`. The rebuilt artifact shape is `GodotClosePathMinimal.sh` + `GodotClosePathMinimal.x86_64` + `GodotClosePathMinimal.pck`, which keeps manual QA apples-to-apples with the earlier stock manual export from `REF-02`. Exact hashes/sizes and comparison notes were written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-qa-rebuild-artifact-notes.md`. Key identity details: wrapper SHA-256 `97f0bf6380058764ba65fa202c00ad3fd4504d4b060f3556c87c1f6c7ce999cc`, binary SHA-256 `a46ef2982935aa6439fe7c8c16072945dfbf86c53b792c5f9e41347e9dc1165a`, PCK SHA-256 `6c7218dbb40a1440ff24b746fbb3886e3ca763bee91edcb5a38cde2b870029b7`. The rebuilt binary matches the installed `4.7.beta1` `linux_debug.x86_64` export template exactly, while the freshly regenerated PCK differs from the earlier in-repo stock export hash even though its size remains `8432` bytes.

---

### Task 2: Prepare/check desktop-control prerequisites for a truthful GUI close test

**Bead ID:** `oc-3dc`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-04`  
**Prompt:** Claim the assigned bead and prepare/check the host desktop-control prerequisites needed for a truthful GUI close test on GNOME Wayland, using the canonical desktop-control workflow from `REF-04`. Rebuild or verify the blind-click helper if needed, note any sudo or environment requirements, and record the honest control limits before QA executes the GUI close test.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/skills/desktop-control/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/desktop-control-prereqs/2026-04-30-prereq-notes.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/desktop-control-prereqs/preflight-pointer-shot.png`

**Status:** ✅ Complete

**Results:** Confirmed this host is on GNOME Wayland (`zorin:GNOME`, `wayland-0`) with the canonical GRD configuration still set to `mirror-primary` and RDP `view-only=false`, and verified the host-local screenshot path with `gnome-screenshot --include-pointer` (`.qa-logs/desktop-control-prereqs/preflight-pointer-shot.png`). The canonical blind-click helper was missing at start, so I rebuilt it via `REF-04`’s required ensure script after installing the missing build prerequisites `freerdp3-dev` and `libwinpr3-dev` under Derrick’s temporary sudo grant. The helper now exists at `/home/derrick/.openclaw/workspace/skills/desktop-control/scripts/libfreerdp-blind/build/blind_rdp_client`. Prerequisite notes and remaining honest control limits for QA are recorded at `.qa-logs/desktop-control-prereqs/2026-04-30-prereq-notes.md`, including the click-only transport caveat, screenshot-first loop requirement, and GRD journal warnings that mean QA should confirm clicks by resulting app state rather than cursor visuals alone.

---

### Task 3: Run the rebuilt artifact through desktop-control / human-equivalent close testing

**Bead ID:** `oc-4a4`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and use the truthful desktop-control path to perform a human-equivalent close test on the rebuilt exported artifact. Capture whether GUI close reproduces the bad behavior, whether the process actually exits, and any backend/logging evidence. Compare that result against earlier automated/terminal findings.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-4a4/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-4a4/2026-04-30-rebuilt-artifact-desktop-close-qa.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-4a4/run_rebuilt_gui_close_xdotool.sh`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-4a4/rebuilt-default-wrapper-xdotool-*`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-4a4/rebuilt-default-wrapper-*`

**Status:** ✅ Complete

**Results:** QA wrote notes to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.qa-logs/oc-4a4/2026-04-30-rebuilt-artifact-desktop-close-qa.md`. The canonical GRD blind-click helper could not be used because `OC_GRD_PASSWORD` was unavailable in this shell, so QA truthfully followed `REF-04`'s screenshot-first workflow and used the skill's X11 branch for the live click because the rebuilt export presented as an X11-discoverable window on the Wayland session. From a fresh screenshot, QA recursively narrowed the top-right titlebar region to a dense-target-ready `53x30` selector cell (`x=1412`, `y=225`), moved the pointer there, captured a pointer-confirmation screenshot, and sent one bounded click. On both the ad hoc pass and the durable harness rerun, the rebuilt stock wrapper logged exactly one `WM_CLOSE_REQUEST`, logged zero `BadWindow` entries, required no forced kill, and the wrapper exited `0` with no surviving visible window/process in the post-click checks. This materially differs from the earlier default/X11 failure family in `REF-03`: under a real titlebar close interaction, the rebuilt QA artifact did **not** reproduce the bad close hang.

---

### Task 4: Audit the rebuilt artifact and desktop-control findings

**Bead ID:** `oc-3hy`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and independently audit the rebuilt artifact identity plus the desktop-control close-test findings. Decide whether the results support or weaken the current upstream framing, and summarize what Derrick should test manually next.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-rebuilt-artifact-desktop-close-audit.md`

**Status:** ✅ Complete

**Results:** Independent audit notes were written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-rebuilt-artifact-desktop-close-audit.md`. Verdict: the rebuilt artifact identity is solid, but the clean human-equivalent titlebar-close result materially **narrows and weakens** the current upstream framing. The earlier default/X11-discoverable failure family (`BadWindow`, forced kill, exit `143`) still exists in the repo evidence, but this rebuilt stock export closed cleanly under a screenshot-driven real titlebar click (`WM_CLOSE_REQUEST`, zero `BadWindow`, launcher exit `0`). That means the current draft is now too strong where it implies that a normal close-button path on the default export reliably reproduces. Recommended next step before any upstream post: Derrick should manually run a short close-method matrix on the rebuilt stock export from a terminal — titlebar click, `Alt+F4`, and direct-binary vs wrapper launch — and only then decide whether to narrow the upstream issue to a specific close route or keep it as a more conditional X11/Xwayland-path report.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Rebuilt a fresh stock `4.7.beta1` debug Linux export artifact from the current standalone repro source, recorded its exact identity/hashes, prepared the host desktop-control prerequisites, executed a truthful human-equivalent close test on the rebuilt artifact, and independently audited what that result means for the existing upstream issue framing.

**Reference Check:** `REF-01` was satisfied by rebuilding directly from the current source repro project and recording the resulting wrapper/binary/PCK identity. `REF-02` remains relevant because the rebuilt artifact is structurally comparable to the earlier stock manual export, but the new audit shows that artifact identity alone no longer explains the close discrepancy. `REF-03` still anchors the earlier default/X11-discoverable failure family and the forced-native-Wayland clean comparison, while the new QA/audit result narrows that story by showing a clean human-equivalent titlebar close on the rebuilt stock export. `REF-04` was followed honestly for desktop-control constraints/prereqs, but the final live click used the skill's X11 branch rather than the canonical GRD blind-click helper because `OC_GRD_PASSWORD` was unavailable in the QA shell.

**Commits:**
- None yet.

**Lessons Learned:** Rebuilding the artifact was the easy part; the harder truth is that close-path evidence is sensitive not just to backend family but also to the exact close route and observability method. A clean human-equivalent titlebar close on an X11-discoverable default-path export is enough to invalidate any upstream wording that implies a normal close button reliably reproduces the bug. Before posting upstream, we need one short manual close-method matrix so the report matches the actual trigger surface.

---

*Completed on 2026-04-30*
