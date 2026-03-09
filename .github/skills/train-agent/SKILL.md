---
name: train-agent
description: >
  Scaffold a new agent file for this repo's team. Use when asked to create a new specialist,
  add a team member, or define a new role. Produces a .agent.md file with correct frontmatter
  and a focused body. Works for Copilot CLI, VS Code, and Claude Code agent formats.
license: MIT
metadata:
  version: "0.1"
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
3. **Install location** — project-level (`.github/agents/`, `.claude/agents/`, `.agents/`) or plugin?

---

## Agent File Format

```markdown
---
name: { kebab-case-name }
description: >
  {One or two sentences. What does this agent do? When should Guild Master route to it?
  Include key domain words — this description is used for routing.}
---

You are {role description}.

## Required Context

{What does this agent read before starting work? AGENTS.md sections, memory skill files,
specific config files it must know about.}

## Expertise

{What this agent is good at. Be specific — vague expertise leads to scope creep.}

## Boundaries

{What this agent never does. Explicit boundaries prevent overlap with other agents.}

## Handoffs

{Who does this agent pass work to, and when? What format?}
```

## Writing a Good Description

The description field is used for routing — Guild Master reads it to decide who gets the work.
Make it keyword-rich and specific:

```yaml
# Bad — too vague
description: Helps with code.

# Good — specific, keyword-rich, clear scope
description: >
  Implements features, fixes bugs, and updates configuration in TypeScript and Go.
  Use for any file change that isn't a test, migration, or documentation update.
```

---

## After Writing the File

1. Add the agent to `AGENTS.md` routing table
2. Tell Guild Master: "I've added a {name} agent for {domain}"
3. If this agent needs memory access, ensure the memory skill is installed in the repo
