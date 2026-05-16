# AeroBeat Assembly Community

**Date:** 2026-05-15  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Plan a staged AeroBeat environment fallback system where assembly-community can show one logical default environment in three quality tiers — high (`splat`), medium (`video`), and low (`image`) — chosen by device capability and runtime performance, with supporting reusable tool repos for performance classification, environment presentation, and camera-gesture validation.

---

## Overview

The cleanest AeroBeat-native path is to build this feature as three reusable tools and one assembly integration pass rather than burying the whole design directly inside `aerobeat-assembly-community`. Existing AeroBeat repos already establish a strong pattern: runtime/package code lives in root `src/`, each package repo develops inside a hidden `.testbed/` Godot workbench restored by GodotEnv, public contracts are event-first and honest about scope, and sidecar asset/config workflows prefer simple sibling JSON files located beside the chosen asset.

From repo inspection, the environment lane already has a useful truth surface: `aerobeat-environment-community` proves image/video/GLB/splat preview scenes separately, uses left-panel config editing with JSON save/load for 3D assets, and recommends `.compressed.ply` as the official splat format even though the underlying GDGS wrapper remains compatibility-capable. The input lane already has a useful truth surface too: `aerobeat-input-core` defines stable intent-first contracts, `InputManager` prefers event relays over raw-pose consumers, and `aerobeat-input-mediapipe-python` uses proving scenes with rich status/metric/event panels rather than minimal demos.

Based on those patterns, the recommended MVP is:
1. add a default-environment performance classifier singleton plus diagnostic testbed to `aerobeat-tool-settings`
2. create `aerobeat-environment-loader` as the stable image/video/GLB/splat environment wrapper with a single demo scene and sibling asset JSON contracts
3. wire those into `aerobeat-assembly-community` so startup immediately picks and loads the default tier behind a logo/intermediate scene
4. create `aerobeat-tool-camera-gesture-control` as a separate contract-driven gesture-parallax/testbed tool
5. keep richer workout fallback authoring and UX flows explicitly post-v1

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Assembly app that will consume the fallback/default environment system | `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community` |
| `REF-02` | Environment source repo for canonical image/video/GLB/splat samples | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-community` |
| `REF-03` | Existing settings tool repo where the performance classifier singleton should live | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings` |
| `REF-04` | Existing input contract repo that defines the camera-control-facing contract boundary | `/home/derrick/Documents/projects/aerobeat/aerobeat-input-core` |
| `REF-05` | Existing MediaPipe Python repo that the camera-gesture-control testbed should use via GodotEnv | `/home/derrick/Documents/projects/aerobeat/aerobeat-input-mediapipe-python` |
| `REF-06` | Existing Gaussian splat tool repo / GDGS integration path relevant to splat support | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-gaussian-splat` |
| `REF-07` | New reusable camera gesture control repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-camera-gesture-control` |
| `REF-08` | New reusable environment loading/swapping repo | `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader` |

---

## Canonical Repo / Testbed Conventions

### Package boundary conventions

From `REF-03` through `REF-08`, the common AeroBeat tool pattern is now clear:

- repo root is the published package boundary
- reusable runtime code lives under root `src/`
- `plugin.cfg` points consumers at repo-root package identity
- tool repos commonly expose `class_name AeroToolManager` as the singleton/autoload-facing entrypoint, even if the real implementation later fans out into more specific manager/service scripts
- repo-local validation lives in hidden `.testbed/` projects instead of turning the package root into the day-to-day editor workbench
- `.testbed/tests/` is the automated test home
- `.testbed/scenes/` and `.testbed/scripts/` are the manual proving/workbench surface

### GodotEnv dependency conventions

Tool repos keep `.testbed/addons.jsonc` intentionally narrow:

- include only the concrete adjacent repos the tool actually needs
- prefer SSH Git remotes or truthful sibling symlink sources
- include `gut` for repo-local tests
- avoid reviving universal `aerobeat-core` style dependency sprawl when not needed

Recommended manifests for this work:

- `aerobeat-tool-settings`: keep current narrow pattern; add only what the classifier testbed really needs
- `aerobeat-tool-camera-gesture-control`: self + `aerobeat-input-core` + `aerobeat-input-mediapipe-python` + `gut`
- `aerobeat-environment-loader`: self + `aerobeat-environment-gaussian-splat` + `gdgs` vendor pin if needed transitively + `gut`; optionally `aerobeat-asset-core` if environment metadata DTOs are formalized there

