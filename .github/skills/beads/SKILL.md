---
name: beads
description: >
  Git-backed issue tracker for multi-session work with dependencies and persistent memory.
  Activate when: issue:create — work needs tracking across sessions; issue:update — claiming,
  updating, or completing an issue; issue:read — checking available or in-progress work;
  issue:ready — finding actionable work at session start or before planning.
  DO NOT USE FOR: decisions, insights, or context — use memory:decision:create.
  Inbox messages — use inbox:message:create.
license: MIT
metadata:
  version: "0.1"
  asset: ../../../plugin/skills/setup/assets/skills/beads/SKILL.md
---

## Overview

beads is a `bd` CLI graph issue tracker. Issues are stored in a Dolt database inside the repo and survive conversation compaction. Use `bd prime` for AI-optimized full context; `bd <command> --help` for syntax.

## Prerequisites

```bash
bd --version  # requires v0.47.0+
```

- `bd` CLI installed and in PATH
- Git repository (`bd` requires git)
- `bd init` run once by a human — agents must NOT run `bd init`

## issue:ready — Session start

Find unblocked work before planning:

```bash
bd ready --json
```

## issue:create — Create an issue

```bash
# Basic
bd create "Title" --description="Detailed context" -t bug|feature|task -p 0-4 --json

# Use stdin for descriptions with special characters (backticks, !, nested quotes)
echo 'Description with `backticks`' | bd create "Title" --description=- --json

# With dependencies
bd create "Title" --description="…" -p 1 --deps discovered-from:<parent-id> --json
```

Priority scale:

- `0` — Critical (security, data loss, broken builds)
- `1` — High
- `2` — Medium (default)
- `3` — Low
- `4` — Backlog

Issue types: `bug`, `feature`, `task`, `epic`, `chore`

## issue:read — Read issues

```bash
bd show <id> --json                          # full context for one issue
bd list --status open --json                 # all open issues
bd list --status open --priority 1 --json   # filtered
```

## issue:update — Update and claim

```bash
bd update <id> --claim --json               # claim atomically
bd update <id> --status in-progress --json
bd update <id> --priority 1 --json
bd update <id> --description "new text" --json

# stdin for special chars
echo 'Updated text' | bd update <id> --description=- --json
```

Do NOT use `bd edit` — it opens an interactive editor that agents cannot use.

## issue:update (complete) — Close an issue

```bash
bd close <id> --reason "What was done" --json
```

## Sync

```bash
bd sync   # sync with Dolt remote (if configured)
```

## Advanced features

Agents can run `bd prime` or `bd <cmd> --help` for depth.

| Feature | Command |
|---------|---------|
| Molecules (templates) | `bd mol --help` |
| Chemistry (pour/wisp) | `bd pour --help`, `bd wisp --help` |
| Agent beads | `bd agent --help` |
| Async gates | `bd gate --help` |
| Worktrees | `bd worktree --help` |
| Full AI context | `bd prime` |
