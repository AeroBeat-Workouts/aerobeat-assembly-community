# AeroBeat Assembly Community

**Date:** 2026-05-06  
**Status:** Draft  
**Agent:** Pico 🐱‍🏍

---

## Goal

Retest the stripped-down exported Godot control app on Cookie before resuming AeroBeat testing so we can tell whether the close crash belongs to plain exported-app close behavior or to the MediaPipe/AeroBeat stack.

---

## Overview

Yesterday’s editor-side Cookie repro narrowed the obvious version mismatch angle: the same close path did not reproduce locally on this Legion Go, and the strongest remaining delta looked environmental, especially Cookie’s NVIDIA/Zorin stack. Before we spend more cycles in the full AeroBeat proving scene again, the fastest truth pass is to rerun the smaller exported-app control artifact on Cookie.

If the plain exported app crashes on close in the same way, we should treat this as a lower-level exported Linux close-path problem and keep the bug surface small. If it closes cleanly while the AeroBeat/MediaPipe path still crashes, then we have permission to move back up-stack and focus on assembly/runtime teardown differences.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Yesterday’s session handoff with the current Cookie editor-close isolation status | `/home/derrick/.openclaw/workspace/memory/2026-05-05.md` |
| `REF-02` | Prior assembly plan covering the minimal exported close-path repro and related validation history | `.plans/2026-04-30-manual-export-vs-repro-close-path-notes.md` |
| `REF-03` | Standalone minimal exported repro project inside assembly repo | `repros/linux-close-minimal/` |
| `REF-04` | Previously built minimal exported control artifact for quick retest context | `build/godot-close-path-minimal-reproducible/` |

Use these IDs in execution, QA, and audit notes so we keep the smaller control-path test separate from the full AeroBeat proving-scene path.

---

## Tasks

### Task 1: Verify the control artifact and prep the Cookie retest path

**Bead ID:** `oc-5fd`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Verify which stripped-down exported control app and launch path should be used for today’s Cookie retest, confirm whether an existing artifact is still the right one or whether a rebuild is safer, and write down the exact launch/close checklist Derrick should use on Cookie. Do not broaden scope into AeroBeat/MediaPipe yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `build/` (only if a rebuild is required)
- `dist/` (only if a rebuild is required)

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`
- Control-artifact files only if a rebuild is required

**Status:** ✅ Complete

**Results:** Research completed against `REF-02`, `REF-03`, and `REF-04`. Chosen control artifact for today’s Cookie retest: `build/godot-close-path-minimal-qa-rebuild-20260430-1048/`, specifically the stock exported wrapper `build/godot-close-path-minimal-qa-rebuild-20260430-1048/GodotClosePathMinimal.sh`. This is the safest plain-Godot control path because it stays fully stripped down to `repros/linux-close-minimal/`, keeps the stock 3-file export shape, and is fresher than `build/godot-close-path-minimal-reproducible/`: the wrapper and binary hashes are identical between the two artifact folders, but the QA rebuild regenerated the PCK from the current source project and already has close-method audit evidence attached (`t1`/`t2`/`t3`/`t5`/`t6` logs).

Rebuild decision: **no rebuild required today**. The minimal repro source files have not changed since the 2026-04-30 QA rebuild, and that rebuild already refreshed the only stale part of the older in-repo stock export (the PCK) while preserving the same stock debug-template wrapper/binary identity. Rebuilding again would not make the Cookie control retest materially safer unless Derrick first changes `repros/linux-close-minimal/`.

Exact Cookie retest checklist for Derrick:
1. On Cookie, open a terminal and run:
   - `cd /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/build/godot-close-path-minimal-qa-rebuild-20260430-1048`
   - `./GodotClosePathMinimal.sh`
2. Wait for the app window to appear and for the terminal to print `[MinimalCloseRepro] READY ...`.
3. Close the window using a **normal human close route only**:
   - preferred first pass: click the titlebar **X**
   - acceptable comparison pass: focus the window and press **Alt+F4**
4. **Do not** use `xdotool windowclose`; prior audit evidence shows that route is a different, dirty close path and is not the truth target for this control retest.
5. Watch the same terminal after close:
   - clean path expectation: `[MinimalCloseRepro] WM_CLOSE_REQUEST ...` appears and the shell prompt returns on its own
   - failure path: the app hangs, spams errors (for example `BadWindow`), or destabilizes Cookie instead of returning cleanly
6. If a second pass is needed, rerun the same `./GodotClosePathMinimal.sh` command rather than switching up to AeroBeat/MediaPipe.

What actually happened in this research pass: inspected the current minimal repro project, prior comparison notes, rebuild notes, and the focused close-method evidence. That evidence shows ordinary titlebar close / Alt+F4 / `wmctrl -c` were clean on the refreshed stock export, while `xdotool windowclose` was the misleading dirty route. The prep recommendation therefore stays narrow: use the refreshed QA rebuild artifact and test only a real human close path on Cookie before broadening scope.

---

### Task 2: Run the Cookie control close test and capture the observed outcome

**Bead ID:** `oc-wze`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Guide the Cookie-side retest of the stripped-down exported control app, capture exactly how Derrick closes it, and record whether Cookie shows the same crash/reset/hang signature as the full AeroBeat path. Focus on observable truth, not theory.

**Folders Created/Deleted/Modified:**
- `.plans/`
- Any Cookie-side log/output folder used for this retest

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`
- Any retest notes/log captures produced for this pass

