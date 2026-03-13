# Guild

> An AI team for any repo. No runtime, no vendor lock-in — just files.

Drop Guild into a repo and you get a self-managing AI team: a Guild Master that orchestrates, specialists that implement and review, shared memory, and a work queue. It works in Claude Code, GitHub Copilot CLI, VS Code, or anything else that reads `.agent.md` files.

Nothing to run. Nothing to install before you start. One `/guild:setup` command and you have a team.

---

## What It Is

Guild is a **Guild Master** agent file and a set of skills in the [agentskills.io](https://agentskills.io) open format. The agents coordinate through skills — structured instructions the AI loads on demand — rather than through a service or runtime.

Install as a Copilot CLI plugin or copy the files in directly. Either way, you get:

- **Guild Master** — orchestrates work, delegates to specialists, synthesizes results
- **Setup skill** — scaffolds your team, memory, and issue tracking in one session
- **Orchestrate, train-agent, train-skill** — core skills for coordination and team growth
- **Work-cycle** — backend-agnostic session discipline: orient, claim, work, land cleanly

Memory and issue tracking default to plain markdown files — no install. Switch to [beads](https://github.com/EmmittJ/gastown) when you want cross-clone sync and dependency graphs.

---

## Use It

**Option A — copy into your repo**

```sh
# grab the agent
curl --create-dirs -o .github/agents/guild-master.agent.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/.github/agents/guild-master.agent.md

# grab the core plugin skills
curl --create-dirs -o .github/skills/orchestrate/SKILL.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/plugin/skills/orchestrate/SKILL.md
curl --create-dirs -o .github/skills/orchestrate/references/handoff.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/plugin/skills/orchestrate/references/handoff.md
curl --create-dirs -o .github/skills/train-agent/SKILL.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/plugin/skills/train-agent/SKILL.md
curl --create-dirs -o .github/skills/train-skill/SKILL.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/plugin/skills/train-skill/SKILL.md

# optional: run /guild:setup interactively to scaffold your team + install memory/issues/inbox
# or install the setup skill manually:
curl --create-dirs -o .github/skills/setup/SKILL.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/plugin/skills/setup/SKILL.md
```

**Option B — install as a Copilot CLI plugin**

```sh
copilot plugin marketplace add EmmittJ/guild
copilot plugin install guild@guild            # Guild Master + orchestrate + train skills

# add the setup skill to bootstrap your team
copilot skill install setup@guild
/guild:setup                    # interactive setup — team, memory, issues, inbox
```

Either way, create an `AGENTS.md` at your repo root to tell Guild Master how your repo works.

---

## AGENTS.md

Guild Master reads this file first. It's where your repo's platform, conventions, and ground rules live — not in Guild itself.

```markdown
# AGENTS.md

## Platform

GitHub. Use `gh` CLI for all platform operations.

## Branches

`main` is protected. All work goes through PRs.

## Ground rules

Flag blockers immediately. Factual accuracy over narrative flair.
```

Memory configuration lives in `.beads/config.yaml` when using beads. A repo on ADO puts its ADO patterns here. Guild never needs to know what ADO is.

---

## First Session

After install, run the setup skill:

```
/guild:setup
```

Any agent with access to the setup skill can run it. It will:

1. Silently scan your repo (language, framework, CI, existing agents)
2. Show you what it found and ask for a universe to cast your team from
3. Guide you through casting your team and scaffolding agent files
4. Optionally install memory, issues, and inbox components

When it's done you'll have:

- `.github/agents/` populated with your team
- `.github/skills/routing/SKILL.md` with your roster and routing rules
- Optionally: beads (bd) for persistent issue tracking, or `.github/skills/markdown-memory/`, `github-issues/`, `markdown-inbox/` for markdown-based components

To verify: check `.github/agents/` for agent files and `.github/skills/routing/SKILL.md` for your team roster.

---

## Customization

Guild installs two kinds of files into your repo. Know which is which before editing.

### Host-owned — yours to change

These files are scaffolded once and then belong to your repo. Edit them freely:

| File / Directory                  | What to put there                                         |
| --------------------------------- | --------------------------------------------------------- |
| `AGENTS.md`                       | Platform, conventions, team constitution                  |
| `.github/agents/*.agent.md`       | Your team's agent files, created by `/guild:setup`        |
| `.github/skills/routing/SKILL.md` | Team roster, routing rules, **model names for each tier** |
| `.beads/`                         | Beads database — issues, decisions, insights (if using beads) |
| `.agents/memory/`                  | Decisions, insights, context (if using markdown memory)   |
| `.agents/issues/`                  | Work items (if using markdown issues)                     |
| `.agents/inbox/`                   | Agent-to-agent messages (if using markdown inbox)         |

The `routing` skill is the primary configuration surface. It's where you set the model names that correspond to the Fast / Standard / Premium tiers used by the orchestrate skill.

### Plugin-owned — do not modify

These files are owned by the Guild plugin and will be overwritten when you upgrade:

| File / Directory             | Why it's plugin-owned                                 |
| ---------------------------- | ----------------------------------------------------- |
| `plugin/skills/orchestrate/` | Core orchestration logic — updated by Guild releases  |
| `plugin/skills/train-agent/` | Agent authoring protocol                              |
| `plugin/skills/train-skill/` | Skill authoring protocol                              |
| `plugin/skills/setup/`       | Setup wizard — team scaffolding + component installer |

If you need to change how orchestration works, open an issue on the Guild repo or fork it. Don't edit plugin-owned files in place — your changes will be lost on the next `copilot plugin update`.

### Installed components — yours after setup

These skills are copied into your repo by `/guild:setup`. Once installed, they belong to your repo — edit them freely:

| File / Directory                  | Installed by   |
| --------------------------------- | -------------- |
| `.github/skills/markdown-memory/` | `/guild:setup` (markdown) |
| `.github/skills/github-issues/`   | `/guild:setup` (github)   |
| `.github/skills/markdown-inbox/`  | `/guild:setup` (markdown) |
| `.github/skills/beads/`           | `/guild:setup` (beads)    |

They also power this repo's self-managing team. If you need to customise how memory, tasks, or inbox work for your project, these are the files to edit.

---

## What Ships

```
# guild plugin — shipped by this repo
plugin/
  skills/
    orchestrate/
      SKILL.md
      references/
        handoff.md
    setup/
      SKILL.md
      assets/
        agents/
          orchestrator.agent.md
          builder.agent.md
          advisor.agent.md
          scribe.agent.md
        skills/
          beads/
          github-issues/
          markdown-inbox/
          markdown-issues/
          markdown-memory/
          routing/
      scripts/
        setup-markdown.sh
        setup-markdown.ps1
        setup-github.sh
        setup-github.ps1
    train-agent/
      SKILL.md
    train-skill/
      SKILL.md

# installed components — copied into your repo by /guild:setup
.github/
  agents/
    guild-master.agent.md   # orchestrates work, delegates to specialists, synthesizes results
    # ...your team's agents scaffolded by /guild:setup
  skills/
    routing/
      SKILL.md              # team roster — host-owned, edit freely
    markdown-memory/
      SKILL.md              # installed component
    github-issues/
      SKILL.md              # installed component
    markdown-inbox/
      SKILL.md              # installed component
```

```
# repo artifact — created on first use, written by agents
.agents/
  memory/
    context/
      {agent}.md
    decisions/
      _summary.md
    insights/
  issues/
    open/
    in_progress/
    closed/
  inbox/
```

---

## Memory & Issue Tracking

Start with markdown. It works immediately — no tools to install, no accounts to configure, nothing that can break in CI. Upgrade to beads when you want more.

| Backend | What it covers | Requires |
| ------- | -------------- | -------- |
| **Markdown** | Memory, issues, inbox | nothing |
| **Beads** | All of the above + cross-clone sync | `bd` CLI v0.47.0+ |
| **GitHub Issues** | Issues only (pair with markdown memory) | `gh` CLI |

### Markdown (Default — start here)

Plain files in `.agents/` — survives compaction, works offline, no dependencies.

```
.agents/
  memory/
    context/         # Working memory: what each agent is doing
    decisions/       # Why we chose X
    insights/        # What's true about this codebase
  issues/
    open/            # Needs to be done — type, priority, blocked-by, discovered-from
    in_progress/     # Work in flight — Notes field for compaction survival
    closed/          # Completed work — audit trail, never delete
  inbox/             # Agent-to-agent messages
```

Issues support type, priority, `blocked-by`, `discovered-from` lineage, and a `## Notes` field for writing `COMPLETED / IN PROGRESS / NEXT` snapshots before context is lost. Each agent owns its own `context/{agent}.md` — concurrent sessions don't conflict.

### Beads (Level up — replaces markdown entirely)

[Beads (`bd`)](https://github.com/EmmittJ/gastown) is a Git-backed issue tracker powered by Dolt. It covers everything markdown does, plus dependency graphs, cross-clone sync, and richer compaction survival. Once you switch to beads, you don't need the markdown components — select it in `/guild:setup` and skip the rest.

Ready to upgrade? Install `bd` and run `/guild:setup` — or just run `bd init` and let Guild Master switch the team over.

```bash
bd init                          # Initialize beads database
bd dolt remote add origin <url>  # Configure sync remote
bd ready                         # See actionable work
bd list --type=decision          # Browse decisions
```

Data lives in `.beads/dolt/` and syncs independently of git via `bd dolt push`/`bd dolt pull`. On a fresh clone, any `bd` command auto-bootstraps from the remote. Requires `bd` CLI v0.47.0+.

### GitHub Issues (Replaces markdown issues only)

GitHub Issues replaces the **issues component only** — it has no equivalent for memory (decisions, insights, context) or inbox. Always pair it with markdown memory + inbox.

- GitHub Issues handles tasks, work items, labels, and compaction-survival via issue comments
- Markdown memory still stores decisions, insights, and per-agent context
- Markdown inbox still handles agent-to-agent messaging

During `/guild:setup`, select GitHub Issues in Step 5C **and** memory + inbox from Step 5A. The two install in parallel and do not conflict.

---

## Upgrading

**Option B (CLI plugin):**

```sh
copilot plugin update guild
```

This replaces plugin-owned files (`plugin/skills/orchestrate/`, `train-agent/`, `train-skill/`, `setup/`) with the latest versions.

Your installed components — `routing/SKILL.md`, `markdown-memory/`, `markdown-inbox/`, `github-issues/` — are not touched. They belong to your repo.

See [CHANGELOG.md](CHANGELOG.md) for breaking changes and migration notes before upgrading.

**Option A (curl):** Re-run the curl commands from the install section to pull updated files.

---

## Adding Your Team

Your team lives in `.github/agents/` (or `.claude/agents/`, `.agents/` — wherever your platform looks). Ask Guild Master to build it:

```
train me an engineer agent for a TypeScript monorepo
train me a security-auditor agent that reviews PRs for CVEs
```

Or write one directly. Guild Master accepts any agent format your tool supports. For Copilot CLI:

```markdown
---
name: engineer
description: Implements features, fixes bugs, and updates configuration. Use for any code or config change.
tools: ["bash", "write", "read_file", "glob", "grep"]
---

You implement with precision and leave the code cleaner than you found it.
```

---

## Adding Skills

Skills follow the [agentskills.io](https://agentskills.io/specification) open format — a `SKILL.md` with YAML frontmatter and instructions, plus optional `scripts/`, `references/`, and `assets/` directories.

Drop any skill into `.github/skills/` and every agent in the session picks it up. Anyone can publish a skill.

---

## Copilot CLI Marketplace

```sh
copilot plugin marketplace add EmmittJ/guild
copilot plugin marketplace browse guild
```

Available plugins: `guild@guild` (includes orchestrate, setup, train-agent, train-skill).

---

## Self-Managing

Guild uses itself. The agents and skills in this repo are the team that works on Guild.

---

## Releases

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

## Contributing

Open an issue. The Guild Master will route it.
