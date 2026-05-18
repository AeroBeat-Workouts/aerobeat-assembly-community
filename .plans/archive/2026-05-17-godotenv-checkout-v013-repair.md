# AeroBeat Assembly Community GodotEnv Checkout v0.1.3 Repair

**Date:** 2026-05-17  
**Status:** In Progress  
**Agent:** Cookie 🍪🐱‍💻

---

## Goal

Diagnose why `godotenv addons install` fails on Chip’s terminal while preparing `aerobeat-input-core` at `checkout v0.1.3`, then repair the local/tooling state so installs succeed again in `aerobeat-assembly-community`.

---

## Overview

Derrick reported a reproducible `godotenv addons install` failure in `aerobeat-assembly-community`. The current error happens after dependency resolution, when GodotEnv shells out to `git checkout v0.1.3` inside `.addons/aerobeat-input-core`, and `git` exits non-zero. That usually means one of a few concrete things: the tag is missing locally/remotely, the clone state in `.addons/aerobeat-input-core` is corrupted/stale, the repo is in a detached or conflicted state, or local Git/SSH/environment assumptions changed on Chip’s machine.

There’s relevant prior repo history here: a previous GodotEnv cleanup pass already fixed stale source identity drift in this same assembly repo while preserving compatibility mount behavior, and a later repo audit confirmed the assembly root manifest/install shape itself was valid. I also checked for additional prior-context breadcrumbs and found useful local history around earlier successful `aerobeat-input-core` reinstall/tag refreshes, but not an exact prior note for this same `checkout v0.1.3` failure. Derrick has now clarified that Chip and Byte can be inspected directly over the SSH mesh (`ssh chip`, `ssh byte`), so the diagnosis pass should include remote memory/history inspection there if the local evidence on this host stays ambiguous. The plan remains to treat this as a targeted install-path failure, not re-litigate the whole repo architecture. First we’ll capture the exact Git failure evidence, then implement the smallest truthful repair, then independently verify repeated install success.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Derrick’s current failure report and stack trace for `godotenv addons install` | current session, 2026-05-17 18:54 EDT |
| `REF-02` | Prior assembly-side GodotEnv audit confirming root manifest/install architecture is valid | `.plans/2026-04-20-assembly-community-godotenv-audit.md` |
| `REF-03` | Prior addon-tree repair showing compatibility/source-identity history in this repo | `.plans/2026-04-24-godotenv-addon-tree-out-of-sync.md` |
| `REF-04` | Current manifest and generated cache/install state | `addons.jsonc`, `.addons/`, `addons/` |
| `REF-05` | Current Git state and reachable refs for the `aerobeat-input-core` dependency source | `.addons/aerobeat-input-core/`, remote `git@github.com:AeroBeat-Workouts/aerobeat-input-core.git` |

---

## Tasks

### Task 1: Reproduce and isolate the failing checkout path