### UI / proving conventions

The strongest current testbed patterns to mirror are:

- left-panel controls + main preview area (`REF-02`)
- direct status text explaining what is supported vs merely compatibility-capable (`REF-02`, `REF-06`)
- save/load JSON beside the selected asset (`REF-02`)
- richer event/metrics panels rather than opaque demos (`REF-05`)
- scene-rooted file pickers targeting the canonical asset folder for that format (`REF-02`)
- cover/contain behavior for 2D assets implemented using `TextureRect.STRETCH_KEEP_ASPECT_*` (`REF-02`)

### Contract / event conventions

AeroBeat input-side contracts already prefer:

- explicit named signals over ambiguous raw dictionaries
- stable, readable payload fields
- start/end event pairs for stateful transitions
- optional richer observations exposed separately from the primary gameplay-facing contract

The new tool APIs should follow the same philosophy:

- simple direct methods for commands
- explicit recommendation / failure / changed signals
- dictionaries for debug/detail payloads only when a rigid typed Godot signal surface would become noisy

---

## Proposed Runtime Designs

### 1) `aerobeat-tool-settings` — default environment performance classifier

**Repo shape**

- `src/AeroToolManager.gd` remains the public autoload-facing entrypoint
- add `src/default_environment_performance_classifier.gd`
- add helper files only if needed, for example:
  - `src/performance_sampling_window.gd`
  - `src/device_capability_snapshot.gd`
  - `src/default_environment_recommendation.gd`
- add diagnostic workbench scene and scripts under `.testbed/scenes/` and `.testbed/scripts/`

**Scope**

This singleton is specifically for **default environment tier recommendation**. It is not a general game-wide graphics quality system in v1.

**Two-phase model**

#### Phase A — static device/context snapshot

Cheap contextual signals gathered for explanation and future policy tuning:

- OS/platform class: desktop/mobile/web/XR
- renderer/backend when available
- GPU/renderer string when available
- display resolution bucket
- optional refresh-rate bucket if cheaply available

In MVP, these signals should **inform** the recommendation but not hard-gate the initial shell/background asset before measurement. They are best treated as supporting evidence rather than the sole decision-maker.

#### Phase B — live performance confirmation

Runtime signals gathered **after** the environment is loaded at startup or after a workout environment loads:

- rolling FPS average
- rolling frame-time average
- worst-frame spike tracker
- warm-up window duration
- sustained low-performance timer (`<30 FPS average for 3 seconds`)

**Public API proposal**

```gdscript
class_name DefaultEnvironmentPerformanceClassifier
extends Node

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

For the shared first pass, other repos should only depend on `recommendation_updated(result)` and `downgrade_recommended(event)`. Extra local signals can exist later, but they are not part of the frozen cross-repo contract.

**Recommendation shape**

```json
{
  "tier": "high | medium | low",
  "confidence": "high | medium | low",
  "recommended_environment_profile": "high | medium | low",
  "startup_estimate": "high | medium | low",
  "live_confirmed": true,
  "signals": {
    "platform": "linux",
    "renderer_name": "...",
    "resolution": [1920, 1080],
    "resolution_bucket": "1080p",
    "rolling_fps": 58.7,
    "rolling_frame_time_ms": 17.0,
    "low_fps_duration_ms": 0
  },
  "reasons": [
    "Desktop renderer detected.",
    "Runtime average FPS stayed above medium/high thresholds during warm-up."
  ]
}
```

**Recommended signals/events**

- `recommendation_updated(result)` — emitted when current recommended tier changes
- `downgrade_recommended(event)` — emitted when sustained low-performance policy trips

`downgrade_recommended` payload:

```json
{
  "from_tier": "high",
  "to_tier": "medium",
  "reason": "sustained_low_fps",
  "threshold_fps": 30.0,
  "threshold_duration_ms": 3000,
  "observed_average_fps": 24.6,
  "sample_window_ms": 3000
}
```

**Testbed expectations**

Diagnostic scene should show:

- startup signals panel
- live sampling panel
- current recommendation + confidence
- human-readable reasons list
- rolling FPS / frame-time labels
- event log for recommendation updates and downgrades
- manual override toggles to simulate weak/medium/strong device classes without spoofing the whole OS

Validation should prove:

- startup environment loads first, then measurement/recommendation runs against the active environment
- emitted recommendations reflect measured behavior rather than only a pre-load guess
- sustained `<30 FPS average for 3 seconds` produces a downgrade recommendation event
- no oscillating repeated downgrade spam once already at `low`

### 2) `aerobeat-tool-camera-gesture-control` — contract-driven gesture parallax/controller tool

**Repo sync status**

Cloned locally from SSH and currently still at template baseline.

**Repo shape**

- `src/AeroToolManager.gd` as public entrypoint
- add `src/camera_gesture_control_manager.gd`
- add `src/camera_gesture_profile.gd` or equivalent constants/config helper
- optionally add `src/contracts/` only if a local DTO layer makes the tuning payloads cleaner

**Purpose**

This repo should transform input-core-compatible tracking/gesture data into **camera-control intent** for environment/testbed use. It should not embed MediaPipe-specific process ownership in runtime code; MediaPipe belongs behind `aerobeat-input-core`/provider wiring, with MediaPipe used in the `.testbed/` proving path via GodotEnv.

**Contract stance**

- runtime code consumes an `AeroInputProvider` / `InputManager` style surface from `REF-04`
- testbed proves the path using `aerobeat-input-mediapipe-python` from `REF-05`
- camera-gesture tool should not require direct knowledge of MediaPipe subprocesses, HTTP streams, or Python runtime prep

**Public API proposal**

```gdscript
class_name CameraGestureControlManager
extends Node

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

