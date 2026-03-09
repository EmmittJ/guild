---
name: memory
description: >
  Persistent memory for this repo's AI team. Stores decisions (why we chose X), insights
  (what we know about this codebase), and context (what's in flight right now).
  Activate when: `memory:decision:create` — a meaningful choice was made;
  `memory:decision:read` — reviewing prior decisions; `memory:insight:create` — something
  non-obvious was discovered; `memory:insight:read` — reviewing known patterns;
  `memory:context:update` — ending a session or handing off; `memory:context:read` — picking
  up from a prior session.
  DO NOT USE FOR: async agent-to-agent messages — use the inbox skill (`inbox:message:create`).
  Tasks — use the tasks skill (`task:item:create`, `task:item:update`, `task:item:read`).
license: MIT
metadata:
  version: "0.1"
---

## Overview

The memory root for this repo is `${memory_root}` (relative to repo root).

The memory directory structure:

```
${memory_root}/
  context/
    {session-id}.md           ← per-session working memory (not committed)
  decisions/
    _summary.md               ← rolling distillation of all decisions
    YYYY-MM-DD-{slug}.md      ← one file per decision, never edited after creation
  insights/
    {domain}.md               ← one file per domain (auth.md, testing.md, ...)
```

Task tracking is managed by the `tasks` skill (`markdown-tasks@guild`).
If that skill is not installed, the tasks directory is unused.

## Session Start Checklist

At the start of every session, read in this order:

1. `AGENTS.md` — team roster, platform, ground rules
2. Scan `${memory_root}/context/` — read recent session files to understand current team state
3. `${memory_root}/decisions/_summary.md` — key architectural decisions

---

## Decisions `memory:decision:create` `memory:decision:read`

Decisions capture **why** — the reasoning behind architectural choices, tool selections,
and approaches that future agents should understand.

**When to write:** Any time a meaningful choice is made that could affect future work.

- Which library to use and why
- Why you chose approach A over approach B
- A constraint discovered that rules something out

**Format:** `YYYY-MM-DD-{slug}.md` in `${memory_root}/decisions/`

```markdown
# {Short title of the decision}

Date: YYYY-MM-DD
Agents: {who was involved}

## Context

{What situation prompted this decision?}

## Decision

{What was decided, stated plainly.}

## Alternatives Considered

- {Option A}: {why not}
- {Option B}: {why not}

## Outcome

{What we expect / what actually happened.}
```

**Rules:**

- Never edit a decision file after writing it — they are append-only by convention
- After writing a decision, update `${memory_root}/decisions/_summary.md` with a one-liner
- `_summary.md` is the first thing agents read; keep it concise

---

## Insights `memory:insight:create` `memory:insight:read`

that help agents avoid repeating mistakes.

**When to write:** When you discover something non-obvious that will help the next agent.

- "The auth module signs JWTs with a custom algorithm — don't use the default"
- "Always pass `--no-cache` when running the test suite or you get stale results"
- "The migrations folder has a separate config — running from root fails silently"

**Format:** One file per domain in `${memory_root}/insights/`

```markdown
# {Domain} Insights

## {Pattern or Gotcha Title}

{Description. Be specific — vague insights are noise.}

## {Another Pattern}

{Description.}
```

**Rules:**

- Insights are collective — any agent writes to the relevant domain file
- Refine freely; this is a living document
- Delete insights that are no longer true
- Keep each insight tight: one thing, clearly stated

---

## Context `memory:context:update` `memory:context:read`

It exists so a new session can pick up where the last one left off without losing state.

**When to write:** At the end of every session, or before handing off work.

**Format:** `${memory_root}/context/{session-id}.md` — one file per session, named by short UUID (e.g. `a3f9c1b2`)

```markdown
# Context — {session-id}

Agent: {agent-name}
Updated: YYYY-MM-DD HH:MM

## Active Work

{What is currently being worked on. Be specific about state — not just "implementing auth"
but "auth controller written, tests failing on token expiry edge case, next: fix + review"}

## Pending Handoffs

- {agent}: {task description} — {any relevant file paths}

## Decisions Pending

{Decisions that need to be made before work can continue.}

## Blocked

{What is stuck and why.}
```

**Rules:**

- Create a new `context/{session-id}.md` at session start using a short UUID (8 hex characters, e.g. `a3f9c1b2`)
- Keep it short; this is a snapshot, not a journal
- The orchestrator can read various `context/` files to synthesize team-wide state
- Context files are not committed — add `${memory_root}/context/` to `.gitignore`
- Old context files may be pruned after they are no longer relevant (e.g., keep last 10)
