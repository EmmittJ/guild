---
name: orchestrate
description: >
  Plan, delegate, and synthesize work across a team of specialized agents. Apply when a request
  needs more than a direct answer — when it requires routing to a specialist, parallelizing work,
  or sequencing steps where each builds on the previous. Covers pattern selection, prompt
  construction, iteration, conflict resolution, memory, and issue lifecycle management.
  DO NOT USE FOR: simple questions answerable directly without spawning agents.
license: MIT
metadata:
  version: "0.4"
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

## Response Tiers

Match agent investment to task complexity. Overpowering simple tasks wastes budget; underpowering complex ones misses errors.

| Tier | When | Agent count |
|------|------|-------------|
| **Direct** | Answerable now, no agent needed | 0 |
| **Lightweight** | Narrow, well-defined, low-stakes | 1 |
| **Standard** | Typical implementation or review | 1–2 |
| **Full** | Architecture, multi-step, high-stakes | 2–5 |

**Rule:** Choose the tier that matches the operation, not the agent. A senior agent doing a narrow task is still Lightweight.

---

## Guild Master Initialization

Apply this sequence at the start of every session. Each step delegates to a skill — skip steps whose skill is not installed. Work begins only after all installed steps complete.

| Step | Skill | What it does |
|------|-------|--------------|
| 1 | `guild-memory` | Follow the guild-memory skill's session start checklist — reads context, decisions summary, and your per-agent insight file |
| 2 | `guild-tasks` | Follow the guild-tasks skill's session start checklist — use `task:ready` to surface actionable work |
| 3 | `guild-inbox` | `inbox:message:read` — check for waiting messages from other agents |
| 4 | `routing` | Apply the routing skill — loads team roster and routing rules. If not installed, scan agent descriptions in the agents directory. |

---

## Decomposing Work

When a request is non-trivial:

1. **Identify outputs** — what does done look like? Work backward.
2. **Find dependencies** — which tasks must complete before others can start?
3. **Assign agents** — match each task to the specialist best suited for it. Use the routing skill if installed; otherwise match against agent `description` fields. The description is the contract — it says what the agent does and what it explicitly excludes. When a task could belong to multiple agents, specificity wins; if it genuinely spans two domains, split it.
4. **Start eagerly** — spawn independent tasks in parallel; don't wait for one to finish before starting another

### Routing Fallbacks

| Situation | Action |
|-----------|--------|
| No matching agent | Implement directly; record the gap |
| Two agents equally matched | Prefer the more specialized one |
| Task outside all agent scopes | Ask user if a new agent should be trained |

### Operation Tiers

Tiers describe the *operation*, not the model. Agents declare their own `model:` — tiers guide your routing decision.

| Tier | Use for |
|------|---------|
| Lightweight | Research, exploration, narrow well-scoped tasks |
| Standard | Typical implementation, reviews, most agent work |
| Full | Architecture decisions, high-stakes reviews, complex multi-step reasoning |

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

## Spawning Agents

### When to spawn vs. answer directly

Answer directly (no spawn) for:
- Status queries — "what's in progress?", "who's on the team?"
- Help and capability questions — "what can you do?"
- Greetings and clarifications
- Config questions — "which model are you using?"

Spawn for everything else. **Default to spawning eagerly** — if an agent could usefully start work, start them. Don't wait to spawn Agent B until Agent A finishes unless B's work literally depends on A's output.

### Single vs. parallel spawning

| Situation | Spawn pattern |
|-----------|---------------|
| One clear owner | Single agent |
| Multiple independent workstreams | Parallel — spawn all at once |
| Two agents could both contribute | Spawn primary; secondary helps in parallel if useful |
| "All hands" request ("team, …") | Fan-out to all relevant agents simultaneously |
| Earlier output feeds later agent | Sequential — wait for A before briefing B |
| Substantial work completed | Always spawn a version control agent in background to record |

**Parallel is the default.** Sequential is only justified when there's a real data dependency.

### Briefing quality

A poor brief produces poor output and requires re-work. Before spawning any agent, verify the brief has:

1. **Role** — one sentence on who they are in this context
2. **Task** — one thing, stated specifically (not "help with auth" — "implement JWT refresh token endpoint in `src/auth/refresh.ts`")
3. **Context** — only what this agent needs: relevant files, prior decisions, constraints. No cross-agent awareness unless their work depends on it.
4. **Output contract** — exactly what to produce, in what format, where to put it

**Prompts are instructions, not suggestions.** Vague task → vague output. If you can't state the output contract, the task isn't decomposed enough yet.

