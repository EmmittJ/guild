# Changelog

All notable changes to this project are documented here.

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