**Status:** ✅ Complete

**Results:** Derrick ran the synced control export on Cookie and reported that it **closed cleanly** through a normal human close route. That means today’s stripped-down exported Godot control app did **not** reproduce the destructive Cookie close behavior seen in the editor-side AeroBeat testing path. Observable truth from this pass: the plain exported Linux close-path control artifact is not sufficient, by itself, to trigger the Cookie crash/reset signature under this retest. This eliminates the broadest "any exported Godot app closes badly on Cookie" theory and narrows the next comparison surface back toward assembly-community export behavior and/or editor-playback close behavior.

---

### Task 3: Audit the result and decide whether we stay downscoped or move back into AeroBeat

**Bead ID:** `oc-8il`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Audit the control-test evidence against prior close-path findings. Answer one decision clearly: did today’s control export reproduce the same close failure on Cookie or not, and therefore should the next loop stay focused on the minimal exported path or return to AeroBeat/MediaPipe teardown work?

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ⏳ Pending

**Results:** Pending. Current expected audit direction after Derrick’s report: the clean close on Cookie means we should move back up from the plain exported control path. The next highest-value branch is an assembly-community Linux export that includes the MediaPipe Python camera runtime so we can answer whether exported assembly + camera teardown also closes cleanly on Cookie. If that also closes cleanly, the remaining suspect surface tightens around **editor playback + closing that playback on Cookie**, not plain exported app close behavior.

---

### Task 4: Prep and sync the assembly-community MediaPipe Linux export for Cookie comparison

