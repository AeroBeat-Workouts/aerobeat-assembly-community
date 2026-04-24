# AeroBeat Assembly Community MediaPipe Linux Import Truth Pass

**Date:** 2026-04-24  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Truth-check and repair the Linux `aerobeat-assembly-community` import/use path for the GodotEnv-installed `aerobeat-input-mediapipe-python` addon so the assembly project imports cleanly and uses the addon intentionally under the current setup.

---

## Overview

The local `aerobeat-input-mediapipe-python` repo is now healthy on Linux in its own `.testbed`, and the next highest-value unknown is whether `aerobeat-assembly-community` can actually import and use that addon through GodotEnv on Linux. Current roadmap scanning showed the assembly already has the manifest shape for this, but also surfaced likely root-project parse/integration issues around provider naming, API arity, and stale assumptions in assembly code.

This pass needs to replace assumption with evidence. First reproduce the current root-project import/use failure path exactly, then implement only the fixes needed to get the Linux assembly import/use path truthful and clean under the current contract reality. After implementation, run independent QA and audit against the root assembly import/runtime path, not just static file inspection.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current roadmap and recommended first slice | `../aerobeat-input-mediapipe-python/.plans/mediapipe-python/2026-04-24-next-phase-cross-repo-roadmap.md` |
| `REF-02` | Assembly addon manifest | `addons.jsonc` |
| `REF-03` | Assembly project/plugin config | `project.godot` |
| `REF-04` | Likely assembly integration points | `src/main.gd`, `src/input_manager.gd` |
| `REF-05` | Current MediaPipe addon adapter/runtime reality | `../aerobeat-input-mediapipe-python/README.md`, `../aerobeat-input-mediapipe-python/src/input_provider.gd` |
| `REF-06` | Prior truthful state that assembly import was still failing | `memory/2026-04-19.md`, `memory/2026-04-24 next-phase scan` |

---

## Tasks

### Task 1: Reproduce the current Linux assembly import/use failures

**Bead ID:** `oc-g1u`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Reproduce the current Linux import/use path for `aerobeat-assembly-community` with the GodotEnv-installed MediaPipe addon. Restore addons, run the root project import/editor path, inspect the likely integration files, and capture the exact current errors or warnings. Map each failure to the stale assumption or API mismatch causing it. Do not implement fixes yet.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md`

**Status:** ✅ Complete

**Results:** Reproduced on Linux after a clean addon restore. Exact commands: `(1) godotenv addons install` from the repo root, which completed successfully and restored `aerobeat-core`, `aerobeat-input-mediapipe`, and `gut`; `(2) godot --headless --path . --import --quit-after 1 --verbose`, which reached editor project load and then emitted the blocking root-project parse errors. Exact failures: `res://src/main.gd:15` → `Could not parse global class "LatencyDisplay" from "res://src/latency_display.gd"`; this traces to `src/latency_display.gd` typing `_provider: MediaPipeProvider`, while the consuming project is still assuming a public global `MediaPipeProvider` class instead of using the addon’s current assembly-facing adapter entrypoint in `addons/aerobeat-input-mediapipe/src/input_provider.gd` (`REF-05`). `res://src/main.gd:35` → `Too few arguments for "get_provider()" call. Expected at least 1 but received 0`; the assembly-local manager still matches an older API where `get_provider()` returned the current provider, but the current core contract is `get_provider(provider_id: String)` plus `get_active_provider()` (`REF-04`, `REF-05`). `res://src/main.gd:58` → `Identifier "MediaPipeProvider" not declared in the current scope`; the assembly still instantiates the addon’s old internal provider class directly, but the current public mounted-addon surface is the `AeroInputProvider` adapter at `addons/aerobeat-input-mediapipe/src/input_provider.gd`, and direct reliance on the internal provider/global class is stale (`REF-05`). `res://src/main.gd:61` → `Invalid argument for "register_provider()" function: argument 1 should be "AeroInputProvider" but is "String"`; the assembly-local manager still calls a legacy `(name, provider)` signature, while current core `InputManager.register_provider()` is `register_provider(provider: AeroInputProvider, settings: Dictionary = {})` (`addons/aerobeat-core/src/input_manager.gd`). `res://src/input_manager.gd:1` → `Class "InputManager" hides a global script class`; the root project carries a stale local `class_name InputManager` that collides with the current global class exported by `addons/aerobeat-core/src/input_manager.gd`. `res://src/input_manager.gd:75` → `Too few arguments for "start()" call. Expected at least 1 but received 0`; the local manager still assumes the pre-contract `start()` shape, while `AeroInputProvider.start(settings_json: String)` now requires the settings argument at the contract surface (`addons/aerobeat-core/src/interfaces/input_provider.gd`, `addons/aerobeat-input-mediapipe/src/input_provider.gd`). Important non-blocking note: direct script checks for the mounted addon adapter and internal provider both passed (`godot --headless --path . --script addons/aerobeat-input-mediapipe/src/input_provider.gd --check-only` and `.../src/providers/mediapipe_provider.gd --check-only` both exited 0), so the current blocker is assembly-side stale integration code, not a broken mounted addon import. Minimal runtime/use check is therefore not truthful yet: the editor can open far enough to report the errors, but the main scene cannot be parsed cleanly, so meaningful root runtime/provider-use validation is blocked until the assembly removes or aligns the stale local integration layer. Recommended repair map for Task 2: (1) stop shadowing core `InputManager` with the repo-local `src/input_manager.gd`, or rewrite the root scene/scripts to consume the core manager API directly; (2) replace legacy provider registration/use in `src/main.gd` with the current core contract (`register_provider(provider, settings)`, `get_provider(provider_id)`/`get_active_provider()`, `set_active_provider(...)` or equivalent current flow); (3) instantiate the mounted addon’s public adapter entrypoint rather than assuming direct access to the internal `MediaPipeProvider`; (4) update `src/latency_display.gd` so it no longer depends on the stale internal provider class name and instead observes the actual adapter/current provider surface; (5) only after those parse-level mismatches are fixed, rerun import and then perform the best available runtime/provider-use check.