**Recommended profile JSON contract**

```json
{
  "version": 1,
  "mode": "gesture",
  "head_tracking_enabled": true,
  "hand_tracking_enabled": false,
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
  "sample_source": "head_position"
}
```

**Input expectations**

For MVP, consume only data already natural to `AeroInputProvider`:

- head position
- optional hand position
- tracking confidence
- tracking lost/restored lifecycle

Do **not** make boxing/flow gesture events the primary parallax driver. Use pose/head motion for camera movement, with gesture events only optional for later toggles or recenter actions.

**Recommended events**

`tracking_state_changed(state)` payload:

```json
{
  "mode": "gesture",
  "tracking": true,
  "confidence": 0.88,
  "normalized_input": {"x": 0.12, "y": -0.04, "z": 0.08},
  "applied_rotation_degrees": {"yaw": 4.8, "pitch": -1.2, "roll": 0.0},
  "applied_translation": {"x": 0.07, "y": -0.01, "z": 0.03}
}
```

**Testbed expectations**

The `.testbed/` scene should visibly compare:

- `gesture` mode
- `mouse_wasd` mode

and provide a left-side control panel with:

- mode switch
- tracking source switch if more than one source becomes available
- sensitivity sliders
- deadzone slider
- smoothing slider
- max yaw/pitch/roll sliders
- max translation sliders
- invert toggles
- recenter button
- save JSON / load JSON buttons
- live debug labels for confidence, normalized input, and applied transform

**Sample environment for testbed**

Use a simple GLB or sample splat environment from `REF-02` so the parallax motion is visible against clear depth cues.

### 3) `aerobeat-environment-loader` — unified environment wrapper

**Repo sync status**

Cloned locally from SSH and currently still at template baseline.

**Repo shape**

- `src/AeroToolManager.gd` remains autoload-facing entrypoint
- add `src/environment_manager.gd`
- add internal helpers as needed:
  - `src/environment_contracts.gd`
  - `src/environment_loader_2d.gd`
  - `src/environment_loader_3d.gd`
  - `src/environment_presenter_cover.gd`

**Purpose**

Provide one AeroBeat-facing API for loading, showing, swapping, and tearing down default or workout environments across:

- image
- video
- GLB
- splat (`.compressed.ply` officially)

**Official format stance**

- splat compatibility may remain wider internally because `REF-06` supports `.ply`, `.compressed.ply`, `.splat`, `.sog`
- AeroBeat official authored/runtime recommendation remains **`.compressed.ply` only** for splats

**Public API proposal**

