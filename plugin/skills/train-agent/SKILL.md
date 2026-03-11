---
name: train-agent
description: >
  Scaffold a new agent file for this repo's team. Use when asked to create a new specialist,
  add a team member, or define a new role. Produces a .agent.md file with correct
  frontmatter and a focused body. Agents live in .github/agents/ and are auto-detected by
  VS Code and the GitHub Copilot CLI.
license: MIT
metadata:
  version: "0.3"
---

## When to Activate

- "train me a {role} agent"
- "create an agent for {specialty}"
- "add a {name} to the team"
- "I need a specialist that can {capability}"

---

## What to Ask First

Before writing anything:

1. **Role and domain** — what does this agent do? What does it never do?
2. **Interactions** — which other agents does it hand off to or receive work from?
3. **Tools** — which categories apply? (see Tools section below)
4. **Visibility** — should it appear in the chat agent picker, or is it subagent-only?

---

## Category Templates

Four pre-built category templates live at `plugin/skills/setup/assets/agents/`. If this agent is being added to a Guild team (i.e. `/guild:setup` was previously run), start from the matching template rather than writing from scratch:

| Category | Template file | Best for |
|---|---|---|
| Orchestrator | `orchestrator.agent.md` | Guild Master, team leads, coordinators |
| Builder | `builder.agent.md` | Engineers, ops, QA, writers — anyone who creates artifacts |
| Advisor | `advisor.agent.md` | Architects, product owners, reviewers, domain experts |
| Scribe | `scribe.agent.md` | Version control, commit discipline, release management |

**When to use a template:** If the role maps cleanly to one of the four categories, use the template — it has correct tool defaults, handoff structure, and placeholder sections already written. Fill in the `{PLACEHOLDER}` values and delete what doesn't apply.

**When to write from scratch:** Novel roles that don't fit any category, or when the user has a specific format requirement. In that case, use the format in this skill directly.

---

## Tool Defaults by Agent Category

| Category         | Tools                                              | Purpose                                                  |
| ---------------- | -------------------------------------------------- | -------------------------------------------------------- |
| **Worker**       | `read`, `search`, `edit`, `execute`, `web`, `todo` | Domain specialists who implement directly                |
| **Orchestrator** | `read`, `search`, `agent`, `web`, `todo`           | Coordinators who delegate; no direct editing or commands |
| **Scribe**       | `read`, `search`, `edit`, `execute`, `todo`        | Applies changes; no web access needed                    |

Exclude tools the agent doesn't need for its role.

---

## Agent File Format

Agents are `.agent.md` files auto-detected by VS Code and the GitHub Copilot CLI. Both read any `.md` file in `.github/agents/`.

```markdown
---
name: { Display Name }
description: >
  {One or two sentences. Shown as placeholder text in chat and used by Guild Master for routing.
  Include key domain words and explicit DO NOT USE FOR exclusions.}
tools:
  - read # Universal baseline — every agent
  - search # Universal baseline — every agent
  # - edit                # Add for agents that create or modify files (engineering, ops, scribe)
  # - execute             # Add for agents that run commands (engineering, ops, scribe)
  # - web                 # Add for agents that need external research
  # - agent               # Orchestrators only — subagent spawning
  # - todo                # Orchestrators and engineers that track work
handoffs:
  - label: { Action label shown on button }
    agent: { target-agent-name }
    prompt: { Pre-filled prompt handed to the next agent. }
---

You are {role description}.

## Required Context

{What does this agent read before starting work? Memory skill files, specific config files.
Use `memory:insight:read` to load any per-agent insights for this role before starting work.
Use `memory:insight:create` when you discover something non-obvious — naming conventions,
gotchas, or patterns a future agent in this role should know.}

## Expertise

{What this agent is good at. Be specific — vague expertise leads to scope creep.}

## Boundaries

{What this agent never does. Explicit boundaries prevent overlap with other agents.}
```

---

## Frontmatter Fields

