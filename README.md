# Guild

> Craft, not configuration.

---

## What It Is

Guild is a **Guild Master** agent file and a set of skills in the [agentskills.io](https://agentskills.io) open format. Drop them into any repo and you have a self-managing AI team — one that knows your platform, can train new agents, and can delegate work to specialists.

It runs in Claude Code, GitHub Copilot CLI, VS Code, or anything else that loads agent files and skills. You can install it as a Copilot CLI plugin, or just copy the files in. There's nothing to import or configure beyond what's already in the repo.

---

## Use It

**Option A — copy into your repo**

```sh
# grab the agent
curl -o .github/agents/guild-master.agent.md \
  https://raw.githubusercontent.com/EmmittJ/guild/main/.github/agents/guild-master.agent.md

# grab the core skills
curl -o .github/skills/orchestrate \
  https://raw.githubusercontent.com/EmmittJ/guild/main/.github/skills/orchestrate
# (repeat for train-agent, train-skill)

# optional: add memory and tasks
mkdir -p .guild
mkdir -p .guild/memory/{context,decisions,insights}
mkdir -p .guild/tasks/{open,in_progress,closed}
mkdir -p .guild/inbox
```

**Option B — install as a Copilot CLI plugin**

```sh
copilot plugin marketplace add EmmittJ/guild
copilot plugin install core@guild             # Guild Master + orchestrate + train skills

# add guild-setup to bootstrap memory and tasks
copilot skill install guild-setup
/guild-setup                                   # interactive setup for your repo

# and use a specific setup variant
copilot skill install guild-setup-markdown    # markdown-based setup
/guild-setup-markdown

copilot skill install guild-setup-github      # GitHub-aware setup
/guild-setup-github
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

Memory configuration lives in `.guild/config.json`, not in AGENTS.md. A repo on ADO puts its ADO patterns here. Guild never needs to know what ADO is.

---

## What Ships

```
# core@guild plugin
.github/
  agents/
    guild-master.agent.md   # orchestrates work, delegates to specialists, synthesizes results
    charter.agent.md        # product owner — requirements, backlog, acceptance criteria
    smith.agent.md          # skill writer — writes and reviews SKILL.md files
    engineer.agent.md       # implementation — file creation, editing, scripts
    auditor.agent.md        # quality gate — signs off before committing
    invoker.agent.md        # CLI integration — plugin manifests, marketplace
    scribe.agent.md         # version control — commits, branches, pull requests
  skills/
    orchestrate/
      SKILL.md
      references/
        routing.md
        handoff.md
    train-agent/
      SKILL.md
    train-skill/
      SKILL.md
    guild-memory/
      SKILL.md
      scripts/
        memory-root.sh
        memory-root.ps1
    guild-tasks/
      SKILL.md
      scripts/
        memory-root.sh
        memory-root.ps1
    guild-inbox/
      SKILL.md
    guild-setup/
      SKILL.md
      scripts/
        setup.sh
        setup.ps1
    guild-setup-markdown/
      SKILL.md
      scripts/
        setup.sh
        setup.ps1
    guild-setup-github/
      SKILL.md
      scripts/
        setup.sh
        setup.ps1
```

```
# repo artifact — created on first use, written by agents
.guild/
  memory/
    context/
      {agent}.md
    decisions/
      _summary.md
    insights/
  tasks/
    open/
    in_progress/
    closed/
  inbox/
```

---

## Memory

The `guild-memory` skill ships with the core plugin. It teaches agents how to read and write memory.
Agents write data to `.guild/memory/` — the persistent, version-controlled memory that travels with the code.

The `guild-tasks` skill manages procedural memory — what needs to be done, what's in progress, and what's closed.

The `guild-inbox` skill manages agent-to-agent async messaging.

```
.guild/
  memory/
    context/         # Working memory: what each agent is doing
    decisions/       # Episodic: why we chose X
    insights/        # Semantic: what's true about this codebase
  tasks/
    open/            # Procedural: needs to be done
    in_progress/     # Procedural: work in flight
    closed/          # Procedural: completed work
  inbox/             # Communication: agent-to-agent messages
```

Each agent owns its own `context/{agent}.md` file — concurrent sessions don't conflict. The orchestrator
reads all context files to synthesize team-wide state when needed.

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

Available plugins: `core@guild` (includes guild-master, orchestrate, train-agent, train-skill, guild-memory, guild-tasks, guild-inbox).

---

## Self-Managing

Guild uses itself. The agents and skills in this repo are the team that works on Guild.

---

## Releases

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

## Contributing

Open an issue. The Guild Master will route it.
