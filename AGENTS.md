# AGENTS.md

## Platform

GitHub. Use `gh` CLI for platform operations. `main` is protected — all work goes through PRs.

## Memory

Skills installed in this repo: `.github/skills/memory`, `.github/skills/tasks`, `.github/skills/inbox`
Roots: `.guild/memory`, `.guild/tasks`, `.guild/inbox`

## Team

| Agent | File | Use for |
|-------|------|---------|
| Guild Master | `.github/agents/guild-master.agent.md` | Default — orchestrates everything |
| Engineer | `.github/agents/engineer.agent.md` | File creation, editing, script implementation |
| Skill Writer | `.github/agents/skill-writer.agent.md` | Writing or reviewing SKILL.md files |
| Copilot CLI | `.github/agents/copilot-cli.agent.md` | Plugin manifests, marketplace, CLI compatibility |
| Reviewer | `.github/agents/reviewer.agent.md` | Quality gate before committing |
| Scribe | `.github/agents/scribe.agent.md` | Commits, branches, pull requests |

## Routing

Standard flow for any change:
```
Guild Master → Engineer/Skill Writer/Copilot CLI → Reviewer → Scribe
```

## Ground Rules

- Guild Master orchestrates; specialists implement
- Reviewer signs off before Scribe commits — never skip the gate
- Flag blockers immediately
- All decisions worth keeping go in `.guild/memory/decisions/`
- Skills ship in `.github/skills/` for project-local use; use `/setup-markdown` to install memory/tasks/inbox into any repo

## File Output Rules

Agents only create files that are a **direct deliverable of their role** — never notes, summaries, scratch files, or analysis artifacts. If it's worth keeping, it goes through a skill:

- Findings and patterns → `memory:insight:create`
- Decisions → `memory:decision:create`
- Tasks → `task:item:create`
- Messages for other agents → `inbox:message:create`

The engineer creates code. The skill-writer creates skills. The scribe commits. No one litters the repo with ad-hoc files.