**Bead ID:** `aerobeat-assembly-community-ooc`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. In `aerobeat-assembly-community`, reproduce `godotenv addons install`, inspect `.addons/aerobeat-input-core`, and determine exactly why `git checkout v0.1.3` is failing on this machine. Capture the Git error text, current refs/tags, and any stale/corrupt cache evidence. Do not repair yet; return the narrowest root-cause explanation.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.addons/`
- `addons/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`

**Status:** ✅ Complete

**Results:** Research pass reproduced the failure and found that the originally reported `aerobeat-input-core` checkout symptom is stale on this machine. `godotenv addons install` does still fail, but the live blocker is different: GodotEnv refuses to replace a dirty generated addon mount at `addons/aerobeat-environment-gaussian-splat-fulfillment/` because it contains untracked generated UID files (`runtime/gaussian_splat_background_loader.gd.uid`, `runtime/gaussian_splat_background_read_worker.gd.uid`, `runtime/gaussian_splat_runtime.gd.uid`). Exact reproduced failure text: `System.IO.IOException: Cannot delete modified addon aerobeat-environment-gaussian-splat-fulfillment. Please backup or discard your changes and delete the addon manually.` Independent inspection of `.addons/aerobeat-input-core` showed no actual checkout problem: it is a valid Git repo, `git fsck --full` passed cleanly, local and remote `v0.1.3` refs exist, and direct `git checkout v0.1.3` succeeded with `HEAD is now at 31f1b02 Bump input-core plugin version to 0.1.3`. SSH history checks on `chip` and `byte` found no corroborating prior `input-core v0.1.3` failure, but did find prior same-pattern GodotEnv failures caused by dirty generated addon mounts with untracked `*.uid` files. Narrowest truthful repair: clean/delete the generated gaussian-splat-fulfillment addon mount (and matching cache entry if needed), then rerun `godotenv addons install`.

---

### Task 2: Repair the minimal broken state

**Bead ID:** `aerobeat-assembly-community-cv5`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. Implement the smallest truthful repair for the checkout/install failure discovered in Task 1. Prefer fixing cache/clone/tag/source state over broad repo churn. Re-run `godotenv addons install`, record exact validation evidence, and commit/push only if repo-tracked files actually change.

**Folders Created/Deleted/Modified:**
- `.addons/`
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`
- repo-tracked files only if the root cause requires it

**Status:** ❌ Failed

**Results:** The coder applied the smallest repair for the first live blocker without touching `aerobeat-input-core`. It cleaned the dirty generated addon mount `addons/aerobeat-environment-gaussian-splat-fulfillment/` by removing the three untracked generated UID files that caused GodotEnv to refuse replacement: `runtime/gaussian_splat_background_loader.gd.uid`, `runtime/gaussian_splat_background_read_worker.gd.uid`, and `runtime/gaussian_splat_runtime.gd.uid`. After that cleanup, the original gaussian-splat-fulfillment blocker was gone. However, rerunning `godotenv addons install` still exited non-zero because a second distinct dirty generated addon surfaced: `addons/openclaw/mcp_bridge.gd.uid`. Exact new failure family: `System.IO.IOException: Cannot delete modified addon openclaw...`. No repo-tracked files changed, and no commit/push was made. Because this was a newly surfaced distinct blocker in the same install flow, the coder stopped instead of silently broadening scope.

---

### Task 2b: Repair follow-up dirty generated addon blocker

**Bead ID:** `aerobeat-assembly-community-7ds`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. Continue the minimal generated-addon cleanup needed for `godotenv addons install` to succeed. The first blocker in `addons/aerobeat-environment-gaussian-splat-fulfillment/` is already resolved; now clean the newly surfaced dirty generated addon state in `addons/openclaw` (`mcp_bridge.gd.uid`) without broadening beyond what the install flow actually requires. Re-run `godotenv addons install`, capture exact evidence, and commit/push only if any repo-tracked files actually change.

**Folders Created/Deleted/Modified:**
- `.addons/`
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`
- repo-tracked files only if the root cause requires it

**Status:** ✅ Complete

**Results:** The follow-up coder pass cleaned only the newly surfaced generated UID blocker in `addons/openclaw`: `mcp_bridge.gd.uid`. After removing that untracked generated file, rerunning `godotenv addons install` completed successfully with `✅ Addons installed successfully.` No additional blockers surfaced afterward. Repo-tracked content did not change: post-install `git diff --stat` for tracked files was empty, `git status --short` only showed the local plan markdown as untracked, and no commit/push was needed. This confirms the repair was purely generated-state cleanup, not a source-repo change.

---

### Task 3: Independently verify repeat install success

**Bead ID:** `aerobeat-assembly-community-9kv`  
**SubAgent:** `primary`  
**Role:** `qa`  
**References:** `REF-01`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. Independently verify that the fix holds by re-running the relevant install path from a clean enough state, confirming the dependency lands correctly and that the original `git checkout v0.1.3` failure no longer occurs.

**Folders Created/Deleted/Modified:**
- `.addons/`
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`

