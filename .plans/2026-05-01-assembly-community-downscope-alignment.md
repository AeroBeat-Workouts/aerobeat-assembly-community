# aerobeat-assembly-community

**Date:** 2026-05-01  
**Status:** In Progress  
**Agent:** Chip 🐱‍💻

---

## Goal

Align `aerobeat-assembly-community` with the locked AeroBeat v1 downscope as the active PC community assembly, keeping runtime/build/docs truth explicit and committing any truthful repo cleanup already sitting locally.

---

## Overview

This repo is part of the AeroBeat input/platform downscope wave following the completed shell pass. The work stayed focused on repo-truth surfaces: README, build/distribution docs, runtime-facing launcher/build copy, and the repo-local plan/handoff.

The locked docs source says this repo should present the current product slice plainly: camera-first gameplay, Boxing + Flow as the retained official v1 gameplay set, and PC community first. That means this pass should remove transition-era “air drumming” presentation, stop implying broader gameplay-input parity, and describe the current `aerobeat-input-core`, `aerobeat-input-mediapipe-python`, and `openclaw` dependency state without pretending that all naming/compatibility work is already normalized.

The repo also already had truthful local dirt: the old root build-distribution investigation doc was deleted while a repo-local `docs/` version existed untracked. Per Derrick’s note, that cleanup belonged in the repo state and was included here.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Parent input/platform coordination plan | `/home/derrick/.openclaw/workspace/projects/openclaw-chip/.plans/2026-05-01-aerobeat-input-platform-downscope-pass.md` |
| `REF-02` | Downscoped docs source of truth | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs` |
| `REF-03` | Owning repo | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community` |
| `REF-04` | Current AeroBeat docs landing scope | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs/docs/index.md` |
| `REF-05` | Official input scope | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs/docs/architecture/input.md` |
| `REF-06` | Official concept/release framing | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs/docs/gdd/concept.md` |

---

## Tasks

### Task 1: Audit and align repo truth

**Bead ID:** `oc-rqa`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Claim the assigned bead, audit the repo against the downscoped AeroBeat docs truth, implement the required alignment changes, run relevant validation, commit/push to `main`, and leave concise QA handoff notes.

**Folders Created/Deleted/Modified:**
- `build-scripts/`
- `build-scripts/templates/`
- `docs/`
- `.plans/`
- `test/integration/`

**Files Created/Deleted/Modified:**
- `README.md`
- `build-scripts/build-linux-bundle.sh`
- `build-scripts/build-macos-bundle.sh`
- `build-scripts/build-windows-bundle.sh`
- `build-scripts/templates/run.sh`
- `build-scripts/templates/run.bat`
- `docs/build-distribution-system.md`
- `INVESTIGATION-build-distribution.md` (deleted in favor of the repo-local `docs/` copy)
- `scripts/restore-addons.sh`
- `.plans/2026-05-01-assembly-community-downscope-alignment.md`

**Status:** ✅ Complete

**Results:**
- Rewrote `README.md` so the repo now describes itself as the **active PC community assembly** for the locked v1 scope instead of using transition-era assembly/dependency prose. It now explicitly calls out: camera-only gameplay input, Boxing + Flow as the retained official gameplay set, PC community first, non-camera gameplay inputs as future work, and the current manifest/runtime truth for `aerobeat-input-core`, `aerobeat-input-mediapipe-python`, and `openclaw`. Validated against `REF-04`, `REF-05`, and `REF-06`.
- Added `docs/build-distribution-system.md` as the repo-local truthful packaging note for the active PC community assembly. Updated it so Linux is framed as the current main PC packaging path while Windows/macOS remain bundle experiments / future validation surfaces rather than equal-status release claims. Kept the older investigation doc out of the active docs path so it no longer acts like the primary repo-facing build note. Validated against `REF-04` and `REF-06`.
- Normalized runtime/build copy across the launcher/build scripts so the repo no longer presents itself as an “air drumming” app. The Linux/Windows/macOS bundle readmes, Windows metadata string, shell/batch launcher banners, and macOS camera-permission wording now describe a **camera-first Boxing and Flow community build/proof path** instead.
- Kept the existing MediaPipe compatibility-install truth explicit in repo docs rather than claiming the dependency naming has already been fully normalized.
- Added a narrow repo-local restore wrapper at `scripts/restore-addons.sh` and switched the README restore step to that script. The wrapper truthfully fixes the assembly's repeatable restore hygiene by deleting the disposable/generated `addons/` and `.addons/` trees before rerunning `godotenv addons install`. This is necessary because the current upstream addon set still reproduces Godot 4.4 `.uid` dirtiness (`aerobeat-input-mediapipe` is missing committed `src/input_provider.gd.uid`, `src/process/desktop_sidecar_launcher.gd.uid`, and `src/runtime/desktop_sidecar_runtime.gd.uid`; `openclaw` is missing committed `mcp_bridge.gd.uid`), so raw `godotenv addons install` still aborts after import/test runs.
- Revalidated the root assembly twice through the repeatable repo-local flow: `./scripts/restore-addons.sh` → `godot --headless --path . --import` → `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`, then the same sequence again. Both passes succeeded. Remaining notes are warnings/risk markers rather than failures: one `test_cleanup_on_exit` case is marked risky because it does not assert, and Godot still warns about a nested repro project under `repros/linux-close-minimal` plus leaked/unfreed objects during teardown.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** A truthful downscope-aligned repo surface for the active PC community assembly, plus a narrow repo-local repeatable restore flow for today's dependency reality. README, build/distribution docs, bundle/readme/runtime copy, and the carried local cleanup now match the locked product story: camera-first gameplay, Boxing + Flow, PC community first, honest current dependency/runtime caveats, and a documented restore wrapper that safely reacquires disposable addon trees after import/test runs.

**Reference Check:**
- `REF-04` satisfied: repo now reflects the locked docs landing scope and PC community priority.
- `REF-05` satisfied: repo wording no longer implies equal-status non-camera gameplay inputs.
- `REF-06` satisfied: runtime/build/docs copy now aligns with the narrowed camera-based Boxing + Flow product framing.
- Deliberate non-deviation note: the manifest and assembly runtime still expose the current `aerobeat-core` + `aerobeat-input-mediapipe-python` compatibility state, but the repo now documents that plainly instead of treating it as already normalized.

**Validation:**
- ✅ `bash -n build-scripts/build-linux-bundle.sh build-scripts/build-macos-bundle.sh build-scripts/build-windows-bundle.sh build-scripts/templates/run.sh`
- ✅ `./scripts/restore-addons.sh`
- ✅ `godot --headless --path . --import`
- ✅ `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - suite result: 10 passing tests, 1 risky/pending test (`test_cleanup_on_exit` does not assert), plus warnings about the nested repro detection under `repros/linux-close-minimal` and leaked/unfreed objects during test teardown.
- ✅ Repeated full-cycle proof: `./scripts/restore-addons.sh` → import → GUT → `./scripts/restore-addons.sh` → import → GUT completed successfully end-to-end.
- ✅ Root-cause repro remains truthful: from the normal post-import generated state, raw `godotenv addons install` still fails because ignored generated `.uid` files inside installed addons are treated as local modifications.
  - reproduced on `aerobeat-input-mediapipe` via `src/input_provider.gd.uid`, `src/process/desktop_sidecar_launcher.gd.uid`, and `src/runtime/desktop_sidecar_runtime.gd.uid`
  - `openclaw` still lacks committed `mcp_bridge.gd.uid`, so it remains a second source-level hazard once the MediaPipe dirtiness is cleared