```gdscript
class_name EnvironmentManager
extends Node

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

**Request contract**

```json
{
  "environment_id": "default-high",
  "tier": "high",
  "kind": "splat",
  "asset_path": "/absolute/or/res/path/demo.compressed.ply",
  "config_path": "/absolute/or/res/path/demo.splat.json",
  "display_mode": "cover",
  "context": "default_shell"
}
```

**2D behavior**

For image/video:

- default MVP behavior should be `cover`
- implementation should mirror the existing `REF-02` image/video scenes using `TextureRect.STRETCH_KEEP_ASPECT_COVERED`
- keep `contain` in the tool for testbed/debug parity, but assembly startup should use `cover`
- video support should stay honest about current Godot/asset truth; if the environment catalog currently standardizes `.ogv`, do not casually overpromise `.mp4` runtime parity in the roadmap

**3D behavior**

For GLB and splat:

- load into a dedicated display root
- apply transform from sibling JSON contract
- use `AeroGaussianSplatManager` from `REF-06` for splats rather than talking to GDGS directly
- configure `WorldEnvironment` compositor for splat displays as needed

**Separate sibling JSON contracts**

Reuse the established `center/scale/rotation` baseline from `REF-02`, but split the filenames/contracts by type.

#### GLB config (`<asset>.glb.json` or `<asset>.json` if final naming stays basename-based)

```json
{
  "version": 1,
  "kind": "glb",
  "center": [0.0, 0.0, 0.0],
  "scale": [1.0, 1.0, 1.0],
  "rotation": [0.0, 0.0, 0.0]
}
```

#### Splat config (`<asset>.splat.json` recommended)

```json
{
  "version": 1,
  "kind": "splat",
  "center": [0.0, 0.0, 0.0],
  "scale": [1.0, 1.0, 1.0],
  "rotation": [0.0, 0.0, 0.0],
  "camera_anchor": [0.0, 0.0, 0.0],
  "recommended_camera_distance": 4.0,
  "allow_gesture_parallax": true
}
```

The extra splat fields are exactly why separate sibling contracts are worth it.

**Loaded-state result contract**

```json
{
  "ok": true,
  "environment_id": "default-high",
  "tier": "high",
  "kind": "splat",
  "asset_path": "...",
  "config_path": "...",
  "node": "runtime node ref omitted from logs",
  "metadata": {
    "format": "compressed.ply",
    "point_count": 123456
  }
}
```

**Recommended failure payload**

```json
{
  "environment_id": "workout-forest-01",
  "tier": "high",
  "kind": "splat",
  "asset_path": "...",
  "reason": "load_failed",
  "message": "Splat file does not exist: ...",
  "recoverable": true
}
```

**Testbed expectations**

One unified scene should exercise four sample loads from `REF-02`:

- one sample image
- one sample canonical `.ogv` video
- one sample GLB
- one sample `.compressed.ply` splat (or the nearest current sample, with plan note that catalog assets should normalize toward `.compressed.ply`)

UI should include:

- left panel with four format buttons/dropdowns
- current asset path label
- cover/contain selector for 2D formats
- transform editors for 3D formats
- save/load config buttons for GLB and splat contracts
- status label + debug info for load results

---



**Additional environment-tool recommendation**

- keep the core manager generic
- add a convenience path for AeroBeat workout-environment YAML ingestion via content-core
- expose `environment_load_progress(progress)` so consumers can show normalized percent + status during heavy loads
- progress payload should prefer a normalized shape like:

```json
{
  "status": "resolving | loading | decoding | instantiating | ready",
  "progress": 0.42,
  "message": "Loading splat asset..."
}
```

For splats, prefer reusing/adapting the progress semantics already exposed by the Gaussian splat integration path instead of inventing a conflicting progress language.

## Assembly Integration Design (`aerobeat-assembly-community`)

### Startup ladder

Assembly should own the orchestration, not the tools.

Recommended startup flow:

1. boot into new `logo_or_bootstrap` scene instead of directly into the current proof-style main shell
2. instantiate the environment manager and load the chosen startup default environment while the bootstrap/logo scene is visible
3. once the environment is loaded, instantiate or activate the settings classifier singleton
4. capture static device/context signals and begin live sampling against the active environment
5. emit a recommendation-detection event when the classifier has enough evidence to recommend `high`, `medium`, or `low`
6. transition into the main shell scene with the active environment already displayed and the recommendation available to consumers

This keeps startup masking aligned with Derrick’s approved direction and makes startup detection recommendation-based rather than a hidden pre-load gate.

### Recommended assembly-owned configuration

Add a simple default environment ladder config owned by the assembly repo, for example under:

- `res://config/default_environment_ladder.json`

