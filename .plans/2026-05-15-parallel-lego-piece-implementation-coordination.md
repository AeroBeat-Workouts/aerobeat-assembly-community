# AeroBeat Parallel Lego Piece Implementation Coordination

**Date:** 2026-05-15  
**Status:** Draft  
**Agent:** Cookie 🍪

---

## Goal

Coordinate parallel implementation of the three reusable AeroBeat Lego-piece repos — `aerobeat-tool-settings`, `aerobeat-environment-loader`, and `aerobeat-tool-camera-gesture-control` — while locking shared contracts early enough to prevent drift.

---

## Overview

Derrick approved the overall direction: do not optimize around `assembly-community` integration yet. The immediate objective is to build the three reusable tool repos, prove them in their own hidden `.testbed/` projects, and make sure their APIs, event payloads, and file/config contracts line up cleanly.

That means the work should run in parallel, but not chaotically. A short contract-lock pass should go first, freezing the minimum shared connector shapes: performance recommendation events from `aerobeat-tool-settings`, environment request/result/error/progress contracts from `aerobeat-environment-loader`, and tuning/profile/runtime API shapes from `aerobeat-tool-camera-gesture-control`. Once those are written down, each repo can move independently with its own coder → QA → auditor loop.

This coordination plan is the umbrella record. The implementation details for each lane live in repo-local plans inside the owning repos, but this file keeps the shared order, dependencies, checkpoints, and cross-repo decisions visible in one place.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Higher-level fallback/design roadmap | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community/.plans/2026-05-15-default-environment-fallback-ladder.md` |
| `REF-02` | First-slice implementation plan for performance classifier | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/.plans/2026-05-15-performance-classifier-first-slice.md` |
| `REF-03` | Tool settings repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings` |
| `REF-04` | Tool environment repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader` |
| `REF-05` | Tool camera gesture control repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-camera-gesture-control` |
| `REF-06` | Content-core contract source for workout environment metadata | `/home/derrick/Documents/projects/aerobeat/aerobeat-content-core` |
| `REF-07` | Gaussian splat integration repo whose progress semantics may be reused | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat` |
| `REF-08` | MediaPipe Python repo used via GodotEnv in camera-control testbed | `/home/derrick/Documents/projects/aerobeat/aerobeat-input-mediapipe-python` |
| `REF-09` | Input-core contract boundary for camera control | `/home/derrick/Documents/projects/aerobeat/aerobeat-input-core` |

---

## Shared Contract Checkpoints

These are now frozen well enough for the three repo lanes to build in parallel without re-negotiating the shared connector shapes.

### Contract Lock A — Performance Recommendation Contract

Owner: `aerobeat-tool-settings`

Locked public singleton surface through `src/AeroToolManager.gd`:

```gdscript
signal recommendation_updated(result: Dictionary)
signal downgrade_recommended(event: Dictionary)

func sample_static_signals() -> Dictionary
func begin_live_sampling(context: Dictionary = {}) -> void
func stop_live_sampling() -> void
func get_current_recommendation() -> Dictionary
func get_current_signals() -> Dictionary
func get_current_reasons() -> PackedStringArray
func should_downgrade_for_active_environment() -> bool
```

Locked `recommendation_updated(result)` payload shape:

```json
{
  "tier": "high | medium | low",
  "confidence": "high | medium | low",
  "recommended_environment_profile": "high | medium | low",
  "startup_estimate": "high | medium | low",
  "live_confirmed": true,
  "signals": {
    "platform": "linux | windows | macos | android | ios | web",
    "renderer_name": "optional string",
    "resolution": [1920, 1080],
    "resolution_bucket": "720p | 1080p | 1440p | 4k",
    "rolling_fps": 58.7,
    "rolling_frame_time_ms": 17.0,
    "low_fps_duration_ms": 0
  },
  "reasons": [
    "Human-readable explanation"
  ]
}
```

Locked `downgrade_recommended(event)` payload shape and policy:

```json
{
  "from_tier": "high | medium | low",
  "to_tier": "medium | low",
  "reason": "sustained_low_fps",
  "threshold_fps": 30.0,
  "threshold_duration_ms": 3000,
  "observed_average_fps": 24.6,
  "sample_window_ms": 3000
}
```

