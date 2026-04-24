# AeroBeat Assembly Community MediaPipe Linux Import Truth Pass

**Date:** 2026-04-24  
**Status:** Complete  
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

**Results:** Implemented the smallest truthful assembly-side compatibility pass needed for Linux import/use under the current addon contract. The working tree already contained the intended broad integration rewrite from stale local assumptions toward the mounted addon adapter (`src/main.gd`, `src/input_manager.gd`, `scenes/main.tscn`, `src/latency_display.gd`), and this coder pass finished the remaining blocking truth fixes instead of broadening scope further. Final assembly-facing behavior: `src/main.gd` now consumes `res://addons/aerobeat-input-mediapipe/src/input_provider.gd` as the public adapter entrypoint, uses the current core lifecycle signals (`started`/`stopped`/`failed`), respects the current `register_provider(provider, settings)` and `get_active_provider()/set_active_provider(...)` contract, avoids double-starting the already auto-activated provider during startup, and keeps simulation-mode fallback honest when activation fails. `src/input_manager.gd` remains only as a non-global shim extending the core manager so the stale local class no longer collides with the addon-exported global `InputManager`; `scenes/main.tscn` points directly at the core manager script. `src/latency_display.gd` now accepts a generic provider node, truthfully degrades when the public adapter does not expose the old latency metrics API, and no longer hard-depends on the stale internal `MediaPipeProvider` global. During validation, a remaining parse blocker surfaced in this file from leftover non-Godot ternary syntax (`? :`), and a runtime-order bug surfaced where `set_provider()` ran before the HUD entered the tree; both were fixed in this pass to make the already-planned compatibility rewrite actually import and run cleanly. Validation evidence: `godotenv addons install` succeeded and restored `aerobeat-core`, `aerobeat-input-mediapipe`, and `gut`; `godot --headless --path . --script src/latency_display.gd --check-only` passed after the syntax fix; `godot --headless --path . --script src/main.gd --check-only` passed; `godot --headless --path . --import --quit-after 1 --verbose` completed project import/editor load without the prior root-project parse failures; `godot --headless --path . --quit-after 2 --verbose` loaded the main scene, registered the mounted MediaPipe addon adapter, and reached runtime with the latency display attached. Remaining truthful caveat for QA: the mounted addon still logs an internal `Node not found: "MediaPipeServer"` on `_onready` before it dynamically creates that child, but the provider recovers, binds UDP successfully, and the assembly now imports and runs past the previous assembly-side blockers; this caveat appears addon-internal rather than another root assembly integration mismatch. Files changed in the final coder pass: `src/main.gd`, `src/latency_display.gd`, and this plan file; task-context files already present in the working tree and validated as part of this pass: `src/input_manager.gd`, `scenes/main.tscn`. Implementation commit: `a5a7472` (`Repair Linux MediaPipe assembly import path`), pushed to `origin/main`. Plan sync updates may follow in later commits.

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

**Status:** ✅ Complete

**Results:** Independently re-verified on Linux from the assembly repo after claiming `oc-05i`, rereading this plan, inspecting the landed assembly files (`addons.jsonc`, `project.godot`, `scenes/main.tscn`, `src/main.gd`, `src/input_manager.gd`, `src/latency_display.gd`) and inspecting the referenced coder commits `a5a7472` and `226d9a7`. Fresh addon reinstall evidence: `godotenv addons install` completed successfully at 2026-04-24 13:05 EDT and restored `aerobeat-core`, `aerobeat-input-mediapipe`, and `gut` from `addons.jsonc`. Import/editor validation evidence: `godot --headless --path . --script src/main.gd --check-only` exited cleanly, and `godot --headless --path . --import --quit-after 1 --verbose` loaded the project/editor/plugins without reproducing the prior root-project parse failures from Task 1; the remaining output was non-blocking editor/plugin noise (`gut` unloads plus an editor exit leak warning), not assembly parse failure. Runtime/use validation evidence: `godot --headless --path . --quit-after 2 --verbose` loaded `res://scenes/main.tscn`, printed `AeroBeat Assembly started`, loaded `res://addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd`, registered the mounted MediaPipe addon adapter, emitted `Tracking started`, and attached the latency display. The known caveat reproduced exactly during provider `_ready`: `ERROR: Node not found: "MediaPipeServer" (relative to "/root/Main/MediaPipeInputProvider/MediaPipeProvider")` from `res://addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd:13`, after which the provider recovered by creating/binding its local UDP server and logged `[MediaPipeServer] UDP socket bound to 127.0.0.1:4242` (twice), followed by normal assembly startup and shutdown (`Tracking started` then `Tracking stopped`). Mounted-addon path truth check: the assembly intentionally mounts the Python repo under `res://addons/aerobeat-input-mediapipe/` via the `addons.jsonc` alias, `project.godot` enables `res://addons/aerobeat-input-mediapipe/plugin.cfg`, `src/main.gd` preloads `res://addons/aerobeat-input-mediapipe/src/input_provider.gd`, and the addon directory installed exactly at `addons/aerobeat-input-mediapipe/`. That mount assumption is therefore correct for the assembly, but the adapter file still contains a stale comment claiming consumers mount it under `res://addons/aerobeat-input-mediapipe-python/`; treat that as documentation drift, not the live import path. QA verdict: import cleanly passes on Linux, and the best truthful runtime/use check available also passes far enough to show the assembly is wiring the mounted addon intentionally and reaching runtime; however, QA cannot call the slice perfectly clean because the addon still emits the exact `MediaPipeServer` missing-child error before recovery. Exact caveat for audit: the remaining blocker/caveat is addon-internal startup ordering in `addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd` (`@onready var _server = $MediaPipeServer` runs before `_ready()` conditionally creates that child), not another root assembly integration mismatch.

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