**Bead ID:** `oc-s5s`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Claim the assigned bead on start. Identify the correct assembly-community Linux export artifact that launches the MediaPipe Python camera logic, verify whether the existing build is still the right comparison artifact or whether a rebuild/sync is required, then sync it to Cookie and provide the exact run/close checklist for Derrick. Keep scope to exported-build comparison only; do not jump back into editor playback yet.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `dist/AeroBeatAssemblyProof-Linux/` (synced to Cookie; no local rebuild)

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`
- Cookie copy of `dist/AeroBeatAssemblyProof-Linux/`

**Status:** ✅ Complete

**Results:** Identified the correct exported-build comparison artifact as the full Linux proof bundle at `dist/AeroBeatAssemblyProof-Linux/`, launched via `dist/AeroBeatAssemblyProof-Linux/run-proof.sh` (with the underlying exported binary/pck at `build/linux-proof/AeroBeatAssemblyProof.x86_64` and `build/linux-proof/AeroBeatAssemblyProof.pck`). This is the right assembly-community comparison target because it is the export path that still boots the assembly-owned MediaPipe proof scene (`src/mediapipe_test_scene.gd`) and carries the loose Python sidecar payload plus prepared runtime under `addons/aerobeat-input-mediapipe/python_mediapipe/`, which is the exact exported-build layer Derrick wanted to compare before returning to editor playback.

Rebuild decision: **no rebuild required**. The code-bearing close-path and MediaPipe teardown changes that matter to this exported comparison path (`src/mediapipe_test_scene.gd`, `src/mediapipe_test_autostart_manager.gd`, `src/main.gd`) were already present before the existing 2026-04-29 proof export was built, and spot checks showed the local proof bundle still matches the current local proof payload for the launcher, export binary, sidecar entrypoint, and runtime-manifest path. The only real drift found was on **Cookie**, where the remote copy of this bundle was stale: remote checksums for the PCK, launcher wrapper, and runtime manifest did not match the current local comparison artifact, and `godot-linux-launch.inc.sh` was missing remotely.

Sync result: refreshed Cookie with `rsync -a dist/AeroBeatAssemblyProof-Linux/ cookie:/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/dist/AeroBeatAssemblyProof-Linux/`. Post-sync verification on Cookie confirmed matching SHA-256 hashes for `AeroBeatAssemblyProof.x86_64`, `AeroBeatAssemblyProof.pck`, `run-proof.sh`, `godot-linux-launch.inc.sh`, `addons/aerobeat-input-mediapipe/python_mediapipe/main.py`, and `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/runtime-manifest.json`. The refreshed remote bundle also has the required runtime/model prerequisites in place: `run-proof.sh` is executable, `pose_landmarker_full.task` exists, and `addons/aerobeat-input-mediapipe/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python` exists on Cookie.

Exact Cookie run/close checklist for Derrick:
1. On Cookie, open a terminal and run:
   - `cd /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/dist/AeroBeatAssemblyProof-Linux`
   - `./run-proof.sh`
2. Wait for the exported proof window to appear and for the terminal/app logs to show the MediaPipe proof scene is active (for example the proof-scene status text plus normal sidecar startup output).
3. Exercise only the exported-build comparison path Derrick wanted:
   - let the camera/MediaPipe path come up
   - then close the exported app using a normal human close route, preferably the titlebar **X**
   - acceptable second pass: focus the window and press **Alt+F4**
4. Do **not** use editor playback and do **not** use `xdotool windowclose` for the truth pass.
5. Expected close method on Cookie: normal window-manager close of `./run-proof.sh` / the `AeroBeatAssemblyProof.x86_64` window. After a clean close, control should return to the launching terminal.
6. If Derrick wants an explicit X11 fallback on Cookie for one comparison run, use either:
   - `AEROBEAT_FORCE_X11=1 ./run-proof.sh`
   - or `./run-proof.sh --x11`

What actually changed in this task: no export rebuild; only the stale Cookie bundle was refreshed to match the already-chosen local proof artifact.

---

### Task 5: Verify Cookie/local assembly-community repo parity and editor-launch Godot alignment

**Bead ID:** `oc-r3l`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Claim the assigned bead on start. Compare local vs Cookie state for `aerobeat-assembly-community`, verify whether Cookie’s repo is aligned with the local repo at the commit/content level needed for today’s retest, and verify that both hosts are using the same intended Godot editor/version path to open the project. Record exact commands/paths/versions and note any mismatch or cleanup required.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ✅ Complete

**Results:** Compared the local Legion Go repo and Cookie repo directly. Content-level retest alignment is good: both hosts are on the same `HEAD` commit `693b7747516443adae719b0a11ee37c37e049fd3` on `main`, and both reported no tracked-file modifications (`git status --short --branch`, `git diff --stat`, `git diff --name-status` all clean aside from untracked files). Local-only drift is the active plan file `.plans/2026-05-06-cookie-exported-app-close-control-check.md` being untracked on the Legion Go. Cookie-only drift is an untracked `.gastown-ignore` file at repo root; that does not affect the Godot retest path but is a real repo-local difference.

Godot editor alignment is also good and now concrete on both hosts. On both hosts, `command -v godot` resolves to the wrapper `/home/derrick/.local/bin/godot`, whose contents are `exec "/home/derrick/.local/share/openclaw/godot/current/godot" "$@"`. That wrapper points to host-local OpenClaw-managed 4.6.2 installs:
- local host real binary: `/home/derrick/.local/share/openclaw/godot/installs/4.6.2-stable-standard-20260408175713/Godot_v4.6.2-stable_linux.x86_64`
- Cookie real binary: `/home/derrick/.local/share/openclaw/godot/installs/4.6.2-stable-standard-20260410071112/Godot_v4.6.2-stable_linux.x86_64`
- both binaries report `4.6.2.stable.official.71f334935`
- both `current/godot` binaries share the same SHA-256: `5a806b2b385279d9607094d33e946ed828e9606df4cb46d258ca27468dc5c1c9`

Launcher/association evidence: both hosts have the desktop launcher `~/.local/share/applications/org.godotengine.Godot.desktop` with `Exec=/home/derrick/.local/bin/godot %U`, so the intended editor-launch path for this project is the same wrapper-driven 4.6.2 binary on both machines. The Legion Go additionally has a side-by-side beta desktop entry `org.godotengine.Godot-4.7-beta1.desktop` pointing at `/home/derrick/.local/bin/godot-4.7-beta1`, but that is not the default wrapper used by `godot` and is not the matching retest target. I did not find an active `~/.config/godot/projects.cfg` entry pinning this repo to a different editor on either host, so the safest exact open command remains explicit CLI launch: `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community`.

Minimal safe correction performed: Cookie’s repo `origin` remote was still configured as HTTPS (`https://github.com/AeroBeat-Workouts/aerobeat-assembly-community.git`) while local already used SSH. I corrected Cookie to `git@github.com:AeroBeat-Workouts/aerobeat-assembly-community.git` so both hosts now match the required SSH-only Git auth convention. No content sync/rebuild was needed.

---

### Task 6: Verify Cookie/local mediapipe-python repo parity and runtime dependency readiness