Policy lock:
- the downgrade threshold is sustained rolling average FPS `< 30.0` for `3000 ms`
- the event is a recommendation, not an automatic swap policy owned by the tool repo
- do not emit repeated downgrade spam for the same current tier without a state reset or tier change

### Contract Lock B — Environment Load Contract

Owner: `aerobeat-environment-loader`

Locked runtime surface:

```gdscript
signal environment_load_started(request: Dictionary)
signal environment_load_progress(progress: Dictionary)
signal environment_load_succeeded(result: Dictionary)
signal environment_load_failed(error: Dictionary)
signal environment_cleared()

func load_environment(request: Dictionary) -> void
func load_environment_from_workout_yaml(yaml_path: String, context: Dictionary = {}) -> void
func clear_environment() -> void
func get_current_environment() -> Dictionary
func supports_kind(kind: String) -> bool
```

Locked generic request shape:

```json
{
  "request_id": "optional string",
  "kind": "image | video | glb | splat",
  "asset_path": "res://... | user://... | absolute path where supported",
  "config_path": "optional path for glb/splat sidecar config",
  "display_mode": "cover | contain",
  "context": "optional caller context string",
  "metadata": {}
}
```

Locked progress payload semantics:

```json
{
  "request_id": "optional string",
  "kind": "image | video | glb | splat",
  "asset_path": "res://...",
  "status": "resolving | loading | decoding | instantiating | applying_config | ready",
  "progress": 0.42,
  "message": "Human-readable status"
}
```

Progress rules:
- `progress` is normalized to `0.0 .. 1.0`
- it is best-effort monotonic within a single request
- `ready` may be emitted as the final progress status, but success is still communicated by `environment_load_succeeded(result)`
- fields should stay stable across all four official formats even when underlying loaders differ

Locked result payload shape:

```json
{
  "ok": true,
  "request_id": "optional string",
  "kind": "image | video | glb | splat",
  "asset_path": "res://...",
  "config_path": "optional path",
  "format": ".png | .ogv | .glb | .compressed.ply",
  "config_applied": true,
  "metadata": {}
}
```

Locked error payload shape:

```json
{
  "ok": false,
  "request_id": "optional string",
  "kind": "image | video | glb | splat",
  "asset_path": "res://...",
  "error_code": "file_missing | unsupported_format | invalid_config | loader_failed",
  "message": "Human-readable explanation",
  "recoverable": true
}
```

Workout-YAML convenience boundary lock:
- workout YAML ingestion is a thin translation layer into the exact generic request contract above
- it may resolve AeroBeat workout environment metadata and choose among already-authored official assets
- it must not change the generic loader API, own fallback-tier policy, or generate fallback derivatives in this lane

Official format support lock:
- image: `.png`
- video: `.ogv`
- model: `.glb`
- splat: `.compressed.ply`
- wider loader compatibility may exist internally, but it is not part of the frozen AeroBeat-authored contract for this pass

Sidecar config lock:
- GLB config and splat config stay separate contracts/files
- both describe environment-content transforms and placement, not the camera
- splat config may carry splat-specific extensions beyond the shared transform baseline

### Contract Lock C — Camera Gesture Control Contract

Owner: `aerobeat-tool-camera-gesture-control`

Locked runtime controller API:

```gdscript
signal control_mode_changed(mode: String)
signal tracking_state_changed(state: Dictionary)
signal profile_loaded(profile: Dictionary)
signal profile_saved(path: String)

func set_enabled(enabled: bool) -> void
func set_control_mode(mode: String) -> void
func attach_camera(camera: Camera3D) -> void
func detach_camera() -> void
func attach_input_source(input_source: Node) -> bool
func detach_input_source() -> void
func apply_profile(profile: Dictionary) -> void
func get_profile() -> Dictionary
func load_profile(path: String) -> Dictionary
func save_profile(path: String) -> Dictionary
func get_debug_state() -> Dictionary
```

Locked control modes:
- `gesture`
- `mouse_wasd`
- `disabled`

