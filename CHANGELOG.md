# Changelog

All notable changes to this project are documented here.

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
