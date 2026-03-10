# Observability — Agent Run Logging, Tracing, and Debugging

Source: Research on Squad, Composio, Babysitter, VAMFI, CloudForge, Mar 2026

## Pull-Based State Detection Over Agent Self-Reporting

Mature systems (Composio) never trust agent self-reporting. They poll external signals every cycle:
- Agent JSONL file `mtime` — if no update in 10 minutes, agent is idle
- SCM (PR status, CI checks) — ground-truth progress independent of what the agent says
- Session state snapshots — atomic flat-file writes, rename-for-atomicity

**Guild gap:** Guild Master reads only the context files agents choose to write. Adding mtime-based idle detection (check `.guild/context/{agent}.md` last-modified) would catch stuck agents without agent cooperation.

Recommended thresholds (from Squad):
```
active → idle: 5 minutes of no writes
idle → stuck: 10 minutes
stuck → escalate: 15 minutes (send inbox message to Guild Master)
stuck → human escalation: 30 minutes
```

## Distributed Tracing with OpenTelemetry

Squad emits full OpenTel spans for:
- Coordinator routing decisions (message → agents + confidence + reason)
- Agent spawns (duration, tier, model)
- Tool calls (type, duration, success/fail)
- Token usage per agent per session
- Session pool health (active/idle/error counts)

Exports to Aspire dashboard (local dev), Datadog, Honeycomb, or Jaeger via OTLP.

**Guild gap:** No instrumentation at all. A lightweight approach:
1. Log every Guild Master routing decision to `.guild/runs/{date}/orchestration.jsonl`
2. Emit span events: `{ timestamp, event, agent, task_id, duration_ms, tokens, cost }`
3. Document OpenTel export as optional enhancement

## Structured Run Logs: JSONL Over Markdown

Babysitter stores everything at `.a5c/runs/{runId}/` — JSONL journals + state snapshots. Event format:
```jsonl
{"timestamp":"2026-03-01T10:00:00Z","event":"task_started","task_id":"T3","agent":"engineer","model":"claude-sonnet-4.5"}
{"timestamp":"2026-03-01T10:12:00Z","event":"task_completed","task_id":"T3","quality_score":0.87,"tokens_used":4200}
```

Benefits over Markdown:
- Machine-readable — grep, jq, SQL import
- Append-only — no write conflicts between concurrent agents
- Deterministic replay — given same log, reproduce any session decision
- Queryable cost aggregation — `jq '[.[] | .tokens_used] | add'`

**Guild gap:** Guild memory is Markdown. For observability, add an optional JSONL run log alongside (not replacing) Markdown memory.

## Token and Cost Tracking Per Agent

Squad records per-session, per-agent cost:
```typescript
tracker.recordUsage({ sessionId, agentName, model, inputTokens, outputTokens, estimatedCost });
const summary = tracker.getSummary();
// → totalEstimatedCost, costs by agent, costs by session
```

Cost by agent reveals: "Reviewer uses 3x the tokens of Engineer" or "orchestrate skill is the most expensive skill."

**Guild gap:** No token accounting. Minimum viable: add optional `tokens:` and `cost:` fields to task completion entries in `.guild/tasks/`. Aggregate monthly in memory.

## Performance Variance Tracking

CloudForge tracks per-task:
```csv
task_id,agent,estimated_hours,actual_hours,variance_pct,quality_score,rework_count
```

Patterns: which agents consistently overshoot estimates? Which tasks produce the most rework? Which skills have the lowest quality scores?

**Guild gap:** No performance baseline. Start by logging `{ task_id, agent, started_at, completed_at, iterations }` to each task on close.

## Flat-File Format for Bash-Friendly Inspection

Composio uses `key=value` format in `.guild/metadata/{session}.txt` with rename-for-atomicity:
```bash
# Write atomically
echo "status=idle" > .guild/state/engineer.txt.tmp
mv .guild/state/engineer.txt.tmp .guild/state/engineer.txt
```

This is bash-friendly, version-control-friendly, and grep-friendly. No dependencies.

## Guild-Specific Recommendations

1. **Adopt (low cost):** Add `mtime` idle detection to Guild Master — check context file age before routing
2. **Adopt (low cost):** Structured JSONL run log per orchestration session
3. **Adopt (medium cost):** Optional cost/token field in task completions
4. **Watch:** Full OpenTel integration — valuable at scale, not urgent for single-team use
