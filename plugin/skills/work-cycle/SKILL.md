---
name: work-cycle
description: >
  Work discipline for agent sessions. Apply at session start (session:start) and session end
  (session:complete). Covers: orient before acting (check ready work), claim atomically before
  starting, link discovered work with parent context, and land the plane before stopping
  (file remaining issues, close done work, push to remote, verify clean).
  Backend-agnostic — works with beads, markdown-issues, or github-issues.
  DO NOT USE FOR: single-step tasks that don't involve issue tracking or session handoff.
license: MIT
metadata:
  version: "0.1"
---

## session:start — Orient Before Acting

Before working on anything, orient:

1. **Read context** — apply `context:read` to restore working state from prior sessions
2. **Check inbox** — apply `message:read` to see waiting messages from teammates
3. **Find ready work** — apply `issue:ready` to see unblocked issues sorted by priority
4. **Claim your task** — apply `issue:claim` to take atomic ownership before starting

> Do not start work on an unclaimed issue. Claiming is the contract that prevents two agents from working the same task.

## During Work — Discover and Link

When you discover new work while executing a task:

1. **File it immediately** — apply `issue:create` with a link to the parent (`discovered-from: <parent-id>`)
2. **Do not context-switch** — file the issue, note it, finish the current task first
3. **One claim at a time** — never hold more than one claimed issue unless explicitly parallelizing

> Discovered work without a parent link is orphaned work. Always link it.

## Integration Cadence — Implement More, Review Less Often

Review gates have real cost. Apply CI principles to keep throughput high:

- **Self-check always** — before marking any task complete, the implementing agent validates its output against the stated output contract; this is lightweight and always required
- **Peer review proportionally** — trigger a peer review pass at logical completion points (a coherent feature, a set of related tasks), not after every individual task
- **Batch related work** — complete a set of related bounded tasks, then trigger one review against their shared acceptance scope; do not request a separate review per individual task

> Many small implementations feeding few well-timed reviews — not one review per implementation. This is how review overhead stays proportional to implementation volume.

## session:complete — Land the Plane

Before ending any session, complete ALL steps in order:

1. **File remaining work** — apply `issue:create` for anything that needs follow-up, with context for future sessions
2. **Run quality gates** — run tests, linters, and builds; trigger peer review for behavioral or architectural changes; skip peer review for bounded mechanical changes (see Integration Cadence above)
3. **Update issue status** — apply `issue:close` for finished work; update notes on in-progress items
4. **Update context** — apply `context:update` so the next session can orient quickly
5. **Push to remote** — `git pull --rebase` then `git push`; verify `git status` shows clean
6. **Verify** — do not hand off until git is clean and pushed

> The session is not complete until `git push` succeeds and `git status` is clean.
> Never hand off with local-only commits. That strands work.

## Rules

- **Orient first, always** — `issue:ready` before planning or asking "what should I work on?"
- **Claim before starting** — never implement against an unclaimed issue
- **Link discovered work** — every new issue gets a `discovered-from` parent
- **Land the plane** — session:complete is mandatory, not optional
- **Git is the gate** — clean push is the definition of done for a session

## Verb Reference

| Verb               | When                          | Dispatches to                |
| ------------------ | ----------------------------- | ---------------------------- |
| `session:start`    | Beginning of any work session | This skill (steps 1–4 above) |
| `session:complete` | End of any work session       | This skill (steps 1–6 above) |
| `issue:ready`      | Orient, pre-planning          | Installed backend skill      |
| `issue:claim`      | Before starting a task        | Installed backend skill      |
| `issue:create`     | Discovered work, new tasks    | Installed backend skill      |
| `issue:close`      | Task complete                 | Installed backend skill      |
| `context:read`     | Session start                 | Installed memory skill       |
| `context:update`   | Session end / handoff         | Installed memory skill       |
| `message:read`     | Session start                 | Installed inbox skill        |
