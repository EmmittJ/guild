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

| Agent        | Role                    | File                                   | Use for                                                                      |
| ------------ | ----------------------- | -------------------------------------- | ---------------------------------------------------------------------------- |
| Guild Master | orchestration           | `.github/agents/guild-master.agent.md` | Default — orchestrates everything                                            |
| steward      | planning + design       | `.github/agents/steward.agent.md`      | Requirements, user stories, architecture, trade-offs, feature briefs         |
| wright       | implementation          | `.github/agents/wright.agent.md`       | File creation, editing, skills, scripts, manifests                           |
| scribe       | version control         | `.github/agents/scribe.agent.md`       | Commits, branches, pull requests                                             |

- Guild Master orchestrates; specialists implement
- Peer review is routed by Guild Master — no dedicated gatekeeper
- Flag blockers immediately
- All decisions worth keeping use `memory:decision:create` — no one is a mind reader
- Skills ship in `.github/skills/` for project-local use; use `/guild:setup` to configure a new repo and install memory/issues/inbox components

## File Output Rules

Agents only create files that are a **direct deliverable of their role** — never notes, summaries, scratch files, or analysis artifacts. If it's worth keeping, it goes through a skill:

- Findings and patterns → `memory:insight:create`
- Decisions → `memory:decision:create`
- Issues → `issue:create`
- Messages for other agents → `inbox:message:create`

The wright creates code and skills. The scribe commits. No one litters the repo with ad-hoc files.
