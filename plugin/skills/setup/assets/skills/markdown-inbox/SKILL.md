---
name: markdown-inbox
description: >
  Async agent-to-agent messaging for a team of AI agents. Messages are markdown files in
  ${inbox_root}/{agent}/ — one file per message, deleted after reading. No write conflicts.
  Activate when: `message:create` — another agent needs to act in a future session;
  `message:read` — checking for waiting messages at session start.
  DO NOT USE FOR: decisions, insights, or context — use `decision:create`.
  Issues — use `issue:create`.
license: MIT
metadata:
  version: "0.1"
---

## Overview

The inbox root for this repo is `${inbox_root}` (relative to repo root).

```
${inbox_root}/
  {agent}/
    {timestamp}-{slug}.md   ← one message per file, delete after reading
```

Agent subdirectories are created on first use — no bootstrapping needed.

Timestamp format: `YYYYMMDD-HHMMSS`

---

## Session Start

Check `${inbox_root}/{your-agent-name}/` for waiting messages. Process each, then delete the file.

---

## Message Format `message:create` `message:read`

Filename: `{timestamp}-{slug}.md` — e.g. `20260309-142300-auth-review-done.md`

```markdown
# {Subject}

From: {sending agent}
To: {receiving agent}
Date: YYYY-MM-DD HH:MM

{Message body. Be specific about what action is needed, if any.}

## Context

{Links to relevant decisions, files, tasks, or other context.}
```

---

## Rules

- Each message is a separate file — prevents write conflicts in concurrent sessions
- Delete the file after reading — inbox is a delivery mechanism, not an archive
- For urgent or blocking issues, prefer a context file over inbox — context is read first
- Never edit another agent's inbox messages
- One concern per message — don't bundle unrelated items
