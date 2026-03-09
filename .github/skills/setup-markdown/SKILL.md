---
name: setup-markdown
description: >
  Bootstrap markdown-based memory, task tracking, and/or inbox into any repo. Prompts the user to
  select which components to install (memory, tasks, inbox, or all). Bootstraps the required
  directory structure and copies the selected skill(s) into the repo's skills directory with paths
  baked in. Safe to re-run — skips anything that already exists.
  Activate when: setting up Guild in a repo for the first time, adding memory, task tracking, or
  inbox, or installing individual components à la carte.
  DO NOT USE FOR: reading or writing memory/tasks/inbox — use the memory, tasks, and inbox skills for that.
license: MIT
metadata:
  version: "0.1"
---

## What This Does

`/setup-markdown` is interactive. It prompts for:

1. **Which components to install** — memory, tasks, inbox, or all
2. **Where skills live** — defaults to `.github/skills`, but any path works
3. **Root path for each component** — defaults to `.guild/memory`, `.guild/tasks`, `.guild/inbox` respectively; any path relative to repo root is accepted

Then it:
- Bootstraps the selected directory structure at the chosen root paths
- Copies the selected skill SKILL.md file(s) into the skills directory with paths baked in

Each component is independent — a repo can use any combination or all three.

---

## Running the Script

**Unix / macOS / WSL:**
```sh
sh .github/skills/setup-markdown/scripts/setup.sh /path/to/repo
```

**Windows PowerShell:**
```powershell
.\.github\skills\setup-markdown\scripts\setup.ps1 -RepoRoot C:\path\to\repo
```

Both scripts are interactive — they prompt for component selection, skills directory, and each component's root path.
Pass `-y` (sh) or `-NonInteractive` (ps1) with env vars to skip prompts in CI.

**CI env vars:** `GUILD_COMPONENTS`, `GUILD_SKILLS_DIR`, `GUILD_MEMORY_ROOT`, `GUILD_TASKS_ROOT`, `GUILD_INBOX_ROOT`

---

## What Gets Created

**Memory component:**
```
.guild/memory/
  decisions/_summary.md
  insights/
  context/
{skills-dir}/memory/SKILL.md
```

**Tasks component:**
```
.guild/tasks/
  open/
  in_progress/
  closed/
{skills-dir}/tasks/SKILL.md
```

**Inbox component:**
```
.guild/inbox/              ← agent subdirs created on first message
{skills-dir}/inbox/SKILL.md
```

---

## After Setup

Register the installed skills in your `plugin.json` or `AGENTS.md`:

```json
"skills": [".github/skills/memory", ".github/skills/tasks", ".github/skills/inbox"]
```

Guild Master will apply whichever of these are present at session start.