Locked JSON tuning/profile schema:

```json
{
  "version": 1,
  "mode": "gesture | mouse_wasd | disabled",
  "invert_x": false,
  "invert_y": false,
  "look_sensitivity_x": 1.0,
  "look_sensitivity_y": 1.0,
  "translation_sensitivity_x": 1.0,
  "translation_sensitivity_y": 0.6,
  "translation_sensitivity_z": 0.4,
  "max_yaw_degrees": 20.0,
  "max_pitch_degrees": 12.0,
  "max_roll_degrees": 4.0,
  "max_translation_meters": [0.6, 0.35, 0.45],
  "smoothing": 0.2,
  "deadzone": 0.03,
  "recenter_speed": 1.8,
  "tracking_confidence_threshold": 0.45,
  "freeze_on_tracking_loss": true,
  "sample_source": "head_position"
}
```

Input boundary lock:
- runtime code consumes an input-core-facing source/adapter boundary rather than MediaPipe-specific process details
- the `.testbed/` may use `aerobeat-input-mediapipe-python` via GodotEnv to satisfy that boundary locally

Locked testbed tunable field list:
- mode switch (`gesture`, `mouse_wasd`, `disabled`)
- invert X/Y toggles
- look sensitivity X/Y sliders
- translation sensitivity X/Y/Z sliders
- max yaw/pitch/roll sliders
- max translation sliders
- smoothing slider
- deadzone slider
- recenter speed slider/button
- tracking confidence threshold slider
- freeze-on-tracking-loss toggle
- save/load JSON profile controls
- live debug labels for confidence, normalized input, and applied transform

### Cross-Repo Consistency Rules

- Event payload names must stay explicit and stable; prefer verb-rich signal names plus dictionary payloads with named keys.
- Request/result/error dictionaries prefer explicit keys over positional assumptions.
- Progress payloads use normalized `0.0 .. 1.0` semantics plus stable status text.
- Official format support wording stays exactly `.png`, `.ogv`, `.glb`, `.compressed.ply`.
- Environment transform configs apply to environment content placement, never to the camera.
- The settings repo emits recommendation events; consumer repos own if/when they act on them.
- Testbed scenes should expose enough live state to prove contracts visually.
- Repos should remain reusable tools first, not hidden app-specific integrations.

---

## Parallel Execution Lanes

### Lane 0: Contract Lock Pass

**Bead ID:** `aerobeat-assembly-community-5yo`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Freeze the minimum shared contracts across the three tool repos before implementation diverges: performance events/payloads, environment request/result/error/progress shapes, workout-YAML convenience boundary, and camera tuning/runtime API. Update this coordination plan and the repo-local plans with the same agreed shapes.

**Folders Created/Deleted/Modified:**
- Coordination + repo-local plan files only

**Files Created/Deleted/Modified:**
- `.plans/*.md` across participating repos

**Status:** ✅ Complete

**Results:** Claimed bead `aerobeat-assembly-community-5yo`, reviewed the umbrella and the three repo-local lane plans, and froze the shared contracts for settings recommendation events, environment request/result/error/progress semantics, workout-YAML translation scope, official format support wording, environment-content transform semantics, and camera-control runtime/profile JSON. The repo-local plans listed below were updated to match these shapes so the three coder lanes can start in parallel without re-opening the contract discussion.

---

### Lane 1: `aerobeat-tool-settings`

**Bead ID:** `aerobeat-tool-settings-gth`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-02`, `REF-03`  
**Prompt:** Execute the repo-local implementation plan in `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/.plans/2026-05-15-performance-classifier-first-slice.md`. Build the singleton contract in `/src/`, the hidden `.testbed/` diagnostic scene, and repo-local validation. Keep the work Lego-piece-only and aligned to the shared contract lock.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/src/`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings/.testbed/`

**Files Created/Deleted/Modified:**
- runtime/testbed/test files per repo-local plan

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Lane 2: `aerobeat-environment-loader`

**Bead ID:** `aerobeat-environment-loader-0qw`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-04`, `REF-06`, `REF-07`  
**Prompt:** Implement the environment tool as a generic loader plus AeroBeat workout-YAML convenience consumer. Build request/result/error/progress contracts, separate GLB vs splat sidecar config handling, and the hidden `.testbed/` proving scene for `.png`, `.ogv`, `.glb`, and `.compressed.ply`. Reuse/adapt splat loading progress semantics from the Gaussian splat integration path where practical.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader/src/`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader/.testbed/`

