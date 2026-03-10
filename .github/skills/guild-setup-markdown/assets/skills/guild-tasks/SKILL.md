---
name: guild-tasks
description: >
  File-based task store for a team of agents. Tasks live as Markdown files in
  ${tasks_root}/open/, in_progress/, and closed/ — the directory is the status, moving a file
  is the state transition. No write conflicts, no shared status fields.
  Activate when: `task:item:create` — work needs tracking across sessions; `task:item:update` —
  claiming, unclaiming, or completing a task; `task:item:read` — checking available or in-progress work;
  `task:ready` — finding actionable work at session start or before planning.
  DO NOT USE FOR: decisions, insights, or context — use the memory skill. Inbox messages — use the inbox skill.
license: MIT
metadata:
  version: "0.2"
---

## Overview

The tasks root for this repo is `${tasks_root}` (relative to repo root).

```
${tasks_root}/
  open/          ← unclaimed work
  in_progress/   ← claimed; agent name in frontmatter
  closed/        ← completed; audit trail, never delete
```

---

## Session Start

1. `${tasks_root}/in_progress/` — tasks you claimed in a prior session (resume or unclaim)
2. `${tasks_root}/open/` — available work (check here before creating new tasks)

---

## Task Format `task:item:create` `task:item:update` `task:item:read`

Filename: `{slug}.md` — short and descriptive, e.g. `add-auth-tests.md`

```markdown
---
priority: high | medium | low
agent: {assigned agent name, or empty if unclaimed}
created: YYYY-MM-DD
blocked-by:
  - {slug of blocking task}
  - {slug of another blocking task}
---

# {Task title}

## What
{What needs to be done. Specific enough that an agent can start without asking.}

## Done when
{Acceptance criteria. What does completion look like?}

## Context
{Links to relevant decisions, files, insights, or other tasks.}
```

---

## State Transitions `task:item:update`

```
open/ → in_progress/    claim: set agent: field, move file
in_progress/ → open/    unclaim: clear agent: field, move file back
in_progress/ → closed/  complete: append outcome note, move file
```

---

## Ready Work `task:ready`

Returns open, unblocked tasks sorted by priority (high → medium → low → unset).

**"Ready" means:** in `${tasks_root}/open/` directory — NOT blocked (all `blocked-by:` slugs exist in `closed/`).

**Implementation — three-step process:**

1. List all files in `${tasks_root}/open/`
2. For each, read `blocked-by:` frontmatter — skip any task where a referenced slug is **not** in `closed/`
3. Sort remaining by `priority:` field: `high` → `medium` → `low` → unset

```sh
# Pseudo-implementation — agents use their read/search tools for this
for f in ${tasks_root}/open/*.md; do
  blocked_by=$(grep "^blocked-by:" "$f" | sed 's/blocked-by://')
  # check each slug exists in closed/
done
# sort remaining by priority: high → medium → low → unset
```

> **Note:** This is pseudocode for illustration. Agents implement this using their read/search tools directly on the filesystem.

---

## Rules

- Check `open/` before creating new tasks — avoid duplicates
- When claiming: update `agent:` and move in the same operation
- Check `blocked-by:` before claiming — don't start blocked work
- `blocked-by:` accepts a list of slugs — all listed tasks must be closed before this one can start
- When you complete a task, check whether any other task was `blocked-by` it — those tasks are now unblocked
- `closed/` is an archive — never delete, never edit
- One file per task — never append to another agent's task file