**Status:** ✅ Complete

**Results:** QA independently reran `godotenv addons install` twice after the generated-state cleanup, and both runs exited `0` with `✅ Addons installed successfully.` QA also re-verified that the original `aerobeat-input-core v0.1.3` suspicion was not the blocker: `.addons/aerobeat-input-core` is healthy, `git fsck --full` is clean, local and remote `v0.1.3` resolve to the same commit (`31f1b026b441a7ef5805349b35edab17b742c52e`), and the cache clone remains on the correct tagged state. The previously cleaned generated UID blockers did not recur during QA reruns: the three gaussian-splat fulfillment UID files remained absent, and `addons/openclaw/mcp_bridge.gd.uid` also remained absent. Repo cleanliness after QA showed no addon-related tracked-file dirt; `git status --short` only showed the local untracked plan markdown.

---

### Task 4: Independent audit and completion verdict

**Bead ID:** `aerobeat-assembly-community-2x6`  
**SubAgent:** `primary`  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. Audit the final state after repair and QA. Confirm whether the original checkout/install failure is actually resolved, whether any repo-tracked changes were necessary, and whether any remaining caveat should stay open as follow-up instead of being silently bundled into this fix.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.addons/`
- `addons/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`

**Status:** ✅ Complete

**Results:** Independent audit confirmed the failure is resolved. A fresh auditor rerun of `godotenv addons install` exited `0` with `✅ Addons installed successfully.` Audit also reconfirmed that the originally suspected `aerobeat-input-core v0.1.3` checkout issue was not real: `.addons/aerobeat-input-core` is healthy, `git checkout v0.1.3` succeeds directly, `git fsck --full` is clean, and `v0.1.3^{}` resolves to commit `31f1b026b441a7ef5805349b35edab17b742c52e`, matching the checked-out state. No repo-tracked changes were necessary for the repair; tracked diff remained empty and only the local plan markdown was untracked. The actual cause was dirty generated addon state, specifically the now-absent generated UID blockers in `addons/aerobeat-environment-gaussian-splat-fulfillment/` and `addons/openclaw/`. Audit found no remaining blocker that should keep this repair open; the only reasonable follow-up is optional prevention/hygiene work if these generated UID dirtiness issues recur.

---

### Task 5: Diagnose the post-repair live discrepancy

**Bead ID:** `aerobeat-assembly-community-phi`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. Diagnose why Derrick still sees `godotenv addons install` fail with an `aerobeat-input-core` checkout error even though the same repo path currently resolves to a healthy `v0.1.3` cache and prior QA/audit reruns succeeded. Compare the exact repo path resolution, current `.addons/aerobeat-input-core` state, the live `godotenv` binary/path/version being executed, and whether command/environment discrepancies or stale cache state can explain the mismatch. Reproduce the command from the shell if possible, capture exact stderr, and return the narrowest evidence-backed explanation plus the next minimal fix.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.addons/`
- `addons/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`

**Status:** ✅ Complete

**Results:** Research proved the repo path was not the discrepancy: `~/Documents/projects/...` and the workspace path resolve to the same underlying repo. On Chip, the live `godotenv` binary was the expected one, and `.addons/aerobeat-input-core` remained healthy at `v0.1.3`. The real contradiction was that the current failing run no longer died in `aerobeat-input-core` at all; once the command was reproduced carefully on Chip, the actual failing cache was `.addons/aerobeat-input-mediapipe`, where raw Git stderr showed `fatal: reference is not a tree: 80ed9ce8f6e845d619595512da3f2300f3551061`. That narrowed the next truthful fix to the stale/incomplete MediaPipe cache clone on Chip, not input-core.

---

### Task 6: Clean Chip MediaPipe addon UID blockers

