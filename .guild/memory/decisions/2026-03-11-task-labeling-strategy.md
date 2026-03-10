# Task Labeling Strategy

**Date:** 2026-03-11  
**Status:** Decided  
**Owner:** Charter (Product)  

## Problem

The 	ask:ready query currently returns only issues with the open label. This creates a gap: **actionable work (open, unblocked issues) can exist without any status label and becomes invisible to agents looking for ready work**.

Example: Issue #7 is open and unblocked but unlabeled — it won't surface in 	ask:ready.

This decision clarifies label semantics, lifecycle, and the definition of "ready work."

---

## Decision

### 1. Label Semantics: Status Labels Are Descriptive, Not Required Gates

**Status labels** (open, in-progress, locked) are **optional, descriptive markers** that document work state. They do NOT gate readiness.

- **Definition of "ready"**: An issue is ready if it meets these conditions:
  - Issue is open (not closed)
  - Issue does NOT have the locked label
  - Regardless of whether it has the open or in-progress label

This inverts the current "open" label from a required gate to a helpful signal.

**Why this design:**

1. **Ground truth is GitHub state**: An open issue is open. A closed issue is closed. Redundant labeling creates sync risks.
2. **Labels are semantic hints, not constraints**: They document intent and history, but don't restrict access.
3. **New unlabeled issues are immediately actionable**: When a charter creates an issue, it's ready to work without waiting for label hygiene.
4. **Unclaimed work is the common case**: New tasks start unowned. Marking them explicitly "open" is overhead.

### 2. 	ask:ready Logic: All Open, Unblocked Issues

**Intent:** Return all actionable work — tasks that:
- Are open (issue state = open)
- Are NOT blocked (no locked label)
- Sorted by priority (high → medium → low → unset)

**Query:**
`sh
gh issue list -R EmmittJ/guild --state open \
  --search "not:label:blocked" \
  --json number,title,labels,state
`

or simpler (filter blocked in agent logic):
`sh
gh issue list -R EmmittJ/guild --state open --json number,title,labels,state
# agent filters: exclude any with label=blocked
`

**Why this change:**

- Catches unlabeled issues (new work from charter)
- Catches issues with only priority labels (work that doesn't have open marker)
- Catches issues labeled in-progress that are actually just waiting (transient labeling errors)
- Sorts by priority, so most important work surfaces first regardless of labeling

### 3. Label Lifecycle: When Are Status Labels Assigned?

**Responsibility by role:**

| Who | When | What |
|-----|------|------|
| **Charter** (task creator) | At creation | Add priority:high/medium/low (optional, default: unknown) |
| **Charter** | At creation | Do NOT add open — it's implicit |
| **Agent** (claiming work) | Before starting | Add in-progress, remove open (if present) |
| **Agent** (unblocking) | When blocked | Add locked, remove both open and in-progress |
| **Agent** (resuming) | Resuming blocked work | Remove locked, add open |

**Examples:**

`sh
# Charter creates a task
gh issue create -R EmmittJ/guild \
  -t "Fix bug in xyz" \
  -b "## What\n..." \
  -l priority:medium
# Result: open issue, unlabeled except for priority

# Agent claims it
gh issue edit -R EmmittJ/guild 42 \
  --add-label in-progress
# Result: open issue with in-progress label

# Agent discovers blocker
gh issue edit -R EmmittJ/guild 42 \
  --add-label blocked \
  --remove-label in-progress
# Result: open issue with blocked label (no longer in-progress)

# Charter unblocks it later
gh issue edit -R EmmittJ/guild 42 \
  --remove-label blocked
# Result: open issue, no status label (ready again)
`

### 4. Priority Labels: Optional, Agent-Visible Default

**Rule:** Priority labels are optional.

- If a task has priority:high, priority:medium, or priority:low, sort by that order.
- If a task has no priority label, treat it as **lowest priority** (work on it last, after all prioritized work).
- When charter creates a task without priority, don't assume — it signals "important enough to exist, but priority TBD."

**Agent guidance:**
- Sort 	ask:ready results by: high (first) → medium → low → unset (last)
- If in doubt, ask charter to add priority via an issue comment or re-opening for triage.

### 5. Handling Unlabeled Issues

**Policy:** Unlabeled issues are immediately actionable.

- No "intake" step required.
- No implicit labels on creation.
- An unlabeled, open issue is ready work.

**Why:** Reduces ceremony, captures intent immediately, lets agents see what needs doing.

---

## Implications for guild-tasks Skill

The skill documentation must be updated:

1. **	ask:ready query** → change from "issues with open label" to "open issues without locked label"
2. **State model diagram** → clarify that open label is optional, and readiness is determined by issue state + locked label
3. **Create guidance** → charter does NOT add open label at creation time; priority is optional
4. **State transitions** → when claiming, agent CAN add in-progress but doesn't need to remove anything (no open label assumed)

---

## How We Implement This

1. **Skill update:** Update .github/skills/guild-tasks/SKILL.md to reflect new semantics
2. **Query update:** 	ask:ready now queries gh issue list --state open and filters locked in agent code
3. **Charter guidance:** When creating a task, add priority label (optional) and body structure; omit open label
4. **Agent guidance:** Before claiming, check for locked label. When claiming, add in-progress. When blocking, add locked and remove in-progress.

---

## Rationale

This design favors:

- **Simplicity**: Ground truth is GitHub state (open/closed). Labels augment, not replace.
- **Safety**: Unlabeled work is never hidden. Priority can be inferred gradually.
- **Workflow clarity**: Charter creates → agent claims → agent blocks → charter unblocks or reassigns.
- **Tooling independence**: If agents change or tools change, the issue state remains readable.

---

## Rollout

1. Update guild-tasks skill SKILL.md (this is safe — backward compatible)
2. Audit open issues, label any that should be locked or have priority set
3. Document this decision in team memory (this file)
4. Update charter and agent training to reference this model
