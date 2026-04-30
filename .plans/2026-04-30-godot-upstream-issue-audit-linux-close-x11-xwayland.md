# Audit — review-only Godot upstream issue draft (Linux close X11/Xwayland)

**Date:** 2026-04-30  
**Auditor bead:** `oc-8e8`  
**Draft reviewed:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/.plans/2026-04-30-godot-upstream-issue-review-draft-linux-close-x11-xwayland.md`

## Verdict

**PASS for Derrick review as submission-ready draft material.**

More precise meaning:
- The draft is **truthful enough and template-aligned enough** for Derrick to review it as the candidate upstream issue body.
- The draft is **not ready to file upstream as-is yet**, because the MRP ZIP attachment/package-prep step is still explicitly pending.

## Section/template audit

Required Godot bug sections from the current template are present:
- `Tested versions` ✅
- `System information` ✅
- `Issue description` ✅
- `Steps to reproduce` ✅
- `Minimal reproduction project (MRP)` ✅

The draft also keeps the extra `In Plain English` section inside `Issue description`, which matches the local guidance without replacing any required section.

## Truthfulness audit

### Supported by repo evidence
- `4.6.2.stable.official.71f334935` failing on the default exported path is consistent with prior evidence and `BadWindow` spam at `platform/linuxbsd/x11/display_server_x11.cpp:1310`.
- `4.7.beta1.official.1c8cc9e7e` still failing on the comparable default exported path is supported by `.qa-logs/oc-my4/` (`EXIT_CODE 143`, forced kill, repeated `BadWindow` at `...:1335`).
- `4.7.beta1` closing cleanly with `--display-driver wayland` is supported by `.qa-logs/oc-7wx/` (`WM_CLOSE_REQUEST` present once, exit `0`, no `BadWindow`).
- The standalone repro framing is truthful: `repros/linux-close-minimal/` is a minimal one-scene project with explicit ready/close logging.

### Important wording checks
- The draft **does not overclaim a generic Linux bug**; it keeps the scope on the X11/Xwayland path. ✅
- The draft **does not claim Wayland proves a full fix**; it correctly labels that result as a backend-path split/comparison. ✅
- The draft **does not present the launcher workaround as an engine fix**; it labels it as local mitigation only. ✅

## Version/backend split audit

This is the strongest part of the draft and it is presented correctly.

What the evidence supports:
- broken on the exported default path tested on this machine, which still appears to run through the X11/Xwayland path
- broken there on both `4.6.2` and `4.7.beta1`
- not reproduced in the `4.7.beta1 --display-driver wayland` comparison run

The draft uses careful wording such as "looks like," "appears to mean," and "not proof that the underlying engine issue is fully fixed," which keeps the inference level honest.

## Exact remaining gap / weak point

1. **MRP attachment is not prepared yet.**
   - The draft truthfully says this.
   - That means it is review-ready, but not directly submit-ready for GitHub filing until the ZIP exists and excludes `.godot`.

## Recommendation

Derrick can review this as the candidate upstream issue text.

Before any actual upstream filing:
- prepare and attach the MRP ZIP from `repros/linux-close-minimal/` without `.godot`
- keep the title/body scope exactly this narrow
- preserve the backend-split caveat language
