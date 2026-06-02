# aerobeat-assembly-community

**Date:** 2026-05-01  
**Status:** Complete  
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

**Status:** ✅ Complete

**What We Built:** A truthful downscope-aligned repo surface for the active PC community assembly, plus a narrow repo-local repeatable restore flow for today's dependency reality. README, build/distribution docs, bundle/readme/runtime copy, and the carried local cleanup now match the locked product story: camera-first gameplay, Boxing + Flow, PC community first, honest current dependency/runtime caveats, and a documented restore wrapper that safely reacquires disposable addon trees after import/test runs.

**Reference Check:**
- `REF-04` satisfied: repo now reflects the locked docs landing scope and PC community priority.
- `REF-05` satisfied: repo wording no longer implies equal-status non-camera gameplay inputs.
- `REF-06` satisfied: runtime/build/docs copy now aligns with the narrowed camera-based Boxing + Flow product framing.
- Deliberate non-deviation note: the manifest and assembly runtime still expose the current `aerobeat-core` + `aerobeat-input-mediapipe-python` compatibility state, but the repo now documents that plainly instead of treating it as already normalized.

**Validation:**
- ✅ `bash -n build-scripts/build-linux-bundle.sh build-scripts/build-macos-bundle.sh build-scripts/build-windows-bundle.sh build-scripts/build-test.sh build-scripts/templates/run.sh scripts/restore-addons.sh`
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
- `8852130` - Fix repeatable addon restore flow
- `910b4f0` - Propagate restore wrapper contract

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

**QA Recheck Update (2026-05-01, post-fix):**
- **Result:** ✅ Recheck passed for this repo pass.
- **Documented restore flow verified:** README now points to `./scripts/restore-addons.sh`, and that wrapper matches the current repo truth by clearing disposable `addons/` + `.addons/` before reacquiring manifest-defined addons.
- **Truth alignment re-spot-check:** `README.md`, `docs/build-distribution-system.md`, `addons.jsonc`, `project.godot`, and launcher/build-script text still match the locked docs stance: camera-only gameplay input, Boxing + Flow, and PC community first.
- **Repeatability proof rerun:** I independently ran `./scripts/restore-addons.sh` → `godot --headless --path . --import` → `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` twice in a row. Both cycles succeeded.
- **Observed validation result:** each GUT pass finished with `11` tests total, `10` passing, `1` risky/pending (`test_cleanup_on_exit` did not assert), and `2` warnings about unfreed children/object cleanup during teardown.
- **Raw reinstall regression still reproduced:** after an import/test cycle, plain `godotenv addons install` still fails on dirty generated addon state in `aerobeat-input-mediapipe` (`src/input_provider.gd.uid`, `src/process/desktop_sidecar_launcher.gd.uid`, `src/runtime/desktop_sidecar_runtime.gd.uid`). That upstream source hygiene issue remains real, but the repo-local wrapper successfully contains it for this assembly.
- **Current blocker assessment:** the previous blocker is resolved at the assembly repo level because the documented restore path is now repeatable. Remaining warnings are follow-up quality items, not blockers for this bead recheck.
- **Beads note:** `bd update oc-rqa --status in_progress --json` currently hits a local Beads identity mismatch (`metadata.json project_id` vs database `_project_id`), so the QA status update had to be recorded in this plan instead of the bead metadata.

**Auditor Update (2026-05-01):**
- **Result:** ❌ Audit failed; bead stays open.
- **Independent validation rerun:** I reran the documented flow myself — `./scripts/restore-addons.sh` → `godot --headless --path . --import` → `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` — twice in a row. Both cycles succeeded, reproducing the same `11` tests / `10` passing / `1` risky pattern and the same teardown/object-leak warnings.
- **Product-contract truth check:** README and `scripts/restore-addons.sh` correctly establish the wrapper-based restore flow as the repo-local contract, and raw `godotenv addons install` still truthfully fails after import/test on dirty generated addon `.uid` state.
- **Blocking gap found:** several non-README repo surfaces still encode the old raw-install contract instead of the wrapper contract:
  - `build-scripts/build-test.sh` still restores with raw `godotenv addons install`
  - `.github/workflows/gut_ci.yml` still runs raw `godotenv addons install`
  - `build-scripts/build-linux-bundle.sh`, `build-scripts/build-macos-bundle.sh`, and `build-scripts/build-windows-bundle.sh` still tell operators to run raw `godotenv addons install` when addons are missing
  - `tests/integration/test_full_pipeline.gd` still documents the old raw-install assumption in comments