**Files Created/Deleted/Modified:**
- runtime/testbed/test files per repo-local plan

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Lane 3: `aerobeat-tool-camera-gesture-control`

**Bead ID:** `aerobeat-tool-camera-gesture-control-4t7`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-05`, `REF-08`, `REF-09`  
**Prompt:** Implement the camera gesture control tool as a contract-driven camera controller, not a MediaPipe-specific tracker. Build the runtime controller in `/src/`, the hidden `.testbed/` scene that depends on `aerobeat-input-mediapipe-python` via GodotEnv, the gesture-vs-mouse/WASD comparison UI, and JSON-backed tunables exposed via the left panel.

**Folders Created/Deleted/Modified:**
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-camera-gesture-control/src/`
- `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-camera-gesture-control/.testbed/`

**Files Created/Deleted/Modified:**
- runtime/testbed/test files per repo-local plan

**Status:** ⏳ Pending

**Results:** Pending execution.

---

### Lane 4: Cross-Repo Consistency Audit

**Bead ID:** `aerobeat-assembly-community-ew4`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-03`, `REF-04`, `REF-05`  
**Prompt:** After the three implementation lanes complete their local QA, audit the cross-repo contracts for naming consistency, payload compatibility, progress/status clarity, and testbed truthfulness. Confirm the three Lego pieces fit together conceptually without requiring immediate consumer integration.

**Folders Created/Deleted/Modified:**
- Coordination + repo-local plans only

**Files Created/Deleted/Modified:**
- `.plans/*.md` as needed for final audit notes

**Status:** ⏳ Pending

**Results:** Pending execution.

---

## Recommended Repo-Local Plan Set

This umbrella coordination plan is paired with:
- `aerobeat-tool-settings/.plans/2026-05-15-performance-classifier-first-slice.md`
- `aerobeat-environment-loader/.plans/2026-05-15-environment-tool-first-implementation-lane.md`
- `aerobeat-tool-camera-gesture-control/.plans/2026-05-15-camera-gesture-control-first-implementation-lane.md`

Those repo-local plans should own the concrete file-level implementation steps, while this coordination plan owns the shared order and contract checkpoints.

---

## Suggested Execution Order

1. Contract Lock A/B/C pass
2. Spawn three coder lanes in parallel
3. Run repo-local QA in each repo
4. Run cross-repo audit for contract consistency
5. Report implementation readiness and choose the first consumer later

---

## Risks To Watch

- `tool-environment` becoming too app-specific too early
- `tool-camera-gesture-control` re-implementing MediaPipe plumbing instead of consuming the contract boundary
- `tool-settings` expanding into a general settings repo instead of staying focused on performance recommendation
- progress payloads drifting across repos
- sidecar config names diverging between GLB and splat handling in awkward ways

---

## Locked Filename Convention Note


- sidecar filename convention preference: basename-style config naming (for example `my_scene.json` beside `my_scene.glb`) rather than extension-appended variants like `my_scene.glb.json`

## Final Results

**Status:** ⚠️ Partial

**What We Built:** The umbrella coordination plan plus a completed contract-lock pass for the three tool lanes. The shared settings, environment, and camera-control contracts are now frozen tightly enough for repo-local coding to proceed in parallel.

**Reference Check:** Aligned to `REF-01` through `REF-09`, with wording normalized across the repo-local plans for official format support, environment-content transforms, progress semantics, settings recommendation events, downgrade thresholds, and camera-control modes/tunables.

**Commits:**
- Pending commit

**Lessons Learned:** Parallel repo work is safe when the connector contracts are locked first, especially around event payloads, async progress semantics, and JSON-backed runtime tuning surfaces.

---

*Completed on 2026-05-15*
