---
name: guild-issues
description: >
  File-based issue store for a team of agents. Issues live as Markdown files in
  ${issues_root}/open/, in_progress/, and closed/ — the directory is the status, moving a file
  is the state transition. No write conflicts, no shared status fields.
  Activate when: `issue:create` — work needs tracking across sessions; `issue:update` —
  claiming, unclaiming, or completing an issue; `issue:read` — checking available or in-progress work;
  `issue:ready` — finding actionable work at session start or before planning.
  DO NOT USE FOR: decisions, insights, or context — use the memory skill. Inbox messages — use the inbox skill.
license: MIT
metadata:
  version: "0.2"
---

## Overview

The issues root for this repo is `${issues_root}` (relative to repo root).

```
${issues_root}/
  open/          ← unclaimed work
  in_progress/   ← claimed; agent name in frontmatter
  closed/        ← completed; audit trail, never delete
```

---

## Session Start

1. `${issues_root}/in_progress/` — issues you claimed in a prior session (resume or unclaim)
2. `${issues_root}/open/` — available work (check here before creating new issues)

---

## Issue Format `issue:create` `issue:update` `issue:read`

Filename: `{slug}.md` — short and descriptive, e.g. `add-auth-tests.md`

```markdown
---
priority: high | medium | low
agent: {assigned agent name, or empty if unclaimed}
created: YYYY-MM-DD
blocked-by:
  - {slug of blocking issue}
  - {slug of another blocking issue}
---

# {Issue title}

## What
{What needs to be done. Specific enough that an agent can start without asking.}

## Done when
{Acceptance criteria. What does completion look like?}

## Context
{Links to relevant decisions, files, insights, or other issues.}
```

---

## State Transitions `issue:update`

```
open/ → in_progress/    claim: set agent: field, move file
in_progress/ → open/    unclaim: clear agent: field, move file back
in_progress/ → closed/  complete: append outcome note, move file
```

---

## Ready Issues `issue:ready`

Returns open, unblocked issues sorted by priority (high → medium → low → unset).

**“Ready” means:** in `${issues_root}/open/` directory — NOT blocked (all `blocked-by:` slugs exist in `closed/`).

**Implementation — three-step process:**

1. List all files in `${issues_root}/open/`
2. For each, read `blocked-by:` frontmatter — skip any issue where a referenced slug is **not** in `closed/`
3. Sort remaining by `priority:` field: `high` → `medium` → `low` → unset

```sh
# Pseudo-implementation — agents use their read/search tools for this
for f in ${issues_root}/open/*.md; do
  blocked_by=$(grep "^blocked-by:" "$f" | sed 's/blocked-by://')
  # check each slug exists in closed/
done
# sort remaining by priority: high → medium → low → unset
```

> **Note:** This is pseudocode for illustration. Agents implement this using their read/search tools directly on the filesystem.

---

## Rules

- Check `open/` before creating new issues — avoid duplicates
- When claiming: update `agent:` and move in the same operation
- Check `blocked-by:` before claiming — don't start blocked work
- `blocked-by:` accepts a list of slugs — all listed issues must be closed before this one can start
- When you complete an issue, check whether any other issue was `blocked-by` it — those issues are now unblocked
- `closed/` is an archive — never delete, never edit
- One file per issue — never append to another agent's issue file
