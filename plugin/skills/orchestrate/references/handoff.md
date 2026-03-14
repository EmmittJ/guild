---
name: handoff
description: >
  Reference for handing off work between agents. Covers the output contract format, session
  start checklist, context.md usage, and inbox message format. Use when passing work to another
  agent, picking up work mid-session, or synthesizing results from a completed subagent.
---

## Session Start Checklist

Every agent should run these before doing substantive work:

1. Apply the skill for `context:read` and `decision:read` — if installed
2. Apply the skill for `message:read` — check for waiting messages, delete after reading
3. Apply the skill for `issue:read` — resume or unclaim in-progress issues, then check open

---

## Output Contract

When completing work that was delegated to you, structure your response as:

```markdown
## Summary

{One paragraph. What was done, what was decided, what changed.}

## Changes

{List of files created, modified, or deleted. One line each.}

- Created: {path} — {why}
- Modified: {path} — {what changed}
- Deleted: {path} — {why}

## Decisions

{Any choices made during the work that future agents should know about.
If significant, also write a decisions file.}

## Follow-Up

{What should happen next. Specific enough that another agent can act without asking.}

- {agent}: {action needed}
```

---

## Handing Off to Another Agent

Before passing work:

1. **Trigger `context:update`** — write current state so the next agent can start immediately
2. **Trigger `decision:create`** if a meaningful choice was made
3. **Trigger `message:create`** if the next agent runs in a separate session
4. **Include the output contract** in your response to Guild Master

### Inline handoff (same session)

Guild Master will route to the next agent. Include in your response:

```
Follow-Up:
- engineer: implement the auth controller at src/auth/controller.ts
  Context: schema is at src/auth/schema.ts, tests at src/auth/controller.test.ts
```

### Async handoff (different session)

Trigger `message:create` — write to the receiving agent's inbox directory:

```markdown
# {Subject}

From: {your name}
To: {agent name}
Date: YYYY-MM-DD HH:MM

{What needs to happen. Be specific.}

## Context

{Relevant files, decisions, bead IDs, or prior decisions.}
```

---

## Context File Format `context:update`

Trigger `context:update` — the `memory` skill handles the path and file creation.
Context files use a short UUID session ID (8 hex characters, e.g. `a3f9c1b2`) and are never committed.

```markdown
# Context — {session-id}

Agent: {agent-name}
Updated: YYYY-MM-DD HH:MM

## Active Work

{What is in progress. State > task name.}
Example: "Auth controller written, tests failing on token expiry — next: fix expiry handling in src/auth/controller.ts:142"

## Pending Handoffs

- {agent}: {task} — {file or bead}

## Decisions Pending

{Choices that must be made before work can continue.}

## Blocked

{What is stuck and why.}
```

---

## Scribe Commits

When work is complete and ready to commit, route to the scribe with the following:

1. **Include a handoff block** using the output contract format — the scribe needs:
   - The exact list of expected changed files (from the Changes section)
   - The intended commit type, scope, and one-line description
   - Whether to push directly to `main` or open a PR
2. **Scribe does not modify code** — if a commit requires changes, it will send back to the implementing agent

Commit message format:

```
{type}({scope}): {description}

{body — what changed and why, referencing decisions if relevant}

Co-authored-by: {agent name} <agent>
```
