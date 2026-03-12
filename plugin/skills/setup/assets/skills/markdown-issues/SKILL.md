---
name: guild-issues
description: >
  File-based issue store for a team of agents. Issues live as Markdown files in
  ${issues_root}/open/, in_progress/, and closed/ — the directory is the status, moving a file
  is the state transition. No write conflicts, no shared status fields.
  Activate when: `issue:create` — work needs tracking across sessions; `issue:update` —
  claiming, unclaiming, completing, or writing progress notes on an issue; `issue:read` —
  checking available or in-progress work; `issue:ready` — finding actionable work at session
  start or before planning.
  DO NOT USE FOR: decisions, insights, or context — use the memory skill. Inbox messages — use the inbox skill.
license: MIT
metadata:
  version: "0.3"
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

1. `${issues_root}/in_progress/` — read each file you claimed in a prior session; read the `## Notes` section to recover context before deciding to resume or unclaim
2. `${issues_root}/open/` — available work (check here before creating new issues)

---

## Issue Format `issue:create` `issue:update` `issue:read`

Filename: `{slug}.md` — short and descriptive, e.g. `add-auth-tests.md`

```markdown
---
type: bug | feature | task | chore | epic
priority: high | medium | low
agent: { assigned agent name, or empty if unclaimed }
created: YYYY-MM-DD
blocked-by:
  - { slug of blocking issue }
discovered-from:
  - { slug of issue this was found while working on }
---

# {Issue title}

## What

{What needs to be done. Specific enough that an agent can start without asking.}

## Done when

{Acceptance criteria. What does completion look like?}

## Context

{Links to relevant decisions, files, insights, or other issues.}

## Notes

{Progress notes — updated in place. Write before any context-heavy operation or session end.
Format: COMPLETED: … IN PROGRESS: … NEXT: … KEY DECISIONS: …}
```

**Field notes:**
- `type` — optional but recommended; helps agents filter by kind of work
- `discovered-from` — use when you find side work while working on another issue; creates a lineage trail
- `## Notes` — the compaction-survival field; see **Compaction Survival** below

---

## State Transitions `issue:update`

```
open/ → in_progress/    claim: set agent: field, move file
in_progress/ → open/    unclaim: clear agent: field, move file back
in_progress/ → closed/  complete: update ## Notes with outcome, move file
```

**Updating notes (in-place edit):** Rewrite the `## Notes` section directly — do not append new sections. The Notes section is a rolling snapshot, not a log.

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

## Compaction Survival `issue:update`

Context compaction discards conversation history. Before any long operation or when ending a session, write a progress snapshot into the `## Notes` section of every in-progress issue you own.

**Notes format:**

```
COMPLETED: {what is fully done}
IN PROGRESS: {exact current state — be specific, not vague}
NEXT: {first concrete action when resuming}
KEY DECISIONS: {choices made that affect future work}
```

**Recovery after compaction:**

1. List `${issues_root}/in_progress/`
2. Read the `## Notes` section of each file you own
3. Resume from "NEXT" — do not re-do completed work

**When to write Notes:**
- Before any file-heavy implementation run
- When ending a session or handing off
- Any time you would lose context if the conversation reset right now

---

## Rules

- Check `open/` before creating new issues — avoid duplicates
- When claiming: update `agent:` and move in the same operation
- Check `blocked-by:` before claiming — don't start blocked work
- `blocked-by:` accepts a list of slugs — all listed issues must be closed before this one can start
- When you complete an issue, check whether any other issue was `blocked-by` it — those issues are now unblocked
- Use `discovered-from:` when a new issue surfaces while working on another — always link the lineage
- `## Notes` is a rolling snapshot — rewrite it in place, do not append new sections
- Write a Notes snapshot before any long operation and before ending a session
- `closed/` is an archive — never delete, never edit
- One file per issue — never append to another agent's issue file
