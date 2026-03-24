---
name: work-cycle
description: >
  Work discipline for worker agents executing assigned tasks. Apply when claiming and implementing
  an issue delegated by an orchestrator. Covers: claim before starting, discover and link new work,
  self-check before reporting done, and close the issue on completion.
  Backend-agnostic — works with beads, markdown-issues, or github-issues.
  DO NOT USE FOR: orchestrator session management (see orchestrate skill); single-step tasks
  that don't involve issue tracking.
license: MIT
metadata:
  version: "0.5"
---

## orient — Before You Claim Anything

When you receive a brief or are about to start work in a fresh session:

1. **Read context** — apply `context:read` to load working state from prior sessions; understand what's already known before touching anything
2. **Check inbox** — apply `message:read` to see if the orchestrator left updated instructions or context

> Skip context:read only if you have explicit in-session context from the orchestrator's brief. When in doubt, read it.

---

## claim — Before You Touch Anything

Once oriented:

1. **Claim your issue** — apply `issue:claim` before touching any files or writing any output
2. **Implement** — work the task as briefed; report back when done or blocked

> Do not implement against an unclaimed issue. Claiming is the contract that prevents two agents from working the same task.

---

## During Work — Discover, Record, and Link

While executing your assigned task:

1. **File discovered work immediately** — apply `issue:create` with `discovered-from: <parent-id>` for anything new that surfaces; do not context-switch, just file it and continue
2. **Record decisions** — when you make a meaningful choice (architecture, approach, trade-off), apply `decision:create` before moving on; don't let it disappear into conversation history
3. **Record insights** — when you discover something non-obvious (a gotcha, a pattern, a constraint), apply `insight:create` so future agents inherit the knowledge
4. **One claim at a time** — do not claim a second issue while one is in progress unless explicitly parallelizing

> Discovered work without a parent link is orphaned work. Always link it.
> Decisions and insights not written down are invisible to the next session.

---

## Done — Self-Check and Close

Before reporting done to the orchestrator:

1. **Validate output** — check your work against the stated output contract in your brief
2. **File remaining discovered work** — any uncovered issues still need `issue:create` with a parent link
3. **Persist working state** — apply `context:update` with a summary of what was done, what was found, and what's next; this is what survives session boundaries
4. **Close your issue** — apply `issue:close` with a reason
5. **Report back** — signal completion; hand off any artifacts to the orchestrator

---

## Rules

- **Claim before starting** — never implement against an unclaimed issue
- **One claim at a time** — finish one before claiming another
- **Link discovered work** — every new issue gets a `discovered-from` parent
- **Write it down** — decisions and insights not recorded are lost; record them as they happen, not after
- **Self-check is not optional** — validate against the output contract before signaling done

---

## Verb Reference

| Verb              | When                                        | Dispatches to           |
| ----------------- | ------------------------------------------- | ----------------------- |
| `context:read`    | Session start, before claiming              | Installed memory skill  |
| `message:read`    | Session start, before claiming              | Installed inbox skill   |
| `issue:claim`     | Before starting an assigned issue           | Installed backend skill |
| `issue:create`    | Filing discovered work                      | Installed backend skill |
| `decision:create` | Meaningful choice made during work          | Installed memory skill  |
| `insight:create`  | Non-obvious discovery during work           | Installed memory skill  |
| `context:update`  | Before closing issue; persist working state | Installed memory skill  |
| `issue:close`     | Task complete                               | Installed backend skill |
| `message:create`  | Async handoff or status to the orchestrator | Installed inbox skill   |
