# v0.6.0 Release Notes — 2026-03-13

Work-cycle skill, beads full integration, guild team recast, CI, and pre-public cleanup.

## Breaking Changes

See [BREAKING_CHANGES.md](BREAKING_CHANGES.md) for migration guidance.

- `.guild/` renamed to `.agents/` — move any existing memory/decisions/inbox files and update agent file paths
- Setup simplified to cast-only flow — Step 3B manual team-definition step removed
- `plugin.json` removed — `marketplace.json` is the single canonical plugin manifest

## What's New

### work-cycle skill (new)

A new `work-cycle` skill codifies session discipline: orient by checking ready work at session start, claim issues atomically before starting, work, and land the plane cleanly at session end (file remaining issues, push to remote, verify clean state). Backend-agnostic — works with beads, markdown-issues, or github-issues. All agent files now include At Session Start / At Session End sections wired to this skill.

### Beads (bd) full integration

A new `beads` skill wraps the `bd` CLI issue tracker in a full agentskills.io-compliant format with progressive disclosure, a CLI reference, and workflow guidance. `bd` is adopted as the default issue backend for the guild repo itself. The `sync-skills` script now stamps `metadata.asset` paths into installed SKILL.md copies. Agent and role registration is wired into the train-agent workflow.

### Routing-driven skill discovery

Session startup is now sequenced by the routing skill's Installed Skills table, ensuring agents discover available skills in a consistent order. The orchestrate skill has been updated with a full-read directive and parallel agent dispatching.

### Guild team recast to crafters

The guild's own agents are renamed to match the crafter theme: steward (planning + design), wright (implementation), scribe (version control), with guild-master as orchestrator. The reviewer/auditor role is retired — peer review is handled by specialists via the orchestrator. Legacy roles charter, smith, auditor, and invoker are no longer included.

### Markdown and github-issues lifted to primary tier

Both backends are now documented as first-class options. Positioning: markdown = lightweight default, beads = full replacement, github-issues = partial drop-in.

### CI and formatting

A Prettier linting workflow is added — CI checks `npx prettier@3.8.1 --check .` on push and pull request. Node.js 18+ is required. Scribe guidelines updated to reflect the formatting requirement.

### sync-skills scripts

New `scripts/sync-skills.sh` and `scripts/sync-skills.ps1` synchronize plugin skills to their installed locations, keeping beads and other bundled skills up-to-date after a pull.

### Documentation and pre-public cleanup

- README: three install paths (script, Copilot CLI, VS Code) and a full VS Code setup walkthrough
- `beads-setup` reference: Dolt remote wiring section
- Contributing guide: fork → branch → PR workflow
- `train-agent`: Security Engineer role template and enhanced role-template mapping
- Wright agent description corrected; stale `res/` artifacts removed; releases index updated

## Upgrade Notes

If you are upgrading from v0.5.x:

1. **Rename `.guild/` to `.agents/`** — move all files from `.guild/` to `.agents/` and update any agent files that reference `.guild/` paths.

2. **Remove `plugin.json`** if present — `marketplace.json` is now the sole plugin manifest.

3. **Re-run `/guild:setup`** to reinstall agents under the new naming conventions, or update your agent files manually to use the new team names (steward, wright, scribe).

4. **Install the work-cycle skill** — add `work-cycle` to your routing skill's Installed Skills table and add At Session Start / At Session End sections to your agent files.

5. **Run `scripts/sync-skills.sh` (or `.ps1`)** after pulling to keep plugin skills in sync with installed copies.
