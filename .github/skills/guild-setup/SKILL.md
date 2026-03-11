---
name: guild-setup
description: >
  Bootstrap core Guild configuration into any repo. Scaffolds AGENTS.md, the routing skill,
  and the guild-master agent if not already present. Run this first — before guild-setup-markdown.
  Activate when: setting up Guild in a repo for the first time, or adding the routing skill to
  an existing repo.
  DO NOT USE FOR: installing memory, tasks, or inbox — use guild-setup-markdown for that.
license: MIT
metadata:
  version: "0.2"
---

## Asset Sources

The files installed by this script are templated copies maintained in this repo.
Each installed file has a corresponding source asset:

| Installed file                  | Source asset                                                                                   |
| ------------------------------- | ---------------------------------------------------------------------------------------------- |
| `{skills-dir}/routing/SKILL.md` | `.github/skills/routing/SKILL.md` → asset copy at `guild-setup/assets/skills/routing/SKILL.md` |

**When editing the routing skill:** also update the asset. The routing skill's frontmatter has
`metadata.asset:` pointing to its asset counterpart — use that as the sync signal.

The asset is a template with placeholder comments for the team roster and routing rules.
Unlike memory/tasks/inbox, the routing skill does not use token substitution — it is filled in
interactively during setup.

---

## What This Does

`/guild-setup` is interactive. It prompts for:

1. **Where skills live** — defaults to `.github/skills`, but any path works
2. **Team roster** — which agents are on the team (name, file, use-for)
3. **Routing rules** — which task patterns route to which agents
4. **Scaffold team agents (optional)** — for each team member defined in the roster, offer to create a starter `.agent.md` using `train-agent`

Then it:

- Scaffolds `AGENTS.md` at the repo root if not already present
- Copies `guild-master.agent.md` into the agents directory if not already present
- Copies the routing skill into the skills directory, filled in with the team roster and rules
- Optionally scaffolds a starter `.agent.md` for each team member via `train-agent` (skips guild-master — already created; skips any agent file that already exists)

Safe to re-run — skips anything that already exists.

---

## What Gets Created

```
AGENTS.md                             ← constitutional rules (if absent)
{agents-dir}/guild-master.agent.md    ← orchestrator agent (if absent)
{skills-dir}/routing/SKILL.md         ← team roster + routing rules
{agents-dir}/{agent-name}.agent.md    ← starter agent file per team member (optional, if scaffolded)
```

---

## Scaffolding Your Team

When you define team members during setup, guild-setup can scaffold a starter `.agent.md` for each one. This is optional — say no if you already have agent files or want to create them manually.

Each scaffolded agent is a minimal stub:

```yaml
---
name: {Agent Name}
description: >
  {role description — fill in what this agent does and when to use it.}
  DO NOT USE FOR: {what belongs to other agents}
tools:
  - read
  - search
  - edit
  - execute
---

{Agent instructions here.}
```

After scaffolding, customize each agent's description and tools. Use `/train-agent` for the full authoring protocol.

**Why not copy the Guild publisher's agents?** The specialist agents in the Guild publisher repo (charter, smith, auditor, etc.) are that team's specific configuration. Your team may have different roles, names, and tools. Scaffold your own.

---

## After Setup

The routing skill is automatically applied by Guild Master at session start — no manual registration is needed.

To set up memory, tasks, or inbox components, run /guild-setup-markdown.