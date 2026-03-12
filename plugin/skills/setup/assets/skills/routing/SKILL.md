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
| {agent-name} | {role}         | `{agent-name}.agent.md` | {what they handle}                    |
| {agent-name} | {role}         | `{agent-name}.agent.md` | {what they handle}                    |
| {agent-name} | version control | `{agent-name}.agent.md` | Commits, branches, pull requests     |
-->

---

## Routing Rules

| Pattern | Role |
| ------- | ---- |

<!-- Add routing patterns here. Example:
| {keywords that match this role's domain}  | {role} (agent: {agent-name}) |
| {keywords that match this role's domain}  | {role} (agent: {agent-name}) |
| review, quality gate, approve             | planning + design role (agent: {advisor-name}) |
| commit, PR, branch, push                  | version control (agent: {agent-name}) |
-->

---

## Default Flow

```
guild-master → {advisor-name} (planning + design) → {builder-name} (implementation) → {advisor-name} (peer review) → {scribe-name}
```

---

## Installed Skills

> **Keep this table in sync with skills actually present under your skills directory.** The orchestrate skill reads this table at every session start — an entry for a skill that is not installed causes startup errors. Entries for installed skills missing from this table are handled gracefully by the verb-based fallback, but explicit entries are preferred.
> To add a skill: copy the skill files, then add an entry here. To remove: delete both the files and the row.

Skills installed by `/guild:setup`. Update this table when adding, removing, or renaming a skill.
Orchestrate reads this at session start and applies each skill in order.

<!-- If using beads: -->
| Order | Skill directory | Session-start action                                                        |
| ----- | --------------- | --------------------------------------------------------------------------- |
| 1     | `beads/`        | `memory:context:read` — load context, decisions, insights, per-agent notes  |
| 2     | `beads/`        | `issue:ready` — surface actionable work                                     |
| 3     | `beads/`        | `inbox:message:read` — check waiting messages from other agents             |

<!-- If using markdown components instead:
| Order | Skill directory    | Session-start action                                             |
| ----- | ------------------ | ---------------------------------------------------------------- |
| 1     | `markdown-memory/` | `memory:context:read` — load context, decisions, per-agent notes |
| 2     | `github-issues/`   | `issue:ready` — surface actionable work                          |
| 3     | `markdown-inbox/`  | `inbox:message:read` — check waiting messages from other agents  |
-->

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
