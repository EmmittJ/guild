---
name: routing
description: >
  Team roster and routing rules for this repo's agent team. Applied by Guild Master at session
  start. Scaffolded by guild-setup — edit this file to change who is on the team, what they do,
  and how work gets routed.
license: MIT
metadata:
  version: "0.1"
---

## Team

| Agent        | File           | Use for                           |
| ------------ | -------------- | --------------------------------- |
| Guild Master | `guild-master` | Default — orchestrates everything |

<!-- Add your team members here. Example:
| Engineer | `engineer` | File creation, editing, script implementation |
| Reviewer | `reviewer` | Quality gate before committing |
| Scribe   | `scribe`   | Commits, branches, pull requests |
-->

---

## Routing Rules

| Pattern | Agent |
| ------- | ----- |

<!-- Add routing patterns here. Example:
| file creation, editing, scripts | engineer |
| review, quality gate, approve   | reviewer |
| commit, PR, branch, push        | scribe   |
-->

---

## Default Flow

```
Guild Master → {your agents here}
```

---

## Model Tiers

Used by Guild Master when spawning tasks via the Copilot CLI (`tasks` tool supports model selection; VS Code `runSubagent` does not). Fill in the models available in your environment using the CLI format.

| Tier     | Model | Use for                             |
| -------- | ----- | ----------------------------------- |
| Fast     | ``    | Research, exploration, narrow tasks |
| Standard | ``    | Typical implementation and review   |
| Premium  | ``    | Architecture, high-stakes reasoning |

<!-- Examples by provider:
> Replace with the models available in your environment.
> For GitHub Copilot, see [Supported AI models in GitHub Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) for the latest models and tiers.
-->
