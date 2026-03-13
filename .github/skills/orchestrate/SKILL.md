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
  asset: ../../../plugin/skills/orchestrate/SKILL.md
  version: "0.5"
---

> **Read this entire file before acting.** This skill is approximately 355 lines. If your first `read_file` call did not return the full content, call it again with a higher `endLine` (e.g. 400) to retrieve the remaining sections — Maker-Checker, Memory/Issues/Inbox, Conflict Resolution, Synthesizing Results, File Output Discipline, Issue Lifecycle, and Quick Reference are all below the midpoint.

## Pattern Selection

Before reaching for the table, run this decision in order:

1. **Can I answer this directly, right now?** → Do it. No spawn needed. (Direct)
2. **Is there one clear specialist owner?** → Delegate to them. (Single agent)
3. **Is this contested, high-stakes, or does it materially affect multiple agents' work?** → Group chat. Bring the relevant agents into a structured debate before anyone acts. (Group chat)

If none of the above fits cleanly, use the table below.

Start with the lowest-complexity pattern that fits. Escalate only when needed.

| Pattern           | When to use                        | Example                                     |
| ----------------- | ---------------------------------- | ------------------------------------------- |
| **Direct**        | Answerable now without delegation  | "What does this function do?"               |
| **Single agent**  | One specialist, one focused task   | "Fix the failing test"                      |
| **Concurrent**    | Independent tasks, no dependencies | "Review security AND update deps"           |
| **Sequential**    | Each step depends on the previous  | "Design schema → implement → test"          |
| **Maker-checker** | Quality gate required              | "Implement auth, then have lead review"     |
| **Group chat**    | Trade-offs need debate             | "Should we use Postgres or SQLite?"         |
| **Scope-first**   | Request is ambiguous               | Any request that could mean multiple things |

**Rule:** If in doubt between two patterns, choose the simpler one. Coordination has a cost.

---

## Response Tiers

Match agent investment to task complexity. Overpowering simple tasks wastes budget; underpowering complex ones misses errors.

| Tier            | When                                  | Agent count |
| --------------- | ------------------------------------- | ----------- |
| **Direct**      | Answerable now, no agent needed       | 0           |
| **Lightweight** | Narrow, well-defined, low-stakes      | 1           |
| **Standard**    | Typical implementation or review      | 1–2         |
| **Full**        | Architecture, multi-step, high-stakes | 2–5         |

**Rule:** Choose the tier that matches the operation, not the agent. A senior agent doing a narrow task is still Lightweight.

---

## Model Selection

For deciding how many agents to spawn, see **Agent Count Tiers** in the Decomposing Work section.

When spawning agents, match the model tier to the operation. Tier names are fixed; model names are host-configured in the `routing` skill.

| Operation type                                                                             | Tier     | Examples                                                      |
| ------------------------------------------------------------------------------------------ | -------- | ------------------------------------------------------------- |
| Research, narrow lookup, reading files, short well-scoped tasks                            | Fast     | "What does this function do?", exploring a directory          |
| Typical implementation, reviews, file editing, most agent work                             | Standard | Writing a skill, implementing a feature, auditing changes     |
| Architecture decisions, security review, contested domain knowledge, high-stakes reasoning | Premium  | Design review, trade-off debate, security audit, release gate |

**The orchestrator selects tier when spawning.** Specialist agents declare their own model preference in their agent file.

**Surface before upgrading.** If a task grows beyond its original tier mid-execution, surface that before continuing — do not silently upgrade. A Lightweight task that turns into an architecture decision warrants a new spawn at the right tier.

> Model names for each tier live in the `routing` skill — that file is host-configured and can be changed without modifying this skill.

---

## Guild Master Initialization

Apply this sequence at the start of every session. Work begins only after all steps complete.

| Step | Action                                                                                                            |
| ---- | ----------------------------------------------------------------------------------------------------------------- |
| 1    | Apply the `routing` skill — loads team roster, routing rules, and the **Installed Skills** table                  |
| 2    | Apply each skill listed under **Installed Skills** in routing, in order. Skip steps whose skill is not installed. |

**Fallback (routing not installed, or Installed Skills table is absent or empty):** Apply skills by verb — attempt `context:read`, then `issue:ready`, then `message:read`. Skip any that produce no result.

---

## Skill Verb Contract

Verbs are colon-namespaced commands dispatched to the backing skill that implements them (listed in the **Installed Skills** table in the routing skill). Standard families:

