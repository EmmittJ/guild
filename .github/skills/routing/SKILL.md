---
name: routing
description: >
  Maps thematic agent names to functional roles. Team roster and routing rules for this repo's agent team. Applied by guild-master at session
  start. Scaffolded by `/guild:setup` — edit this file to change who is on the team, what they do,
  and how work gets routed.
license: MIT
metadata:
  version: "0.2"
  asset: ../../../plugin/skills/setup/assets/skills/routing/SKILL.md
---

## Team

| Agent        | Role              | File                                   | Use for                                                              |
| ------------ | ----------------- | -------------------------------------- | -------------------------------------------------------------------- |
| guild-master | orchestration     | `guild-master.agent.md` | Default — orchestrates everything                                                    |
| steward      | planning + design | `steward.agent.md`      | Requirements, user stories, architecture, trade-offs, feature briefs                 |
| wright       | implementation    | `wright.agent.md`       | File creation, editing, skills, scripts, manifests                                   |
| scribe       | version control   | `scribe.agent.md`       | Commits, branches, pull requests                                                     |

---

## Routing Rules

| Pattern                                                                                          | Role                                          |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------- |
| requirements, user stories, PRD, acceptance criteria, architecture, design, trade-offs           | planning + design role (agent: steward)       |
| file creation, editing, scripts, implementation, skills, manifests, plugin                       | implementation role (agent: wright)           |
| review, quality gate, approve                                                                    | peer review (routed by guild-master)          |
| commit, PR, branch, push                                                                         | version control role (agent: scribe)          |

---

## Default Flow

```
guild-master → steward (planning + design) → wright (implementation) → peer review (guild-master routes) → scribe
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

---

## Model Tiers

Used by guild-master when spawning tasks via the Copilot CLI (`tasks` tool supports model selection; VS Code `runSubagent` does not). Fill in the models available in your environment using the CLI format.

| Tier     | Model               | Use for                             |
| -------- | ------------------- | ----------------------------------- |
| Fast     | `claude-haiku-4.5`  | Research, exploration, narrow tasks |
| Standard | `claude-sonnet-4.6` | Typical implementation and review   |
| Premium  | `claude-opus-4.6`   | Architecture, high-stakes reasoning |

> Replace with the models available in your environment.
> For GitHub Copilot, see [Supported AI models in GitHub Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) for the latest models and tiers.
