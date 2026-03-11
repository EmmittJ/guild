# Testing Agent Behavior — Patterns From the Orchestration Ecosystem

Source: Research on Babysitter, VAMFI, Squad, Composio, TAKT, Mar 2026

## The Core Problem: Agents Are Non-Deterministic

Traditional unit tests assert `f(x) == y`. Agent behavior isn't deterministic — the same input can produce different outputs across runs. Testing strategies therefore focus on:

1. **Structural correctness** — did the agent produce the required artifact in the right format?
2. **Routing correctness** — did Guild Master route to the right agent for this input?
3. **Gate correctness** — did the Reviewer catch this defect? Did the circuit breaker fire at 3 retries?
4. **Regression against recorded sessions** — does re-running the session produce equivalent decisions?

## Deterministic Replay From Event Logs

Babysitter and VAMFI store full execution as NDJSON event logs. Replay is possible because:

- Every decision is recorded as an event with inputs and outputs
- State is rebuilt from events (event sourcing)
- Given the same event sequence, the system reaches the same state

Test pattern:

```bash
# Capture a known-good session
guild run > .guild/test-fixtures/security-review-session.ndjson

# Later, replay and assert routing decisions match
guild test replay .guild/test-fixtures/security-review-session.ndjson \
  --assert "engineer routed to reviewer for security changes" \
  --assert "reviewer rejected 2 times before approval"
```

**Guild gap:** No replay capability. Minimum viable: capture Guild Master routing decisions to a JSONL log and write test assertions against that log.

## Routing Correctness Tests

Given the routing table in squad:

```typescript
const rules = [
  {
    pattern: "security|vulnerability|CVE",
    agents: ["@reviewer"],
    tier: "full",
  },
  { pattern: "typo|rename", agents: ["@engineer"], tier: "lightweight" },
];
```

Tests assert: does `matchRoute("fix SQL injection vulnerability")` return `{ agents: ['@reviewer'], tier: 'full' }`?

These are deterministic because the routing table is code — not LLM inference.

**Guild recommendation:** Extract Guild Master's routing rules into a config file (even if implicit today). Write unit tests that cover routing edge cases: ambiguous requests, multi-agent tasks, escalation paths.

## Success Criteria as Executable Assertions

The orchestration-patterns insight notes: "success_criteria and definition_of_done must be measurable gates." This doubles as a test spec:

```yaml
task:
  id: T3
  success_criteria:
    - tests_pass: true
    - coverage_min: 80
    - no_high_severity_vulns: true
  definition_of_done:
    - code merged to feature branch
    - changelog entry added
```

A validator (Reviewer or automated check) runs each criterion programmatically. If criterion is not met, task is not done — regardless of what the agent reports.

**Guild gap:** Guild has output contracts ("exactly what to produce") but no programmatic verification. Adding a `@verify` block to agent output specs — or a structured `acceptance_criteria:` field in tasks — would let Guild Master auto-verify before accepting.

## Blind Validation: Preventing Confirmation Bias

Zeroshot's key innovation: validators never see the worker's context or session history. They only see the output artifact. This prevents:

- Reviewer thinking "well, the engineer tried hard, so I'll let this slide"
- Reviewer rationalizing away edge cases they saw the engineer encounter

**Test implication:** Reviewer agent tests should provide only the output artifact — not the preceding conversation. If the Reviewer correctly identifies a defect in isolation, it validates the reviewer works correctly without context contamination.

## Per-Agent Performance Metrics as Test Baselines

CloudForge tracks:

```csv
task_id,agent,estimated_hours,actual_hours,variance_pct,quality_score,rework_count
```

Once you have a baseline, tests can assert:

- Engineer's rework count should be < 2 for routine tasks
- Reviewer's quality score should be ≥ 0.85 on approved outputs
- Total task time should not exceed estimated \* 1.5

**Guild gap:** No performance baseline exists. Starting to collect metrics now (even manually) creates a dataset for future regression tests.

## Failure Injection / Chaos Testing

Squad and Babysitter both test "what if agent X fails?":

- **Agent failure:** engineer returns malformed output → verify Reviewer catches it
- **Loop test:** Reviewer rejects 3 times → verify circuit breaker fires and Guild Master intervenes
- **Timeout test:** Engineer takes 30 minutes → verify idle detection fires and escalation occurs
- **Quality gate failure:** test that `quality_score < 0.7` triggers rework, not merge

**Test structure:**

```markdown
## Test: Reviewer circuit breaker fires at 3 rejections

Setup: Task with impossible requirements (always fails review)
Action: Run engineer → reviewer loop
Assert: After 3 rejections, Guild Master receives escalation inbox message
Assert: Task status is 'blocked', not cycling
```

**Guild gap:** No test suite for failure modes. Priority order: (1) routing tests, (2) circuit breaker tests, (3) failure injection.

## Approval Gate Regression Tests

Capture real human approval gate interactions as fixtures:

```markdown
## Fixture: security-fix-gate

Input: Engineer output with SQL injection fix
Gate context: { changes, tests, coverage }
Expected: Reviewer approves without requesting changes
```

Re-run to verify: does the Reviewer still approve this known-good output after agent updates?

## Test Harness Architecture (Recommended for Guild)

Phase 1 (low cost):

1. JSONL routing log — capture all Guild Master routing decisions
2. Test assertions against log — grep/jq for expected patterns
3. Document known-good fixtures in `.guild/test-fixtures/`

Phase 2 (medium cost): 4. Routing unit tests — extract routing rules to config, write deterministic tests 5. Success criteria verification — programmatic `@verify` step in task close 6. Per-agent performance log — baseline for regression detection

Phase 3 (high cost): 7. Deterministic replay — full event-sourced session replay 8. Chaos/failure injection — simulate agent failures, assert recovery behavior

## Key Principle: Test the Infrastructure, Not the LLM

Don't test "does the engineer write good code?" — that's non-deterministic and model-dependent. Test:

- Does routing get the right agent? (deterministic)
- Does the circuit breaker fire correctly? (deterministic)
- Does the quality gate enforce its threshold? (deterministic)
- Does the escalation message include all required fields? (deterministic)

The LLM output quality improves as models improve; the orchestration infrastructure stays constant.