Suggested shape:

```json
{
  "version": 1,
  "default_environment_id": "community-default",
  "auto_apply_mode": "auto",
  "tiers": {
    "high": {
      "kind": "splat",
      "asset_path": "res://assets/environments/default/demo.compressed.ply",
      "config_path": "res://assets/environments/default/demo.splat.json"
    },
    "medium": {
      "kind": "video",
      "asset_path": "res://assets/environments/default/calm_blue_sea_1.ogv",
      "display_mode": "cover"
    },
    "low": {
      "kind": "image",
      "asset_path": "res://assets/environments/default/perfect-hue-may-14-2026.png",
      "display_mode": "cover"
    }
  }
}
```

### Workout environment recovery rules (MVP)

Approved MVP policy:

- if direct workout environment load errors, return to the default environment immediately
- if workout environment average FPS stays below `30` for `3 seconds`, emit a recommendation event to move down one rung:
  - `high -> medium`
  - `medium -> low`
- do not silently auto-author or auto-generate workout fallback derivatives in v1
- do not implement aggressive live oscillating auto-swaps in v1

### Recommended assembly-level events

- `default_environment_tier_selected(result)`
- `default_environment_ready(result)`
- `workout_environment_load_failed(error)`
- `workout_environment_fallback_applied(result)`
- `workout_environment_downgrade_recommended(event)`

These can be assembly-local signals or event-bus messages, but they should stay assembly-owned because they represent product policy, not reusable tool internals.

### Minimal scene changes

Current assembly is still proof-oriented (`scenes/main.tscn`, `mediapipe_*` scenes). For MVP planning, add:

- `scenes/bootstrap_environment.tscn`
- `src/bootstrap_environment.gd`
- one assembly shell node that owns the environment manager child/display root

Keep the current MediaPipe proof/control scenes intact; do not entangle the fallback ladder with close-crash proofing surfaces.

---

## Testbed / Validation Expectations

### `aerobeat-tool-settings`

Validate:

- startup detection runs after the startup environment is loaded
- live sampling updates recommendation state and emits recommendation events
- downgrade event fires after sustained low FPS threshold
- diagnostic scene clearly explains *why* the current tier was chosen

### `aerobeat-tool-camera-gesture-control`

Validate:

- MediaPipe path can drive camera motion through input-core-compatible attachment
- mouse+WASD comparison mode exists in same scene
- tuning panel values round-trip through JSON save/load
- control clamps prevent disorienting camera motion
- tracking loss cleanly recenters or freezes according to chosen policy

### `aerobeat-environment-loader`

Validate:

- image `cover` fills screen without letterboxing
- video `cover` mirrors the same behavior while remaining honest about actual video backend support
- GLB load/save/load config round-trips
- splat load/save/load config round-trips
- load failures produce structured errors rather than partial scene corruption

### `aerobeat-assembly-community`

Validate:

- startup bootstrap scene hides startup environment loading and post-load performance detection
- classifier emits a recommendation event for the active startup environment after measurement
- direct workout env failure returns to default environment
- sustained low-performance in workout env emits recommendation event with next rung

---

## MVP-First Implementation Order

1. **`aerobeat-tool-settings` classifier + diagnostic testbed**
   - lowest dependency risk
   - produces the tier recommendation API assembly will depend on

2. **`aerobeat-environment-loader` unified manager + sample testbed**
   - proves the actual high/medium/low environment rung behavior in isolation
   - formalizes the sibling JSON contracts before assembly depends on them

3. **`aerobeat-assembly-community` bootstrap integration**
   - consumes both tools
   - implements startup environment loading, post-load recommendation detection, and workout failure recovery policy

4. **`aerobeat-tool-camera-gesture-control`**
   - independent but adjacent work
   - uses environment assets/testbeds to validate parallax/control feel without blocking the core fallback ladder MVP

### Validation order

1. settings testbed truth
2. environment testbed truth
3. assembly startup ladder truth
4. assembly workout recovery truth
5. gesture-control tuning truth

---

## Post-v1 / Explicit Non-MVP Scope

These items should stay documented but not block MVP:

