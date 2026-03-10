---
name: routing
description: >
  Team roster and routing rules for this repo's agent team. Applied by Guild Master at session
  start. Scaffolded by guild-setup — edit this file to change who is on the team, what they do,
  and how work gets routed.
license: MIT
metadata:
  version: "0.1"
  asset: .github/skills/guild-setup/assets/skills/routing/SKILL.md
---

## Team

| Agent | File | Use for |
|-------|------|---------|
| Guild Master | `guild-master` | Default — orchestrates everything |
| Product Owner | `product-owner` | Requirements, user stories, backlog, acceptance criteria, PRDs |
| Engineer | `engineer` | File creation, editing, script implementation |
| Skill Writer | `skill-writer` | Writing or reviewing SKILL.md files |
| Copilot CLI | `copilot-cli` | Plugin manifests, marketplace, CLI compatibility |
| Reviewer | `reviewer` | Quality gate before committing |
| Scribe | `scribe` | Commits, branches, pull requests |

---

## Routing Rules

| Pattern | Agent |
|---------|-------|
| requirements, user stories, PRD, acceptance criteria, backlog, prioritization | product-owner |
| file creation, editing, scripts, implementation | engineer |
| skill write, skill review, SKILL.md | skill-writer |
| manifest, plugin.json, marketplace | copilot-cli |
| review, quality gate, approve | reviewer |
| commit, PR, branch, push | scribe |

---

## Default Flow

```
Guild Master → Product Owner → Engineer / Skill Writer / Copilot CLI → Reviewer → Scribe
```

---

## Model Tiers

Used by Guild Master when spawning tasks via the Copilot CLI (`tasks` tool supports model selection; VS Code `runSubagent` does not). Fill in the models available in your environment using the CLI format.

| Tier | Model | Use for |
|------|-------|---------|
| Fast | `claude-haiku-4.5` | Research, exploration, narrow tasks |
| Standard | `claude-sonnet-4.5` | Typical implementation and review |
| Premium | `claude-opus-4.5` | Architecture, high-stakes reasoning |

> Replace with the models available in your environment. Examples: `gpt-4o-mini` / `gpt-4o` / `o1` (OpenAI), `gemini-2.0-flash` / `gemini-2.0-pro` (Google).
