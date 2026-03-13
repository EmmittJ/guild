---
name: beads
description: >
  Persistent memory system for multi-session AI work. Git-backed issue tracker with
  dependency graphs, compaction-safe notes, session handoff, and agent coordination.
  Activate when: issue:create — work needs tracking across sessions; issue:claim —
  taking atomic ownership of an issue; issue:update — updating metadata, notes, or
  priority; issue:close — completing an issue; issue:read — checking available or
  in-progress work; issue:ready — finding actionable work at session start or before
  planning; memory — writing notes that survive compaction; session handoff — handing
  off context to a future session; agent coordination — tracking multi-agent work.
  DO NOT USE FOR: single-session checklists (use TodoWrite). Decisions, insights, or
  team context — use decision:create. Inbox messages — use message:create.
license: MIT
compatibility: Requires bd CLI v0.47.0+ in PATH. Run `bd --version` to verify.
metadata:
  asset: ../../../plugin/skills/setup/assets/skills/beads/SKILL.md
  version: "0.2"
---

## Overview

beads (`bd`) is a persistent memory system for AI agents. Issues live in a Dolt database
inside the repo — they survive conversation compaction, session resets, and long gaps between
sessions. Use beads when work spans multiple sessions, has dependencies, or needs to survive
context loss.

Run `bd prime` for AI-optimized full workflow context.
Run `bd <command> --help` for command syntax.

**bd vs TodoWrite:**

| bd (persistent)       | TodoWrite (ephemeral) |
| --------------------- | --------------------- |
| Multi-session work    | Single-session tasks  |
| Complex dependencies  | Linear execution      |
| Survives compaction   | Conversation-scoped   |
| Git-backed, team sync | Local to session      |

See [references/BOUNDARIES.md](references/BOUNDARIES.md) for detailed decision criteria.

## Prerequisites

```bash
bd --version  # requires v0.47.0+
```

- `bd` CLI installed and in PATH
- Git repository (`bd` requires git)
- `bd init` run once by a human — **agents must NOT run `bd init`**

## Session Start — `issue:ready`

Always run at session start when bd is available:

```bash
bd ready --json          # unblocked work ready to claim
bd status --json         # database snapshot (like git status)
```

If in_progress issues exist from a prior session, run `bd show <id> --json` for each and read the `notes` field to recover context.

**Diagnostics:**

```bash
bd dolt show             # connection status + remotes + config sources
bd doctor                # check/fix installation health
bd prime                 # AI-optimized workflow context
bd status                # counts by status
bd list --all            # every issue regardless of status
```

## Create — `issue:create`

```bash
# Basic
bd create "Title" --description="Detailed context" -t bug|feature|task|epic|chore -p 0-4 --json

# Special characters in description — use stdin
echo 'Description with `backticks` and "quotes"' | bd create "Title" --description=- --json

# With dependency (discovered during other work)
bd create "Title" --description="…" --deps discovered-from:<parent-id> --json
```

Priority: `0` critical · `1` high · `2` medium (default) · `3` low · `4` backlog

See [references/ISSUE_CREATION.md](references/ISSUE_CREATION.md) for when and how to create issues.

## Read — `issue:read`

```bash
bd show <id> --json                           # full context for one issue
bd list --status open --json                  # all open issues
bd list --status open --priority 1 --json     # filtered
bd ready --json                               # unblocked issues only
bd stale --days 30 --json                     # forgotten issues
```

**JSON output shapes differ by command:**

- `bd ready --json` / `bd list --json` → flat array `[{id, title, status, ...}]`
- `bd show <id> --json` → nested object `{issue: {id, title, ...}}`

## Claim — `issue:claim`

```bash
bd update <id> --claim --json   # atomic claim — sets status to in_progress, assigns to current session
```

Claiming is the contract that prevents two agents from working the same task. Always claim before starting. If `bd update --claim` returns an error, the issue is already claimed by another agent — find a different issue.

## Update — `issue:update`

```bash
bd update <id> --claim --json                 # claim atomically (sets in-progress)
bd update <id> --status in-progress --json
bd update <id> --priority 1 --json
bd update <id> --notes "COMPLETED: x. IN PROGRESS: y. NEXT: z." --json

# stdin for special chars
echo 'Updated text' | bd update <id> --description=- --json
```

Valid statuses: `open` · `in_progress` · `blocked` · `deferred` · `closed` · `pinned` · `hooked`
There is NO `failed` status — for failures, use `bd update <id> --status=blocked --append-notes "reason"`.

