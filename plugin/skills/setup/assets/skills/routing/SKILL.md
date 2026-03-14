---
name: routing
description: >
  Maps thematic agent names to functional roles. Team roster and routing rules for this repo's agent team. Applied by the orchestrator at session
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

## SDLC Phases

Map your agents to each phase in the Team table. The orchestrator routes work through these stages.

| Phase         | Responsibility                                                      | When                                                |
| ------------- | ------------------------------------------------------------------- | --------------------------------------------------- |
| **Design**    | Requirements, acceptance criteria, architecture, trade-off analysis | New features, ambiguous requests, significant scope |
| **Implement** | Code, files, configuration, scripts, artifacts                      | Spec is clear; design phase complete or skipped     |
| **Verify**    | Tests, linters, builds — automated quality gates                    | After every implementation; never skipped           |
| **Review**    | Peer validation of output against acceptance criteria               | Behavioral changes, shared-contract impact          |
| **Integrate** | Commit, branch, pull request, version history                       | Verify passes; review passes or is skipped          |

## Default Flow

**Full path** — new features, behavioral changes, shared-contract impact:

```
Design → Implement → Verify → Review → Integrate
```

**Fast path** — bounded tasks, no shared-contract impact:

```
Implement → Verify → Integrate
```

See the Maker-Checker skip criteria in the `orchestrate` skill to determine which path applies.

---

## Installed Skills

> **Keep this table in sync with skills actually present under your skills directory.** The orchestrate skill reads this table at every session start — an entry for a skill that is not installed causes startup errors. Entries for installed skills missing from this table are handled gracefully by the verb-based fallback, but explicit entries are preferred.
> To add a skill: copy the skill files, then add an entry here. To remove: delete both the files and the row.

Skills installed by `/guild:setup`. Update this table when adding, removing, or renaming a skill.
Orchestrate reads this at session start and applies each skill in order.

<!-- If using beads: -->

| Order | Skill directory | Session-start action                                                |
| ----- | --------------- | ------------------------------------------------------------------- |
| 1     | `beads/`        | `context:read` — load context, decisions, insights, per-agent notes |
| 2     | `beads/`        | `issue:ready` — surface actionable work                             |
| 3     | `beads/`        | `message:read` — check waiting messages from other agents           |

<!-- If using markdown components instead:
| Order | Skill directory    | Session-start action                                             |
| ----- | ------------------ | ---------------------------------------------------------------- |
| 1     | `markdown-memory/` | `context:read` — load context, decisions, per-agent notes |
| 2     | `github-issues/`   | `issue:ready` — surface actionable work                          |
| 3     | `markdown-inbox/`  | `message:read` — check waiting messages from other agents  |
-->

---

## Model Tiers

Used by the orchestrator when spawning tasks via the Copilot CLI (`tasks` tool supports model selection; VS Code `runSubagent` does not). Fill in the models available in your environment using the CLI format.

| Tier     | Model | Use for                             |
| -------- | ----- | ----------------------------------- |
| Fast     | ``    | Research, exploration, narrow tasks |
| Standard | ``    | Typical implementation and review   |
| Premium  | ``    | Architecture, high-stakes reasoning |

<!-- Examples by provider:
> Replace with the models available in your environment.
> For GitHub Copilot, see [Supported AI models in GitHub Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) for the latest models and tiers.
-->
