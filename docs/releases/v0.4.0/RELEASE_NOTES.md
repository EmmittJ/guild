# v0.4.0 Release Notes

## Summary

Quality, distribution, and team model improvements. This release hardens the agent permission model,
fixes the plugin distribution contract, adds the architect agent as a full team member, and formalizes
the orchestration lifecycle and task labeling strategy.

## What's New

### Architect Agent

A new `architect` agent joins the team as technical counterpart to `charter` (product owner). The
architect owns architecture decisions, design patterns, technical strategy, and quality decisions.
Charter and architect are peers — they collaborate or debate depending on the task.

Updated routing default flow:

```
guild-master → charter + architect → engineer/smith/invoker → auditor → scribe
```

### Orchestrate Skill v0.4 — Issue Lifecycle Management

Guild Master now owns the full issue lifecycle through explicit monitoring checkpoints:

- **Create**: Guild Master creates a tracking issue for every delegated task
- **Delegate**: Assigns to specialist with full context
- **Monitor**: Five named checkpoints (Claim Check, Progress Check, Stall Check, Review Check, Commit Check)
- **Escalation**: Four defined intervention patterns (stall, escalation, conflict, quality failure)

### Task Labeling Strategy v2

Labels are optional. Ground truth is GitHub issue state (open/closed). An unlabeled open issue is
immediately actionable. The only gate label is `blocked` — presence means do not start.

Charter no longer adds an `open` label at creation. Priority labels are advisory.

### Documentation Release Structure

All release documentation now lives in `docs/releases/vX.Y.Z/`. Root `CHANGELOG.md` is the single
source of truth for version history. Temporary planning artifacts (implementation guides, executive
summaries) are deleted after release.

## Fixes

### Auditor RBAC Hardening

Removed `edit` and `execute` tools from `auditor.agent.md`. The auditor is a read-only quality gate —
enforced at the tooling level, not just in prose. The maker-checker pattern (implement → review → commit)
now has a hard boundary: the reviewer cannot modify what it reviews.

### Plugin Distribution Fix

`plugin.json` now defines all three plugins advertised in `marketplace.json`:

- `core@guild` — Guild Master + orchestrate, train-agent, train-skill, guild-setup, guild-setup-markdown, guild-setup-github
- `markdown-memory@guild` — guild-memory, guild-inbox, guild-tasks skills (file-based memory/inbox/tasks runtime)
- `guild-setup-github@guild` — guild-setup-github skill (GitHub Issues task tracking setup)

Previously, `markdown-memory@guild` and `guild-setup-github@guild` install handles resolved to nothing,
producing silent failures.

### guild-setup v0.2 — Team Agent Scaffolding

`/guild-setup` now optionally scaffolds starter `.agent.md` files for each team member defined during
setup. The Guild publisher's specialist agents (charter, smith, etc.) are that team's specific
configuration — other repos define their own teams. `guild-setup` now makes that easy.

### Stale Artifact Cleanup

Removed `2026-03-10-agent-tooling-implementation-guide.md` from team memory. This was a planning
artifact for work that is complete. Its presence alongside settled decisions created confusion about
implementation status.

## No Breaking Changes

All changes are additive or hardening fixes. Existing installations continue to work without
modification.

- The auditor RBAC change only affects repos where auditor was being used to edit files — which
  contradicts the agent's documented purpose.
- The `plugin.json` additions are backward-compatible.
- `guild-setup` v0.2 is additive — the new scaffolding step is opt-in.
