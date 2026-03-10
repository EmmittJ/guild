---
name: guild-tasks
description: >
  GitHub Issues task store for a team of agents. Tasks are issues — status via labels, closed
  issue = completed task. No write conflicts, no shared files.
  Activate when: task:item:create — work needs tracking; task:item:update — claiming, unclaiming,
  blocking, or completing a task; task:item:read — checking available or in-progress work;
  task:ready — finding actionable work at session start or before planning.
  DO NOT USE FOR: decisions, insights, or context — use the memory skill. Inbox messages — use the inbox skill.
license: MIT
metadata:
  version: "0.1"
  asset: .github/skills/guild-setup-github/assets/skills/guild-tasks/SKILL.md
---

## Overview

Tasks are GitHub Issues in `${github_repo}`. Status is tracked via labels; a closed issue is a
completed task.

**Label scheme:**

| Label | Meaning |
|-------|---------|
| `open` | Unclaimed, available work |
| `in-progress` | Claimed by an agent (this session) |
| `blocked` | Cannot proceed — blocking issue referenced in body |
| `priority:high` | Urgent |
| `priority:medium` | Normal priority |
| `priority:low` | Nice-to-have |

**State model:**
- Open issue + `open` label → available
- Open issue + `in-progress` label → claimed
- Open issue + `blocked` label → blocked
- Closed issue → done (archive)

> **Note (v1):** Agent identity is not tracked via assignees in this version. Claimed work is
> identified by the `in-progress` label only. Assignee mapping is deferred to a future version.

---

## Session Start

Run these two commands at the top of each session:

```sh
gh issue list -R ${github_repo} -l in-progress   # tasks claimed in a prior session (resume or unclaim)
gh issue list -R ${github_repo} -l open           # available work
```

---

## Task Format `task:item:create`

> **Shell note:** Always use `--body-file` or a heredoc for issue bodies. Inline `-b "text with \n"` passes literal backslash-n characters, not newlines.

Create an issue with a descriptive title, a structured body, and at least one status label.

**Required body structure:**

````markdown
## What
{What needs to be done. Specific enough that an agent can start without asking.}

## Done when
{Acceptance criteria. What does completion look like?}

## Context
{Links to relevant decisions, files, insights, or other tasks.}
````

**Pattern 1 — `--body-file` (recommended):**

```sh
cat > /tmp/guild-issue.md << 'EOF'
## What
{description}

## Done when
{acceptance criteria}

## Context
{links, related issues, notes}
EOF

gh issue create -R ${github_repo} \
  -t "{Task title}" \
  --body-file /tmp/guild-issue.md \
  -l open \
  -l priority:medium
```

**Pattern 2 — heredoc inline (bash/sh):**

```sh
gh issue create -R ${github_repo} \
  -t "{Task title}" \
  -b "$(cat << 'EOF'
## What
{description}

## Done when
{acceptance criteria}

## Context
{links, related issues, notes}
EOF
)" \
  -l open \
  -l priority:medium
```

**Pattern 3 — PowerShell here-string:**

```powershell
$body = @"
## What
{description}

## Done when
{acceptance criteria}

## Context
{links, related issues, notes}
"@
gh issue create -R ${github_repo} -t "{Task title}" -b $body -l open -l priority:medium
```
---

## State Transitions `task:item:update`

| Transition | Command |
|------------|---------|
| Create (open) | `gh issue create -R ${github_repo} -t "..." -b "..." -l open` |
| Claim (open → in-progress) | `gh issue edit -R ${github_repo} {number} --add-label in-progress --remove-label open` |
| Unclaim (in-progress → open) | `gh issue edit -R ${github_repo} {number} --add-label open --remove-label in-progress` |
| Block | `gh issue edit -R ${github_repo} {number} --add-label blocked --remove-label open --remove-label in-progress` |
| Complete | `gh issue close -R ${github_repo} {number}` |

---

## Read Commands `task:item:read`

```sh
gh issue list -R ${github_repo} -l open           # available work
gh issue list -R ${github_repo} -l in-progress    # claimed work
gh issue list -R ${github_repo} -l blocked        # blocked work
gh issue view -R ${github_repo} {number}          # full issue detail
```

---

## Ready Work `task:ready`

Returns open, unclaimed, unblocked tasks sorted by priority (high → medium → low → unset).

**"Ready" means:** has `open` label — does NOT have `in-progress` or `blocked` label.

```sh
gh issue list -R ${github_repo} -l open
```

> Agents should sort results by `priority:` label after retrieving — high before medium before low.

Use this at session start and before planning new work to surface actionable tasks sorted by priority.

---

## Blocked-by

GitHub Issues has no native blocking relationship. Use the `blocked` label to signal state and
document the dependency in the issue body:

```markdown
## Context
Blocked by #42.
```

Before claiming a task, check whether any referenced blocking issues are still open:

```sh
gh issue view -R ${github_repo} 42   # check if still open
```

---

## Priority

Add one priority label at create time. Omit if no prioritization is needed.

```sh
-l priority:high    # urgent
-l priority:medium  # normal
-l priority:low     # nice-to-have
```

---

## Rules

- Check open issues before creating — avoid duplicates (`gh issue list -R ${github_repo} -l open`)
- When claiming: add `in-progress` and remove `open` in the same `gh issue edit` call
- Check the issue body for "Blocked by #N" before claiming — don't start blocked work
- To block a task: add `blocked`, remove both `open` and `in-progress` in one call
- Closed issues are an archive — never reopen to edit; create a new issue if work resumes
- One issue per task