- automatic generation of workout fallback 2D derivatives from uploaded/custom workout environments
- richer in-product UI for warning, explaining, and accepting downgrade recommendations
- persistent user override setting for `auto/high/medium/low`
- automatic live shell environment up/down re-swapping beyond recommendation events
- gesture-parallax polish such as per-environment authored motion envelopes, roll effects, depth-aware parallax weighting, and authored recenter anchors
- generalized cross-platform graphics quality framework beyond default environment tier selection

---

## Tasks

### Task 1: Inspect current repo patterns for new AeroBeat tool repos and testbeds

**Bead ID:** `aerobeat-assembly-community-ayc`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** Inspect the existing AeroBeat tool/input repos to capture the canonical structure for `/src/` runtime code, `.testbed/` projects, GodotEnv dependencies, event patterns, and sibling JSON config/test patterns. Summarize the conventions the two new repos and the tool-settings singleton should follow so they feel native to the existing AeroBeat ecosystem.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-default-environment-fallback-ladder.md`

**Status:** ✅ Complete

**Results:** Both new repos were synced locally via SSH. Repo inspection established the canonical package/testbed pattern used throughout this plan: root `src/`, hidden `.testbed/`, narrow GodotEnv manifests, event-first public APIs, `AeroToolManager` entrypoints, left-panel proving UIs, and sibling JSON save/load patterns for 3D asset configs. Validated against `REF-03` through `REF-08`.

---

### Task 2: Plan the `aerobeat-tool-settings` performance classifier singleton + diagnostic testbed

**Bead ID:** `aerobeat-assembly-community-ywj`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-03`, `REF-01`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-settings`, inspect the repo and design a new singleton in `/src/` that reads device/performance signals and classifies the device as `high`, `medium`, or `low` for default-environment selection. Define the signal sources, recommendation rules, public API, emitted events, and the `.testbed/` scene/dashboard that should visualize the collected signals, current recommendation, and any downgrade recommendations for the current device.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-default-environment-fallback-ladder.md`

**Status:** ✅ Complete

**Results:** Planned a two-phase classifier in `REF-03`: static device/context snapshot plus live performance confirmation after environment load. Locked the recommendation shape, downgrade event payload, sampling rules, and diagnostic testbed requirements. Aligned to Derrick’s approved post-load recommendation-event flow and `<30 FPS for 3 seconds` downgrade trigger.

---

### Task 3: Plan the new `aerobeat-tool-camera-gesture-control` repo and contract-driven camera testbed

**Bead ID:** `aerobeat-assembly-community-2jh`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-04`, `REF-05`, `REF-07`  
**Prompt:** Plan the new `/home/derrick/Documents/projects/aerobeat/aerobeat-tool-camera-gesture-control` repo. Define the runtime `/src/` API, how it consumes an input-core contract instead of embedding MediaPipe-specific logic, how the `.testbed/` project should depend on `aerobeat-input-mediapipe-python` via GodotEnv, how the comparison UI should switch between camera gesture control and mouse+WASD, and how multiple range/speed/tuning variables should be exposed as UI sliders/toggles and saved/loaded as key/value JSON.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-default-environment-fallback-ladder.md`

**Status:** ✅ Complete

**Results:** Planned the repo as an input-core-driven camera-control adapter rather than a MediaPipe-specific runtime. Locked the public API, recommended profile JSON contract, UI expectations for gesture-vs-mouse/WASD comparison, and the testbed dependency path through `REF-05` via GodotEnv.

---

### Task 4: Plan the new `aerobeat-environment-loader` repo and multi-format environment singleton

**Bead ID:** `aerobeat-assembly-community-nbl`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-02`, `REF-06`, `REF-08`, `REF-09`  
**Prompt:** Plan the new `/home/derrick/Documents/projects/aerobeat/aerobeat-environment-loader` repo. Define the runtime singleton in `/src/` for loading/swapping AeroBeat-supported `.png`, `.ogv`, `.glb`, and `.compressed.ply` environments; specify full-screen image/video behavior (cover without letterboxing); define separate sibling config contracts for GLB and splat environment transforms/config; decide how the repo should remain generic while also conveniently ingesting AeroBeat workout-environment YAML/metadata through the content-core contract path; include progress/status reporting for long loads; and design the `.testbed/` scene with one sample image, video, GLB, and splat pulled from `aerobeat-environment-community`.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-default-environment-fallback-ladder.md`

