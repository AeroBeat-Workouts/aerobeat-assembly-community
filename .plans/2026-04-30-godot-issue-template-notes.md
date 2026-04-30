# Godot bug issue template + reporting guidance notes

**Date:** 2026-04-30  
**Scope:** Internal research only for review-ready upstream draft  
**Repo:** `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community`

## Sources

1. Godot GitHub bug template  
   `https://raw.githubusercontent.com/godotengine/godot/master/.github/ISSUE_TEMPLATE/bug_report.yml`
2. Godot contributing guide (`Reporting bugs`)  
   `https://raw.githubusercontent.com/godotengine/godot/master/CONTRIBUTING.md`
3. Godot contributing docs (`Testing and reporting issues`)  
   `https://contributing.godotengine.org/en/latest/feedback/reporting_issues.html`
4. Godot release policy (supported versions guidance referenced by template)  
   `https://docs.godotengine.org/en/latest/about/release_policy.html`

## Current required bug-template fields

The current GitHub bug template requires these sections:

1. **Tested versions**
   - Must list versions where the bug reproduces.
   - Should also list versions where it does **not** reproduce when known.
   - Include the **Git commit hash** for development/non-official builds.
   - They explicitly want regression-shape evidence when available.

2. **System information**
   - Required.
   - For OS/graphics/platform issues, include OS version, CPU architecture/model, GPU, driver, and rendering/backend details when relevant.
   - Template warns reports may be closed if this is missing.

3. **Issue description**
   - Brief summary of what is broken vs expected.
   - Logs/code should be text, not screenshot-only.
   - Screenshots/videos are allowed as supplements, not replacements.

4. **Steps to reproduce**
   - Required.
   - Must be concrete and reproducible.
   - If an MRP exists, explain exactly how to use it.

5. **Minimal reproduction project (MRP)**
   - Required field.
   - If project-independent, they allow `N/A`.
   - Otherwise they strongly want a small ZIP without the `.godot` folder, under 10 MB.
   - For non-C# engine bugs, prefer a GDScript MRP if possible.

## Guidance that matters for our Linux exported close-path bug

### Recommended evidence to include

- **One bug only.** Keep the issue narrowly framed as the exported Linux close-path bug on the X11/Xwayland path; do not mix in launcher workaround design or unrelated teardown history.
- **Version matrix.** Include at minimum:
  - reproducible on current supported stable used for the repro,
  - reproducible on current comparable prerelease/default-path run,
  - not reproducible on forced native Wayland run if that is a different backend path rather than a version fix.
- **Exact build IDs.** Use full Godot version strings/commit hashes where available, especially for `4.7.beta1.official.1c8cc9e7e`.
- **System/backend specificity.** State Wayland desktop session plus the fact that the failing exported binary still exercises the X11/Xwayland path by default, while forced `--display-driver wayland` closes cleanly.
- **Concrete expected vs actual behavior.** Expected: exported app should close normally when window manager requests close. Actual: repeated `BadWindow`, hang until forced kill, exit `143` on X11/Xwayland path.
- **MRP path and packaging notes.** Point to the standalone minimal repro in `repros/linux-close-minimal/`, then prepare a submission ZIP that excludes `.godot`.
- **Exact repro steps.** Include export/build/run/close steps, not just "close the app".
- **Artifacts as supporting evidence.** Link or summarize logs proving the backend split, but keep the main issue readable.

### Pitfalls to avoid

- Do **not** claim a generic Linux close bug if the evidence is specifically **X11/Xwayland path broken, Wayland-native path clean**.
- Do **not** present the local launcher workaround as an engine fix.
- Do **not** omit unsupported-version context; the template explicitly asks for supported/latest verification.
- Do **not** dump giant logs inline. Include concise excerpts in the issue body and keep larger artifacts attached or summarized.
- Do **not** rely on screenshots of logs/errors.
- Do **not** mix AeroBeat-specific app behavior into the core report when the standalone repro already isolates the engine/runtime path.
- Do **not** forget the MRP upload instructions: ZIP, no `.godot`, wait for upload completion.

## Recommended review-only draft structure

Use this order so the draft stays template-compliant while preserving readability:

1. **Title**
   - Descriptive, one bug only.
   - Candidate shape: `Linux exported app hangs on close with repeated BadWindow on X11/Xwayland path, but closes cleanly on native Wayland`

2. **In Plain English** *(internal readability aid; add near top of Issue description, not as a replacement for required fields)*
   - 2-4 bullets:
     - what breaks,
     - where it breaks,
     - what comparison makes it credible,
     - why it matters.

3. **Tested versions**
   - Reproducible in: stable + 4.7 beta1 default export path.
   - Not reproducible in: 4.7 beta1 forced native Wayland path.
   - Call out that the “not reproducible” case is a backend-path distinction, not proof of a full engine fix.

4. **System information**
   - Full host/system info copied from Godot where possible, then add explicit session/backend notes if the standard string does not capture them.

5. **Issue description**
   - Brief actual vs expected.
   - State that a standalone minimal repro isolates the issue from AeroBeat.
   - Mention X11/Xwayland failure vs native Wayland clean close.

6. **Steps to reproduce**
   - Keep numbered.
   - Include the exact exported-run path that hits the bad behavior.
   - Include the comparison run that forces Wayland.

7. **Minimal reproduction project (MRP)**
   - Provide the ZIP attachment reference and a one-line description of how to run/export it.
   - Mention that `.godot` was excluded.

8. **Optional concise supporting notes inside Issue description or end of Steps**
   - brief log excerpt (`BadWindow`, forced-kill exit `143`),
   - explicit backend evidence,
   - why this appears backend/path specific.

## Best framing for this draft

Frame it as:
- **an exported Linux app close-path bug**
- **reliably reproducible in a standalone minimal project**
- **specifically failing on the X11/Xwayland path**
- **not reproducing on the forced native Wayland path in current prerelease testing**

That framing matches the evidence and avoids overstating the claim.
