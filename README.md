# AeroBeat Assembly Community

This repo is the **active PC community assembly app** for AeroBeat's current v1 product slice.

An **Assembly** is the top-level Godot project that composes the concrete AeroBeat addons needed to produce a runnable game client.

## Current product truth

This assembly should be read against the locked `aerobeat-docs` v1 scope:

- **official v1 gameplay:** Boxing and Flow
- **official v1 gameplay input:** camera only
- **primary release target:** PC community first
- **non-camera gameplay inputs:** future work, not current parity promises
- **mouse/touch:** valid for UI navigation, not gameplay parity claims

## Repository details

- **Type:** Assembly (Game Client)
- **License:** **GNU GPLv3** (Strict Copyleft)
- **Primary dependency contract:** `addons.jsonc` at repo root
- **Current concrete dependencies:**
  - `aerobeat-input-core` pinned at `v0.1.2`, installed at addon key/path `aerobeat-input-core`
  - `aerobeat-input-mediapipe-python`, installed through the compatibility addon directory key `aerobeat-input-mediapipe`
  - `openclaw` installed from the upstream Godot addon subtree for local tooling/runtime integration
  - `gut` for repo-local validation

## Runtime truth

This assembly currently boots the **camera-first MediaPipe Python path**. It does **not** claim equal-status keyboard, gamepad, JoyCon, touch, mouse, or XR gameplay support.

The MediaPipe Python sidecar remains a separate runtime concern from the Godot addon manifest:

- `addons.jsonc` restores the Godot addon/plugin dependency layout
- Python + MediaPipe runtime dependencies still need to exist wherever the assembly is run
- build/distribution scripts in this repo are specifically about packaging that camera-sidecar runtime for PC community experimentation and proofing

## GodotEnv assembly flow

Assembly repos use a **root** `addons.jsonc` manifest instead of the package-repo `.testbed/addons.jsonc` convention.

- Canonical runtime/dev manifest: `addons.jsonc`
- Installed addons: `addons/`
- GodotEnv cache: `.addons/`
- Repo-local tests: `tests/`

The repo root is the real runnable project. Restore dependencies into `addons/`, then open/import/test the root project directly.

### Restore dependencies

From the repo root:

```bash
./scripts/restore-addons.sh
```

This repo's repeatable restore flow intentionally clears the generated `addons/`
and `.addons/` install targets before reacquiring them from `addons.jsonc`.
That is necessary because the current upstream addon set still contains missing
Godot 4.4-generated `.uid` files (reproduced here under
`aerobeat-input-mediapipe` and `openclaw`), so rerunning raw
`godotenv addons install` after import/test runs can abort on dirty installed
addon trees.

### Open the assembly

From the repo root:

```bash
godot --editor --path .
```

### Import smoke check

From the repo root:

```bash
godot --headless --path . --import
```

### Run tests

From the repo root:

```bash
godot --headless --path . --script addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gexit
```

## Compatibility note: current MediaPipe install key

One compatibility edge is still explicit in this repo:

- the assembly code currently loads the addon from `res://addons/aerobeat-input-mediapipe/`
- the owning repo still lives at `aerobeat-input-mediapipe-python`
- the manifest therefore installs that repo through the compatibility directory key `aerobeat-input-mediapipe`

That is current repo truth, not a claim that the dependency contract is fully normalized yet.

## Validation notes

- `addons.jsonc` is the committed assembly dependency contract.
- the assembly now mounts its input foundation at `res://addons/aerobeat-input-core/`
- that input-core addon path is sourced from `git@github.com:AeroBeat-Workouts/aerobeat-input-core.git` pinned to `v0.1.2`
- `aerobeat-input-mediapipe-python` is the official gameplay-input dependency for this assembly today
- `openclaw` is intentionally installed from its addon subtree so the project receives `res://addons/openclaw/` instead of the repo root helper/tooling folders
- `addons/` is a generated install target and must not be committed
- repo-local tests live under `tests/` and run against the root assembly project

## Structure

- `addons.jsonc` - Root GodotEnv assembly manifest
- `project.godot` - Runnable AeroBeat assembly project
- `src/` - Assembly-specific game/runtime logic
- `scenes/` - Root scenes for the assembly app
- `tests/` - Repo-local GUT and integration tests
- `build-scripts/` - PC bundle/build experiments for the camera-first assembly runtime
- `docs/` - Repo-local technical notes for build/distribution work
