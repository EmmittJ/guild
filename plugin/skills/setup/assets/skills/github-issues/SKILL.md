---
name: github-issues
description: >
  GitHub Issues issues store for a team of agents. Issues track status via labels — closed
  issue = completed issue. No write conflicts, no shared files.
  Activate when: issue:create — work needs tracking; issue:update — claiming, unclaiming,
  blocking, or completing an issue; issue:read — checking available or in-progress work;
  issue:ready — finding actionable work at session start or before planning.
  DO NOT USE FOR: decisions, insights, or context — use `memory:decision:create`. Inbox messages — use `inbox:message:create`.
license: MIT
metadata:
  version: "0.4"
---

## Overview

Issues are tracked as GitHub Issues in `${github_repo}`. Status is tracked via labels; a closed issue is a
completed issue.

**Label scheme:**

| Label             | Meaning                               | When used                        |
| ----------------- | ------------------------------------- | -------------------------------- |
| `in-progress`     | Claimed by an agent this session      | Add when claiming work           |
| `blocked`         | Cannot proceed — see body for blocker | Add when a blocker is discovered |
| `priority:high`   | Urgent                                | Optional; at create time         |
| `priority:medium` | Normal priority                       | Optional; at create time         |
| `priority:low`    | Nice-to-have                          | Optional; at create time         |

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

Run these commands at the top of each session:

```sh
# 1. Your claimed work from prior sessions
gh issue list -R ${github_repo} -l in-progress

# 2. Available unblocked work
gh issue list -R ${github_repo} --state open --search "-label:blocked"
```

**Recovery from prior session:** For each in-progress issue you own, check its comment thread for a progress note:

```sh
gh issue view -R ${github_repo} {number} --comments
```

Find the most recent comment containing `COMPLETED:` / `IN PROGRESS:` / `NEXT:` — that is your resumption point.

---

## Create `issue:create`

> **Shell note:** Always use `--body-file` or a heredoc for issue bodies. Inline `-b "text with \n"` passes literal backslash-n characters, not newlines.

Create an issue with a descriptive title, a structured body, and optionally a priority label.

**Required body structure:**

```markdown
## What

{What needs to be done. Specific enough that an agent can start without asking.}

## Done when

{Acceptance criteria. What does completion look like?}

## Context

{Links to relevant decisions, files, insights, or other tasks.}
```

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
gh issue create -R ${github_repo} -t "{Task title}" -b $body -l priority:medium
```

---

## Compaction Survival

Context compaction discards conversation history. Before any long operation or when ending a session, post a progress comment on each in-progress issue you own.

**Progress comment format:**

```sh
gh issue comment -R ${github_repo} {number} -b "$(cat << 'EOF'
COMPLETED: {what is fully done}
IN PROGRESS: {exact current state — be specific}
NEXT: {first concrete action when resuming}
KEY DECISIONS: {choices made that affect future work}
EOF
)"
```

**PowerShell:**

```powershell
$progress = @"
COMPLETED: {what is fully done}
IN PROGRESS: {exact current state}
NEXT: {first concrete action when resuming}
KEY DECISIONS: {choices made}
"@
gh issue comment -R ${github_repo} {number} -b $progress
```

**When to post a progress comment:**
- Before any file-heavy implementation run
- When ending a session or handing off
- Any time you would lose context if the conversation reset right now

**Recovery:** `gh issue view -R ${github_repo} {number} --comments` — find the most recent `COMPLETED:` comment and resume from `NEXT:`.

---

## Discovered-from

When you find side work while working on another issue, create the new issue and reference the parent in the body:

```markdown
## Context

Discovered while working on #{parent-number}.
```

This creates a visible lineage trail in the GitHub UI without requiring any special labels.

---

## Update `issue:update`

| Transition            | Command                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------- |
| Create (ready)        | `gh issue create -R ${github_repo} -t "..." -b "..." -l priority:medium`                  |
| Claim (→ in-progress) | `gh issue edit -R ${github_repo} {number} --add-label in-progress`                        |
| Unclaim (→ ready)     | `gh issue edit -R ${github_repo} {number} --remove-label in-progress`                     |
| Block                 | `gh issue edit -R ${github_repo} {number} --add-label blocked --remove-label in-progress` |
| Complete              | `gh issue close -R ${github_repo} {number}`                                               |

---

## Read `issue:read`

```sh
gh issue list -R ${github_repo} --state open --search "-label:blocked"  # available work
gh issue list -R ${github_repo} -l in-progress    # claimed work
gh issue list -R ${github_repo} -l blocked        # blocked work
gh issue view -R ${github_repo} {number}          # full issue detail
```

---

## Ready `issue:ready`

Returns open, unblocked issues regardless of status labels, sorted by priority (high → medium → low → unset).

**"Ready" means:** GitHub issue state is open AND does NOT have `blocked` label.

```sh
gh issue list -R ${github_repo} --state open --search "-label:blocked"
```

This catches unlabeled issues, priority-only issues.

> Agents should sort results by `priority:` label after retrieving — high before medium before low. Unset priority = lowest.

---

## Blocked-by

GitHub Issues has no native blocking relationship. Use the `blocked` label to signal state and
document the dependency in the issue body:

```markdown
## Context

Blocked by #{number}. {Brief reason.}
```

Before claiming an issue, check whether any referenced blocking issues are still open:

```sh
gh issue view -R ${github_repo} {number}   # check if still open
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
- Check open issues before creating — avoid duplicates (`gh issue list -R ${github_repo} --state open`)
- Check the issue body for "Blocked by #N" before claiming — don't start blocked work
- To block an issue: add `blocked`, remove `in-progress` in one call
- Closed issues are an archive — never reopen to edit; create a new issue if work resumes
- One issue per work item
