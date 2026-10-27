# SOLIDWORKS design partner 1.0.0

Use `$solidworks-design-partner` with a rough design idea, detailed specification or revision. Start at [SKILL.md](SKILL.md). It supports verified direct tools, user-run macro source and manual SOLIDWORKS guidance. It requires no Skill Forge installation or new remote service.

Examples: “Develop a printed electronics enclosure”; “Use these complete dimensions and generate VBA source”; “Guide me manually through a hinged bracket”; “Change walls2→3 mm while keeping the exterior fixed.” Quick SOLIDWORKS questions get direct answers; unrelated requests do not activate the design interview.

Copy this complete folder into the host's user skill directory, preserving existing customizations. Current Codex user scope is `~/.agents/skills/`. Invoke by name; restart the host if discovery has not refreshed. This installs instructions/resources only.

See [Windows macros](references/windows-macros.md) for prerequisites, source import, execution, troubleshooting, reruns and the remaining live acceptance procedure. [SmokePlate.bas](examples/SmokePlate.bas) is synthetic source; it is not a binary .swp or an executed CAD model. Use [the brief](templates/design-brief.md) and [manual guide](references/manual-modeling.md) without Windows remote access. Configure version/templates/transfer/paths for your setup.

Release limitations: no Windows compiler or live SOLIDWORKS tests were run by this release build. No native CAD files are bundled; no physical fit or performance is certified. [Integration references](references/integrations.md) describe inspected upstream tools, licenses and limits. All bundled material is original and [MIT licensed](LICENSE). Repository evidence and release packages: [GitHub](https://github.com/HarryBurd33/solidworks-design-partner).
