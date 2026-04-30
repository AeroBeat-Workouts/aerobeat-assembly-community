# AeroBeat Assembly Community

**Date:** 2026-04-28  
**Status:** In Progress  
**Agent:** Pico 🐱‍🏍

---

## Goal

Copy the current Linux proof build to Cookie and launch it there so Derrick can verify webcam tracking behavior.

---

## Overview

We already have a fresh Linux proof export bundle in the local assembly repo. The immediate goal is not to rebuild or productize distribution, but to move the existing `dist/AeroBeatAssemblyProof-Linux.tar.gz` artifact onto Cookie, place it in the matching repo path under `dist/`, extract it, and run the exported app for live webcam validation.

This execution pass uses direct SSH/Tailscale transfer as the shortest path. If the test succeeds and needs to become repeatable, the next slice can formalize distribution via CI-backed artifact publishing.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Prior handoff describing the current fresh proof bundle paths | `memory/2026-04-27.md#L30-L52` |
| `REF-02` | Current repo ignore rules covering build outputs | `.gitignore` |

---

## Tasks

### Task 1: Transfer proof bundle to Cookie and launch it

**Bead ID:** `oc-tj6`  
**SubAgent:** `primary`  
**Role:** `primary`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Orchestrator-owned direct execution for this one-off transfer/run pass. Copy `dist/AeroBeatAssemblyProof-Linux.tar.gz` from the local repo to Cookie at `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/dist/`, extract it there, launch the exported app, and capture any run output or blockers for Derrick’s webcam validation.  

**Folders Created/Deleted/Modified:**
- `dist/` on Cookie repo path

**Files Created/Deleted/Modified:**
- `dist/AeroBeatAssemblyProof-Linux.tar.gz` on Cookie
- extracted `dist/AeroBeatAssemblyProof-Linux/` on Cookie

**Status:** ⏳ In Progress

**Results:** Copied `dist/AeroBeatAssemblyProof-Linux.tar.gz` to Cookie at `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/dist/`, extracted it there, and launched the exported app successfully against Cookie's active GUI session. First launch attempt failed because SSH used the wrong display target (`:0`); inspection of Cookie's desktop session showed GNOME/Xorg was actually on `DISPLAY=:1`, and relaunching with `DISPLAY=:1` plus the active user bus/runtime environment produced a live process (`./AeroBeatAssemblyProof.x86_64`) with no immediate startup errors. Derrick then confirmed the app window appeared and camera preview worked, but there was no skeleton tracking. Repo inspection explains why: `src/mediapipe_test_scene.gd` intentionally ships this proof scene with `@export var start_pose_provider: bool = false`, and when the sidecar starts in that mode the UI explicitly enters `Python sidecar running (camera preview mode)` with the note `Pose provider start is disabled in this proof scene to keep the play path warning-free.` So the current export is behaving as built; it is a preview-only proof, not a pose-tracking proof.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** We successfully transferred and launched the current Linux proof bundle on Cookie for live validation, which proved that the exported camera-preview path boots on another agent terminal. Validation also exposed two real product bugs: (1) the export is preview-only because pose-provider startup is intentionally disabled in the proof scene, so skeleton tracking never starts; and (2) closing the exported app caused Derrick's Zorin GUI session to crash back to sign-in, which points to a real shutdown/desktop-stability bug in the export path and/or its sidecar teardown behavior.

**Reference Check:** `REF-01` remains true for the bundle identity/path. `REF-02` remains true for ignore coverage. The runtime behavior observed on Cookie now truthfully extends the known proof caveats beyond the original handoff.

**Commits:**
- Pending

**Lessons Learned:** Cross-terminal proof surfaced higher-value truth than local export smoke tests: launch success alone is not enough. We now need a dedicated follow-up pass for pose-provider enablement and for safe/clean export shutdown on Zorin.

---

*Completed on 2026-04-28*
