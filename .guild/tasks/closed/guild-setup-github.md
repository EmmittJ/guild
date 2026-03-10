---
priority: high
agent:
created: 2026-03-10
---

# guild-setup-github skill

## What

Build a new `/guild-setup-github` skill that installs GitHub Issues-backed task tracking as a drop-in replacement for the markdown tasks skill. Tasks only — memory and inbox remain file-based (guild-setup-markdown).

### Known requirements from scoping

- **Same verb interface**: `task:item:create`, `task:item:update`, `task:item:read` — agents don't need to change behavior
- **GitHub Issues as backend**: status via labels, closed issue = completed task
- **Label scheme (no prefix)**:
  - Status: `open`, `in-progress`, `blocked`
  - Priority: `priority:high`, `priority:medium`, `priority:low`
- **Setup scripts**: both `setup.sh` (bash + gh CLI) and `setup.ps1` (PowerShell + gh CLI)
- **Idempotent scripts**: `gh label create --force`, skip skill file if already exists
- **CI mode**: env vars `GUILD_SKILLS_DIR`, `GUILD_REPO`; flag `-y` / `-NonInteractive`
- **Recommend markdown** for memory + inbox in the After Setup section
- Pattern to follow: `guild-setup-markdown` SKILL.md + scripts

### Files to produce

1. `.github/skills/guild-setup-github/SKILL.md`
2. `.github/skills/guild-setup-github/assets/skills/tasks/SKILL.md` (GitHub-backed tasks skill)
3. `.github/skills/guild-setup-github/scripts/setup.sh`
4. `.github/skills/guild-setup-github/scripts/setup.ps1`
5. `plugin.json` — add `guild-setup-github` to core skills array

---

### Spec: `.github/skills/guild-setup-github/SKILL.md`

Frontmatter:
```yaml
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
```

Sections required (mirroring `guild-setup-markdown/SKILL.md`):
- **Asset Sources** — table mapping the installed skill to its source asset, with the same sync-signal note
- **What This Does** — describes interactive prompts (skills dir, repo slug) and what the script produces
- **Running the Script** — usage for both `setup.sh` and `setup.ps1`, with CI env var documentation
- **What Gets Created** — the 6 labels (with colors) and the skill file path
- **After Setup** — confirms the tasks skill is active and recommends `/guild-setup-markdown` for memory and inbox

---

### Spec: `.github/skills/guild-setup-github/assets/skills/tasks/SKILL.md`

This is the GitHub-backed tasks skill that gets copied into the target repo. It must:

**Frontmatter:**
```yaml
name: tasks
description: >
  GitHub Issues task store for a team of agents. Tasks are issues — status via labels, closed
  issue = completed task. No write conflicts, no shared files.
  Activate when: task:item:create — work needs tracking; task:item:update — claiming, unclaiming,
  blocking, or completing a task; task:item:read — checking available or in-progress work.
  DO NOT USE FOR: decisions, insights, or context — use the memory skill. Inbox messages — use the inbox skill.
license: MIT
metadata:
  version: "0.1"
  asset: .github/skills/guild-setup-github/assets/skills/tasks/SKILL.md
```

**`${github_repo}` placeholder** — all `gh` commands in the file use `-R ${github_repo}`. The setup script substitutes this with the actual `owner/repo` slug at install time. The installed skill has the repo hardcoded.

**Sections and required content:**

*Overview* — label scheme table (all 6 labels with what each means), and the state model (open issue = open/in-progress/blocked; closed issue = done).

*Session Start* — two commands agents must run at the top of each session:
```sh
gh issue list -R ${github_repo} -l in-progress   # tasks claimed in a prior session
gh issue list -R ${github_repo} -l open           # available work
```

