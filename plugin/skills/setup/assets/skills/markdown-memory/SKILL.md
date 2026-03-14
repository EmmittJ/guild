---
name: markdown-memory
description: >
  Persistent memory for this repo's AI team. Stores decisions (why we chose X), insights
  (what we know about this codebase), and context (what's in flight right now).
  Activate when: `decision:create` — a meaningful choice was made;
  `decision:read` — reviewing prior decisions; `insight:create` — something
  non-obvious was discovered; `insight:read` — reviewing known patterns;
  `context:update` — ending a session or handing off; `context:read` — picking
  up from a prior session.
  DO NOT USE FOR: async agent-to-agent messages — use `message:create`.
  Issues — use `issue:create`, `issue:update`, or `issue:read`.
license: MIT
metadata:
  version: "0.2"
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
    {agent-name}/
      {slug}.md               ← per-agent learnings, one file per topic
```

Use `issue:create`, `issue:update`, and `issue:read` to track work.
If no issues skill is installed, the issues directory is unused.

## Session Start Checklist

At the start of every session, read in this order:

1. Scan `${memory_root}/context/` — read recent session files to understand current team state
2. `${memory_root}/decisions/_summary.md` — key architectural decisions
3. Check for a directory at `${memory_root}/insights/{your-name}/` — read any files there for per-agent learnings about how you work in this repo

---

## Decisions `decision:create` `decision:read`

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

## Insights `insight:create` `insight:read`

Insights capture patterns and gotchas that help agents avoid repeating mistakes.

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

### Per-Agent Insights

`{agent-name}/` directories under `insights/` capture learnings about a specific agent's behavior, tendencies, or gotchas in this repo. Each file covers one topic. Created when an agent is trained; populated as the team works with that agent.

**When to write:** When the orchestrator (or any agent) notices a pattern about how a specific agent behaves.

- "engineer tends to skip the `.ps1` partner script when creating Unix-first features — always check"
- "reviewer returns false positives on generated files — scope its brief explicitly"

**Format:** `{slug}.md` in `${memory_root}/insights/{agent-name}/`

```markdown
# {Short title of the pattern or tendency}

{What this agent reliably does or misses. Specific enough to act on.}
```

**Rules:**

- The orchestrator reads the agent's insight directory before briefing that agent
- The agent itself reads its own directory at session start (per session start checklist)
- One file per topic — split concerns, don't pile everything into one file
- Populate gradually — start empty, fill as patterns emerge

---

## Context `context:update` `context:read`

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