**Bead ID:** `oc-cvb`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`  
**Prompt:** Claim the assigned bead on start. Compare local vs Cookie state for `aerobeat-input-mediapipe-python`, verify whether Cookie’s repo is aligned with the local repo at the commit/content level needed for today’s retest, and verify that the MediaPipe Python/runtime dependencies on Cookie are present and look correct for the editor-driven proving-scene path. Record exact commit/status/runtime evidence and any mismatch or refresh required.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ✅ Complete

**Results:** Compared local vs Cookie state for `aerobeat-input-mediapipe-python` and verified that Cookie is aligned at the **code/runtime payload level needed for today’s retest**, with one minor repo-level drift that does **not** affect the proving-scene path. Local repo state: `main` at `c09ee3362876641d98a48b08eab483d5bf940dd4`, clean working tree. Cookie repo state: `main` at `ed0bd9279312932006997cac2eea899a8a7cc2a4`, clean working tree, `behind 1`. The exact missing commit on Cookie is `c09ee33 Update MediaPipe regression investigation plans`, and its diff is **plans-only** (`.plans/2026-05-05-cookie-close-crash-regression-isolation.md`, `.plans/2026-05-05-editor-warning-cleanup.md`, `.plans/2026-05-05-proving-scene-runtime-regression-fix.md`). No tracked code, scene, Python sidecar, model, or runtime files differ between the two hosts for the files relevant to today’s retest.

Concrete content evidence: matching SHA-256 hashes on local and Cookie for `README.md`, `plugin.cfg`, `python_mediapipe/main.py`, `python_mediapipe/requirements.txt`, and all three model assets (`pose_landmarker_{lite,full,heavy}.task`). Cookie also has the prepared Linux runtime tree present under `python_mediapipe/assets/runtimes/linux-x64/`, including `runtime-manifest.json`, `.runtime-ready`, and `venv/bin/python`. Runtime metadata on Cookie reports `validation_status: ready`, `platform_key: linux-x64`, `python_executable: venv/bin/python`, and `python_version: 3.14.2`. The venv resolves at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-mediapipe-python/python_mediapipe/assets/runtimes/linux-x64/venv/bin/python`.

Dependency/readiness evidence on Cookie: `mediapipe`, `cv2`, and `numpy` import successfully inside the prepared runtime venv; repo-local modules (`args`, `one_euro_filter`, `platform_utils`, `camera_streamer`, `roi_tracker`, `runtime_paths`) also import successfully when launched from the repo path; and `runtime_paths.get_model_path()` resolves all three task assets with `exists=True`. Package evidence from Cookie’s venv includes `mediapipe==0.10.35`, `numpy==2.4.4`, `opencv-python==4.13.0.92`, `opencv-contrib-python==4.13.0.92`, `absl-py==2.4.0`, `flatbuffers==25.12.19`, `matplotlib==3.10.9`, and `sounddevice==0.5.5`. `python_mediapipe/requirements.txt` remains intentionally minimal (`mediapipe>=0.10.0`, `opencv-python`, `numpy`), and the Cookie runtime manifest records that those requirements were installed into the runtime-local venv.

Notable non-blocking drift: Cookie’s Git remote is still HTTPS (`https://github.com/AeroBeat-Workouts/aerobeat-input-mediapipe-python.git`) rather than SSH, and Cookie’s prepared runtime uses Python 3.14.2 while the local prepared runtime metadata still reflects a 3.12.3 scaffolded manifest. That local-vs-Cookie Python/runtime-prep mismatch is worth remembering for future parity work, but it does **not** block today’s Cookie editor-driven proving-scene retest because the Cookie-side runtime is present, marked ready, and passes direct import/path checks. No repo or runtime refresh was required for this task, so nothing was changed on Cookie.

---

### Task 7: Audit pre-retest readiness and define the next editor retest ladder

**Bead ID:** `oc-6wy`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Audit the environment-alignment findings from Tasks 5 and 6 plus today’s clean exported-build results. Decide whether non-engine drift has been eliminated well enough to proceed with Derrick’s next editor retest ladder: (1) open assembly-community in editor and run/close, then if clean (2) open mediapipe-python and run/close. Write the clearest next-step checklist and call out anything still mismatched.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ✅ Complete

**Results:** Audit verdict: **ready to proceed with Derrick’s editor retest ladder**. Based on Task 2 plus the parity/alignment checks in Tasks 4, 5, and 6, the meaningful non-engine drift has been reduced enough that another Cookie editor retest is now a useful signal instead of a likely environment false positive. Today’s evidence says the plain exported control close path is clean on Cookie, the assembly-community export artifact on Cookie was refreshed to match local, both hosts are pointed at the same intended Godot 4.6.2 editor wrapper/binary, and the Cookie-side MediaPipe Python runtime for the proving-scene path is present and passes direct dependency/import/model checks.

**Blocking mismatches:** none found from today’s evidence.

**Non-blocking mismatches still present:**
- `aerobeat-assembly-community`: local-only untracked plan file `.plans/2026-05-06-cookie-exported-app-close-control-check.md`.
- `aerobeat-assembly-community`: Cookie-only untracked repo-root `.gastown-ignore`.
- `aerobeat-input-mediapipe-python`: Cookie is behind local by one **plans-only** commit `c09ee33`; no tracked code/runtime payload drift relevant to retest.
- `aerobeat-input-mediapipe-python`: Cookie remote is still HTTPS instead of SSH.
- `aerobeat-input-mediapipe-python`: local prepared runtime metadata reflects Python 3.12.3 while Cookie’s ready runtime is 3.14.2; worth normalizing later, but Cookie’s runtime passed readiness/import checks and is not a blocker for today’s editor retest.
- Plan-record mismatch: this plan contains concrete prep/sync evidence for the assembly-community exported proof bundle, but it does **not** record a separate Task-level execution result for that export being run/closed today. That documentation gap is non-blocking for the next editor retest ladder, but worth tightening in follow-up notes if Derrick wants the exported-proof evidence chain to be fully explicit.

