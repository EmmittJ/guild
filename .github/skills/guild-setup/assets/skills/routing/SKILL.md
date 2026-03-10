---
name: routing
description: >
  Maps thematic agent names to functional roles. Team roster and routing rules for this repo's agent team. Applied by guild-master at session 
  start. Scaffolded by guild-setup — edit this file to change who is on the team, what they do,
  and how work gets routed.
license: MIT
metadata:
  version: "0.2"
---

## Team

| Agent | Role | File | Use for |
|-------|------|------|---------|
| guild-master | guild-master | `guild-master.agent.md` | Default — orchestrates everything |

<!-- Add your team members here. Example:
| charter | product-owner | `charter.agent.md` | Requirements, user stories, backlog, acceptance criteria, PRDs |
| engineer | engineer | `engineer.agent.md` | File creation, editing, script implementation |
| smith | skill-writer | `smith.agent.md` | Writing or reviewing SKILL.md files |
| auditor | reviewer | `auditor.agent.md` | Quality gate before committing |
| scribe | scribe | `scribe.agent.md` | Commits, branches, pull requests |
-->

---

## Routing Rules

| Pattern | Role |
|---------|------|

<!-- Add routing patterns here. Example:
| requirements, user stories, PRD, acceptance criteria, backlog, prioritization | product-owner role (agent: charter) |
| file creation, editing, scripts, implementation | engineer role (agent: engineer) |
| skill write, skill review, SKILL.md | skill-writer role (agent: smith) |
| review, quality gate, approve | reviewer role (agent: auditor) |
| commit, PR, branch, push | scribe role (agent: scribe) |
-->

---

## Default Flow

```
guild-master → {your agents here}
```

---

## Model Tiers

Used by guild-master when spawning tasks via the Copilot CLI (`tasks` tool supports model selection; VS Code `runSubagent` does not). Fill in the models available in your environment using the CLI format.

| Tier     | Model | Use for                             |
| -------- | ----- | ----------------------------------- |
| Fast     | ``    | Research, exploration, narrow tasks |
| Standard | ``    | Typical implementation and review   |
| Premium  | ``    | Architecture, high-stakes reasoning |

<!-- Examples by provider:
> Replace with the models available in your environment.
> For GitHub Copilot, see [Supported AI models in GitHub Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) for the latest models and tiers.
-->
