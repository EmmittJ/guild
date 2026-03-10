---
name: guild-setup-github
description: >
  Bootstrap GitHub Issues-backed task tracking into any repo. Creates the required labels and
  copies the GitHub tasks skill with the repo slug baked in. Safe to re-run — labels use --force,
  skill file is skipped if already present.
  Activate when: setting up Guild task tracking in a repo that uses GitHub Issues as the backend.
  Run /guild-setup first to configure core settings (AGENTS.md, routing) if not already done.
  DO NOT USE FOR: reading or writing tasks — use the tasks skill for that. Memory or inbox setup —
  use /guild-setup-markdown for those.
license: MIT
metadata:
  version: "0.1"
---

## Asset Sources

The task skill installed by this script is a templated copy of the GitHub-backed tasks skill asset
in this repo:

| Installed skill | Source asset |
|----------------|--------------|
| `{skills-dir}/tasks/SKILL.md` | `.github/skills/tasks/SKILL.md` → asset copy at `guild-setup-github/assets/skills/tasks/SKILL.md` |

**When editing the GitHub tasks skill:** also update the corresponding asset. The source skill's
frontmatter has `metadata.asset:` pointing to its asset counterpart — use that as the sync signal.

---

## What This Does

`/guild-setup-github` is interactive. It prompts for:

1. **Where skills live** — defaults to `.github/skills`, but any path works
2. **Repo slug** — `owner/repo` used in all `gh` commands; auto-detected from the current directory
   via `gh repo view --json nameWithOwner -q .nameWithOwner`; user may override

Then it:
- Creates the 6 required GitHub labels in the target repo
- Copies the GitHub tasks skill `SKILL.md` into the skills directory with the repo slug baked in

**Prerequisites:** `gh` CLI must be installed and authenticated (`gh auth status`). The script
checks this before doing anything and exits with a clear error if either condition is not met.

---

## Running the Script

**Unix / macOS / WSL:**
```sh
sh .github/skills/guild-setup-github/scripts/setup.sh /path/to/repo
```

**Windows PowerShell:**
```powershell
.\.github\skills\guild-setup-github\scripts\setup.ps1 -RepoRoot C:\path\to\repo
```

Both scripts are interactive — they prompt for skills directory and repo slug.
Pass `-y` (sh) or `-NonInteractive` (ps1) with env vars to skip prompts in CI.

**CI env vars:**

| Variable | Default | Purpose |
|----------|---------|---------|
| `GUILD_SKILLS_DIR` | `.github/skills` | Where to install the skill |
| `GUILD_REPO` | (required) | `owner/repo` slug for `gh` CLI; error if not set in CI mode |

**CI examples:**

```sh
# sh
GUILD_REPO=myorg/myrepo sh setup.sh /path/to/repo -y

# ps1
.\setup.ps1 -RepoRoot C:\path\to\repo -NonInteractive -GuildRepo myorg/myrepo
```

---

## What Gets Created

**Labels** (created with `gh label create --force` — safe to re-run):

| Label | Color | Meaning |
|-------|-------|---------|
| `open` | `#0075ca` | Unclaimed, available work |
| `in-progress` | `#e4e669` | Claimed by an agent |
| `blocked` | `#d73a4a` | Cannot proceed — see issue body for reason |
| `priority:high` | `#b60205` | Urgent |
| `priority:medium` | `#fbca04` | Normal priority |
| `priority:low` | `#cfd3d7` | Nice-to-have |

**Skill file:**
```
{skills-dir}/tasks/SKILL.md   ← GitHub-backed tasks skill with repo slug baked in
```

---

## After Setup

The installed tasks skill is immediately active — Guild Master will apply it at session start.
No plugin registration or AGENTS.md update is needed.

For memory and inbox (file-based), run: `/guild-setup-markdown`
