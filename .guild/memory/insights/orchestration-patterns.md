# Agent Orchestration Patterns

Source: `claudeforge/marketplace` — super plugins (ai-studio-orchestrator, enterprise-workspace, devops-platform) and orchestration agents, Mar 2026

## The Core Idea: Task DAG + Agent Assignment

Effective orchestration treats work as a **directed acyclic graph (DAG)** of tasks, not a sequential to-do list. Each task has:
- Explicit `dependencies: [T1, T2]` — gates execution
- `parallel_group` — tasks in the same group can run concurrently
- `assigned_agent` — matched by skill, availability, and load
- `success_criteria` and `definition_of_done` — measurable gates before closing

This alone enables fan-out (one task → multiple parallel agents) and fan-in (many results → one synthesizer).

## Task Decomposition Protocol

Before any execution, break requirements into atomic tasks:
```yaml
tasks:
  - id: T1
    name: Database Schema Design
    dependencies: []
    agent: database-architect
    priority: critical
    parallel_group: foundation

  - id: T3
    name: OAuth2 Integration
    dependencies: [T1, T2]     # blocked until both complete
    agent: api-integration-specialist
    parallel_group: integrations
```

Implicit requirements (tests, docs, security) must be made explicit tasks — not assumed.

## Parallelization Groups: 36% Efficiency Gain

CloudForge demonstrated sequential 22h → 14h with parallelization by grouping independent tasks:
```python
parallel_groups = {
    'foundation': ['T1'],
    'core_api': ['T2'],
    'integrations': ['T3','T4','T5'],  # all runnable after T2
    'ui': ['T6'],                       # parallel with integrations
    'testing': ['T7','T8'],
}
```
Identify the **critical path** first, then maximize parallelism around it.

## Agent Selection Scoring

When multiple agents could handle a task, score them:
```typescript
// 40% availability + 40% performance history + 20% load balance
const score =
  (current.availability ? 1 : 0) * 0.4 +
  current.recent_performance * 0.4 +
  (1 - current.current_load) * 0.2;
```

## Handoff Context Package

Every task handoff must include a structured context package — not just a task name:
```yaml
context_package:
  task_id: T3
  description: "Integrate Google and GitHub OAuth2"
  dependencies_completed:
    - T1: Database schema ✓
    - T2: Auth API ✓
  available_resources:
    - Database connection configured
    - Auth endpoints tested
    - OAuth credentials in env vars
  success_criteria:
    - Users can sign in with Google/GitHub
    - Token refresh implemented
    - >80% test coverage
  definition_of_done:
    - Code merged to feature branch
    - Tests passing
    - Docs updated
  time_budget: "6 hours"
  blocking: [T7, T9]
  blocked_by: []
```
Missing handoff context = information loss = rework.

## Replan Triggers

Don't let blocked work spin indefinitely. Define explicit replan triggers:
```typescript
const replanTriggers = [
  { condition: 'task_duration > estimated * 1.5', action: 'reassign_or_split_task' },
  { condition: 'critical_task_blocked > 2h',      action: 'escalate_blocker_resolution' },
  { condition: 'quality_score < 0.7',             action: 'trigger_code_review' },
];
```

Error recovery strategies per failure type:
- **Agent failure:** retry (max 2) → reassign to backup → split into smaller tasks → escalate to human
- **Dependency failure:** pause dependent tasks → analyze impact → adjust plan → communicate delays
- **Quality gate failure:** trigger code review → provide actionable feedback → allocate rework time

## Quality Gates (Pre-Close Checklist)

```yaml
quality_gates:
  code_review:
    required: true
    automated_checks: [linting, tests, coverage_min_80, no_high_vulns]
  documentation:
    api_docs: updated
    changelog: entry_added
```

## State Tracking: Append-Only JSONL Log

The hook system logs task events passively — no blocking, just journaling:
```bash
# Pre-tool hook fires before every tool call
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "{\"timestamp\":\"$TIMESTAMP\",\"task_id\":\"$TASK_ID\",\"action\":\"$ACTION\"}" \
  >> "$LOG_DIR/task-log.jsonl"
```

For richer state, use JSON files keyed by base64-encoded workspace path (allows concurrent sessions):
```javascript
state.workspaces[btoa(workspacePath)] = {
  path: workspacePath,
  actions: [...],
  lastAction: 'sync',
  lastUpdate: '...'
};
```

## MCP Server Pattern: Read/Write Separation

The enterprise-workspace MCP server separates concerns cleanly:
- **Resources (read-only):** `workspace://state`, `workspace://metrics`, `workspace://compliance`
- **Tools (write):** `track_workspace()`, `record_metric()`, `update_compliance()`

Metrics use a **rolling window of 100 samples** per metric per workspace — prevents unbounded growth.

## Performance Tracking Schema

```csv
task_id,agent,estimated_hours,actual_hours,variance_pct,quality_score,rework_count
T1,engineer,0.5,0.5,0,9.0,0
T2,engineer,1.0,1.2,+20,8.5,1
```
Track variance and rework count — these reveal where estimates are systematically wrong and which tasks need skill investment.

## Guild-Specific Application

The guild's current flow (Guild Master → specialist → Reviewer → Scribe) is **sequential**. With orchestration:
- Guild Master decomposes into task DAG
- Engineer + Skill Writer run **in parallel** on independent subtasks
- Reviewer gates the fan-in
- Scribe fires only after quality gate

For guild tasks that fit this model, store task state in `.guild/tasks/` (already exists) using the YAML schema above. Use `blocked_by` and `blocking` arrays — the tasks skill doesn't currently model dependencies explicitly.

## Key Quotes

> "Break complex requirements into atomic, executable tasks with clear success criteria, appropriate granularity, minimal dependencies, and optimal parallelization potential." — task-coordinator.md

> "The best workflow is invisible, supporting creativity rather than constraining it." — workflow-optimizer.md

> "AI handles repetitive, AI excels at pattern matching. Humans handle creative, humans excel at judgment. Clear interfaces between human and AI work. Fail gracefully with human escalation." — workflow-optimizer.md
