# SOLIDWORKS design partner

A reusable agent skill that develops rough ideas into buildable specifications and helps construct editable designs in SOLIDWORKS. It proposes geometry, materials and attachment choices, tracks uncertainties and revisions, and selects an execution path from actual capabilities.

## Use

- `$solidworks-design-partner I want a custom 3D-printed enclosure for electronics, with mounting points, cable openings, and a removable lid.`
- `$solidworks-design-partner Here are the complete plate dimensions. Generate VBA source and Windows instructions; do not interview me again.`
- `$solidworks-design-partner Guide me manually through a three-part hinged camera bracket.`
- `$solidworks-design-partner Change the walls from 2 to 3 mm and keep the exterior fixed. Check what no longer fits.`

It activates for developing, modeling, revising or building SOLIDWORKS designs. Complete specifications proceed directly. A quick question such as “What does fully defined mean?” gets a direct answer; an unrelated request does not activate the design workflow.

## Three paths and prerequisites

| Path | What you need | What it provides |
|---|---|---|
| Direct construction | Verified tools reaching the intended live Windows SOLIDWORKS document and supporting the requested operations | Actual model changes, saves and exports only when executed and checked |
| User-run automation | Agent source authoring; compatible Windows SOLIDWORKS/VBA environment; verified templates, transfer and output paths | Honest source plus setup/run/troubleshooting and acceptance instructions |
| Manual guidance | SOLIDWORKS on the user's machine | Manageable planes, sketches, constraints, dimensions, features and checks |

The skill itself needs only an agent that can read Markdown. It works without Skill Forge, Python, an MCP server or a paid API. Python3.9+ is optional for repository release checks. The bundled smoke source is VBA, with no added runtime dependency; verify macro support and template paths for the installed release. VSTA alternatives have release-specific prerequisites.

A Mac running Codex and a separate Windows PC running SOLIDWORKS are supported through source/manual handoff. No connection, transfer arrangement or Windows execution is assumed. Configure the actual host, version/edition, templates, add-ins, paths and supported operations when relevant. [Optional integrations and provenance](solidworks-design-partner/references/integrations.md) are research references only.

## Install

Copy the whole `solidworks-design-partner/` folder, including its resources, into your verified user skill directory. Current Codex documentation identifies `~/.agents/skills/` for user scope; see [official skill locations](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills). Do not overwrite an existing customized folder: compare/back it up and merge deliberately. Other hosts may use different locations.

For a fresh user-level install from the repository root:

```sh
mkdir -p "$HOME/.agents/skills"
test ! -e "$HOME/.agents/skills/solidworks-design-partner" && cp -R solidworks-design-partner "$HOME/.agents/skills/solidworks-design-partner"
```

For the ZIP, extract the single `solidworks-design-partner/` directory there instead. Codex normally detects skill changes; if it does not appear, restart the app and invoke `$solidworks-design-partner`. Installation does not add Windows tools or grant remote access. To uninstall, preserve any customizations, then remove only this skill's folder.

## Resources

- [Core skill](solidworks-design-partner/SKILL.md)
- [Editable design brief](solidworks-design-partner/templates/design-brief.md)
- [Windows source/import/run/troubleshooting guide](solidworks-design-partner/references/windows-macros.md)
- [Synthetic smoke source](solidworks-design-partner/examples/SmokePlate.bas)
- [Manual modeling guide](solidworks-design-partner/references/manual-modeling.md)
- [Direct capability verification](solidworks-design-partner/references/direct-access.md)
- [Validation evidence and limits](docs/VALIDATION.md)

## Release and limitations

Run `python3 scripts/check_release.py` for local structure, links, privacy-pattern and manifest checks; `python3 scripts/check_release.py --package` also creates a deterministic installable ZIP under `dist/`. These checks cannot prove engineering correctness or detect all private information. Review publication contents as well.

No live SOLIDWORKS session, Windows VBA compiler, native CAD creation, rebuild, save/export or physical fit test was available in this release environment. The portable package is usable now; Windows acceptance remains a documented procedure. Text scenario evaluations use synthetic inputs and do not establish CAD correctness, automatic activation in every host, or physical performance. Source generation is distinct from execution and verified outputs.

Original material is [MIT licensed](LICENSE), copyright2026 HarryBurd33. Linked projects and official documentation retain their own licenses and terms; no third-party implementation is bundled.
