# AGENTS.md

## Platform

GitHub. Use `gh` CLI for platform operations. Commit directly to `main` — no PR required unless explicitly requested.

## Memory

Skills installed in this repo: `.github/skills/markdown-memory`, `.github/skills/github-issues`, `.github/skills/markdown-inbox`

## Customization

Host-owned files (edit freely): `AGENTS.md`, `.github/agents/`, `.github/skills/routing/SKILL.md`, `.guild/`
Plugin-owned files (do not modify): all other `.github/skills/` directories

See `README.md` for the full boundary table.

## Team

| Agent        | Role                | File                                   | Use for                                                                                      |
| ------------ | ------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------- |
| Guild Master | orchestration       | `.github/agents/guild-master.agent.md` | Default — orchestrates everything                                                            |
| charter      | product owner       | `.github/agents/charter.agent.md`      | Requirements, user stories, backlog, acceptance criteria                                     |
| architect    | technical architect | `.github/agents/architect.agent.md`    | Architecture decisions, design patterns, technical trade-offs and debates with product owner |
| engineer     | implementation      | `.github/agents/engineer.agent.md`     | File creation, editing, script implementation                                                |
| smith        | skill writer        | `.github/agents/smith.agent.md`        | Writing or reviewing SKILL.md files                                                          |
| invoker      | CLI integration     | `.github/agents/invoker.agent.md`      | Plugin manifests, marketplace, CLI compatibility                                             |
| auditor      | quality gate        | `.github/agents/auditor.agent.md`      | Quality gate before committing                                                               |
| scribe       | version control     | `.github/agents/scribe.agent.md`       | Commits, branches, pull requests                                                             |

- Guild Master orchestrates; specialists implement
- Auditor signs off before Scribe commits — never skip the gate
- Flag blockers immediately
- All decisions worth keeping use `memory:decision:create` — no one is a mind reader
- Skills ship in `.github/skills/` for project-local use; use `/guild:setup` to configure a new repo and install memory/issues/inbox components

## File Output Rules

Agents only create files that are a **direct deliverable of their role** — never notes, summaries, scratch files, or analysis artifacts. If it's worth keeping, it goes through a skill:

- Findings and patterns → `memory:insight:create`
- Decisions → `memory:decision:create`
- Issues → `issue:create`
- Messages for other agents → `inbox:message:create`

The engineer creates code. The smith creates skills. The scribe commits. No one litters the repo with ad-hoc files.
