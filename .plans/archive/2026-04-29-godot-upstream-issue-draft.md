# AeroBeat Assembly Community

**Date:** 2026-04-29  
**Status:** ✅ Complete  
**Agent:** Pico 🐱‍🏍

---

## Goal

Draft a Godot upstream issue for the exported Linux close-path bug that follows Godot’s current GitHub issue guidelines and uses our strongest backend-split evidence, but stop at review-ready draft only.

---

## Overview

We now have a much stronger story than a generic crash report: the standalone minimal repro is broken on the X11/Xwayland path, clean on forced native Wayland, and locally mitigated via launcher-side Wayland preference. That is good enough to justify an upstream draft, but only if the draft matches Godot’s current issue template and reporting expectations.

This plan keeps the work narrow. First, gather Godot’s current issue-submission format and any relevant reporting guidance. Then write a review-only draft in the repo that follows that structure exactly while also including an `In Plain English` section for readability. Finally, independently audit whether the draft is truthful, complete, and ready for Derrick to review before any actual submission.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Backend-split investigation plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-4-7-close-hang-check.md` |
| `REF-02` | Wayland workaround plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-linux-wayland-workaround-path.md` |
| `REF-03` | Standalone minimal repro project | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/` |
| `REF-04` | Godot issue submission template/guidelines | `https://raw.githubusercontent.com/godotengine/godot/master/.github/ISSUE_TEMPLATE/bug_report.yml` ; `https://raw.githubusercontent.com/godotengine/godot/master/CONTRIBUTING.md` ; `https://contributing.godotengine.org/en/latest/feedback/reporting_issues.html` ; `https://docs.godotengine.org/en/latest/about/release_policy.html` ; local notes: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-issue-template-notes.md` |

---

## Tasks

### Task 1: Gather Godot issue template and submission guidance

**Bead ID:** `oc-al7`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and gather Godot’s current GitHub issue submission template plus any related reporting guidelines relevant to bug reports. Identify the required sections/fields, any guidance about reproduction projects/logs/system info, and anything we should avoid. Recommend the exact structure the draft should follow.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-upstream-issue-draft.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-issue-template-notes.md`

**Status:** ✅ Complete

**Results:** Completed research against Godot’s current upstream bug-report sources in `REF-04` and captured a concise internal summary in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-issue-template-notes.md`. The current GitHub bug template requires: `Tested versions`, `System information`, `Issue description`, `Steps to reproduce`, and `Minimal reproduction project (MRP)`. The strongest guidance for this draft is to keep it to one bug, verify against supported/latest versions, include exact version strings and commit hashes, provide full OS/backend/system details, attach or reference a real MRP ZIP (without `.godot`), and avoid screenshot-only logs or overclaiming a generic Linux failure when the evidence actually shows an X11/Xwayland-vs-native-Wayland split. Recommended draft structure: descriptive one-bug title; a short `In Plain English` section near the top of the issue description for readability; then the required template sections filled with our backend-split evidence and exact repro/MRP details. `REF-01`, `REF-02`, and `REF-03` remain the supporting evidence pool for Task 2.

---

### Task 2: Draft the Godot issue in repo for review only

