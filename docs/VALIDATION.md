# Validation record — release 1.0.0

Accepted for the available portable source/text scope on 2026-10-26 (America/Denver). This release does not claim live SOLIDWORKS or physical validation.

## Executed evidence

- Structural validation: Skill Forge's generic validator passed nine skill files and 14 relative resource references. The standalone release checker passed required files, metadata, 41 local Markdown links in the final repository, license equality, limited private-path/credential patterns and the final hash manifest. Privacy checks are limited patterns plus review, not a guarantee that arbitrary content is safe to publish.
- Text scenarios: 13 actual baseline and 13 actual initial candidate responses are retained. Initial candidate: 24/26, eleven cases meeting criteria and two partial (C1 material recommendation; C11 manual fallback), zero critical failures. The baseline scored 26/26 but had research context and accidental criteria exposure. This is not a clean causal comparison and establishes no improvement over a direct prompt. Candidate responses were saved before expected-criteria/baseline reads; a JSON serialization quote defect was then repaired without changing the text. Grading is non-blind and candidate self-grading is a limitation.
- Repairs and follow-up: concrete conditional material choices and concrete safe manual continuation were added; the Windows source's drive-root parent handling and stale dimension dialog were fixed. Two original regressions plus two new held-out scenarios produced four fresh responses scoring 8/8, zero critical failures. Their expectations were visible in the follow-up. The other eleven original cases were not regenerated. The independent final resource review found no remaining material source/text gap.
- Source checks: explicit millimeter-to-meter conversions, new-document/collision ordering, directory guard, checked results/errors, native-file checks and no intentional existing-document close passed static inspection. Independent path-string checks include drive root, nested and UNC cases; they do not execute VBA or test a Windows filesystem. Decimal arithmetic checked the supplied unit/revision/enclosure fixtures independently of CAD.
- Packaging and install: the deterministic ZIP passed CRC and SHA-256 comparison for all nine released skill files. The actual global user-level installed copy matches those same nine hashes. The installer adds one local administrative receipt, excluded from the release. Native Codex `skills/list` with reload found the installed skill enabled in user scope from two working directories; no model turn was started. Discovery does not prove automatic activation on every future request.

Native workers inherited configured model settings; the exact active model/effort and task-attributable tokens, subscription usage and API dollars were unknown. No separate paid API route was used. The researcher, constructor and independent evaluator were actual separate native agents; the evaluator also generated and graded candidate text, which limits independence.

## Evidence files

- [Frozen cases](../validation/cases.json), [follow-up cases](../validation/followup-cases.json), and [evidence hashes](../validation/evidence-manifest.json)
- [Baseline responses](../validation/baseline-responses.json), [candidate responses](../validation/candidate-responses.json), [original grades](../validation/model-grades.json), [follow-up responses/grades](../validation/followup-results.json)
- [Initial independent review](../validation/independent-review.md), [final independent review](../validation/final-review.md), [execution limits/privacy transformation](../validation/execution-notes.md), [response provenance](../validation/response-provenance.json)
- [Final source checks](../validation/final-source-static-checks.json), [root-path oracle](../validation/root-path-check.json), [arithmetic results](../validation/arithmetic-checks.json), [release manifest](../release-manifest.json)

Original response hashes identify the retained private raw execution record. The public candidate copy replaces only absolute local build-root prefixes with `<REPO_ROOT>/`; its distinct public hash is recorded. No private build state or actual design data is published. All design and capability fixtures are synthetic.

## Unavailable Windows acceptance

No intended live Windows session, installed SOLIDWORKS version/edition, transfer bridge or real CAD document was verified. VBA compilation, COM behavior, actual sketch/feature/dimension checks, rebuild, native save/reopen, exports, assembly mates/fit/interference and physical performance remain unexecuted. Generated source and authored examples are not models or runtime results.

Use the [Windows acceptance table](../solidworks-design-partner/references/windows-macros.md#check-the-resulting-model-on-windows) on the actual installation. Run the unchanged synthetic plate in a new document and fresh output, compile first, measure 80 × 40 × 3 mm, inspect editable features and one body, rebuild/save/reopen, and check rerun preservation. Verify requested exports separately. Production enclosures and assemblies need their own requirement/evidence records and relevant physical testing.
