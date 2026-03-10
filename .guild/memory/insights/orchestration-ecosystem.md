# Agent Orchestration — GitHub Ecosystem Survey

Source: `github.com/topics/agent-orchestration` + deep reads of top repos, Mar 2026

## TAKT — Declarative State Machine for Agent Workflows

**Repo:** `nrslib/takt` | TypeScript, MIT

TAKT models workflows as **pieces** (workflow definitions) composed of **movements** (states). Each movement specifies:
- `persona` — which agent archetype executes it
- `edit: true/false` — whether the agent can write files
- `rules` — conditions that determine the next movement

```yaml
name: plan-implement-review
movements:
  - name: plan
    persona: planner
    edit: false
    rules:
      - condition: Planning complete
        next: implement

  - name: review
    persona: reviewer
    edit: false
    rules:
      - condition: Approved
        next: COMPLETE
      - condition: Needs fix
        next: implement    # fix loop — routes back
```

`COMPLETE` and `ABORT` are terminal states. Rules create **fix loops** — a reviewer can send work back to implementer indefinitely until quality is met.

**Faceted Prompting** — prompts are split into independent facets (persona, policy, knowledge, instruction) that compose freely across workflows. You can mix a "security-reviewer" persona with a "frontend-policy" without rewriting either.

**Worktree isolation** — each task runs in an isolated git worktree, preventing task A from corrupting task B's working state.

**NDJSON execution logs** — every step logged in structured newline-delimited JSON for full traceability from task to PR.

**Key insight for Guild:** The movement/rule model is essentially a typed routing table. Guild Master currently routes by convention; codifying it as explicit movements + rules would make the orchestration declarative, inspectable, and shareable as a "repertoire package."

---

## Zeroshot — Conductor + Blind Validation Loop

**Repo:** `covibes/zeroshot` | JavaScript, MIT

Zeroshot uses a **conductor** that classifies tasks by complexity and type, then selects a workflow template:
- **Trivial:** 1 agent, no validation
- **Simple:** worker + 1 validator
- **Standard+:** planner + worker + 3–5 validators

```
TASK → CONDUCTOR (Complexity × TaskType → Workflow)
         ├── TRIVIAL: 1 agent → COMPLETE
         ├── SIMPLE: worker → validator → [REJECT → worker loop | OK → COMPLETE]
         └── STANDARD+: planner → worker → [requirements, code, security, tester, adversarial validators]
```

**Blind validation** is the key innovation: validators never see the worker's context or code history. They evaluate outputs with fresh eyes, preventing confirmation bias. Rejections include actionable findings, not vague complaints.

**Accept/reject loop** — the worker keeps iterating until all validators approve or a max iteration count is hit.

**SQLite ledger** — all state persisted to SQLite. Crash? `zeroshot resume <id>`. This makes every run deterministic and reproducible.

**Task acceptance criteria gate** — if you can't describe what "done" means, don't run. Validators can only verify what's specified.

**Key insight for Guild:** The Reviewer agent should be a **blind validator** — it should not have access to the Engineer's session context, only the output artifacts. This prevents the reviewer from rationalizing away problems.

---

## Babysitter — Event-Sourced, Resumable Orchestration

**Repo:** `a5c-ai/babysitter` | JavaScript, MIT

Core loop:
```
Iterate → Get Effects → Execute Tasks → Post Results → repeat until complete
```

Everything stored at `.a5c/runs/<runId>/` — journal, tasks, state. **Pause, resume, or recover at any point.**

**Quality convergence** — the loop doesn't stop when a task "completes"; it stops when quality targets are met. Tasks iterate until they score above a threshold.

**Human-in-the-loop breakpoints** — structured approval checkpoints where the human must sign off before the loop continues. Not a chat interruption — a defined process step with full context provided.

**Deterministic replay** — because everything is event-sourced, you can replay execution from any recorded state. Useful for debugging why an agent took a wrong turn.

**2,000+ pre-built process templates** in the process library — covering TDD, security review, API design, etc.

**Key insight for Guild:** The guild's `.guild/tasks/` filesystem already does something similar, but without replay or quality convergence. Adding a quality score threshold (not just "done/not done") would shift the gate from binary to continuous.

---

## VAMFI/claude-user-memory — Research-First Development with Circuit Breaker

**Repo:** `VAMFI/claude-user-memory` | Shell, MIT

Enforces a **Research → Plan → Implement → Learn** sequence with hard quality gates:
- Research gate: ≥80 quality score required before planning
- Plan gate: ≥85 quality score required before implementing
- Circuit breaker: 3 retries max per phase — prevents infinite loops

9 specialized agents: orchestration, research, planning, implementation, debugging, deployment.

**Knowledge graph persistence** — patterns and learnings auto-captured after each session and persist across sessions. The system literally gets smarter over time.

**Key insight for Guild:** The Research phase before Implementation is often skipped in the guild flow. Requiring a documented research step (even lightweight — "read existing files, check for existing patterns") would reduce rework. The circuit breaker pattern (max retries before escalation) is directly applicable to the Reviewer → Engineer loop.

---

## Playbooks — Semantic Programming Language for Agents

**Repo:** `playbooks-ai/playbooks` | Python, MIT

Playbooks treats LLMs as **semantic execution engines** (like CPUs). Programs are written in structured natural language Markdown, compiled to **PBAsm** (Playbooks Assembly), and executed by a runtime.

```markdown
## GetCountryFact($country)
### Steps
- Return an unusual historical fact about $country
```

```python
@playbook
async def process_countries(countries: List[str]):
    for country in countries:
        fact = await GetCountryFact(country)  # calls NL playbook from Python
        await Say("user", f"{country}: {fact}")
```

Natural language and Python run on the **same call stack** — Python provides determinism, NL provides reasoning.

PBAsm defines: explicit call stacks, yields/waits/interrupts, scoped variables, resumable execution boundaries.

**Programs are stable; execution improves as LLMs improve.** You don't rewrite orchestration when models get better.

**Key insight for Guild:** Skill files in the guild are currently prose instructions. Structuring them as Playbooks-style executable specifications (## Steps, triggers, conditions) would make them more like programs than suggestions. The `@playbook` decorator pattern — calling NL routines from Python — is a clean model for mixing deterministic scripting with agent reasoning.

---

## Mission Control — Dashboard with Agent SOUL System

**Repo:** `builderz-labs/mission-control` | TypeScript/Next.js, MIT

6-column Kanban: `inbox → backlog → todo → in-progress → review → done`

**Agent SOUL system** — each agent has a `soul.md` file defining personality, capabilities, and behavioral guidelines. Syncs bidirectionally between disk and database. Agents can be edited live through the dashboard.

**Inter-agent messaging** via comms API — agents send structured messages to each other, enabling coordinated multi-agent workflows without a central orchestrator being in the session.

**Local Claude Code session tracking** — auto-discovers sessions by scanning `~/.claude/projects/`, extracts token usage, model info, message counts, cost estimates from JSONL transcripts every 60 seconds.

**Attribution/audit/cost report** per agent — track which agent used what tokens on which tasks.

**Key insight for Guild:** The SOUL system is essentially a formalized version of what `.github/agents/*.agent.md` does, but with live sync and edit capability. The 6-column Kanban maps well to the guild tasks structure — the current `open/in_progress/closed` could gain `inbox` (unprocessed), `backlog` (queued), and `review` (pending sign-off) columns.