**Bead ID:** `oc-34s`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and draft a review-only upstream Godot issue in the repo that follows the gathered Godot template/guidelines exactly. Use the strongest truthful evidence: standalone minimal repro, broken on X11/Xwayland, clean on forced native Wayland, and local launcher workaround existing without claiming the engine bug is solved. Include an `In Plain English` section near the top for readability while preserving the required template structure.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-upstream-issue-draft.md`

**Status:** ✅ Complete

**Results:** Drafted a review-only upstream issue at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md` using the exact current Godot bug-template section structure from `REF-04`: `Tested versions`, `System information`, `Issue description`, `Steps to reproduce`, and `Minimal reproduction project (MRP)`. The draft includes a short `In Plain English` section near the top of `Issue description`, keeps the claim tightly scoped to the exported Linux **X11/Xwayland** close-path failure, and explicitly says the clean `--display-driver wayland` result is a backend-path comparison rather than proof of a full engine fix. Exact evidence used: `REF-01` for the `4.6.2` default-path baseline (`EXIT_CODE 143`, forced kill, repeated `BadWindow` at `display_server_x11.cpp:1310`), `REF-01` for the `4.7.beta1` default-path rerun (`EXIT_CODE 143`, forced kill, repeated `BadWindow` at `display_server_x11.cpp:1335`), `REF-02` for the local launcher workaround framing, `REF-03` for the standalone MRP source path, and `REF-04` for the required template/order. The draft also records that the launcher workaround is local mitigation only, not an upstream engine fix claim.

---

### Task 3: Audit the draft for truthfulness and guideline compliance

**Bead ID:** `oc-8e8`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and independently audit the review-only Godot issue draft for factual truthfulness, template/guideline compliance, and evidence quality. Confirm whether Derrick can review it as submission-ready draft material, or call out exact missing/weak sections.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-audit-linux-close-x11-xwayland.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-29-godot-upstream-issue-draft.md`

**Status:** ✅ Complete

**Results:** Independent audit passed. Audit notes were written to `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-audit-linux-close-x11-xwayland.md`. Verdict: the review-only draft follows the current Godot bug-template section structure (`Tested versions`, `System information`, `Issue description`, `Steps to reproduce`, `Minimal reproduction project (MRP)`), stays truthful about the evidence, and presents the version/backend split correctly: default exported path still reproduces on `4.6.2` and `4.7.beta1`, while forced native Wayland on `4.7.beta1` is the non-reproducing comparison case and is explicitly not presented as proof of a complete engine fix. The one exact remaining gap is upstream filing prep, not truthfulness: the MRP ZIP is not attached/prepared yet, so the draft is suitable for Derrick review as submission-ready draft material but should not be filed upstream as-is until the ZIP exists without `.godot`.

---

### Task 4: Sanitize the standalone MRP so it is generic and portable

**Bead ID:** `oc-sr0`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and sanitize `repros/linux-close-minimal/` so the upstream MRP is generic to any Godot developer. Remove or rewrite any AeroBeat-specific wording, Derrick-specific wording, local machine paths, OpenClaw-specific notes, or bundled/generated artifacts that are not required for the reproduction project itself. Keep the repro minimal, portable, and truthful. Rebuild the MRP ZIP from the cleaned project without `.godot`, then update this plan with exactly what was removed/kept and the new ZIP path.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/`

**Files Created/Deleted/Modified:**
- `repros/linux-close-minimal/README.md` (rewritten to generic upstream-MRP wording)
- `repros/linux-close-minimal/scripts/main.gd` (rewritten to remove AeroBeat-specific text)
- `repros/linux-close-minimal/build-linux-bundle.sh` (deleted; repo-local helper not required for upstream source-project MRP)
- `repros/linux-close-minimal/godot-4.7-beta1-install-notes.md` (deleted; local install notes not appropriate for upstream MRP)
- `repros/linux-close-minimal/build/` (deleted)
- `repros/linux-close-minimal/dist/` (deleted)
- `repros/linux-close-minimal/.godot/` (deleted from sanitized project scope)
- `repros/linux-close-minimal/.qa-logs/` (deleted)
- `repros/linux-close-minimal/icon.svg.import` (deleted in retry/fix pass after audit)
- `repros/linux-close-minimal/scripts/main.gd.uid` (deleted in retry/fix pass after audit)
- `.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip` (rebuilt in retry/fix pass)

**Status:** ✅ Complete