---

### Task 2: Repair the Linux assembly import/use path under the current addon contract

**Bead ID:** `oc-q52`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Implement the smallest truthful set of fixes needed so `aerobeat-assembly-community` imports cleanly on Linux and intentionally uses the GodotEnv-installed MediaPipe addon under the current contract reality. Preserve explicit compatibility boundaries where needed; do not overclaim nonexistent contract maturity. Run relevant validation, commit and push by default, and update this plan with exact results.

**Folders Created/Deleted/Modified:**
- `src/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `addons.jsonc`
- `project.godot`
- `src/main.gd`
- `src/input_manager.gd`
- other directly-related assembly files as needed
- `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md`

**Status:** ✅ Complete

**Results:** Implemented the smallest truthful assembly-side compatibility pass needed for Linux import/use under the current addon contract. The working tree already contained the intended broad integration rewrite from stale local assumptions toward the mounted addon adapter (`src/main.gd`, `src/input_manager.gd`, `scenes/main.tscn`, `src/latency_display.gd`), and this coder pass finished the remaining blocking truth fixes instead of broadening scope further. Final assembly-facing behavior: `src/main.gd` now consumes `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` as the public adapter entrypoint, uses the current core lifecycle signals (`started`/`stopped`/`failed`), respects the current `register_provider(provider, settings)` and `get_active_provider()/set_active_provider(...)` contract, avoids double-starting the already auto-activated provider during startup, and keeps simulation-mode fallback honest when activation fails. `src/input_manager.gd` remains only as a non-global shim extending the core manager so the stale local class no longer collides with the addon-exported global `InputManager`; `scenes/main.tscn` points directly at the core manager script. `src/latency_display.gd` now accepts a generic provider node, truthfully degrades when the public adapter does not expose the old latency metrics API, and no longer hard-depends on the stale internal `MediaPipeProvider` global. During validation, a remaining parse blocker surfaced in this file from leftover non-Godot ternary syntax (`? :`), and a runtime-order bug surfaced where `set_provider()` ran before the HUD entered the tree; both were fixed in this pass to make the already-planned compatibility rewrite actually import and run cleanly. Validation evidence: `godotenv addons install` succeeded and restored `aerobeat-core`, `aerobeat-input-mediapipe`, and `gut`; `godot --headless --path . --script src/latency_display.gd --check-only` passed after the syntax fix; `godot --headless --path . --script src/main.gd --check-only` passed; `godot --headless --path . --import --quit-after 1 --verbose` completed project import/editor load without the prior root-project parse failures; `godot --headless --path . --quit-after 2 --verbose` loaded the main scene, registered the mounted MediaPipe addon adapter, and reached runtime with the latency display attached. Remaining truthful caveat for QA: the mounted addon still logs an internal `Node not found: "MediaPipeServer"` on `_onready` before it dynamically creates that child, but the provider recovers, binds UDP successfully, and the assembly now imports and runs past the previous assembly-side blockers; this caveat appears addon-internal rather than another root assembly integration mismatch. Files changed in the final coder pass: `src/main.gd`, `src/latency_display.gd`, and this plan file; task-context files already present in the working tree and validated as part of this pass: `src/input_manager.gd`, `scenes/main.tscn`. Commit: `228e9b0` (`Repair Linux MediaPipe assembly import path`), pushed to `origin/main`.

---

### Task 3: QA the repaired Linux assembly import/runtime path

**Bead ID:** `oc-05i`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Independently verify that `aerobeat-assembly-community` now imports cleanly on Linux with the GodotEnv-installed MediaPipe addon and that the intended import/runtime path makes sense. Reinstall addons as needed, rerun import/editor validation, and perform the best truthful runtime/use check available. Report any remaining exact blocker.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 4: Audit closure of the Linux assembly import truth pass

**Bead ID:** `oc-cot`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Audit whether `aerobeat-assembly-community` now truthfully passes the Linux MediaPipe addon import/use slice. Verify the root project import path, the addon wiring assumptions, and any remaining caveats. Close only if the evidence supports that this slice is actually complete.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-04-24-mediapipe-linux-import-truth-pass.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending.

**Reference Check:** Pending.

**Commits:**
- Pending

**Lessons Learned:** Pending.

---

*Completed on Pending*