*Task Format `task:item:create`* — how to create an issue. Required fields: title (task slug + description), body (## What / ## Done when / ## Context sections matching the markdown task format), labels (one status label + optionally one priority label). Example `gh issue create` command with all flags shown.

*State Transitions `task:item:update`* — explicit gh commands for all five transitions:

| Transition | Command |
|-----------|---------|
| Create (open) | `gh issue create -R ${github_repo} -t "..." -b "..." -l open` |
| Claim (open → in-progress) | `gh issue edit -R ${github_repo} {number} --add-label in-progress --remove-label open` |
| Unclaim (in-progress → open) | `gh issue edit -R ${github_repo} {number} --add-label open --remove-label in-progress` |
| Block | `gh issue edit -R ${github_repo} {number} --add-label blocked --remove-label open --remove-label in-progress` |
| Complete | `gh issue close -R ${github_repo} {number}` |

*Read commands `task:item:read`* — list by status label, view a specific issue:
```sh
gh issue list -R ${github_repo} -l open
gh issue list -R ${github_repo} -l in-progress
gh issue list -R ${github_repo} -l blocked
gh issue view -R ${github_repo} {number}
```

*Blocked-by* — no native GitHub relationship; document in the issue body as "Blocked by #N". Use the `blocked` label. Before claiming a task, check whether any referenced blocking issues are still open.

*Priority* — add one of `priority:high`, `priority:medium`, `priority:low` at create time. Omit if no priority needed.

*Rules* — mirror the markdown tasks rules, translated to GitHub Issues context:
- Check open issues before creating — avoid duplicates
- When claiming: add `in-progress`, remove `open` in the same `gh issue edit` call
- Check body for "Blocked by #N" before claiming — don't start blocked work
- `closed` issues are an archive — never reopen to edit; create a new issue if work resumes
- One issue per task

---

### Spec: `setup.sh` and `setup.ps1`

**Script signature:**

`sh setup.sh <repo-root> [-y]`
- `repo-root` — absolute path to the repo (required, same as guild-setup-markdown)
- `-y` — non-interactive; reads all values from env vars

`.\setup.ps1 -RepoRoot <path> [-NonInteractive] [-SkillsDir <path>] [-GuildRepo <owner/repo>]`

**Interactive flow (no -y / no -NonInteractive):**

1. Prompt: `Skills directory [.github/skills]:` — where to install the tasks skill
2. Prompt: `Repo (owner/repo) [<auto-detected>]:` — auto-detect default via `gh repo view --json nameWithOwner -q .nameWithOwner`; present the detected value as the default; user may override

**CI env vars:**

| Var | Default | Purpose |
|-----|---------|---------|
| `GUILD_SKILLS_DIR` | `.github/skills` | Where to install the skill |
| `GUILD_REPO` | (required) | `owner/repo` slug for gh CLI; error if not set in CI mode |

**Label creation** — exactly 6 labels, created with `gh label create --force -R <repo>`:

| Label | Color |
|-------|-------|
| `open` | `#0075ca` |
| `in-progress` | `#e4e669` |
| `blocked` | `#d73a4a` |
| `priority:high` | `#b60205` |
| `priority:medium` | `#fbca04` |
| `priority:low` | `#cfd3d7` |

**Skill file installation** — copy `assets/skills/tasks/SKILL.md` to `{skills-dir}/tasks/SKILL.md`, substituting `${github_repo}` with the resolved repo slug. Skip (print "skipped") if destination already exists.

**Output on success:**
```
Done. Add the installed skill to your plugin.json or AGENTS.md:

  "skills": ["{skills-dir}/tasks"]

  Repo: owner/repo

For memory and inbox, run: /guild-setup-markdown
```

**Error conditions:**
- Missing `repo-root` argument → print usage and exit 1
- `GUILD_REPO` not set in CI mode → print error and exit 1
- `gh` not installed → print "Error: gh CLI is required. Install from https://cli.github.com" and exit 1
- `gh` not authenticated → print "Error: gh CLI is not authenticated. Run: gh auth login" and exit 1

Note: there is no MCP or other fallback — `gh` CLI is the only supported method. Check `gh auth status` upfront before doing anything else.

---

### Spec: `plugin.json`

Add `.github/skills/guild-setup-github` to the `skills` array in the `"core"` plugin object. The resulting array must contain all existing entries plus the new one (do not remove anything).

---

## Done when

Most criteria can be verified statically (grep, jq, file existence). Idempotency and label-creation criteria require running the scripts against an authenticated GitHub account — those are manual verification.

### File existence
- [ ] `test -f .github/skills/guild-setup-github/SKILL.md`
- [ ] `test -f .github/skills/guild-setup-github/assets/skills/tasks/SKILL.md`
- [ ] `test -f .github/skills/guild-setup-github/scripts/setup.sh`
- [ ] `test -f .github/skills/guild-setup-github/scripts/setup.ps1`
- [ ] `jq '.plugins[0].skills | contains([".github/skills/guild-setup-github"])' plugin.json` returns `true`

### `guild-setup-github/SKILL.md`
- [ ] Frontmatter contains `name: guild-setup-github`
- [ ] Description activates on setup intent and deactivates on task read/write and memory/inbox setup
- [ ] Asset Sources table present, maps installed skill path to source asset path
- [ ] Running the Script section documents both `setup.sh` and `setup.ps1` usage, including `-y` / `-NonInteractive` and all CI env vars (`GUILD_SKILLS_DIR`, `GUILD_REPO`)
- [ ] What Gets Created section lists all 6 labels with their names and colors, plus the installed skill path
- [ ] After Setup section recommends `/guild-setup-markdown` for memory and inbox

### `assets/skills/tasks/SKILL.md`
- [ ] Frontmatter `name: tasks`, `metadata.asset:` points to `.github/skills/guild-setup-github/assets/skills/tasks/SKILL.md`
- [ ] All `gh` commands use `-R ${github_repo}` (the literal placeholder string, not a hardcoded repo)
- [ ] Documents `task:item:create` — `gh issue create` with title, body, and label flags shown
- [ ] Documents `task:item:update` — all five transitions (create, claim, unclaim, block, complete) with exact `gh issue edit` / `gh issue close` commands
- [ ] Documents `task:item:read` — `gh issue list` filtered by each status label, and `gh issue view`
- [ ] Session Start section lists the two commands to run at session open (in-progress check, then open list)
- [ ] Blocked-by pattern documented (body reference + `blocked` label)
- [ ] Priority label usage documented (one of `priority:high/medium/low`, optional)
- [ ] Rules section present and covers: check before creating, claim atomicity, blocked-by check, archive rule

### `setup.sh`
- [ ] Shebang is `#!/usr/bin/env sh`, uses `set -e`
- [ ] Requires `repo-root` as first positional arg; prints usage and exits 1 if missing
- [ ] Interactive mode: prompts for skills dir (default `.github/skills`), then repo slug (default from `gh repo view`)
- [ ] CI mode (`-y`): reads `GUILD_SKILLS_DIR` and `GUILD_REPO` from env; exits 1 with error message if `GUILD_REPO` is unset
- [ ] Creates all 6 labels with `gh label create --force -R <repo>` using the specified colors
- [ ] Copies asset skill to `{skills-dir}/tasks/SKILL.md` with `${github_repo}` substituted
- [ ] Prints "skipped" (not an error) if skill file already exists
- [ ] Re-running with same args exits 0 (idempotent — `--force` handles labels, skip handles skill file)
- [ ] Prints "For memory and inbox, run: /guild-setup-markdown" at completion

### `setup.ps1`
- [ ] `#Requires -Version 5.1`, `$ErrorActionPreference = "Stop"`
- [ ] `-RepoRoot` is mandatory; errors if missing
- [ ] Interactive mode: prompts for skills dir and repo slug (same defaults as sh)
- [ ] `-NonInteractive` flag + `-GuildRepo` param + `-SkillsDir` param mirror `-y` + env vars in sh
- [ ] CI mode: reads `GUILD_SKILLS_DIR` and `GUILD_REPO` from env when params not provided; exits 1 with error if `GUILD_REPO` unresolvable
- [ ] Creates same 6 labels with same colors via `gh label create --force`
- [ ] Copies and substitutes skill file; skips if exists
- [ ] Re-running exits 0 (idempotent)
- [ ] Prints "For memory and inbox, run: /guild-setup-markdown" at completion

## Context

- Pattern reference: `.github/skills/guild-setup-markdown/`
- Markdown tasks interface to replicate: `.github/skills/tasks/SKILL.md`
- Plugin registration: `plugin.json`
- Decision: tasks-only (memory/inbox stay file-based — GitHub Issues not a good fit for those)

---

## Product Owner Notes

**Decisions made during spec sharpening:**

1. **`${github_repo}` as the single placeholder** — The markdown tasks skill uses `${tasks_root}` to bake in a file path. The GitHub-backed skill only needs the repo slug (`owner/repo`) since Issues live in GitHub, not the filesystem. One placeholder, substituted by the setup script at install time.

2. **Label colors specified** — The original spec said "create labels" but gave no colors, which would produce GitHub's random-color defaults and inconsistent installs. I assigned a deliberate palette: blue for open, yellow for in-progress, red for blocked, dark red / amber / gray for priority tiers. Engineers must use these exact hex values.

3. **GUILD_REPO is required in CI mode (not optional)** — There is no safe default for `owner/repo`. If it's unset in CI mode, the script must exit with an error, not silently skip label creation.

4. **Auto-detect repo slug in interactive mode** — `gh repo view --json nameWithOwner -q .nameWithOwner` is the right way to offer a default. If `gh` is not authenticated the prompt still appears, just with no default prefilled.

5. **Agent field not tracked in v1** — The markdown tasks skill has an `agent:` frontmatter field (who claimed it). GitHub Issues has assignees, but mapping this cleanly requires `gh` user lookups. Deferred: v1 uses only labels for status/priority. Agents identify claimed work by the `in-progress` label, not by assignee. Document this limitation in the SKILL.md rules section.

6. **Blocked-by via body text, not a label** — There is no native "blocked by #N" relationship in GitHub Issues. The `blocked` label signals state; the issue body (or a comment) carries the reference to the blocking issue number. This mirrors the markdown `blocked-by:` frontmatter convention closely enough for agents to follow.

7. **`-GuildRepo` param on setup.ps1** — The sh script uses env vars exclusively for CI. The ps1 pattern (from guild-setup-markdown) exposes params directly in addition to env vars, which is more idiomatic PowerShell. Added `-GuildRepo` param to match; env var `GUILD_REPO` is the fallback when the param is omitted.

8. **`plugin.json` entry goes in the existing `"core"` plugin** — There is only one plugin object today. Adding a second just for guild-setup-github would be premature. It belongs with the other setup skills.

9. **"Done when" criteria are written for static verification** — Most criteria can be checked with `grep`, `jq`, and file-existence tests without running scripts against a live GitHub account. The idempotency and error-exit criteria require running the scripts but are scoped to local behavior (no real label creation needed to verify exit codes and skip logic).

---

## Outcome

Completed. All 5 files created: SKILL.md, assets/skills/tasks/SKILL.md, scripts/setup.sh, scripts/setup.ps1, and plugin.json updated. All spec requirements met.
