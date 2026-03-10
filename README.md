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

# optional: add markdown memory
# copy plugins/markdown/skills/memory into your .github/skills/
mkdir -p .guild
echo '{ "memory": ".agents/memory" }' > .guild/config.json
mkdir -p .agents/memory/{context,decisions,insights,inbox,tasks/open,tasks/in_progress,tasks/closed}
```

**Option B — install as a Copilot CLI plugin**

```sh
copilot plugin marketplace add EmmittJ/guild
copilot plugin install core@guild             # Guild Master + orchestrate + train skills

# pick your memory backend (mix and match)
copilot plugin install markdown-memory@guild # file-based memory: decisions, insights, context, inbox
copilot plugin install markdown-tasks@guild  # file-based tasks: open/in_progress/closed

# bootstrap Guild config in your repo
mkdir -p .guild
echo '{ "memory": ".agents/memory" }' > .guild/config.json
mkdir -p .agents/memory/{context,decisions,insights,inbox}
# if you installed markdown-tasks:
mkdir -p .agents/memory/tasks/{open,in_progress,closed}
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

# markdown-memory@guild plugin
plugins/markdown-memory/
  plugin.json
  skills/memory/
    SKILL.md
    scripts/
      memory-root.sh
      memory-root.ps1

# markdown-tasks@guild plugin
plugins/markdown-tasks/
  plugin.json
  skills/tasks/
    SKILL.md
    scripts/
      memory-root.sh    # resolves $memory root same way
      memory-root.ps1
```

```
# repo artifact — created on first use, written by agents
.agents/memory/
  context/
    {agent}.md
  decisions/
    _summary.md
  insights/
  inbox/
  tasks/          # only present if markdown-tasks@guild is installed
    open/
    in_progress/
    closed/
```

---

## Memory

The `memory` skill ships read-only with the `markdown-memory@guild` plugin. It teaches agents the protocol.
Agents write data to wherever `.guild/config.json` declares as the memory path — that's the part
that persists as a repo artifact and travels with the code.

```json
// .guild/config.json
{
  "memory": ".agents/memory"
}
```

| Type | What it stores | Location |
|------|---------------|----------|
| Episodic | Why we chose X | `{memory}/decisions/*.md` |
| Semantic | What's true about this codebase | `{memory}/insights/{domain}.md` |
| Working | What's in flight for each agent | `{memory}/context/{agent}.md` |
| Communication | Messages to specific agents | `{memory}/inbox/{agent}/*.md` |
| Procedural | What needs to be done | `{memory}/tasks/{open,in_progress,closed}/` |

Each agent owns its own context file — concurrent sessions don't conflict. The orchestrator
reads all `context/` files to synthesize team-wide state when needed.

---

## Adding Your Team

Your team lives in `.github/agents/` (or `.claude/agents/`, `.agents/` — wherever your platform looks). Ask Guild Master to build it:

```
train me an engineer agent for a TypeScript monorepo
train me a security-reviewer agent that reviews PRs for CVEs
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

Available plugins: `core@guild`, `markdown-memory@guild`, `markdown-tasks@guild`.

---

## Self-Managing

Guild uses itself. The agents and skills in this repo are the team that works on Guild.

---

## Contributing

Open an issue. The Guild Master will route it.