**Results:** Sanitized `REF-03` into a generic, portable source-project MRP. Rewrote `README.md` to describe the repro without AeroBeat/internal-QA framing, and rewrote the in-app explanatory text in `scripts/main.gd` to remove AeroBeat boot-path wording while preserving the close-path behavior and stdout logging. Deleted non-portable or non-essential files from the project scope: `build-linux-bundle.sh` (because it depended on a repo-local launcher template outside the MRP folder), `godot-4.7-beta1-install-notes.md` (machine-local/OpenClaw install notes), plus generated/export/runtime artifacts `build/`, `dist/`, `.godot/`, and `.qa-logs/`. After Task 5's audit flagged two remaining editor-generated files, this retry/fix pass removed `icon.svg.import` and `scripts/main.gd.uid` from the sanitized source tree and rebuilt the ZIP in place at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip`. Final ZIP contents are exactly: `.gitignore`, `README.md`, `export_presets.cfg`, `icon.svg`, `project.godot`, `scenes/main.tscn`, and `scripts/main.gd`. Verified the rebuilt ZIP no longer contains `icon.svg.import` or `scripts/main.gd.uid`, and the sanitized source tree still excludes `.godot` plus generated/export outputs per `REF-04` guidance.

---

### Task 5: Audit the sanitized MRP and rebuilt ZIP

**Bead ID:** `oc-1n7`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead and independently audit the sanitized `repros/linux-close-minimal/` project plus the rebuilt MRP ZIP. Confirm that the packaged project is generic to any Godot developer, excludes `.godot`, excludes unnecessary generated/export/runtime artifacts, and contains no AeroBeat-, Derrick-, or local-machine-specific wording/paths unless absolutely required for the bug reproduction. If it passes, close the bead and record the final ZIP path.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/repros/linux-close-minimal/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-mrp-audit-sanitized-linux-close-minimal.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip`

**Status:** ✅ Complete

**Results:** Final re-audit passed and updated the audit notes in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-mrp-audit-sanitized-linux-close-minimal.md`. Rechecked the sanitized source tree at `repros/linux-close-minimal/` and the rebuilt ZIP at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip`. Confirmed the previously failing editor-generated files `icon.svg.import` and `scripts/main.gd.uid` are now absent from both source and ZIP, and confirmed no remaining `AeroBeat`, `OpenClaw`, `Derrick`, `/home/derrick`, or similar local-machine contamination in the source tree or extracted ZIP payload. Final ZIP contents are exactly: `.gitignore`, `README.md`, `export_presets.cfg`, `icon.svg`, `project.godot`, `scenes/main.tscn`, and `scripts/main.gd`. Verdict: this sanitized source-project MRP ZIP now passes the strict audit and Derrick can recheck/sign off now.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** The repo now contains a review-only upstream issue draft at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md`, an independent draft audit at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-audit-linux-close-x11-xwayland.md`, and a final-passing sanitized standalone source-project MRP ZIP at `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.artifacts/godot-linux-close-minimal-source-mrp-sanitized-2026-04-30.zip`.

**Reference Check:** `REF-04` supplied the exact template/guideline structure. `REF-01` supplied the reproducible default-path evidence on `4.6.2` and `4.7.beta1`, `REF-02` supplied the truthful local-workaround framing, and `REF-03` anchors the standalone MRP source path named in the draft. The independent issue-draft audit confirmed the backend/version split is presented correctly and not overstated, and the final MRP re-audit confirmed the rebuilt ZIP excludes `icon.svg.import` and `scripts/main.gd.uid`, excludes `.godot`/generated outputs, and is generic/portable for upstream sharing.

**Commits:**
- None yet.

**Lessons Learned:** Strong technical evidence is only half the job; upstream submission format matters too, and backend-path specificity matters more than broad “Linux bug” wording. A review-ready issue body and a directly fileable issue are not the same thing—the final MRP ZIP attachment prep is its own gate. For upstream MRPs, the source ZIP should stay ruthlessly generic and should not carry local investigation leftovers, personal paths, or prebuilt export artifacts unless they are essential to the reproduction itself.

---

*Completed on 2026-04-30*