**Commits:**
- `3a3b304` - Align assembly-community with downscoped PC camera-first truth

**QA Review Update (2026-05-01):**
- **Result:** ❌ Initial QA failed, then coder follow-up landed a repo-local repeatability fix for recheck.
- **Truth alignment verified:** README, `docs/build-distribution-system.md`, `addons.jsonc`, `project.godot`, launcher/build-script copy, and integration-test intent all align with the locked docs truth for camera-only Boxing + Flow on PC community first.
- **Stale wording spot-check:** no stale “air drumming” language remains in the inspected README/build/docs/runtime surfaces; remaining hits are only in this plan’s historical prose.
- **Blocking defect found:** the repo’s primary documented restore command (`godotenv addons install`) was not safely repeatable after import/test runs because generated ignored addon `.uid` files caused GodotEnv to abort addon replacement.
- **Coder follow-up fix:** the documented repo-local restore flow now runs through `./scripts/restore-addons.sh`, which clears disposable/generated `addons/` and `.addons/` state before reacquiring manifest-defined dependencies. This keeps the assembly usable and repeatable without pretending the current upstream addon sources are already clean.
- **Residual upstream/source truth:** raw `godotenv addons install` still fails after import/test because `aerobeat-input-mediapipe` and `openclaw` do not yet ship every required `.uid` file in source. That remains the source-level fix path, but it no longer blocks this repo’s documented restore flow.
- **Warning assessment:**
  - `test_cleanup_on_exit` lacking an assertion is **not** itself a release blocker, but it leaves cleanup behavior unverified and likely masks the teardown leak warning.
  - nested repro project warning under `repros/linux-close-minimal` is **not** blocking for this pass.
  - duplicate addon UID warnings from the compatibility/generated addon trees are **not** the blocking issue here.

**Lessons Learned:** This repo is truth-critical because it sits on the active assembly path. Even “docs-only” cleanup touches runtime credibility here: stale bundle/readme copy and transition-language can silently contradict the locked product scope just as much as a bad manifest can, and validation claims should distinguish between clean-install success, repeatable repo-local restore success, and the still-separate upstream source hygiene needed to eliminate raw `godotenv addons install` dirtiness altogether.

---

*Completed on 2026-05-01*
