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

**What We Built:** Completed the investigation pass and recorded the downstream owner-repo fix validation. The investigation correctly isolated the cause to the installed addon root `.gdignore`, and the later owner-repo follow-up proved that diagnosis by removing the broad ignore, reinstalling the addon, and restoring normal Godot scan/class-cache visibility for the mounted MediaPipe payload.

**Reference Check:** `REF-01` still matches the intended assembly install path for `aerobeat-input-mediapipe`. `REF-02` and `REF-04` now tell the full before/after story truthfully: before the owner-repo fix, the installed addon tree carried a root `.gdignore` and stayed absent from filesystem/global-class caches; after the follow-up refresh from `aerobeat-input-mediapipe-python` commit `ea26670`, the refreshed mounted addon no longer has root `.gdignore` or `python_mediapipe/.gdignore`, `filesystem_cache*` now contains `res://addons/aerobeat-input-mediapipe/`, `.../python_mediapipe/`, and `.../src/` entries, and `global_script_class_cache.cfg` again registers `MediaPipeProvider`, `MediaPipeCameraView`, and `MediaPipeConfig` from the mounted addon path. Hidden-dir scans found no cache entries under `.beads/`, `.github/`, `.plans/`, `.testbed/`, or `.git/`, so the validated consumer state now matches the intended visible/hidden split. `REF-03` remains consistent: the assembly still only enables the real editor plugins under `[editor_plugins]`; MediaPipe is visible/indexed again because the tree is no longer globally ignored, not because it was re-enabled as an editor plugin.

**Commits:**
- Initial investigation plan update committed and pushed to `main` with the visibility diagnosis.
- Owner-repo fix consumed by this assembly refresh: `ea26670` in `../aerobeat-input-mediapipe-python` (`Fix addon selective visibility layout`).

**Lessons Learned:** In Godot 4.6, an addon tree can still exist on disk and be directly readable through `FileAccess` / direct `load()` calls while remaining absent from the filesystem dock and global class cache if the installed addon root is covered by `.gdignore`. The follow-up also showed the truthful fix pattern: move `.gdignore` down onto only the repo-only folders that should stay hidden, then clear scan caches and re-import to prove `filesystem_cache` and `global_script_class_cache` have repopulated for the intended visible addon surfaces.

---

*Completed on 2026-04-24*
