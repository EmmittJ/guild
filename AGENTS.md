# AGENTS.md

## Platform

GitHub. Use `gh` CLI for platform operations. `main` is protected — all work goes through PRs.

## Memory

Skills installed in this repo: `.github/skills/memory`, `.github/skills/tasks`, `.github/skills/inbox`
Roots: `.guild/memory`, `.guild/tasks`, `.guild/inbox`

## Ground Rules

- Guild Master orchestrates; specialists implement
- Reviewer signs off before Scribe commits — never skip the gate
- Flag blockers immediately
- All decisions worth keeping go in `.guild/memory/decisions/`
- Skills ship in `.github/skills/` for project-local use; use `/guild-setup` to configure a new repo, then `/guild-setup-markdown` to install memory/tasks/inbox components

## File Output Rules

Agents only create files that are a **direct deliverable of their role** — never notes, summaries, scratch files, or analysis artifacts. If it's worth keeping, it goes through a skill:

- Findings and patterns → `memory:insight:create`
- Decisions → `memory:decision:create`
- Tasks → `task:item:create`
- Messages for other agents → `inbox:message:create`

The engineer creates code. The skill-writer creates skills. The scribe commits. No one litters the repo with ad-hoc files.