**Status:** ✅ Complete

**Results:** Planned the unified environment manager, request/result/error contracts, 2D cover behavior, GDGS-wrapper routing for splats, and separate GLB vs splat sidecar JSON contracts. The testbed design intentionally mirrors `REF-02` proving patterns while consolidating them into one reusable repo.

---

### Task 5: Record future assembly-community consumption notes without making it a near-term implementation focus

**Bead ID:** `aerobeat-assembly-community-c4h`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-08`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-assembly-community`, record only the minimum future-consumer notes needed so the Lego-piece repos expose the right events/contracts for later use. Do not optimize around immediate assembly integration. Capture the future workout-environment recovery hooks at a policy level: direct environment load errors should return to the default environment, and sustained low performance (below 30 FPS average for 3 seconds) should emit a recommendation event to swap profile to `medium` or `low`. Keep later UI warning flows and automatic workout fallback asset generation documented as post-v1 work.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-default-environment-fallback-ladder.md`

**Status:** ✅ Complete

**Results:** Planned a bootstrap/logo scene that loads the startup environment first, then runs detection and emits recommendation events from the measured result, plus an assembly-owned ladder config and workout recovery event policy. Kept current MediaPipe proof scenes separate from the new startup ladder surface.

---

### Task 6: Produce an MVP-first execution roadmap across repos

**Bead ID:** `aerobeat-assembly-community-64y`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-03`, `REF-07`, `REF-08`  
**Prompt:** Turn the planning outputs into a concrete implementation roadmap with repo boundaries, recommended creation order, validation order, and MVP vs phase-2 separation. The roadmap should treat the shell/default environment ladder as MVP, include workout load-error recovery and performance recommendation events, and clearly mark later expansion such as workout-specific fallback asset generation and refined gesture-parallax polish.

**Folders Created/Deleted/Modified:**
- Planning/docs only expected

**Files Created/Deleted/Modified:**
- `.plans/2026-05-15-default-environment-fallback-ladder.md`

**Status:** ✅ Complete

**Results:** Produced a repo-by-repo MVP-first roadmap, explicit validation order, and a clean post-v1 boundary. The plan is now consistent enough to serve as the implementation handoff for coding passes.

---

## Internal Consistency Check

I checked the roadmap against the inspected repo truths and Derrick’s approved constraints:

- `.compressed.ply` is treated as the official splat target while preserving wrapper-level compatibility truth from `REF-06`
- environment-side transform configs are explicitly for environment content placement, not the camera
- camera control mode naming is frozen as `gesture`, `mouse_wasd`, and `disabled`
- the performance classifier stays in `aerobeat-tool-settings/src/`
- startup auto-apply is handled in assembly behind a bootstrap/logo scene
- workout load failure returns to default environment
- sustained `<30 FPS average for 3 seconds` emits a downgrade recommendation event
- camera gesture testbed uses `aerobeat-input-mediapipe-python` via GodotEnv and input-core contract boundaries
- environment tool uses separate GLB and splat JSON contracts
- workout fallback asset generation and richer UI handling remain post-v1

Design fork resolved: for the default shell/background and for workout environments, run performance detection **after** the environment loads and emit recommendation events from the measured result. My recommendation remains that MVP should prefer recommendation events over surprise live swaps.

---

## Locked Filename Convention Note


- sidecar filename convention preference: basename-style config naming (for example `my_scene.json` beside `my_scene.glb`) rather than extension-appended variants like `my_scene.glb.json`

## Final Results

**Status:** ✅ Complete

**What We Built:** A concrete implementation roadmap for the default environment fallback ladder across `aerobeat-tool-settings`, `aerobeat-environment-loader`, `aerobeat-tool-camera-gesture-control`, and `aerobeat-assembly-community`, grounded in the actual current AeroBeat repo conventions and testbed patterns.

**Reference Check:** `REF-01` through `REF-08` were inspected and mapped into the proposed repo shapes, testbed structures, contracts, and integration design. No implementation code was added; this was planning/research only.

**Commits:**
- Pending commit

**Lessons Learned:** The repo ecosystem is already opinionated enough that the right answer was to follow existing package/testbed/event conventions rather than invent a bespoke fallback architecture. The strongest reuse win is keeping product policy in the assembly and reusable load/classify/control behavior inside tool repos.

---

*Completed on 2026-05-15*