**Exact next-step checklist for Derrick:**
1. On Cookie, open the assembly-community project explicitly with the matching editor path:
   - `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community`
2. Run the same proving-scene/editor playback path used in the prior close-crash investigation.
3. Let the scene reach its normal ready/running state, including the expected MediaPipe/camera startup behavior.
4. Close the running editor-played app using a normal human close route only, preferably the titlebar **X**. If Derrick wants a second comparison pass, use **Alt+F4**.
5. Record whether Cookie closes cleanly, hangs, throws window-manager/BadWindow style noise, kills the editor session, or destabilizes the host.
6. **If and only if Step 1 closes cleanly**, move to the plugin repo ladder rung:
   - `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-mediapipe-python`
7. In that repo, run/close the closest equivalent editor path Derrick has been using for the plugin-side isolation pass.
8. Again use only a normal human close route and record whether the close is clean or destructive.
9. If assembly-community reproduces the destructive close but mediapipe-python does not, the remaining suspect surface stays centered on assembly-community/editor-playback teardown. If both are clean, today’s earlier failure was likely tied to a narrower transient/editor-state factor that is no longer present. If both fail, the suspect surface widens back toward shared editor/runtime/host behavior on Cookie.

Bottom line: proceed with the editor retest ladder now; no concrete blocker remains in today’s non-engine parity checks.

---

### Task 8: Locate and stop the stale Gastown-related process on Cookie, then identify why it returns

**Bead ID:** `oca-mun`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`  
**Prompt:** Claim the assigned bead on start. On Cookie, locate the stale process or service responsible for `.gastown-ignore` showing back up, stop/kill it safely if possible, and identify what is causing it to restart or persist. Record the exact process/service/timer evidence, what you stopped, and whether it is likely to come back.

**Folders Created/Deleted/Modified:**
- `.plans/`
- Cookie runtime/service state as needed

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ✅ Complete

**Results:** Cookie does **not** currently have a live Gastown daemon, tmux session, cron job, or systemd user service creating `.gastown-ignore`. Concrete checks on Cookie found: no `gastown`/`gt` user process, no tmux sessions, no matching cron entries, and no Gastown-related systemd user units beyond unrelated OpenClaw services. The actual creation path is Cookie’s **interactive Gastown shell hook** at `~/.config/gastown/shell-hook.sh`, sourced from `~/.bashrc` (`[[ -f "/home/derrick/.config/gastown/shell-hook.sh" ]] && source "/home/derrick/.config/gastown/shell-hook.sh"`). That hook contains the only discovered `.gastown-ignore` write path: `touch "$repo_root/.gastown-ignore"` inside `_gastown_offer_add()` when the user answers `never` to the `Add '<repo>' to Gas Town? [y/N/never]` prompt.

Evidence chain for the assembly-community repo: the untracked `.gastown-ignore` on Cookie was last created at `2026-05-06 09:07:11 -0400`, and Cookie’s `~/.cache/gastown/asked-repos` was updated at the exact same timestamp, which matches the shell-hook prompt flow. No process currently had its cwd inside `aerobeat-assembly-community`, so this was not a stale long-running repo worker; it was a shell-startup/in-repo prompt side effect.

Minimal safe fix applied on Cookie:
- edited `~/.local/state/gastown/state.json` to set `"enabled": false` so `_gastown_enabled()` now short-circuits before any repo detection or prompt logic runs
- moved the current stray file out of the repo to `~/.local/share/Trash/files/gastown-ignore-aerobeat-assembly-community-20260506-104105`
- verified with an interactive login shell (`bash -lic`) inside `aerobeat-assembly-community` that `.gastown-ignore` stays absent

Will it come back? **Not while Gastown remains disabled in `~/.local/state/gastown/state.json`.** It would come back only if Gastown is re-enabled (or the shell hook is otherwise restored to active behavior) and someone again answers `never` at the interactive add-to-Gastown prompt inside that repo. Follow-up recommended: if Derrick wants Gastown available on Cookie for other repos, re-enable it intentionally later and either remove the `source ~/.config/gastown/shell-hook.sh` line from `~/.bashrc` permanently or keep Gastown disabled until this AeroBeat isolation work is finished.

---

### Task 9: Diagnose and repair Cookie assembly-community open errors after setup

**Bead ID:** `oc-e79`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Claim the assigned bead on start. Investigate the current Cookie assembly-community open errors after running godotenv and the mediapipe-python install scripts, repair the underlying issue if it is safe to do so, and record the exact root cause plus the concrete fix. Focus on restoring the intended editor-open state for today’s retest, not on broader refactors.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `addons/`
- `.addons/`
- related setup/runtime files only if needed for the fix

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`
- `addons.jsonc`
- `../aerobeat-input-mediapipe-python/src/autostart_manager.gd`
- `../aerobeat-input-mediapipe-python/src/process/mediapipe_process.gd`

**Status:** ✅ Complete