**DO NOT use `bd edit`** — opens an interactive editor agents cannot use.

See [references/RESUMABILITY.md](references/RESUMABILITY.md) for how to write notes that survive compaction.

## Close — `issue:close`

```bash
bd close <id> --reason "What was done and why" --json   # terminal state — marks work complete
bd update <id> --status=blocked --append-notes "reason" # non-terminal update
bd reopen <id>                                          # undo a close
```

Do NOT use `bd update --status=closed` — that flag is not the close command. Use `bd close`.

**⚠️ Stale in_progress:** Issues moved to `in_progress` stay there until explicitly closed. Agents MUST call `bd close <id> --reason "..."` at task completion. If a session ends without closing, the issue stays in_progress and must be manually closed next session. Stale in_progress issues cause `bd ready` to be unreliable.

## Sync

```bash
bd sync                 # sync with Dolt remote (if configured)
bd dolt push            # explicit Dolt push
```

**Remote wiring — two-step required:**

```bash
bd dolt remote add origin git+https://github.com/owner/repo.git
bd dolt remote list   # must show [SQL + CLI], not [CLI only]
# If [CLI only]: re-run the add command (idempotent), then verify again
bd dolt push          # only push when [SQL + CLI] confirmed
```

## Dependencies

```bash
bd dep add <id> blocks <other-id>             # A blocks B
bd dep add <id> discovered-from <parent-id>   # side quest link
bd dep tree <id>                              # visualize graph
```

See [references/DEPENDENCIES.md](references/DEPENDENCIES.md) for dependency semantics.

## Compaction Survival

Write structured notes before any context-heavy operation:

```bash
bd update <id> --notes "COMPLETED: what's done. IN PROGRESS: current state.
NEXT: what comes next. KEY DECISIONS: why we chose X." --json
```

After compaction — run `bd list --status in_progress --json` then `bd show` each one.

See [references/RESUMABILITY.md](references/RESUMABILITY.md) for full patterns.

## Agent Registration — `agent:register`

When a new agent is added to the team, register it in beads.

**Key concept:** Roles are persistent shared definitions — they describe a functional position,
not a specific agent. Multiple agents can point to the same role bead. When adding a new agent
that fills an existing role, slot it to the **existing** role bead — don't create a new one.

Both agent and role beads are **pinned** — they never close, never appear in `bd ready`,
and persist as infrastructure in the data plane.

```bash
# 1. Find the matching role — reuse if it exists
bd list --type=role
# Only create a new role if no existing one fits:
bd create "{role-name}" --type=role --description="{what this role owns}" --json

# 2. Create the agent bead
bd create "{agent-name}" --type=agent --description="{one-liner from agent frontmatter}" --json
# → returns {agent-id}

# 3. Add system label (required for slot commands to work)
bd update {agent-id} --add-label "gt:agent" --json

# 4. Slot agent to its role (required — role slot is mandatory)
bd slot set {agent-id} role {role-id}

# 5. Verify
bd slot show {agent-id}
```

**Agent states** — agents self-report state during work:

```bash
bd agent state {agent-id} working    # actively executing
bd agent state {agent-id} stuck      # blocked, needs help
bd agent state {agent-id} idle       # waiting for work
bd agent heartbeat {agent-id}        # update last_activity
bd agent show {agent-id}             # full agent details
```

**Work dispatch** — attach work to an agent's hook:

```bash
bd slot set {agent-id} hook {issue-id}   # attach work
bd slot clear {agent-id} hook            # detach when done
```

See [references/AGENTS.md](references/AGENTS.md) for full agent bead architecture.

## Advanced features

| Feature               | Command              | Reference                                                 |
| --------------------- | -------------------- | --------------------------------------------------------- |
| Molecules (templates) | `bd mol --help`      | [MOLECULES.md](references/MOLECULES.md)                   |
| Chemistry (pour/wisp) | `bd pour --help`     | [CHEMISTRY_PATTERNS.md](references/CHEMISTRY_PATTERNS.md) |
| Agent beads           | `bd agent --help`    | [AGENTS.md](references/AGENTS.md)                         |
| Async gates           | `bd gate --help`     | [ASYNC_GATES.md](references/ASYNC_GATES.md)               |
| Worktrees             | `bd worktree --help` | [WORKTREES.md](references/WORKTREES.md)                   |
| Workflows             | `bd prime`           | [WORKFLOWS.md](references/WORKFLOWS.md)                   |
| Full CLI              | `bd <cmd> --help`    | [CLI_REFERENCE.md](references/CLI_REFERENCE.md)           |
