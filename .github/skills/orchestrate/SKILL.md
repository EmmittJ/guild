---
name: orchestrate
description: >
  Plan, delegate, and synthesize work across a team of specialized agents. Apply when a request
  needs more than a direct answer — when it requires routing to a specialist, parallelizing work,
  or sequencing steps where each builds on the previous. Covers pattern selection, prompt
  construction, iteration, conflict resolution, and memory.
  DO NOT USE FOR: simple questions answerable directly without spawning agents.
license: MIT
metadata:
  version: "0.2"
---

## Pattern Selection

Start with the lowest-complexity pattern that fits. Escalate only when needed.

| Pattern | When to use | Example |
|---------|-------------|---------|
| **Direct** | Answerable now without delegation | "What does this function do?" |
| **Single agent** | One specialist, one focused task | "Fix the failing test" |
| **Concurrent** | Independent tasks, no dependencies | "Review security AND update deps" |
| **Sequential** | Each step depends on the previous | "Design schema → implement → test" |
| **Maker-checker** | Quality gate required | "Implement auth, then have lead review" |
| **Group chat** | Trade-offs need debate | "Should we use Postgres or SQLite?" |
| **Scope-first** | Request is ambiguous | Any request that could mean multiple things |

**Rule:** If in doubt between two patterns, choose the simpler one. Coordination has a cost.

---

## Session Start

Before planning any work, apply available skills in this order:

1. `memory` skill — follow its session start checklist if installed
2. `tasks` skill — follow its session start checklist if installed
3. Read `AGENTS.md` — team, platform, ground rules, routing table

---

## Decomposing Work

When a request is non-trivial:

1. **Identify outputs** — what does done look like? Work backward.
2. **Find dependencies** — which tasks must complete before others can start?
3. **Assign agents** — match each task to the specialist best suited for it (see `references/routing.md`)
4. **Start eagerly** — spawn independent tasks in parallel; don't wait for one to finish before starting another

### Prompt construction

Each agent prompt has four parts:

```
You are {agent role}.

Task: {specific, scoped task — one thing}

Context:
- {only what this agent needs — no cross-agent awareness}
- {relevant files, prior decisions, constraints}

Output: {exactly what to produce and in what format}
```

**Principle: context isolation.** Each agent gets only what they need. Don't brief Agent B on what Agent A is doing unless B's work depends on A's output.

---

## Maker-Checker

Use when output quality matters and a second perspective catches real problems.

1. **Make** — agent implements
2. **Check** — different agent (or lead) reviews against criteria
3. **Fix** — if checker rejects, maker revises with specific feedback
4. **Cap** — after 3 iterations without approval, escalate to the user

Don't loop forever. Three rounds is the limit.

---

## Memory

When these situations arise, invoke the `memory` skill:

- `memory:decision:create` — a meaningful choice was made
- `memory:decision:read` — reviewing prior decisions
- `memory:insight:create` — something non-obvious was discovered
- `memory:insight:read` — reviewing known patterns or gotchas
- `memory:context:update` — ending a session or handing off
- `memory:context:read` — picking up from a prior session

---

## Inbox

When this situation arises, invoke the `inbox` skill:

- `inbox:message:create` — another agent needs to act in a future session
- `inbox:message:read` — checking for waiting messages

---

## Tasks

When these situations arise, invoke the `tasks` skill:

- `task:item:create` — work needs to be tracked across sessions
- `task:item:update` — claiming, unclaiming, or completing a task
- `task:item:read` — checking available or in-progress work

---

## Conflict Resolution

When agents produce conflicting outputs or disagree on approach:

1. **Check AGENTS.md** — does the repo's constitution resolve it?
2. **Check decisions** — has this been decided before?
3. **Maker-checker** — have a lead agent adjudicate with explicit criteria
4. **Escalate** — if AGENTS.md is silent and precedent doesn't apply, ask the user

Don't invent a resolution. Surface the conflict clearly.

---

## Synthesizing Results

When subagents complete:

1. Collect all outputs
2. Check for conflicts or gaps
3. Write a summary in the output contract format (see `references/handoff.md`)
4. Trigger `memory:context:update` — record working memory before the session ends
5. Route the commit to a scribe agent — the implementing agent never commits their own work

---

## File Output Discipline

Agents must only create files that are a **deliverable of their assigned role** — not notes, summaries, scratch files, or analysis artifacts.

When briefing any agent that will research, explore, or analyze:

> Do not write findings to files. Use the `memory` skill to record anything worth keeping — insights via `memory:insight:create`, decisions via `memory:decision:create`. Only create files that are a direct deliverable of your role (e.g. a skill file, an agent file, a script).

If a spawned agent produces stray files, delete them and re-capture the content through the appropriate skill before the session ends.

---

## Quick Reference

| Task | What to do |
|------|-----------|
| Ambiguous request | Ask one clarifying question before planning |
| Blocked agent | Trigger `memory:context:update`, surface to user |
| Agent out of scope | Re-route to correct specialist |
| No specialist available | Implement directly, trigger `memory:decision:create` |
| Repeated failure | Cap at 3 attempts, escalate |
| End of session | Trigger `memory:context:update`; trigger `inbox:message:create` if handoff needed |
| Stray files found in repo | Delete them; re-capture content via `memory:insight:create` |




