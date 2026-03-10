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
  version: "0.2"
  asset: .github/skills/guild-setup-github/assets/skills/guild-tasks/SKILL.md
---

## Overview

Tasks are GitHub Issues in `EmmittJ/guild`. Status is tracked via labels; a closed issue is a
completed task.

**Label scheme:**

| Label | Meaning | When used |
|-------|---------|-----------|
| `open` | Optional marker for unclaimed work | Historical/optional — not required |
| `in-progress` | Claimed by an agent this session | Add when claiming work |
| `blocked` | Cannot proceed — see body for blocker | Add when a blocker is discovered |
| `priority:high` | Urgent | Optional; at create time |
| `priority:medium` | Normal priority | Optional; at create time |
| `priority:low` | Nice-to-have | Optional; at create time |

**State model:**
- Open issue (no labels) → ready
- Open issue + `in-progress` → claimed
- Open issue + `blocked` → blocked
- Closed issue → done

> **Note (v2):** Ground truth is GitHub issue state (open/closed), not labels. Status labels are
> optional descriptive markers — unlabeled open issues are immediately actionable. Agent identity
> is not tracked via assignees in this version.

---

## Session Start

Run these two commands at the top of each session:

```sh
gh issue list -R EmmittJ/guild -l in-progress   # tasks claimed in a prior session (resume or unclaim)
gh issue list -R EmmittJ/guild --state open --search "-label:blocked"  # available work
```

---

## Task Format `task:item:create`

> **Shell note:** Always use `--body-file` or a heredoc for issue bodies. Inline `-b "text with \n"` passes literal backslash-n characters, not newlines.

Create an issue with a descriptive title, a structured body, and optionally a priority label.

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

gh issue create -R EmmittJ/guild \
  -t "{Task title}" \
  --body-file /tmp/guild-issue.md \
  -l priority:medium
```

**Pattern 2 — heredoc inline (bash/sh):**

```sh
gh issue create -R EmmittJ/guild \
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
gh issue create -R EmmittJ/guild -t "{Task title}" -b $body -l priority:medium
```

> **Note:** The `open` label is optional. New issues without labels are immediately actionable.

---

## State Transitions `task:item:update`

| Transition | Command |
|------------|---------|
| Create (ready) | `gh issue create -R EmmittJ/guild -t "..." -b "..." -l priority:medium` |
| Claim (→ in-progress) | `gh issue edit -R EmmittJ/guild {number} --add-label in-progress --remove-label open` (omit `--remove-label open` if issue has no `open` label) |
| Unclaim (→ ready) | `gh issue edit -R EmmittJ/guild {number} --remove-label in-progress` |
| Block | `gh issue edit -R EmmittJ/guild {number} --add-label blocked --remove-label open --remove-label in-progress` |
| Complete | `gh issue close -R EmmittJ/guild {number}` |

---

## Read Commands `task:item:read`

```sh
gh issue list -R EmmittJ/guild --state open --search "-label:blocked"  # available work
gh issue list -R EmmittJ/guild -l in-progress    # claimed work
gh issue list -R EmmittJ/guild -l blocked        # blocked work
gh issue view -R EmmittJ/guild {number}          # full issue detail
```

---

## Ready Work `task:ready`

Returns open, unblocked tasks regardless of status labels, sorted by priority (high → medium → low → unset).

**"Ready" means:** GitHub issue state is open AND does NOT have `blocked` label.

```sh
gh issue list -R EmmittJ/guild --state open --search "-label:blocked"
```

This catches unlabeled issues, priority-only issues, and issues with historical `open` labels.

> Agents should sort results by `priority:` label after retrieving — high before medium before low. Unset priority = lowest.

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
gh issue view -R EmmittJ/guild 42   # check if still open
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

- **Ground truth is GitHub issue state (open/closed), not labels.** Labels are optional workflow markers.
- **New issues without labels are immediately actionable.** No intake ceremony required.
- Check open issues before creating — avoid duplicates (`gh issue list -R EmmittJ/guild --state open`)
- When claiming: add `in-progress` and remove `open` in the same `gh issue edit` call
- Check the issue body for "Blocked by #N" before claiming — don't start blocked work
- To block a task: add `blocked`, remove both `open` and `in-progress` in one call
- Closed issues are an archive — never reopen to edit; create a new issue if work resumes
- One issue per task