**Status:** ✅ Complete

**Results:** Independent audit reran the evidence path instead of trusting the prior task notes. Commit provenance checked first: `git show --stat --oneline --summary a5a7472`, `226d9a7`, and `0ffc2c4` confirmed the implementation commit landed the assembly/runtime rewiring and the later commits only updated the plan. Root import path truth check passed independently: after `godotenv addons install`, `godot --headless --path . --script src/main.gd --check-only` exited cleanly, and `godot --headless --path . --import --quit-after 1 --verbose` loaded `res://scenes/main.tscn`, `res://src/main.gd`, and the enabled plugins from `project.godot` without reproducing the Task 1 parse blockers; remaining output was non-blocking editor/plugin noise plus an editor-exit leak warning, not root-project parse failure. Addon wiring truth check passed independently: `addons.jsonc` mounts the Python repo under the assembly alias `aerobeat-input-mediapipe`; `project.godot` enables `res://addons/aerobeat-input-mediapipe/plugin.cfg`; `scenes/main.tscn` points the `InputManager` node at `res://addons/aerobeat-core/src/input_manager.gd`; `src/main.gd` preloads `res://addons/aerobeat-input-mediapipe/src/input_provider.gd`; and the addon files exist exactly at `addons/aerobeat-input-mediapipe/plugin.cfg`, `.../src/input_provider.gd`, and `.../src/providers/mediapipe_provider.gd` (`REF-02`, `REF-03`, `REF-04`, `REF-05`). Best truthful runtime/use path also passed independently: `godot --headless --path . --quit-after 2 --verbose` printed `AeroBeat Assembly started`, loaded `res://addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd`, logged `Registered MediaPipe addon adapter`, `Initializing MediaPipe addon adapter...`, `Tracking started`, and `Latency display added`, then shut down cleanly with exit code 0. Remaining caveat truth-check: the exact QA-reported error reproduced verbatim — `ERROR: Node not found: "MediaPipeServer" (relative to "/root/Main/MediaPipeInputProvider/MediaPipeProvider")` from `res://addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd:13` — and direct file inspection explains it: the addon still declares `@onready var _server = $MediaPipeServer` at line 13, then only conditionally creates that child later inside `_ready()` lines 38-42. Despite that startup-order flaw, the provider recovers immediately by loading `src/server/mediapipe_server.gd`, binding UDP on `127.0.0.1:4242`, and continuing through assembly startup/shutdown. Auditor verdict: this plan slice is complete with a non-blocking addon-internal caveat, not blocked by another root assembly import/use mismatch. The slice should close because the scoped goal was truthful Linux assembly import/use, which now passes; the startup-order bug should be tracked as follow-on addon cleanup work rather than holding this assembly truth-pass bead open.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** The assembly repo now truthfully supports the Linux MediaPipe addon import/use slice: the root project imports cleanly, the assembly mounts and enables the addon under the actual `res://addons/aerobeat-input-mediapipe/` path, the main scene uses the core `InputManager` plus the addon’s public adapter entrypoint, and the best available headless runtime path reaches provider registration/startup instead of failing at parse time.

**Reference Check:** `REF-02` satisfied: the manifest alias and installed addon directory match the live assembly import path. `REF-03` satisfied: `project.godot` enables the mounted addon plugin and points the project at `res://scenes/main.tscn`. `REF-04` satisfied: `src/main.gd`, `src/input_manager.gd`, and `scenes/main.tscn` now align with the current core/addon contract instead of the stale local API assumptions from Task 1. `REF-05` satisfied with caveat: the assembly correctly uses the addon’s public adapter/runtime surface, but the addon still contains documentation drift in the adapter comment (`aerobeat-input-mediapipe-python` path mention) and a startup-order bug in `src/providers/mediapipe_provider.gd` that emits a recoverable `MediaPipeServer` missing-child error before self-healing. `REF-01` satisfied: this work completed the recommended first truthful assembly import/use slice. `REF-06` superseded: the prior state of assembly import failure is no longer true after the landed fixes and rerun validation.

**Commits:**
- `a5a7472` - Repair Linux MediaPipe assembly import path
- `226d9a7` - Sync MediaPipe truth-pass plan results
- `0ffc2c4` - Record QA evidence for Linux MediaPipe truth pass
- `2778fd5` - Audit MediaPipe Linux truth-pass closure

**Lessons Learned:** For cross-repo Godot addon truth passes, import success and runtime truth are different checks: file-path mounting, enabled plugin state, and live scene wiring all need independent verification. Also, a recoverable addon-internal error can be real without invalidating a narrower assembly-slice claim; the right move is to record it precisely and spin follow-on cleanup instead of overreporting either “fully clean” or “still blocked.”

---

*Completed on 2026-04-24*
