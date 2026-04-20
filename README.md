# AeroBeat Assembly Community

This repo is the community assembly app for AeroBeat.

An **Assembly** is the top-level Godot project that composes released or in-flight AeroBeat addons into a runnable game client.

## 📋 Repository Details

*   **Type:** Assembly (Game Client)
*   **License:** **GNU GPLv3** (Strict Copyleft)
*   **Primary dependency contract:** `addons.jsonc` at repo root
*   **Current concrete dependencies:**
    *   `aerobeat-core` (Pinned foundation)
    *   `aerobeat-input-mediapipe-python` via the temporary installed-addon compatibility path `addons/aerobeat-input-mediapipe`
    *   `gut` (Repo-local test dependency)

## GodotEnv assembly flow

Assembly repos use a **root** `addons.jsonc` manifest instead of the package-repo `.testbed/addons.jsonc` convention.

- Canonical runtime/dev manifest: `addons.jsonc`
- Installed addons: `addons/`
- GodotEnv cache: `.addons/`
- Repo-local tests: `test/`

The repo root is the real runnable project. Restore dependencies into `addons/`, then open/import/test the root project directly.

### Restore dependencies

From the repo root:

```bash
godotenv addons install
```

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
  -gdir=res://test \
  -ginclude_subdirs \
  -gexit
```

## Scoped migration note: deferred `aerobeat-input-mediapipe-python`

This assembly has one intentionally scoped exception during Batch 5.

- The assembly code still expects the installed addon path `res://addons/aerobeat-input-mediapipe/`.
- The owning repo is still `aerobeat-input-mediapipe-python`, which Derrick explicitly asked to keep out of this migration wave until its own dedicated plan.
- Because that repo has not been given a dedicated release/tagging cleanup yet, this assembly manifest keeps it on `checkout: "main"` and installs it through the compatibility directory key `aerobeat-input-mediapipe`.
- That means Batch 5 migrates the assembly repo onto the root-manifest GodotEnv flow, but it does **not** claim that the MediaPipe Python dependency is already fully normalized/released.

This is deliberate and temporary, not hidden debt.

## Validation notes

- `addons.jsonc` is the committed assembly dependency contract.
- `aerobeat-core` is pinned to `v0.1.0`.
- `aerobeat-input-mediapipe-python` remains intentionally deferred and is consumed here through the compatibility install key `aerobeat-input-mediapipe` on `main` until its dedicated migration/release work exists.
- `addons/` is a generated install target and must not be committed.
- Repo-local tests live under `test/` and run against the root assembly project.

## 📂 Structure

*   `addons.jsonc` - Root GodotEnv assembly manifest.
*   `project.godot` - Runnable AeroBeat app.
*   `src/` - Assembly-specific game logic.
*   `scenes/` - Root scenes for the assembly app.
*   `test/` - Repo-local GUT and integration tests.
*   `build-scripts/` - Distribution packaging scripts.
