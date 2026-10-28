# Anatomy outline update — 1.1.0

This release adds a proportionate concept outline before CAD or macro construction: parts, dimensions/datums, interfaces, assumptions and feature order. “Outline only” stops before construction; already authorized complete builds avoid a new approval ceremony. Corrections propagate through the outline, brief, parameters and downstream build/check artifacts.

The original Node20.10+ renderer uses the unmodified MIT Anatomy isometric core at revision1482e8469b0a9e0d8cc18ea2740a01423d29ae80, with its original copyright2026 Ryan and complete license retained. It emits editable SVG, self-contained HTML with assembled/exploded views, and the input parameters. The preview table and geometry use the same values. See [notices](../solidworks-design-partner/THIRD_PARTY_NOTICES.md) and the [synthetic preview](../examples/concept-preview/outline.html).

## Evidence

The saved candidate’s inspected source hashes and frozen case hash were rechecked before adoption. Nine parent CLI checks and nine independent CLI checks passed. Actual headless Chrome screenshots of assembled/exploded states were visually inspected; DOM checks confirmed three part transforms and an unchanged dimension table. Static source/resource checks passed. See [CLI evidence](../validation/anatomy-update/cli-checks.json), [browser evidence](../validation/anatomy-update/browser-checks.json), and [independent review](../validation/anatomy-update/review.md).

Actual compact model responses scored baseline16/18 and candidate18/18 with zero critical failures. The narrow observed benefit is explicit outline-before-construction ordering. The same executor saw both versions and expectations; grading was nonblind and the sample small. This does not establish causal or general improvement. [Responses/grades](../validation/anatomy-update/model-evaluation.json) and [frozen cases](../validation/anatomy-update/cases.json) retain the actual evidence.

## Limits and next tests

The renderer supports boxes and vertical cylinders as simplified envelopes. It does not provide CAD import/export, Boolean holes/cutouts, rotations about arbitrary axes, engineering drawings, true interference/tolerance checks or physical fit/strength verification. A part-level status does not replace parameter provenance in the brief. Full Anatomy WebGL/live3D/React/PDF/gallery functionality is not bundled. Missing dimensions or missing Node use a written/symbolic outline instead.

Windows VBA compilation and actual SOLIDWORKS model/feature/rebuild/save/reopen/export tests remain deferred by user instruction. The existing [Windows smoke procedure](../solidworks-design-partner/references/windows-macros.md) is unchanged. Direct control still requires a verified intended Windows connection. No preview or successful source test proves live CAD success or physical performance.

Release acceptance additionally requires the installed user-level copy and published ZIP/source to match the release manifest; those comparisons are performed during delivery, with exact commit recorded in the delivery report.

## Installation verification

The actual managed user-level copy reports version1.1.0 and all15 release-file hashes match the manifest. Nine renderer checks executed against that installed copy passed; native Codex skills/list with forceReload discovered it enabled in user scope from two working directories, without starting a model turn. [Installed test record](../validation/anatomy-update/installed-checks.json).
