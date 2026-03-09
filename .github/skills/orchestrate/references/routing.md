---
name: routing
description: How to read agent descriptions, match tasks to specialists, and resolve routing conflicts.
---

## How Routing Works

Guild Master routes by matching the task description against agent `description` fields in
`.agent.md` files. The description is the contract — it says what the agent does and when
to use it.

Read all agent descriptions in `AGENTS.md` or the agents directory at session start.
Build a mental routing table before any work starts.

---

## Reading Agent Descriptions

A good description answers:
1. What domain does this agent own?
2. What tasks should be routed here?
3. What is explicitly excluded?

```yaml
# Example — clear ownership
description: >
  Implements features, fixes bugs, and updates configuration in TypeScript and Go.
  Use for any file change that isn't a test, migration, or documentation update.
  DO NOT route: security reviews, database migrations, documentation.
```

If a description is vague, ask the team to improve it before routing.

---

## AGENTS.md Routing Table

Repos should define a routing table in `AGENTS.md`:

```markdown
## Routing

| Domain | Agent | Notes |
|--------|-------|-------|
| Code changes | engineer | TypeScript, Go, Python |
| Tests | tester | Unit, integration, e2e |
| Database | db-admin | Migrations, schema, queries |
| Documentation | scribe | Docs, changelogs, ADRs |
| Security | security | CVE review, secrets, auth audit |
| PR review | lead | Final approval, architecture |
| Commits | scribe | Always commits last |
```

---

## Resolving Domain Conflicts

When a task could belong to multiple agents:

1. **Specificity wins** — the more specific description takes the task
   - "fix this TypeScript type error" → engineer (not lead)
2. **Check exclusions** — does one agent's description explicitly exclude this?
3. **Split the task** — if a task genuinely spans two domains, decompose and route each part
4. **AGENTS.md is authoritative** — repo-level routing rules override defaults

---

## Fallback Rules

| Situation | Action |
|-----------|--------|
| No matching agent | Route to guild-master (implement directly) |
| Two agents equally matched | Prefer the more specialized one |
| Agent description is silent on this task | Ask the agent if it can handle it |
| Task is outside all agent scopes | Note the gap, ask user if they want a new agent trained |

---

## Routing Checklist

Before delegating to an agent:

- [ ] Agent description covers this task
- [ ] No exclusion in the description
- [ ] No routing override in AGENTS.md
- [ ] Prompt scoped to what this agent needs (not a full brief)
- [ ] Expected output format specified
