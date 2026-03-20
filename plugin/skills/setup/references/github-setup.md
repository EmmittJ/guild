# GitHub Issues Setup Reference

When GitHub Issues is selected as the issues backend during `/guild:setup`, complete these
steps after scaffolding agents. This backend replaces the markdown issues component only —
always also install markdown memory and inbox (Step 5A).

## Prerequisites

```bash
gh auth status   # must show "Logged in to github.com"
```

Install `gh` CLI if not present: https://cli.github.com

## 1. Detect or Set the Repo Slug

```bash
# Auto-detect from the current repo
gh repo view --json nameWithOwner -q .nameWithOwner

# Or set manually
owner/repo
```

The slug is baked into the installed `github-issues/SKILL.md` at install time so agents
never need to look it up.

## 2. Create GitHub Labels

Five labels are required. Using `--force` makes the command idempotent — safe to re-run
if setup is interrupted or repeated.

```bash
gh label create "in-progress"     --color "#e4e669" --description "Claimed by an agent" --force
gh label create "blocked"         --color "#d73a4a" --description "Cannot proceed" --force
gh label create "priority:high"   --color "#b60205" --description "Urgent" --force
gh label create "priority:medium" --color "#fbca04" --description "Normal priority" --force
gh label create "priority:low"    --color "#cfd3d7" --description "Nice-to-have" --force
```

| Label             | Color     | Meaning             |
| ----------------- | --------- | ------------------- |
| `in-progress`     | `#e4e669` | Claimed by an agent |
| `blocked`         | `#d73a4a` | Cannot proceed      |
| `priority:high`   | `#b60205` | Urgent              |
| `priority:medium` | `#fbca04` | Normal priority     |
| `priority:low`    | `#cfd3d7` | Nice-to-have        |

## 3. Install the Skill

Copy `assets/skills/github-issues/SKILL.md` to `{skills-dir}/github-issues/SKILL.md`,
replacing the `${repo}` placeholder with the actual slug. If a `markdown-issues` skill
already exists at that path, it is removed and replaced.

```
{skills-dir}/github-issues/SKILL.md   ← repo slug baked in
```

> **Scope reminder:** GitHub Issues replaces the issues component only. Memory and inbox
> still use markdown — always run Step 5A first and select at least memory + inbox.

## Running the Script

`scripts/setup-github.sh` (Unix/macOS/WSL) and `scripts/setup-github.ps1` (Windows)
automate all of the above steps.

**Unix / macOS / WSL:**

```sh
sh scripts/setup-github.sh /path/to/repo
```

**Windows PowerShell:**

```powershell
.\scripts\setup-github.ps1 -RepoRoot C:\path\to\repo
```

**CI env vars** (required in CI — no interactive prompts):

| Variable           | Purpose                             |
| ------------------ | ----------------------------------- |
| `GUILD_SKILLS_DIR` | Where to install the skill file     |
| `GUILD_REPO`       | Repo slug (`owner/repo`) to bake in |
