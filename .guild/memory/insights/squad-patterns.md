# Squad — Multi-Agent Orchestration Patterns

Source: `bradygaster/squad` — programmable multi-agent runtime for GitHub Copilot, Feb 2026

## What Squad Is

A TypeScript SDK + CLI for orchestrating persistent, themed AI development teams against a codebase. Agents have named identities, persistent `history.md` files, and typed charters. The runtime handles routing, parallel spawning, session pooling, and cost tracking.

## Response Tiers — Match Investment to Complexity

Before spawning any agent, classify the request:

| Tier | Agents | Model | Timeout | Trigger |
|------|--------|-------|---------|---------|
| Direct | 0 | none | instant | Status, help, greetings |
| Lightweight | 1 | fast | 30s | Simple lookup, rename, single file |
| Standard | 1 | standard | 120s | Feature dev, testing, docs |
| Full | 5 | premium | 300s | Architecture review, security audit |

**Key insight:** Never over-provision. "Fix a typo" should never spin up 5 premium agents. A direct response handler short-circuits all spawning for status queries — zero latency.

## Fan-Out with Error Isolation

```typescript
// spawnParallel uses Promise.allSettled — one failure doesn't block others
const results = await spawnParallel(agentConfigs, deps);
// results[i].status === 'success' | 'failed'
// Failed agents return error context; others continue independently
```

Each spawn in the pipeline: compile charter → resolve model → create session → send task → register in pool → emit events.

## Charter-Driven Agent Identity

Each agent has a `charter.md` defining:
- **What I Own** — scope of responsibility
- **Boundaries** — what I escalate to others
- **How I Work** — operating principles
- **Preferred Model** — model selection hint

The system prompt automatically includes this. Agent has a stable identity across sessions.

## Routing Rules — Declarative, Not Hardcoded

```typescript
const rules = [
  { pattern: 'feature-dev',   agents: ['@fenster'],         tier: 'standard' },
  { pattern: 'bug-fix',       agents: ['@hockney'],         tier: 'lightweight' },
  { pattern: 'architecture',  agents: ['@keaton'],          tier: 'full' },
];
```

`matchRoute(message, router)` returns `{ agents, confidence: 'high'|'medium'|'low', reason }`. Routing is compiled from config, not embedded in LLM prompts — deterministic and auditable.

## Coordinator Pipeline

```
User Message
  ↓ Direct Response Check (fast path — no agents)
  ↓ Route Analysis (message → rules → agents + confidence)
  ↓ Spawn Strategy (direct | single | multi | fallback)
  ↓ Fan-Out Spawn (Promise.allSettled)
  ↓ Event Aggregation + Result Collection
```

`CoordinatorResult` carries: `strategy`, `routing` (agents + confidence + reason), `spawnResults[]`, `durationMs`.

## Event Bus — Pub/Sub for Cross-Session Coordination

```typescript
eventBus.subscribe('session:created', handler);
eventBus.subscribe('agent:milestone', handler);
eventBus.subscribe('coordinator:routing', handler);
```

Events are typed (`SquadLifecycleEvent | SquadOperationalEvent`). Handler errors don't cascade — each handler is isolated. This enables real-time observability without agents needing to know about each other.

## Hook Pipeline — Deterministic Governance

Instead of asking an LLM to "not delete prod", enforce it with hooks:

```typescript
const hooks = new HookPipeline({
  allowedWritePaths: ['src/**', 'tests/**'],
  blockedCommands: ['rm -rf', 'git push --force'],
  scrubPii: true,
});

hooks.addPreToolHook(async (ctx) => {
  if (!isValidSchema(ctx.arguments.content)) {
    return { action: 'block', reason: 'Schema validation failed' };
  }
  return { action: 'allow' };
});
```

Pre-tool hooks block operations; post-tool hooks scrub outputs. Policies are code — composable, auditable, no hallucination risk.

## Per-Agent History Files

Each agent maintains `.squad/agents/{name}/history.md`:
```markdown
## What I've Learned About This Project
- Naming convention: snake_case for DB tables, camelCase for JS
- Deployment: Always run migrations before rolling out
- Test-first required for critical paths
```

On next session, charter includes: "Review history.md — remember what you've learned." The agent gets smarter over time without any infrastructure.

## Decisions Log as Shared Audit Trail

`.squad/decisions.md` — auto-logged by the Scribe-equivalent. Every spawn decision, outcome, and reasoning is recorded. Agents can reference this to understand what the team has already decided.

## Session Pool Management

```typescript
export type SessionStatus = 'creating' | 'active' | 'idle' | 'error' | 'destroyed';

// Pool tracks concurrent sessions, enforces capacity (default: 10)
// Idle timeout: 5 min — auto-cleanup of stale sessions
// Health checks via pool.active() and pool.findByAgent()
```

## Cost Tracking Per Agent

```typescript
tracker.recordUsage({
  sessionId, agentName, model,
  inputTokens, outputTokens, estimatedCost
});
const summary = tracker.getSummary();
// → totalEstimatedCost, costs by agent, costs by session
```

Integrated with event bus — tracks `session:message` events automatically.

## Themed Casting — Deterministic Team Identity

Agents are cast from a named "universe" (e.g., "usual-suspects"). Same universe → same names across sessions via `CastingHistory`. Teams have memorable personas with backstories injected into system prompts. Committed to git — reproducible across clones.

**Adapted for guild:** Each guild agent (Guild Master, Engineer, Skill Writer, Reviewer, Scribe) is a "cast member" with a charter, history file, and routing specialization.

## Guild-Specific Routing Adaptation

```typescript
const routing = defineRouting({
  rules: [
    { pattern: 'file-creation|editing|scripts', agents: ['@engineer'],     tier: 'standard' },
    { pattern: 'skill.*write|skill.*review',    agents: ['@skill-writer'],  tier: 'standard' },
    { pattern: 'manifest|plugin|marketplace',  agents: ['@copilot-cli'],   tier: 'lightweight' },
    { pattern: 'review|quality|approve',       agents: ['@reviewer'],      tier: 'lightweight' },
    { pattern: 'commit|PR|branch',             agents: ['@scribe'],        tier: 'direct' },
  ],
});
```

## Error Hierarchy Worth Adopting

Squad's error structure: base `SquadError` → `severity` (INFO/WARNING/ERROR/CRITICAL) + `category` (SDK_CONNECTION, SESSION_LIFECYCLE, TOOL_EXECUTION, MODEL_API, CONFIGURATION, RATE_LIMIT) + `recoverable: boolean`.

The `recoverable` flag is key — determines whether to retry automatically or escalate to human.

## OpenTel Integration

Full distributed tracing on every coordinator decision, spawn, and tool call. Metrics: token usage, agent spawns/errors/duration, session pool health, response tier distribution. Visualized via Aspire dashboard or OTLP export (Datadog, Honeycomb).