**Results:** Root cause was two-layer drift, not a Cookie-only cache glitch. The owning `aerobeat-input-mediapipe-python` repo still hardcoded addon-mount preloads to `res://addons/aerobeat-input-mediapipe-python/...` inside `src/autostart_manager.gd` and `src/process/mediapipe_process.gd`, which breaks when assembly consumers mount that repo under the compatibility alias `res://addons/aerobeat-input-mediapipe/`. On top of that, this assembly repo was pinned in `addons.jsonc` to stale addon commit `e2d203f72301d94c18334ace1d0e986c3512a224`, so rerunning GodotEnv on Cookie kept reinstalling the broken payload even after local setup work.

Repair applied:
- In owner repo `../aerobeat-input-mediapipe-python`, replaced the hardcoded addon-path preloads with script-local dynamic loads so the sidecar helper/runtime scripts resolve relative to the current mounted script location instead of assuming the repo name. Landed and pushed as commit `efabe54` (`Make sidecar helpers mount-path agnostic`).
- In this assembly repo, updated `addons.jsonc` to pin `aerobeat-input-mediapipe` to fixed source commit `efabe5451dc2af9788c4dc0b3bef0d85805dd0ae`. Landed and pushed as commit `d0fc7b9` (`Pin MediaPipe addon to mount-path fix`).
- On Cookie, fast-forwarded both local repos, then reran the repo’s documented `./scripts/restore-addons.sh` flow because raw `godotenv addons install` was separately blocked by dirty generated `openclaw` addon state (`mcp_bridge.gd.uid`).

Verification on Cookie:
- Fresh installed addon no longer contains any `res://addons/aerobeat-input-mediapipe-python/src/runtime/...`, `.../src/process/...`, or `.../src/config/...` references in the repaired files.
- `godot --headless --editor --path . --quit-after 1 --verbose` no longer logs the previous MediaPipe parse/load failures (`desktop_sidecar_runtime.gd`, `desktop_sidecar_launcher.gd`, `Parse Error`, `Failed to load script` all absent).
- Remaining headless-editor output was limited to non-blocking startup noise (`Detected another project.godot`, scan-thread abort on fast exit, ObjectDB leak warning at shutdown), not the prior addon open blocker.

Net effect: Cookie now has a clean regenerated assembly addon tree sourced from the fixed MediaPipe commit, and the specific editor-open blocker Derrick reported is repaired for the next retest.

---

### Task 10: Audit readiness after Gastown cleanup + setup repair

**Bead ID:** `oc-qrk`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Audit the Cookie environment after the stale Gastown-process check and the assembly-community setup repair. Decide whether Derrick can proceed with the editor retest ladder from a clean-enough non-engine baseline, and write the exact next steps plus any remaining caveats.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ✅ Complete

**Results:** Audit verdict: **ready to proceed**. Tasks 8 and 9 removed the two most credible non-engine confounders before another Cookie editor retest: (1) the stray `.gastown-ignore` was traced to Cookie’s interactive Gastown shell hook rather than a mystery background worker, then neutralized by disabling Gastown in `~/.local/state/gastown/state.json` and verifying a fresh interactive shell no longer recreates the file; and (2) the assembly open failure after setup was traced to a real addon mount-path bug plus stale addon pinning, then repaired by landing owner-repo commit `efabe54` (`Make sidecar helpers mount-path agnostic`), pinning assembly `addons.jsonc` to `efabe5451dc2af9788c4dc0b3bef0d85805dd0ae` in commit `d0fc7b9` (`Pin MediaPipe addon to mount-path fix`), and regenerating Cookie’s addon tree via `./scripts/restore-addons.sh`.

That means Derrick can now reopen `aerobeat-assembly-community` on Cookie and continue the editor retest ladder from a **clean-enough baseline**. The prior open blocker is gone, the Gastown prompt side effect is out of the repo path for now, and today’s earlier exported-build checks were already clean. The remaining uncertainty is now back where it belongs: the editor-playback close path itself.

**Blocking issues:** none from the audited evidence.

**Non-blocking caveats:**
- Keep Gastown disabled on Cookie during this isolation pass; re-enabling it could reintroduce `.gastown-ignore` prompt side effects.
- Cookie’s `aerobeat-input-mediapipe-python` repo is still behind local by one **plans-only** commit and still uses an HTTPS remote; neither affects today’s retest signal.
- Cookie may still show benign fast-exit headless-editor noise (`Detected another project.godot`, scan-thread abort on quick quit, ObjectDB leak warning). Those were not the prior open blocker and should not be confused with the destructive close symptom.
- Use only normal human close routes for truth testing; avoid `xdotool windowclose`.

**Exact next-step checklist for Derrick on Cookie:**
1. In a fresh Cookie shell, confirm Gastown stays out of the way by simply working from the repo normally; do not re-enable Gastown before the retest.
2. Open assembly-community with the matched editor wrapper:
   - `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community`
3. Run the same proving-scene/editor playback path used in the earlier close-crash investigation.
4. Let the scene fully reach its normal ready/running state, including the expected MediaPipe/camera startup behavior.
5. Close the running app with a normal human close route only:
   - first pass: titlebar **X**
   - optional comparison pass: **Alt+F4**
