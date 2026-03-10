# AGENTS.md

## Platform

GitHub. Use `gh` CLI for platform operations. Commit directly to `main` — no PR required unless explicitly requested.

## Memory

Skills installed in this repo: `.github/skills/guild-memory`, `.github/skills/guild-tasks`, `.github/skills/guild-inbox`

## Team

| Agent         | File                                    | Use for                                                  |
| ------------- | --------------------------------------- | -------------------------------------------------------- |
| Guild Master  | `.github/agents/guild-master.agent.md`  | Default — orchestrates everything                        |
| Product Owner | `.github/agents/product-owner.agent.md` | Requirements, user stories, backlog, acceptance criteria |
| Engineer      | `.github/agents/engineer.agent.md`      | File creation, editing, script implementation            |
| Skill Writer  | `.github/agents/skill-writer.agent.md`  | Writing or reviewing SKILL.md files                      |
| Copilot CLI   | `.github/agents/copilot-cli.agent.md`   | Plugin manifests, marketplace, CLI compatibility         |
| Reviewer      | `.github/agents/reviewer.agent.md`      | Quality gate before committing                           |
| Scribe        | `.github/agents/scribe.agent.md`        | Commits, branches, pull requests                         |

- Guild Master orchestrates; specialists implement
- Reviewer signs off before Scribe commits — never skip the gate
- Flag blockers immediately
- All decisions worth keeping use `memory:decision:create` — no one is a mind reader
- Skills ship in `.github/skills/` for project-local use; use `/guild-setup` to configure a new repo, then `/guild-setup-markdown` to install memory/tasks/inbox components

## File Output Rules

Agents only create files that are a **direct deliverable of their role** — never notes, summaries, scratch files, or analysis artifacts. If it's worth keeping, it goes through a skill:

- Findings and patterns → `memory:insight:create`
- Decisions → `memory:decision:create`
- Tasks → `task:item:create`
- Messages for other agents → `inbox:message:create`

The engineer creates code. The skill-writer creates skills. The scribe commits. No one litters the repo with ad-hoc files.