| Field                      | Required    | Notes                                                                                                                                      |
| -------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                     | Recommended | Display name shown in chat picker; Title Case is fine. **Used for `agent:` references in handoffs** — the display name, not the file name. |
| `description`              | Yes         | Routing + chat placeholder — make it keyword-rich                                                                                          |
| `model`                    | Optional    | Leave unset — let the user or routing config assign. See Model Field below.                                                                |
| `tools`                    | Recommended | List of tool categories (see Tools section below)                                                                                          |
| `handoffs`                 | Optional    | Guided workflow transitions to next agent                                                                                                  |
| `agents`                   | Optional    | List of subagents this agent can invoke; `*` for all                                                                                       |
| `user-invocable`           | Optional    | `false` to hide from picker (subagent-only)                                                                                                |
| `disable-model-invocation` | Optional    | `true` to prevent other agents from invoking this one                                                                                      |

### Model Field

Omit `model:` from agent files — leave model selection to the user or the routing config. Agent files ship as portable artifacts; hardcoding a model name couples them to a specific provider.

When model selection matters at runtime: the Copilot CLI `tasks` tool supports passing a model name when spawning a subagent. VS Code `runSubagent` does not. Model tier assignments live in the `routing` skill, in CLI format (e.g. `claude-sonnet-4.5`), not in agent files.

### Tools

`read` and `search` are the universal baseline — every agent gets them. Add others only when the role genuinely needs them.

| Tool      | Add when                        | Examples                                  |
| --------- | ------------------------------- | ----------------------------------------- |
| `read`    | Always                          | All agents                                |
| `search`  | Always                          | All agents                                |
| `edit`    | Agent creates or modifies files | Engineer, Smith                           |
| `execute` | Agent runs commands             | Engineer, Scribe (git), ops, testing      |
| `web`     | Agent needs external research   | Orchestrator, Copilot CLI, architect      |
| `agent`   | Agent spawns subagents          | Orchestrator only                         |
| `todo`    | Agent tracks work across turns  | Orchestrator, engineers that manage tasks |

**Posture rule:** review-only agents (Reviewer, Security) get `read` + `search` and nothing else — no `execute`, no `web`. The restricted toolset enforces the read-only contract.

**Visibility rule:** agents invoked only as subagents (never directly by users) should set `user-invocable: false`. Note: agents that receive handoffs must remain user-invocable — the handoff button switches the user to that agent directly.

### Handoffs

Handoff buttons appear after a chat response and let users move to the next agent with one click.
Use them to wire up the standard flow: engineer → reviewer → scribe.

```yaml
handoffs:
  - label: Review Changes
    agent: Reviewer
    prompt: Review the changes just made against the acceptance criteria.
  - label: Commit
    agent: Scribe
    prompt: Commit all changes with a descriptive message.
    send: false
```

---

## Writing a Good Description

Description serves two purposes: placeholder text in the VS Code/Copilot CLI chat input, and the routing
signal Guild Master uses to pick the right agent. Make it specific and keyword-rich:

```yaml
# Bad — too vague
description: Helps with code.

# Good — specific, keyword-rich, explicit scope
description: >
  Implements features, fixes bugs, and updates configuration in TypeScript and Go.
  Use for any file change that isn't a test, migration, or documentation update.
  DO NOT USE FOR: security reviews, database migrations, documentation.
```

### Reviewer-Type Agents

If training a reviewer, validator, or quality-gate agent, add this to its description and boundaries:

> Receives **output artifacts only** — not the implementer's prompt, working notes, or intent. Judges on the artifact's own merit (blind validation).

This prevents confirmation bias where a reviewer who knows what was attempted rationalizes away real problems.

---

## After Writing the File

1. Add the agent to `AGENTS.md` team table
2. Update the `routing` skill — Team table, Routing Rules table, and Default Flow
3. Use `memory:insight:create` to seed a per-agent insight entry for this role (even if empty — signals to future agents that insights should accumulate here)
4. Tell Guild Master: "I've added a {name} agent for {domain}"
5. If this agent needs memory access, ensure the memory skill is installed in the repo