6. Record the exact outcome: clean close, hang, `BadWindow`/window-manager noise, editor death, or host destabilization.
7. **Only if assembly-community now closes cleanly**, continue to the second ladder rung:
   - `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-mediapipe-python`
8. Run the closest equivalent plugin-side editor isolation path Derrick has been using, then close it the same human way and record the outcome.
9. Interpret the branch point:
   - assembly fails / plugin clean => suspect stays centered on assembly-community editor-playback teardown
   - both clean => prior failure was likely transient/editor-state-specific and is no longer reproduced
   - both fail => suspect widens back toward shared Cookie editor/runtime/host behavior

Bottom line: **yes, Derrick should proceed with reopening assembly-community on Cookie now**; the remaining issues are caveats, not blockers.

---

### Task 11: Repair remaining detector/provider mount-path assumptions in MediaPipe addon

**Bead ID:** `oc-upq`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Claim the assigned bead on start. Fix the remaining `aerobeat-input-mediapipe-python` detector/provider scripts that still hardcode `res://addons/aerobeat-input-mediapipe-python/...` so the addon works when mounted in assembly as `res://addons/aerobeat-input-mediapipe/`. Repin any affected consumer manifest, sync Cookie if needed, and verify the previous pose-detector parse blocker is gone.

**Folders Created/Deleted/Modified:**
- `.plans/`
- MediaPipe addon source files under `src/`
- assembly consumer addon pin/config only if needed

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`
- Relevant `aerobeat-input-mediapipe-python/src/...` files
- `addons.jsonc` if repinning is required

**Status:** ✅ Complete

**Results:** Root cause was a second wave of owner-repo mount-path assumptions that survived the earlier sidecar-helper repair. `src/providers/mediapipe_provider.gd` and `src/detectors/pose_detector_substrate.gd` still preloaded detector dependencies through the owner-only mount key `res://addons/aerobeat-input-mediapipe-python/...`, which parses in the repo-local `.testbed` but breaks when the assembly mounts the addon under `res://addons/aerobeat-input-mediapipe/`. Once the first sidecar/runtime fix landed, the next Cookie blocker moved to these detector/provider preloads.

Repair applied in the owner repo: removed the remaining hardcoded detector preloads and let the scripts resolve sibling detector classes through their registered script classes instead of owner-path literals. Landed and pushed in `../aerobeat-input-mediapipe-python` as commit `80ed9ce` (`Make detector/provider mounts alias-safe`). Exact files fixed there: `src/providers/mediapipe_provider.gd` and `src/detectors/pose_detector_substrate.gd`.

Consumer follow-through: repinned this assembly repo’s `addons.jsonc` from `efabe5451dc2af9788c4dc0b3bef0d85805dd0ae` to `80ed9ce8f6e845d619595512da3f2300f3551061`, landed/pushed as commit `35ca8e8` (`Pin MediaPipe addon to detector/provider fix`), then refreshed installed addon payloads locally and on Cookie via `./scripts/restore-addons.sh`.

Validation evidence:
- Repo-local owner check: after `cd .testbed && godotenv addons install`, headless `--check-only` parses against `addons/aerobeat-input-mediapipe-python/src/providers/mediapipe_provider.gd` and `.../src/detectors/pose_detector_substrate.gd` returned clean logs with no parse/load failures.
- Local assembly consumer check: restored addons, confirmed `.addons/aerobeat-input-mediapipe/.git/HEAD` is `80ed9ce8f6e845d619595512da3f2300f3551061`, then ran `godot --headless --editor --path . --quit-after 1 --verbose`; the log showed no `pose_detector_substrate`, `Parse Error`, or `Failed to load script` cascade.
- Cookie consumer check: fast-forwarded both repos, reran `./scripts/restore-addons.sh`, confirmed installed addon HEAD `80ed9ce8f6e845d619595512da3f2300f3551061`, confirmed zero remaining owner-path detector refs in installed `addons/` + `.addons/` payloads (`MATCH_PROVIDER_REF_COUNT=0`), and reran the headless editor-open probe with `TARGET_ERROR_COUNT=0`. The previous pose-detector/provider parse blocker is gone on Cookie; remaining log noise was limited to the pre-existing OpenClaw MCP port-in-use warning plus generic quick-exit scan/ObjectDB noise.

Exact next step for Derrick: on Cookie, reopen the assembly project in the editor with `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community`, run the proving-scene/editor playback path again, and then close it with a normal human close route (titlebar X first, Alt+F4 only as a comparison pass) to continue the close-crash isolation ladder from a now-fixed addon-open baseline.

---

### Task 12: Audit editor-open readiness after detector/provider mount-path repair

**Bead ID:** `oc-9yi`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Audit the repair for the remaining MediaPipe detector/provider mount-path assumptions and confirm whether Cookie should now be able to reopen assembly-community without the earlier pose-detector preload parse cascade. Record any remaining blockers precisely.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 13: Repair assembly input-core contract mismatch against current MediaPipe adapter

