# Human-in-the-Loop — Approval Gates, Escalation, and Intervention Patterns

Source: Research on Babysitter, Composio, Squad, TAKT, VAMFI, Mar 2026

## Structured Approval Checkpoints, Not Chat Interruptions

Babysitter's key design: human-in-the-loop is a **defined process step**, not an interruption mid-task. The loop pauses at a known point with full context provided upfront. The human gets:
- What was completed before the gate
- What decision or approval is needed
- What happens next in each branch (approve / reject / redirect)
- A recommended action with reasoning

**Guild gap:** Guild's maker-checker (implement → review → feedback → revise) is implicit. Formalizing a "sign-off gate" before Scribe commits — a distinct step where a human (or Guild Master) explicitly approves — would make the workflow declarative and auditable.

Recommended gate structure:
```markdown
## Approval Gate: {task_id}

**What's ready:** {summary of work completed}
**Decision needed:** Approve to commit, reject to revise, redirect to re-scope
**Recommendation:** {agent recommendation with reasoning}
**If approved:** Scribe will commit with message: {message}
**If rejected:** Engineer will revise: {specific changes needed}
**Deadline:** {time — if no response in 2h, escalate}
```

## Escalation With Context and Priority

Composio defines explicit escalation configs:
```yaml
reactions:
  - trigger: task_blocked
    escalateAfter: 2 failures
    notify: human
    message_template: "{task} blocked after {n} attempts. Tried: {attempts}. Recommendation: {recommendation}."
```

Squad's error hierarchy uses `recoverable: boolean` to decide: retry automatically (recoverable) or escalate immediately (not recoverable).

**Guild gap:** Guild Master says "cap at 3 retries, escalate" — but escalation is unstructured. Escalation messages should always include:
1. **What's blocked** — specific task and blocker
2. **What was tried** — all attempts with outcomes
3. **Why it failed** — root cause if known
4. **Recommendation** — what human action resolves it
5. **Priority** — blocking (work stopped) vs. non-blocking (degraded)

## Separating Decision Authority From Implementation Review

Squad separates: who approves decisions (architectural, product) from who reviews implementation (code quality, correctness). These are different concerns and different people.

**Guild gap:** Reviewer agent approves implementation but also implicitly approves architectural choices. Separating these:
- **Product Owner** approves requirements changes, scope decisions, tradeoffs
- **Reviewer** approves implementation quality (correctness, tests, style)
- **Guild Master** approves orchestration decisions (routing, agent assignment)

Each has its own approval gate with different context provided.

## Non-Blocking Notifications vs. Blocking Approvals

Composio's "reactions" engine supports lightweight notifications that don't block the workflow:
```yaml
reactions:
  - trigger: task_duration > estimated * 1.2
    action: notify_human
    message: "Task {id} is running 20% over estimate. No action needed — informational."
    blocking: false
```

**Guild gap:** Guild either blocks (inbox message requiring reply) or doesn't notify at all. Adding a `notify:` intent that sends a non-blocking status update (via GitHub issue comment, or inbox as informational) would enable "hey, this is taking longer than expected" without halting work.

## Circuit Breaker: Max Retries Before Escalation

VAMFI enforces hard retry caps per phase:
- Research phase: max 3 retries before escalation
- Plan phase: max 3 retries before escalation
- Implementation phase: max 3 retries before marking blocked

**Guild gap:** Reviewer → Engineer retry loops can cycle indefinitely. Adding a circuit breaker (configurable per task, default 3 rounds) that escalates to Guild Master (or human) when exceeded would prevent runaway loops.

```markdown
circuit_breaker:
  reviewer_engineer_loop: 3    # after 3 rejections, Guild Master intervenes
  quality_gate_attempts: 3     # after 3 quality gate failures, escalate
  escalation_target: guild-master  # or human
```

## Human Breakpoints in Event-Sourced Workflows

Babysitter's event-sourced model enables deterministic breakpoints: the loop literally pauses at a recorded state, the human acts, then the loop resumes from that state. This means:
- The human doesn't need to re-read context — it's provided
- The loop can be paused indefinitely and resumed days later
- Decisions at breakpoints are logged and replayable

**Guild gap:** Guild doesn't persist session state in a way that enables resumability. A lightweight version: when escalating, save full task state to `.guild/escalations/{task_id}.md` including all prior context, so the human (or returning Guild Master) can resume without re-reading the whole session.

## Approval Gate vs. Assignment Authority

Clear distinction (from Squad's charter model):
- **Assignment authority** — who decides which agent works on what (Guild Master)
- **Approval authority** — who says "this output meets the bar" (Reviewer + human for high-stakes)
- **Commit authority** — who pushes to main (Scribe, only after approval)

Conflating these (e.g., "Reviewer both picks up work and approves it") creates unclear responsibility.

## Guild-Specific Recommendations

1. **Adopt:** Formalize sign-off gate before Scribe commits — inbox message with structured approval context
2. **Adopt:** Escalation message template (what/tried/why/recommendation/priority)
3. **Adopt:** Circuit breaker for reviewer-engineer loop (default: 3 rounds → escalate)
4. **Consider:** Non-blocking `notify:` action for progress updates without blocking orchestration
5. **Watch:** Full event-sourced resumability — valuable for long-running tasks, complex to implement
