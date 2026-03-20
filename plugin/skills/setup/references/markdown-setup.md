# Markdown Setup Reference

When markdown components are selected during `/guild:setup`, complete these steps after
scaffolding agents. No external tools required — all state lives as plain Markdown files
under `.agents/`.

## Overview

Three independent components are available. Install all of them unless you have a specific
reason to skip one:

| Component | Purpose                                       | Replaceable by |
| --------- | --------------------------------------------- | -------------- |
| memory    | Decisions, insights, and session context      | Beads          |
| issues    | Directory-as-status task tracking             | Beads, GitHub  |
| inbox     | Async agent-to-agent messaging                | Beads          |

## Components

### memory

Stores decisions, discovered insights, and session handoff context.

```
.agents/memory/
  decisions/_summary.md   ← decision index (agents append here)
  insights/               ← one file per discovered pattern
  context/                ← session handoff notes
{skills-dir}/markdown-memory/SKILL.md
```

### issues

Directory-as-status task tracking. Moving a file between directories is the state
transition — no shared status fields, no locking required.

```
.agents/issues/
  open/           ← unclaimed work
  in_progress/    ← claimed (one agent per file, file name = slug)
  closed/         ← completed
{skills-dir}/markdown-issues/SKILL.md
```

**State transitions:**

```
open/ → in_progress/   (claim)
in_progress/ → closed/ (complete)
in_progress/ → open/   (release / abandon)
```

### inbox

Async agent-to-agent messaging. Each agent owns a subdirectory; messages are single
Markdown files dropped there. Reading a message means deleting it.

```
.agents/inbox/
  {agent-name}/   ← created on first incoming message, not at setup time
{skills-dir}/markdown-inbox/SKILL.md
```

## Configuring Root Paths

The default roots can be changed at install time:

| Component | Default root       |
| --------- | ------------------ |
| memory    | `.agents/memory`   |
| issues    | `.agents/issues`   |
| inbox     | `.agents/inbox`    |

The installed SKILL.md for each component is stamped with the configured root during
setup — the `${memory_root}`, `${issues_root}`, and `${inbox_root}` placeholders are
replaced with the actual paths. Agents read the installed skill and always work against
those paths without needing to re-resolve them.

## Running the Script

`scripts/setup-markdown.sh` (Unix/macOS/WSL) and `scripts/setup-markdown.ps1` (Windows)
automate all of the above steps.

**Unix / macOS / WSL:**

```sh
sh scripts/setup-markdown.sh /path/to/repo
```

**Windows PowerShell:**

```powershell
.\scripts\setup-markdown.ps1 -RepoRoot C:\path\to\repo
```

**Interactive prompts:**

1. Which components to install — `memory`, `issues`, `inbox`, or `all`
2. Where skills live — default `.github/skills`
3. Root path for each selected component

**CI env vars** (suppresses all interactive prompts):

| Variable             | Purpose                                           |
| -------------------- | ------------------------------------------------- |
| `GUILD_COMPONENTS`   | Comma-separated list: `memory,issues,inbox` / `all` |
| `GUILD_SKILLS_DIR`   | Where to install skill files                      |
| `GUILD_MEMORY_ROOT`  | Override default `.agents/memory`                 |
| `GUILD_ISSUES_ROOT`  | Override default `.agents/issues`                 |
| `GUILD_INBOX_ROOT`   | Override default `.agents/inbox`                  |