**Bead ID:** `oc-a4j`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Claim the assigned bead on start. Diagnose and repair the `aerobeat-input-core` contract mismatch now blocking assembly open on Cookie. The current evidence shows assembly is still consuming an older `boxing_input.gd` surface with names like `block_start` / `knee_strike_left` / `leg_lift_left`, while the MediaPipe adapter now expects `guard_start` / `knee_left` / `leg_lift_left_start`. Identify the correct input-core version/commit to use, repin assembly if needed, refresh Cookie, and verify the parse blocker is gone.

**Folders Created/Deleted/Modified:**
- `.plans/`
- assembly addon config/install state
- input-core repo only if an owner-side fix is genuinely required

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`
- `addons.jsonc` if repinning is required
- Any owner-repo files only if needed for the fix

**Status:** ✅ Complete

**Results:** Root cause confirmed as a release/pin drift, not an assembly-local script bug. The assembly manifest was still pinned to `aerobeat-input-core` tag `v0.1.2`, and that release still ships the older `src/interfaces/boxing_input.gd` contract (`block_start`, `block_end`, `knee_strike_left/right`, `leg_lift_left/right`). The currently mounted MediaPipe adapter in assembly already expects the newer gameplay-intent contract (`guard_start/end`, `squat_*`, `lean_*`, `sidestep_*`, `knee_left/right`, `leg_lift_*_start/end`). In the owner repo, the needed contract already existed on `main` in commits `96908ab` (`Define v1 gameplay intent contract`) and `3ab8d94` (`Align slice B flow and knee intent contract`), but no release tag exposed that contract to tagged consumers. That made the truthful fix owner-side release work plus a consumer repin, not a consumer-side patch.

Exact fix applied:
- `aerobeat-input-core`: bumped `plugin.cfg` version from `0.1.2` to `0.1.3`, committed/pushed `31f1b02` (`Bump input-core plugin version to 0.1.3`), then tagged/pushed `v0.1.3` from that corrected `HEAD` so the current gameplay-intent contract is available to consumers.
- `aerobeat-assembly-community`: updated `addons.jsonc` to pin `aerobeat-input-core` from `v0.1.2` to `v0.1.3`.

Validation completed in both local and Cookie consumer states:
- Before the fix, local headless import reproduced the exact parse cascade in `.qa-logs/oc-a4j-before-import.log`, including `Identifier "guard_start" not declared in the current scope`, `Identifier "knee_left" not declared in the current scope`, and `Failed to load script "res://src/main.gd" with error "Parse error"`.
- After tagging `v0.1.3`, a full local addon restore via `./scripts/restore-addons.sh` reinstalled `aerobeat-input-core` from branch/tag `v0.1.3`; the installed payload now reports `plugin.cfg` version `0.1.3` and the mounted `boxing_input.gd` contains `signal guard_start`, `signal knee_left(power: float)`, and `signal leg_lift_left_start`. A fresh local `godot --headless --path . --import --quit --verbose --log-file .qa-logs/oc-a4j-after-import-local.log` produced no parse/compile/load-script errors.
- Cookie refresh: synced the repinned `addons.jsonc` plus the refreshed mounted addon payload/caches to Cookie after the target machine’s broad `godotenv addons install` path stalled in unrelated dependency reinstall noise. On Cookie, the installed `addons/aerobeat-input-core/src/interfaces/boxing_input.gd` now also contains `guard_start`, `knee_left`, and `leg_lift_left_start`, and a fresh headless import log at `.qa-logs/oc-a4j-cookie-import-full.log` reports **no** `Parse Error`, `Compile Error`, or `Failed to load script` entries. The original `guard_start` / `knee_left` family blocker is gone on Cookie.

Exact next step for Derrick: reopen assembly-community on Cookie with `/home/derrick/.local/bin/godot --editor --path /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community` and verify the project now opens past the previous MediaPipe/input-core parse wall so Task 14 can audit any remaining non-contract blockers.

---

### Task 14: Audit editor-open readiness after input-core contract repair

**Bead ID:** `oc-leg`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Audit the input-core contract repair and confirm whether Cookie should now be able to reopen assembly-community without the current `guard_start`/`knee_left`-family parse cascade. Record any remaining blockers precisely.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-06-cookie-exported-app-close-control-check.md`

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Drafted and extended the execution plan for Cookie-side close-path isolation, then used it to eliminate the plain exported control path and the exported MediaPipe proof path before moving back toward editor-based retest work.

**Reference Check:** `REF-01` through `REF-04` define the current evidence chain and the intended smaller bug surface for today’s test.

**Commits:**
- None yet.

**Lessons Learned:** When the question is "is this plain exported-close behavior or an AeroBeat-specific teardown issue," the smallest exported control artifact should be the first branch point. With both exported paths now reported clean on Cookie today, the next useful branch is environment parity and editor-path alignment before retrying the crash shape from yesterday.

---

*Completed on 2026-05-06*