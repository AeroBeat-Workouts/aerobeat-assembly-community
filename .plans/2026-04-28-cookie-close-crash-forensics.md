# AeroBeat Assembly Community

**Date:** 2026-04-28  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Capture higher-value forensic evidence on Cookie so we can diagnose why closing the exported AeroBeat proof app resets Derrick's Zorin desktop session.

---

## Overview

We already proved two truths on Cookie: the rebuilt proof now tracks correctly, and closing the app still triggers a destructive desktop-session reset. The prior log pull showed session restart evidence but not a precise smoking gun such as a Godot crash stack, GPU fault, or explicit coredump.

This pass is focused on better evidence, not a fix yet. The idea is to arm log capture before the next run so the next manual close gives us a clearer event timeline: app process exit, child/sidecar behavior, user-session journal changes, and any coredump or crash-related evidence visible without additional operator setup.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Cookie transfer/run notes and initial crash observations | `.plans/2026-04-28-cookie-build-transfer-and-run.md` |
| `REF-02` | Cross-repo fix/rebuild plan documenting the fresh tracking-default artifact | `/home/derrick/.openclaw/workspace/projects/openclaw-pico/.plans/2026-04-28-mediapipe-source-repo-fix-and-polyrepo-warning.md` |

---

## Tasks

### Task 1: Arm forensic capture and reproduce Cookie close crash

**Bead ID:** `oc-n9v`  
**SubAgent:** `primary`  
**Role:** `primary`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Orchestrator-owned direct execution. Arm journal/process/coredump-adjacent capture on Cookie, launch the rebuilt proof app, have Derrick reproduce the close-triggered desktop reset, then collect the resulting evidence and summarize what the timeline proves versus what remains unknown.

**Folders Created/Deleted/Modified:**
- Cookie: `dist/logs/`

**Files Created/Deleted/Modified:**
- Cookie forensic logs under `dist/logs/`

**Status:** ⏳ In Progress

**Results:** First two forensic attempts improved confidence but did not yet identify the exact teardown trigger. We proved the rebuilt app tracks correctly on Cookie and that closing it resets the Zorin X11 desktop session into a fresh GNOME/Xorg session, but we still lack a smoking-gun crash line. Next pass will narrow specifically on the shutdown choreography by wrapping `run-proof.sh` with explicit start/exit-code/timestamp logging and by capturing the MediaPipe sidecar autostart log directly alongside the persistent host-local session capture.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** We captured progressively better Cookie close-crash evidence until we proved two durable truths: (1) the rebuilt proof tracks correctly on Cookie, and (2) closing the sidecar-enabled MediaPipe proof path resets Cookie's Zorin X11 desktop session into a fresh GNOME/Xorg session. We also captured the original Python sidecar force-exit behavior and then verified later that removing that force-exit path did not stop the desktop reset.

**Reference Check:** `REF-01` and `REF-02` remain accurate. The later A/B control test superseded the broad uncertainty here by proving the reset requires the MediaPipe proof teardown path rather than plain Godot exported-window close behavior.

**Commits:**
- N/A (forensics/logging pass)

**Lessons Learned:** The most useful evidence came from host-local persistent capture plus direct sidecar log tailing. That evidence was sufficient to justify the upstream shutdown fix and then, when the crash persisted, to justify the no-sidecar A/B control test that narrowed the blame surface further.

---

*Completed on 2026-04-28*
