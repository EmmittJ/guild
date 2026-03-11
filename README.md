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
mkdir -p .guild/issues/{open,in_progress,closed}
mkdir -p .guild/inbox
```

**Option B — install as a Copilot CLI plugin**

```sh
copilot plugin marketplace add EmmittJ/guild
copilot plugin install core@guild             # Guild Master + orchestrate + train skills

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

Memory configuration lives in `.guild/config.json`, not in AGENTS.md. A repo on ADO puts its ADO patterns here. Guild never needs to know what ADO is.

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
| `.guild/memory/`                  | Decisions, insights, context — written by your agents     |
| `.guild/issues/`                  | Work items — written by your agents                       |
| `.guild/inbox/`                   | Agent-to-agent messages                                   |

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

| File / Directory               | Installed by   |
| ------------------------------ | -------------- |
| `.github/skills/guild-memory/` | `/guild:setup` |
| `.github/skills/guild-issues/` | `/guild:setup` |
| `.github/skills/guild-inbox/`  | `/guild:setup` |

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
        routing.md
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
          routing/
          markdown-memory/
          markdown-issues/
          markdown-inbox/
          github-issues/
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
    guild-memory/
      SKILL.md              # installed component
    guild-issues/
      SKILL.md              # installed component
    guild-inbox/
      SKILL.md              # installed component
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
  issues/
    open/
    in_progress/
    closed/
  inbox/
```

---

## Memory

The `guild-memory` skill ships with the core plugin. It teaches agents how to read and write memory.
Agents write data to `.guild/memory/` — the persistent, version-controlled memory that travels with the code.

The `guild-issues` skill manages procedural memory — what needs to be done, what's in progress, and what's closed.

The `guild-inbox` skill manages agent-to-agent async messaging.

```
.guild/
  memory/
    context/         # Working memory: what each agent is doing
    decisions/       # Episodic: why we chose X
    insights/        # Semantic: what's true about this codebase
  issues/
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

Available plugins: `core@guild` (includes guild-master, orchestrate, train-agent, train-skill, guild-memory, guild-issues, guild-inbox).

---

## Self-Managing

Guild uses itself. The agents and skills in this repo are the team that works on Guild.

---

## Releases

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

## Contributing

Open an issue. The Guild Master will route it.
