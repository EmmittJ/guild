# v0.5.0 Release Notes — 2026-03-11

Setup consolidation, skill renames, documentation, and template improvements.

## Breaking Changes

See [BREAKING_CHANGES.md](BREAKING_CHANGES.md) for migration guidance.

- Installed skill directories renamed: `guild-memory` → `markdown-memory`, `guild-inbox` → `markdown-inbox`, `guild-issues` → `github-issues`
- Plugin skills moved from `.github/skills/` to `plugin/skills/` — agents that reference plugin skills by path need updating
- `guild-setup`, `guild-setup-markdown`, `guild-setup-github` consolidated into `setup` — single `/guild:setup` command

## What's New

### Setup consolidation

`guild-setup`, `guild-setup-markdown`, and `guild-setup-github` have been merged into a single `setup` skill. One command — `/guild:setup` — handles team scaffolding, markdown component installation, and GitHub Issues backend setup.

Step 3B (manual team definition) is now fully documented, equivalent in depth to universe casting.

### Skill renames

Installed skill directories use descriptive names rather than the `guild-` prefix:

- `.github/skills/markdown-memory/` (was `guild-memory`)
- `.github/skills/markdown-inbox/` (was `guild-inbox`)
- `.github/skills/github-issues/` (was `guild-issues`)

Skill activation verbs are unchanged (`decision:create`, `issue:read`, `message:create`).

### Documentation

- README: First Session walkthrough, Upgrading section, corrected Option A curl commands
- `train-agent` skill now references the four category templates
- `train-skill` skill has a proper When to Activate heading
- `{HANDOFF_PROMPT}` placeholder documented in builder and advisor template tables

### Design

- Skill discovery design decision recorded — see `.guild/memory/decisions/2026-03-11-skill-discovery.md`

## Upgrade Notes

If you are upgrading from v0.4.x:

1. Re-run `/guild:setup` to reinstall skills under the new directory names, OR rename your installed skill directories manually:
   - `.github/skills/guild-memory/` → `.github/skills/markdown-memory/`
   - `.github/skills/guild-inbox/` → `.github/skills/markdown-inbox/`
   - `.github/skills/guild-issues/` → `.github/skills/github-issues/`

2. Update any agent files that reference old skill names in "At Session Start" sections.
