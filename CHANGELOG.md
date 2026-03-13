# Changelog

All notable changes to this project are documented here.

## [v0.6.0] — 2026-03-13

Work-cycle skill, beads full integration, guild team recast, CI, and pre-public cleanup.
See [release notes](docs/releases/v0.6.0/RELEASE_NOTES.md).

### Added

- `work-cycle` skill — session discipline (orient, claim, work, land the plane); wired into all agent At Session Start / At Session End sections
- `beads` skill — full agentskills.io-compliant wrapper for `bd` CLI issue tracker; adopted as default issue backend for this repo
- `sync-skills.sh` / `sync-skills.ps1` — syncs plugin skills to installed locations
- Prettier CI workflow — `npx prettier@3.8.1 --check .` on push/PR; Node.js 18+ required
- PreCompact snapshot hook and session-end git gate as plugin hooks
- Security Engineer role template in `train-agent`

### Changed

- Guild agents recast: guild-master (orchestrator), steward (planning), wright (implementation), scribe (version control) — legacy charter/smith/auditor/invoker roles retired
- Session startup sequenced by routing skill's Installed Skills table
- Orchestrate skill updated: full-read directive, parallel agent dispatching
- Markdown and github-issues documented as first-class backends alongside beads
- `sync-skills` stamps `metadata.asset` paths into installed SKILL.md copies
- README: three install paths, full VS Code setup walkthrough
- beads-setup reference: Dolt remote wiring section added
- Contributing guide updated: fork → branch → PR workflow

### Breaking

- `.guild/` renamed to `.agents/` — move existing memory/decisions/inbox files and update agent file paths
- Setup simplified to cast-only flow — manual team-definition step (Step 3B) removed
- `plugin.json` removed — `marketplace.json` is the single canonical plugin manifest

## [v0.5.0] — 2026-03-11

Setup consolidation, skill renames, documentation, and template improvements.
See [release notes](docs/releases/v0.5.0/RELEASE_NOTES.md).

### Changed

- Merged `guild-setup`, `guild-setup-markdown`, and `guild-setup-github` into a single `setup` skill — one command (`/guild:setup`) handles team scaffolding and component installation
- Renamed `guild-tasks` to `github-issues` — skill activation verbs are now `issue:create`, `issue:update`, `issue:read`, `issue:ready`
- Moved plugin skills from `.github/skills/` to `plugin/skills/` — plugin-owned files no longer live alongside host-owned installed components
- Updated `metadata.asset:` paths in `markdown-memory`, `markdown-inbox`, `github-issues`, `routing` to point to new `plugin/skills/setup/assets/` location

### Breaking

- Installed skill directories renamed: `guild-memory` → `markdown-memory`, `guild-inbox` → `markdown-inbox`, `guild-issues` → `github-issues` — re-run `/guild:setup` or rename manually
- Plugin skills moved from `.github/skills/` to `plugin/skills/` — update any agent files referencing old paths
- Setup commands consolidated — `guild-setup`, `guild-setup-markdown`, `guild-setup-github` replaced by `/guild:setup`

## [v0.4.0] — 2026-03-10

Architect agent, orchestration lifecycle, RBAC hardening, plugin distribution fix, guild-setup team scaffolding.
See [release notes](docs/releases/v0.4.0/RELEASE_NOTES.md).

### Added

- `architect` agent — technical counterpart to charter; owns architecture decisions, design patterns, and technical strategy
- Orchestrate skill v0.4 — Issue Lifecycle Management with monitoring checkpoints and escalation rules
- Task labeling strategy v2 — labels are optional; ground truth is GitHub issue state; `blocked` is the only gate
- Documentation release structure — versioned `docs/releases/vX.Y.Z/` with RELEASE_NOTES.md and BREAKING_CHANGES.md
- `markdown-memory@guild` and `guild-setup-github@guild` plugin definitions — fixes silent install failures
- guild-setup v0.2 — optional team agent scaffolding step

### Fixed

- Auditor RBAC — removed `edit` and `execute` tools; quality gate is now enforced at tooling level
- Stale planning artifact removed from team memory decisions

## [v0.3.0] — 2026-03-10

Thematic agent naming. All agents renamed to craftsmanship-aligned names.
See [release notes](docs/releases/v0.3.0/RELEASE_NOTES.md).

### Added

- Thematic agent names: charter, smith, auditor, invoker
- Role column in routing table
- Breaking change documentation and migration guide

### Breaking

- Agent file renames — consumers must re-run setup scripts

## [v0.2.0] — 2026-03-10

Skill namespace rename. All installable data skills prefixed with `guild-`.
See [docs/releases/v0.2.0/](docs/releases/v0.2.0/).

### Changed

- Renamed installable skills to use `guild-` prefix: `memory` → `guild-memory`, `tasks` → `guild-tasks`, `inbox` → `guild-inbox`

### Breaking

- Skill name changes — consumers must re-run setup scripts