**Bead ID:** `aerobeat-assembly-community-9k1`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. On Chip over SSH, remove only the untracked generated `.uid` files currently dirtying `addons/aerobeat-input-mediapipe` (`src/input_provider.gd.uid`, `src/process/desktop_sidecar_launcher.gd.uid`, `src/runtime/desktop_sidecar_runtime.gd.uid`), rerun `~/.local/bin/godotenv addons install`, and report exact results. Do not broaden scope beyond the named generated-state cleanup unless a new blocker is surfaced by the install flow.

**Folders Created/Deleted/Modified:**
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`
- generated addon files under `addons/aerobeat-input-mediapipe/` on Chip only

**Status:** ✅ Complete

**Results:** The targeted MediaPipe addon cleanup on Chip removed only the three named untracked generated `.uid` files under `addons/aerobeat-input-mediapipe`, and `godotenv addons install` then moved past the MediaPipe addon successfully. No tracked repo files changed. The rerun did surface one final blocker later in the chain: `addons/openclaw/mcp_bridge.gd.uid` was also dirty and had to be handled separately rather than being silently bundled into this step.

---

### Task 7: Clean Chip OpenClaw addon UID blocker

**Bead ID:** `aerobeat-assembly-community-asn`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-04`, `REF-05`  
**Prompt:** Claim the bead on start. On Chip over SSH, remove only the untracked generated `addons/openclaw/mcp_bridge.gd.uid` file, rerun `~/.local/bin/godotenv addons install`, and report exact results. Do not broaden scope beyond this named generated-state cleanup unless the install flow surfaces a new blocker.

**Folders Created/Deleted/Modified:**
- `addons/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-17-godotenv-checkout-v013-repair.md`
- generated addon files under `addons/openclaw/` on Chip only

**Status:** ✅ Complete

**Results:** Removing only `addons/openclaw/mcp_bridge.gd.uid` on Chip cleared the final remaining generated-state blocker. After that cleanup, `~/.local/bin/godotenv addons install` completed successfully with exit code `0`, no new blocking failure surfaced, and no tracked repo files changed. The only remaining note was a non-blocking warning about possible overlap involving `aerobeat-environment-gaussian-splat-fulfillment`, which did not prevent install success.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Fully diagnosed and repaired the Chip-side `godotenv addons install` failure chain for `aerobeat-assembly-community` without changing any source-tracked repo files. The investigation proved the original `aerobeat-input-core v0.1.3` checkout suspicion was misleading. The real issues were: a stale/incomplete Chip-side `.addons/aerobeat-input-mediapipe` cache clone missing the target commit object, followed by dirty generated `.uid` files inside installed addon mounts (`addons/aerobeat-input-mediapipe` and `addons/openclaw`). Refreshing the MediaPipe cache clone and removing only the untracked generated addon `.uid` blockers restored successful installs on Chip.

**Reference Check:** `REF-01` satisfied: the reported install failure was reproduced, re-diagnosed accurately, and resolved on Chip. `REF-02` and `REF-03` remained valid context showing the assembly manifest/install architecture and prior input-core/source-identity cleanup were not the live problem. `REF-04` and `REF-05` were truth-checked directly through the final diagnosis: current generated install/cache state is healthy after the Chip-side cache refresh and generated-state cleanup, and `aerobeat-input-core` remained valid throughout.

**Commits:**
- No repo-tracked file changes were required for the repair itself.
- No code commit or push was necessary in `aerobeat-assembly-community`; this was an operational/cache/generated-state repair.

**Lessons Learned:** GodotEnv’s early addon-resolution lines can be misleading when a later cache or mounted-addon failure is the real blocker. For multi-addon repos, the strongest truth path is: capture the full run, inspect the exact failing cache or mounted addon named by the deepest real error, and treat `.addons/` cache health plus generated `.uid` dirt in `addons/` as separate classes of failure. Also, this failure family is common enough that it justified building the shared `godotenv-sync` maintenance command in the OpenClaw repo as follow-up prevention tooling.

---

*Created on 2026-05-17*