- **Why this blocks closure:** this bead was explicitly re-opened to make the wrapper-based restore flow the truthful repo-local contract. That contract is fixed in README, but it is not yet propagated across the remaining build/validation/operator surfaces, so the repo still gives contradictory instructions depending on which entrypoint someone uses.
- **Warning assessment:**
  - `test_cleanup_on_exit` lacking an assertion is **not blocking** for this bead; it is a weak test, not evidence that the repeatable restore contract is broken.
  - nested repro warning for `repros/linux-close-minimal` is **not blocking**; it is known editor scan noise.
  - teardown/unfreed-object warnings are **not blocking for this bead** because the documented restore flow and root validation path still complete successfully, but they remain worth separate follow-up.
- **Repo cleanliness:** after the audit rerun, `git status --short` showed only this plan file modified; generated addon trees remained untracked/ignored as expected.

**Coder Follow-up Update (2026-05-01, post-audit contract propagation):**
- **Result:** ✅ Narrow follow-up fix landed; bead remains open for QA/audit recheck.
- **Exact stale surfaces updated:**
  - `build-scripts/build-test.sh` now restores through `./scripts/restore-addons.sh` instead of raw `godotenv addons install`
  - `.github/workflows/gut_ci.yml` now restores through `./scripts/restore-addons.sh`
  - `build-scripts/build-linux-bundle.sh` now tells operators to run `./scripts/restore-addons.sh` from the repo root when the installed addon tree is missing
  - `build-scripts/build-macos-bundle.sh` now tells operators to run `./scripts/restore-addons.sh` from the repo root when the installed addon tree is missing
  - `build-scripts/build-windows-bundle.sh` now tells operators to run `./scripts/restore-addons.sh` from the repo root when the installed addon tree is missing
  - `tests/integration/test_full_pipeline.gd` comments now describe the wrapper-based restore contract
- **Validation rerun after propagation:**
  - `bash -n build-scripts/build-linux-bundle.sh build-scripts/build-macos-bundle.sh build-scripts/build-windows-bundle.sh build-scripts/build-test.sh build-scripts/templates/run.sh scripts/restore-addons.sh` ✅
  - `./scripts/restore-addons.sh` → `godot --headless --path . --import` → `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` ✅
  - repeated second full cycle of the same wrapper/import/GUT flow ✅
- **Observed rerun output:** both GUT passes again finished with `11` tests total, `10` passing, `1` risky/pending (`test_cleanup_on_exit` did not assert), and `2` warnings about unfreed children/object cleanup during teardown. The nested `repros/linux-close-minimal` project warning and the ObjectDB leak warning still reproduce during import/teardown, but they do not break the documented restore/import/GUT contract.
- **QA handoff:** the wrapper-based restore contract is now propagated across the stale build/CI/comment surfaces that the audit flagged, so this repo is ready for QA recheck.
- **Beads note:** direct `bd update oc-rqa --status in_progress --json` still hits the local Beads identity mismatch unless the environment skips the identity check, so the follow-up state is recorded here in the plan instead of closing or mutating the bead.

