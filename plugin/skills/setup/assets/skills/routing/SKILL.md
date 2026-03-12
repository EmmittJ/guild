---
name: routing
description: >
  Maps thematic agent names to functional roles. Team roster and routing rules for this repo's agent team. Applied by guild-master at session 
  start. Scaffolded by `/guild:setup` — edit this file to change who is on the team, what they do,
  and how work gets routed.
license: MIT
metadata:
  version: "0.2"
---

## Team

| Agent        | Role         | File                    | Use for                           |
| ------------ | ------------ | ----------------------- | --------------------------------- |
| guild-master | guild-master | `guild-master.agent.md` | Default — orchestrates everything |

<!-- Add your team members here. Example:
| steward | planning + design | `steward.agent.md` | Requirements, user stories, architecture, trade-offs, feature briefs |
| wright | implementation | `wright.agent.md` | File creation, editing, skills, scripts, manifests |
| scribe | version control | `scribe.agent.md` | Commits, branches, pull requests |
-->

---

## Routing Rules

| Pattern | Role |
| ------- | ---- |

<!-- Add routing patterns here. Example:
| requirements, user stories, PRD, acceptance criteria, architecture, design, trade-offs | planning + design role (agent: steward) |
| file creation, editing, scripts, implementation, skills, manifests, plugin | implementation role (agent: wright) |
| review, quality gate, approve | peer review (routed by guild-master) |
| commit, PR, branch, push | version control role (agent: scribe) |
-->

---

## Default Flow

```
guild-master → {your agents here}
```

---

## Installed Skills

Skills installed by `/guild:setup`. Update this table when adding, removing, or renaming a skill.
Orchestrate reads this at session start and applies each skill in order.

| Order | Skill directory    | Session-start action                                             |
| ----- | ------------------ | ---------------------------------------------------------------- |
| 1     | `markdown-memory/` | `memory:context:read` — load context, decisions, per-agent notes |
| 2     | `github-issues/`   | `issue:ready` — surface actionable work                          |
| 3     | `markdown-inbox/`  | `inbox:message:read` — check waiting messages from other agents  |

<!-- Add or remove rows to match what /guild:setup installed. -->

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
