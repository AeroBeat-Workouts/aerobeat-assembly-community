# AeroBeat Assembly MediaPipe Addon Editor Visibility / Indexing Pass

**Date:** 2026-04-24  
**Status:** Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Determine why the generated MediaPipe addon exists on disk in `aerobeat-assembly-community/addons/` but does not appear in the Godot editor filesystem dock, then apply the smallest truthful fix.

---

## Overview

Derrick clarified that this is not a missing-install problem: the generated MediaPipe addon is present on disk under the assembly repo’s `addons/` directory, but the editor is not showing it under the `addons` folder. That makes this an editor visibility/indexing problem until proven otherwise.

This pass should stay narrow. We need to confirm the addon contents on disk, verify whether Godot can still load resources from that path even if the dock hides it, inspect scan/import/cache state, and determine whether the issue is editor refresh/indexing, hidden/filter state, or something deeper in the generated addon tree. Then we fix only what is needed.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current assembly addon manifest | `addons.jsonc` |
| `REF-02` | Current generated addon tree | `addons/`, `.addons/` |
| `REF-03` | Current project/editor config | `project.godot` |
| `REF-04` | Current MediaPipe addon payload | `addons/aerobeat-input-mediapipe/` |

---

## Tasks

### Task 1: Reproduce and classify the editor visibility/indexing issue

**Bead ID:** `oc-out`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Verify that the MediaPipe addon exists on disk, confirm whether Godot can load resources from that path even when the filesystem dock does not show it, inspect scan/import/cache state, and determine whether this is an editor visibility issue, a stale cache problem, or a deeper addon indexing problem. Do not implement yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.godot/`
- `.qa-logs/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-mediapipe-addon-editor-visibility-indexing-pass.md`

**Status:** ✅ Complete

**Results:** Confirmed `addons/aerobeat-input-mediapipe/` exists on disk with a normal Godot addon payload at the top level (`plugin.cfg`, `README.md`, `src/`, `python_mediapipe/`) plus embedded repo metadata (`.git/`, `.beads/`, `.plans/`). Exact evidence: `plugin.cfg` declares `name="AeroBeat Input Driver For MediaPipe via Python"` and `script="src/input_provider.gd"`; `find addons/aerobeat-input-mediapipe -maxdepth 2 -type f` showed the expected addon files.

Headless Godot 4.6.2 check showed this is not a truly missing addon path. `DirAccess.open("res://addons")` listed `aerobeat-input-core`, `aerobeat-input-mediapipe`, and `gut`. Direct file access and direct script loading worked for the MediaPipe addon payload: `FileAccess.file_exists("res://addons/aerobeat-input-mediapipe/plugin.cfg") == true`; `ResourceLoader.exists(...) == true` and `load() != null` for `src/input_provider.gd`, `src/providers/mediapipe_provider.gd`, and `src/camera_view.gd`.

The failure is in editor scanning/indexing, not basic disk presence. The addon root contains `addons/aerobeat-input-mediapipe/.gdignore`. `.godot/editor/filesystem_cache10` contains `res://addons/`, `res://addons/aerobeat-input-core/`, and `res://addons/gut/`, but no `res://addons/aerobeat-input-mediapipe/` entry. `.godot/global_script_class_cache.cfg` likewise contains classes from `aerobeat-input-core` and `gut`, but none of the MediaPipe `class_name` scripts (`MediaPipeProvider`, `MediaPipeCameraView`, `MediaPipeConfig`, etc.). That missing class registration explains why loading `src/mediapipe_input_with_camera.gd` produced parse errors for `MediaPipeProvider` and `MediaPipeCameraView` even though those scripts themselves can be loaded directly.

Diagnosis: this is primarily an editor visibility / indexing problem caused by the root-level `.gdignore` in the installed addon path, not a stale cache and not a missing-addon-on-disk problem. The caches are consistent with Godot intentionally skipping scanner/class-cache registration for that tree. Recommended next fix: remove or relocate the root `.gdignore` from `addons/aerobeat-input-mediapipe/` so only the subdirectories that truly need exclusion stay ignored (for example keep ignore boundaries inside `python_mediapipe/` or other non-resource folders), then force a rescan by reopening the project or clearing `.godot/` as needed.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Completed the investigation pass only. Verified the generated MediaPipe addon is physically present in `addons/aerobeat-input-mediapipe/`, confirmed Godot can directly read and load files from that path, and isolated the visibility failure to scanner/index/class-cache behavior rather than missing files.

**Reference Check:** `REF-01` matched the intended assembly install path for `aerobeat-input-mediapipe`. `REF-02` and `REF-04` matched the on-disk addon tree, including the root `.gdignore` that is suppressing normal editor indexing. `REF-03` showed the project only has `aerobeat-input-core` and `gut` enabled in `[editor_plugins]`, which is consistent with MediaPipe never becoming a discoverable editor plugin in the current scanned state.

**Commits:**
- Plan update committed and pushed to `main` with the MediaPipe addon visibility diagnosis.

**Lessons Learned:** In Godot 4.6, an addon tree can still exist on disk and be directly readable through `FileAccess` / direct `load()` calls while remaining absent from the filesystem dock and global class cache if the installed addon root is covered by `.gdignore`. That produces a misleading “it exists but the editor can’t see it” state that looks like stale cache at first glance but is actually intentional scanner exclusion.

---

*Completed on 2026-04-24*