### Failure handling

- One agent failing does not stop others — continue parallel work and surface the failure
- If an agent returns output that doesn't meet the output contract, send it back with specific feedback (see Maker-Checker)
- If an agent fails twice on the same task, try a different agent or decompose the task further
- Cap retries at 3 — after that, surface to the user with a clear description of what failed and why

### Direct response handling

Some requests should never spawn an agent. Answer these yourself:

```
Status queries:    "what's in progress?", "who is active?", "show tasks"
Help requests:     "what can you do?", "how do I…"
Config queries:    "which model?", "show team"
Greetings:        "hi", "hello", "hey"
Routing queries:  "who should I ask about X?"
```

For everything else, route. The orchestrator does not implement, research, write code, create files, or produce deliverables. **Dispatch work and synthesize results.**

---

## Maker-Checker

Use when output quality matters and a second perspective catches real problems.

1. **Make** — agent implements
2. **Check** — different agent (or lead) reviews against criteria
3. **Fix** — if checker rejects, maker revises with specific feedback
4. **Cap** — after 3 iterations without approval, escalate to the user

Don't loop forever. Three rounds is the limit.

### Blind Validation

When the checker is a reviewer-type agent, apply **blind validation**:

- Give the reviewer only the output artifacts (files, diffs, deliverables)
- Do **not** share the maker's prompt, working notes, or intent
- A reviewer who knows what the maker was trying to do rationalizes problems away

> **Brief template:** "Review these files for [criteria]. You have no prior context — judge the artifacts on their own merit."

If a reviewer-type agent's description says "receives output artifacts only," enforce this strictly in your brief.

---

## Memory

When these situations arise, invoke the `guild-memory` skill:

- `memory:decision:create` — a meaningful choice was made
- `memory:decision:read` — reviewing prior decisions
- `memory:insight:create` — something non-obvious was discovered
- `memory:insight:read` — reviewing known patterns or gotchas
- `memory:context:update` — ending a session or handing off
- `memory:context:read` — picking up from a prior session

---

## Inbox

When this situation arises, invoke the `guild-inbox` skill:

- `inbox:message:create` — another agent needs to act in a future session
- `inbox:message:read` — checking for waiting messages

---

## Tasks

When these situations arise, invoke the `guild-tasks` skill:

- `task:ready` — at session start and before planning new work, call this first to get actionable tasks sorted by priority
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
5. Route the commit to a version control agent — the implementing agent never commits their own work

---

## File Output Discipline

Agents must only create files that are a **deliverable of their assigned role** — not notes, summaries, scratch files, or analysis artifacts.

When briefing any agent that will research, explore, or analyze:

> Do not write findings to files. Use the `guild-memory` skill to record anything worth keeping — insights via `memory:insight:create`, decisions via `memory:decision:create`. Only create files that are a direct deliverable of your role (e.g. a skill file, an agent file, a script).

If a spawned agent produces stray files, delete them and re-capture the content through the appropriate skill before the session ends.

---

## Issue Lifecycle Management

Guild Master owns delegated work from creation through closure.

| Step | Owner | What happens |
|------|-------|--------------|
| 1. Create | Guild Master | Create tracking issue with clear "Done When" criteria |
| 2. Delegate | Guild Master → Specialist | Brief specialist; specialist claims issue (`in-progress`) |
| 3. Monitor | Guild Master | Poll progress; intervene if stalled |
| 4. Review | reviewer agent | Validate against acceptance criteria |
| 5. Commit | version control agent | Commit changes; issue closes |

**Guild Master's task is not complete until the issue is closed.** If an issue is `in-progress` with no activity, check in — ask "what's blocking?" Escalate to the user only when genuinely blocked: external dependency or a stall exceeding 24 hours.

Every delegation that produces an artifact gets a tracking issue. No invisible work. Exception: quick clarifications that produce no artifact output do not require an issue.

---

## Quick Reference

| Task | What to do |
|------|-----------|
| Ambiguous request | Ask one clarifying question before planning |
| Blocked agent | Trigger `memory:context:update`, surface to user |
| Stalled task (no progress after 2 rounds) | Stop looping — escalate to user with a clear description of what is stuck and why |
| Agent out of scope | Re-route to correct specialist |
| No specialist available | Implement directly, trigger `memory:decision:create` |
| Repeated failure | Cap at 3 attempts, escalate |
| End of session | Trigger `memory:context:update`; trigger `inbox:message:create` if handoff needed |
| Stray files found in repo | Delete them; re-capture content via `memory:insight:create` |