**QA Recheck Update (2026-05-01, final contract-propagation pass):**
- **Result:** ✅ Recheck passed for the scoped wrapper-contract propagation bead.
- **Repo-surface verification:** independently re-inspected the active repo truth surfaces after the coder follow-up: `README.md`, `docs/build-distribution-system.md`, `addons.jsonc`, `project.godot`, `scripts/restore-addons.sh`, `build-scripts/build-test.sh`, `.github/workflows/gut_ci.yml`, `build-scripts/build-linux-bundle.sh`, `build-scripts/build-macos-bundle.sh`, `build-scripts/build-windows-bundle.sh`, `build-scripts/templates/run.sh`, `build-scripts/templates/run.bat`, and `tests/integration/test_full_pipeline.gd`.
- **Contract propagation check:** the previously stale repo-owned surfaces now consistently point to `./scripts/restore-addons.sh` as the truthful restore entrypoint whenever this assembly needs its generated addon trees rebuilt. README/build/CI/test comments no longer contradict that contract.
- **Truth alignment spot-check:** the inspected README/build/runtime text still matches the locked docs truth from `aerobeat-docs`: camera-only gameplay input, Boxing + Flow as official v1 gameplay, and PC community first. I found no remaining stale “air drumming” wording in the active repo-owned surfaces I checked.
- **Independent validation rerun:** after a clean repo-local pass, I ran the documented flow twice in a row: `./scripts/restore-addons.sh` → `godot --headless --path . --import` → `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`, then repeated the same sequence again. Both cycles completed successfully.
- **Observed validation output:** each GUT run still reports `11` tests total, `10` passing, `1` risky/pending (`test_cleanup_on_exit` did not assert), and `2` warnings tied to unfreed children/object cleanup during teardown. Import still warns about the nested repro project at `repros/linux-close-minimal` being ignored.
- **Raw-install truth check:** immediately after the validated import/test state, plain `godotenv addons install` still fails exactly as expected on dirty generated addon `.uid` files in `aerobeat-input-mediapipe` (`src/input_provider.gd.uid`, `src/process/desktop_sidecar_launcher.gd.uid`, `src/runtime/desktop_sidecar_runtime.gd.uid`). That upstream/source hygiene issue remains real, but the wrapper contract truthfully contains it for this assembly.
- **Repeatability note:** my first combined automation attempt hit a one-off transient `git add -A` failure inside the generated `addons/aerobeat-input-mediapipe` checkout during restore, but I could not reproduce it afterward; two direct end-to-end wrapper/import/GUT cycles succeeded cleanly. I am treating that first hit as non-blocking flake/noise unless it recurs.
- **Blocking assessment:** no remaining blocker was found for this bead’s scope. The wrapper-based restore contract propagation now appears complete across the repo-owned surfaces that previously drifted.
- **Remaining non-blocking defects/warnings:**
  - `test_cleanup_on_exit` is still weak/risky because it performs no assertion.
  - GUT teardown still warns about unfreed children/object cleanup.
  - Godot still warns about the nested repro project under `repros/linux-close-minimal`.
  - raw `godotenv addons install` remains non-repeatable after import/test until upstream addon sources commit the missing generated `.uid` files.

**Final Auditor Recheck Update (2026-05-01):**
- **Result:** ✅ Audit passed; bead can close.
- **Repo-truth audit:** I independently rechecked the repo-owned contract surfaces that previously drifted — `README.md`, `docs/build-distribution-system.md`, `scripts/restore-addons.sh`, `build-scripts/build-test.sh`, `.github/workflows/gut_ci.yml`, `build-scripts/build-linux-bundle.sh`, `build-scripts/build-macos-bundle.sh`, `build-scripts/build-windows-bundle.sh`, `tests/integration/test_full_pipeline.gd`, `addons.jsonc`, and `project.godot`. They now consistently present the wrapper-based restore flow as the documented contract and keep the camera-only Boxing + Flow / PC-community-first product truth aligned with `aerobeat-docs`.
- **Validation evidence:** I verified the expected raw-install failure mode (`godotenv addons install` still aborts after import/test on generated `.uid` dirtiness inside `aerobeat-input-mediapipe`) and separately reran the documented repo contract successfully: `./scripts/restore-addons.sh` → `godot --headless --path . --import` → `godot --headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`.
- **Repeatability assessment:** during audit I did hit intermittent `git clone ... exit 128` restore flakes inside GodotEnv cache refreshes, but direct manual SSH clones to the same remotes succeeded and a subsequent clean wrapper → import → GUT rerun also succeeded. I am treating those clone hiccups as external transport/cache noise rather than a repo-contract mismatch because the repo-owned restore contract, truth surfaces, and validated happy path are coherent once the SSH fetch succeeds.
- **Warning assessment:**
  - `test_cleanup_on_exit` lacking an assertion is **not blocking** for this bead; it is weak coverage, not a contract failure.
  - the nested repro project warning under `repros/linux-close-minimal` is **not blocking**.
  - teardown/unfreed-object warnings are **not blocking** for this scoped assembly-truth bead because import and GUT still complete and the wrapper-based restore contract is now documented consistently.
- **Repo cleanliness:** `git status --short` remained clean for tracked files after the audit; generated `addons/` and `.addons/` stayed ignored as expected.
- **Beads note:** the repo still has the known Beads identity mismatch, so closing required using `BEADS_SKIP_IDENTITY_CHECK=1`.

**Lessons Learned:** This repo is truth-critical because it sits on the active assembly path. Even “docs-only” cleanup touches runtime credibility here: stale bundle/readme copy and transition-language can silently contradict the locked product scope just as much as a bad manifest can, and validation claims should distinguish between clean-install success, repeatable repo-local restore success, and the still-separate upstream source hygiene needed to eliminate raw `godotenv addons install` dirtiness altogether.

---

*Completed on 2026-05-01*