| Verb | Description | Returns |
| ---- | ----------- | ------- |
| `decision:create` | Record a meaningful choice with rationale | Confirmation |
| `decision:read` | Review prior decisions | Stored decisions |
| `insight:create` | Record a non-obvious discovery or pattern | Confirmation |
| `insight:read` | Review known patterns and gotchas | Stored insights |
| `context:update` | Save working state before session ends or handoff | Confirmation |
| `context:read` | Restore working state at session start | Prior context |
| `issue:ready` | List unblocked issues ready to claim, sorted by priority | Issue list |
| `issue:create` | Create a tracked issue with description and priority | Issue ID |
| `issue:claim` | Atomically take ownership of an issue before starting work | Updated issue |
| `issue:update` | Update metadata, priority, notes, or status on an issue | Updated issue |
| `issue:close` | Mark an issue complete with a reason | Closed issue |
| `issue:read` | Read issue details or list issues | Issue data |
| `message:create` | Leave an async message for another agent to act on | Confirmation |
| `message:read` | Check and process waiting messages | Messages |

The verb namespace is open — backends and skills may introduce new verb domains. New verbs should be registered in the **Installed Skills** table in the routing skill and documented in the implementing skill's body.

---

## Decomposing Work

When a request is non-trivial:

1. **Identify outputs** — what does done look like? Work backward.
2. **Find dependencies** — which tasks must complete before others can start?
3. **Assign agents** — match each task to the specialist best suited for it. Use the routing skill if installed; otherwise match against agent `description` fields. The description is the contract — it says what the agent does and what it explicitly excludes. When a task could belong to multiple agents, specificity wins; if it genuinely spans two domains, split it.
4. **Start eagerly** — spawn independent tasks in parallel; don't wait for one to finish before starting another

### Routing Fallbacks

| Situation                     | Action                                                        |
| ----------------------------- | ------------------------------------------------------------- |
| No matching agent             | Explain the gap; offer to train a new agent via `train-agent` |
| Two agents equally matched    | Prefer the more specialized one                               |
| Task outside all agent scopes | Ask user if a new agent should be trained                     |

### Routing Principles

These rules apply to the orchestrator only. Specialists escalate unclear scope — they do not re-route.

**Primary domain wins.** When two agents could both handle a task, route to the agent whose _primary_ domain is the core concern — not an agent for whom it's adjacent work. Adjacent capability is a fallback, not a first choice.

**Exclusion is a signal.** If an agent's description says "DO NOT USE FOR X", treat that as a hard boundary. Route X elsewhere even if X is closely related to their domain.

**Cross-domain tasks: decompose before routing.** A task that genuinely spans two specialist domains should be split into two tasks with a clear handoff point. Do not assign it whole to one agent and hope.

**No specialist found: explain the gap.** Do not guess or assign to the closest match. Surface the gap to the user and offer to train a new agent via the `train-agent` skill.

### Agent Count Tiers

These tiers describe how many agents to spawn and how much coordination overhead is warranted — not which model to use. For model selection, see **Model Selection** below.

| Tier        | Use for                                                                   |
| ----------- | ------------------------------------------------------------------------- |
| Lightweight | Research, exploration, narrow well-scoped tasks                           |
| Standard    | Typical implementation, reviews, most agent work                          |
| Full        | Architecture decisions, high-stakes reviews, complex multi-step reasoning |

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

> **What can I launch right now?** That is always the first question. Default to parallel. Serialize only when a task genuinely requires the previous output to proceed. If in doubt, start it — don't wait.

### When to spawn vs. answer directly

Answer directly (no spawn) for:

- Status queries — "what's in progress?", "who's on the team?"
- Help and capability questions — "what can you do?"
- Greetings and clarifications
- Config questions — "which model are you using?"

Spawn for everything else. **Default to spawning eagerly** — if an agent could usefully start work, start them. Don't wait to spawn Agent B until Agent A finishes unless B's work literally depends on A's output.

**Anticipatory spawning (opt-in).** For substantial tasks, you may optionally spawn downstream agents on _setup work_ while the primary builder works — scaffolding test environments, writing stubs, preparing fixtures. Do not spawn agents to run tests against incomplete output. If the primary builder's output is rejected and the spec changes, Guild Master owns re-briefing any anticipatorily-spawned agents.

### Single vs. parallel spawning

| Situation                        | Spawn pattern                                                |
| -------------------------------- | ------------------------------------------------------------ |
| One clear owner                  | Single agent                                                 |
| Multiple independent workstreams | Parallel — spawn all at once                                 |
| Two agents could both contribute | Spawn primary; secondary helps in parallel if useful         |
| "All hands" request ("team, …")  | Fan-out to all relevant agents simultaneously                |
| Earlier output feeds later agent | Sequential — wait for A before briefing B                    |
| Substantial work completed       | Always spawn a version control agent in background to record |

**Parallel is the default.** Sequential is only justified when there's a real data dependency.

**Before spawning a second concurrent builder on a system another builder is already modifying:** call a Design Review — bring both builders and Guild Master to align on interfaces, contracts, and risk before work diverges. Record the outcome via `decision:create`.

**After a peer reviewer rejects the same work twice:** call a Retrospective — builder, reviewer, and Guild Master discuss what failed, root cause, and what changes. Record the pattern via `insight:create`.

### Briefing quality

A poor brief produces poor output and requires re-work. Before spawning any agent, verify the brief has:

1. **Role** — one sentence on who they are in this context
2. **Task** — one thing, stated specifically (not "help with auth" — "implement JWT refresh token endpoint in `src/auth/refresh.ts`")
3. **Context** — only what this agent needs: relevant files, prior decisions, constraints. No cross-agent awareness unless their work depends on it.
4. **Output contract** — exactly what to produce, in what format, where to put it

**Prompts are instructions, not suggestions.** Vague task → vague output. If you can't state the output contract, the task isn't decomposed enough yet.

### Failure handling

A **blocked** task requires external input before it can proceed — it is not merely slow. A slow task is still making progress. The distinction matters: slow tasks get more time; blocked tasks get the escalation ladder immediately.

- One agent failing does not stop others — continue parallel work and surface the failure
- If an agent returns output that doesn't meet the output contract, send it back with specific feedback (see Maker-Checker)
- If an agent fails twice on the same task or declares itself blocked:
  1. Return with specific, actionable feedback — name exactly what is missing
  2. Re-decompose: break the task smaller or approach it from a different angle
  3. Re-route to a different agent with a fresh brief
  4. Surface to the user — call `context:update` first so no state is lost
- Cap the full ladder at 3 iterations before surfacing unconditionally

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

When the checker is a specialist performing peer review, apply **blind validation**:

- Give the reviewer only the output artifacts (files, diffs, deliverables)
- Do **not** share the maker's prompt, working notes, or intent
- A reviewer who knows what the maker was trying to do rationalizes problems away

> **Brief template:** "Review these files for [criteria]. You have no prior context — judge the artifacts on their own merit."

Enforce this strictly in every peer review brief — the reviewing specialist receives artifacts only, never the maker's working notes or intent.

---

## Memory, Issues, and Inbox

These verbs are provided by whichever backing skill is listed in the routing skill's **Installed Skills** table. Apply the skill for the verb when these situations arise:

**Memory:**
- `decision:create` — a meaningful choice was made
- `decision:read` — reviewing prior decisions
- `insight:create` — something non-obvious was discovered
- `insight:read` — reviewing known patterns or gotchas
- `context:update` — ending a session or handing off
- `context:read` — picking up from a prior session

**Issues:**
- `issue:ready` — at session start and before planning new work, call this first to get actionable issues sorted by priority
- `issue:create` — work needs to be tracked across sessions
- `issue:claim` — atomically take ownership of an issue before starting; prevents two agents from working the same task
- `issue:update` — update metadata, notes, priority, or status on an in-progress issue
- `issue:close` — mark an issue complete with a reason at session end or task completion
- `issue:read` — checking available or in-progress work

**Inbox:**
- `message:create` — another agent needs to act in a future session
- `message:read` — checking for waiting messages

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
4. Trigger `context:update` — record working memory before the session ends
5. Route the commit to a version control agent — the implementing agent never commits their own work

---

## File Output Discipline

Agents must only create files that are a **deliverable of their assigned role** — not notes, summaries, scratch files, or analysis artifacts.

When briefing any agent that will research, explore, or analyze:

> Do not write findings to files. Record anything worth keeping via `insight:create` and `decision:create` using a skill. Only create files that are a direct deliverable of your role (e.g. a skill file, an agent file, a script).

If a spawned agent produces stray files, delete them and re-capture the content through the appropriate skill before the session ends.

---

## Issue Lifecycle Management

Guild Master owns delegated work from creation through closure.

| Step        | Owner                     | What happens                                              |
| ----------- | ------------------------- | --------------------------------------------------------- |
| 1. Create   | Guild Master              | Create tracking issue with clear "Done When" criteria     |
| 2. Delegate | Guild Master → Specialist | Brief specialist; specialist claims issue (`in-progress`) |
| 3. Monitor  | Guild Master              | Poll progress; intervene if stalled                       |
| 4. Review   | peer reviewer (specialist) | Validate against acceptance criteria                      |
| 5. Commit   | version control agent     | Commit changes; issue closes                              |

**Guild Master's task is not complete until the issue is closed.** If an issue is `in-progress` with no activity, check in — ask "what's blocking?" Escalate to the user only when genuinely blocked: external dependency or a stall exceeding 24 hours.

Every delegation that produces an artifact gets a tracking issue. No invisible work. Exception: quick clarifications that produce no artifact output do not require an issue.

---

## Quick Reference

| Task                      | What to do                                                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Ambiguous request         | Ask one clarifying question before planning                                                                                    |
| Blocked or stalled task   | Follow escalation ladder: feedback → re-decompose → re-route → surface to user (call `context:update` before surfacing) |
| Agent out of scope        | Re-route to correct specialist                                                                                                 |
| No specialist available   | Explain the gap; offer to train a new agent via `train-agent`                                                                  |
| Repeated failure          | Cap at 3 attempts, escalate                                                                                                    |
| End of session            | Trigger `context:update`; trigger `message:create` if handoff needed                                              |
| Stray files found in repo | Delete them; re-capture content via `insight:create`                                                                    |
