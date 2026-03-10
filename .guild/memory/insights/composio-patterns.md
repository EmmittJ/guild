# ComposioHQ Agent Orchestrator — Patterns

Source: `ComposioHQ/agent-orchestrator` — multi-agent coding session orchestrator, Mar 2026

## What It Is

A plugin-based orchestration runtime that spawns coding agents (Claude Code, Codex, Aider), assigns them issues, monitors their work via PR/CI/review state, and auto-responds with reactions. The orchestrator doesn't write code — it supervises agents that do.

## 8-Slot Plugin Architecture

Everything swappable via clean interfaces:
- **Runtime** — where sessions execute (tmux, docker, process)
- **Agent** — AI coding tool (claude-code, codex, aider, opencode)
- **Workspace** — code isolation (git worktree, clone)
- **Tracker** — issue source (GitHub, Linear)
- **SCM** — PR/CI/review queries (GitHub)
- **Notifier** — human notifications (desktop, Slack, webhook)
- **Terminal** — attach UI (iTerm2, web)

Guild equivalent: the agent team *is* the plugin set. Each agent file is an "Agent plugin" with a known interface.

## Hash-Based Directory Isolation

All session paths derived from a hash of the config file location:
```
Config: ~/code/project/agent-orchestrator.yaml
Hash: sha256("~/code/project").slice(0,12) = "a3b4c5d6e7f8"

Sessions: ~/.agent-orchestrator/a3b4c5d6e7f8-project/sessions/
Tmux name: a3b4c5d6e7f8-proj-1  (globally unique)
Human name: proj-1               (readable)
```
Multiple checkouts of the same config never collide. All paths computed — none configured.

## Pull-Based State Detection (Never Trust Agent Self-Reporting)

Orchestrator doesn't wait for agents to report status. On every poll cycle it queries:
1. Runtime: is the process alive?
2. Agent: what's it doing? (read JSONL session files)
3. SCM: does a PR exist? (detect by branch name)
4. CI: what's the check status?
5. Reviews: any pending comments?

**Key**: agent activity detected by reading `~/.claude/sessions/{id}/session.jsonl` mtime and content — not terminal parsing. This is language/runtime agnostic and works with any agent that writes structured logs.

## 10-State Session Machine

```
SPAWNING → WORKING → PR_OPEN → CI_FAILED ──┐
                              → REVIEW_PENDING  │
                              → CHANGES_REQUESTED→ WORKING (loop)
                              → APPROVED+green → MERGEABLE → MERGED → CLEANUP

At any point:
NEEDS_INPUT  → notify human
STUCK (idle >10m) → notify human
ERRORED → cleanup + notify
KILLED → cleanup
```

State is determined by the orchestrator querying plugins — not by agents.

## Reaction Engine — Config-Driven Auto-Responses

```yaml
reactions:
  ci-failed:
    auto: true
    action: send-to-agent
    message: "CI failed. Fix the failures and push again."
    retries: 3
    escalateAfter: 2        # after 2 failures, notify human instead

  changes-requested:
    auto: true
    action: send-to-agent
    escalateAfter: 30m      # if not resolved in 30min, escalate

  agent-stuck:
    threshold: 10m
    action: notify
    priority: urgent
```

Reaction tracker stores `{ attempts, firstTriggered }` per `sessionId:reactionKey`. Escalates on max retries OR elapsed time. Clears on session completion.

**Guild adaptation**: reactions for `engineer-blocked`, `reviewer-idle`, `skill-needs-test`, `task-stalled`.

## Workspace Hooks — Instant Metadata Updates

Agent writes metadata via hooks rather than API calls:
```json
// .claude/settings.json
{
  "hooks": {
    "post_tool_use": {
      "cmd": "sh",
      "args": [".claude/update-metadata.sh"]
    }
  }
}
```
When agent runs `gh pr create`, the hook fires and writes `pr=https://...` to the session metadata file. Orchestrator learns instantly without polling SCM.

## Flat-File Metadata — No Database Dependency

Session state stored as `key=value` files, one per session:
```
project=integrator
issue=INT-100
branch=feat/INT-100
status=working
pr=https://github.com/.../pull/123
lastPendingReviewFingerprint=abc123...
```

Writes are atomic (write to `.tmp.{pid}.{timestamp}`, then rename — POSIX atomic). Bash-compatible. No DB. Easy to inspect, version control, and debug.

## Review Comment Fingerprinting — No Duplicate Spam

```typescript
// Metadata tracks fingerprint of what was sent to agent
lastPendingReviewFingerprint: hash(all review comments)
lastPendingReviewDispatchHash: hash(what we already sent)

// Only send if BOTH fingerprints differ
if (newFingerprint !== last && newDispatch !== lastDispatch) {
  sendToAgent(comments);
}
```

Prevents the agent from being spammed with the same review comments on every poll cycle.

**Guild adaptation**: fingerprint memory decisions to avoid re-discussing the same patterns in every session.

## Activity State with Timeout Progression

```typescript
type ActivityState = 'active' | 'ready' | 'idle' | 'waiting_input' | 'blocked' | 'exited'

// Thresholds:
// active → ready: agent output stops
// ready → idle: 5 min of "ready" state
// idle → stuck: 10 min threshold (configurable)
// stuck → notify human
```

On stuck detection: emit event, fire reaction (send check-in or escalate). On agent reply: clear stuck state.

## Orchestrator-as-Session (Meta Pattern)

The orchestrator can spawn a special "orchestrator session" — an OpenCode instance with system prompt containing all agent context. This orchestrator-session can spawn sub-agents for complex tasks and synthesize their outputs. Agent-orchestrator recursion.

**Guild master** already plays this role conceptually. This pattern makes it explicit and programmatic.

## Layered Prompt Composition

```
BASE_AGENT_PROMPT (built-in guidance)
  + project.agentRules (AGENTS.md-style per-project rules)
  + tracker.generatePrompt(issueId) (issue context)
  + user message (manual override)
```

Prompts are assembled from layers, not hardcoded. Guild equivalent: `system prompt = agent charter + project AGENTS.md + current task context`.

## Session Spawn Flow (Key Steps)

1. Reserve session ID from prefix + counter (`app-1`, `be-3`)
2. Create workspace (worktree clone)
3. Create runtime (tmux session with unique name)
4. Fetch issue context from tracker
5. Build layered launch prompt
6. Launch agent in runtime
7. Write metadata atomically
8. LifecycleManager picks up in next poll

## Key Data Structures

```typescript
interface Session {
  id: SessionId;           // "int-1"
  projectId: string;
  status: SessionStatus;   // "working", "pr_open", "ci_failed", etc.
  activity: ActivityState; // "active", "ready", "idle"
  branch: string | null;
  pr: PRInfo | null;
  runtimeHandle: RuntimeHandle | null;
  lastActivityAt: Date;
}

interface ReactionConfig {
  auto: boolean;
  action: "send-to-agent" | "notify" | "auto-merge";
  message?: string;
  retries?: number;
  escalateAfter?: number | string;  // "30m" or retry count
  threshold?: string;               // "10m" for time-based triggers
}
```

## Most Transferable Patterns for Guild

| Composio Pattern | Guild Adaptation |
|---|---|
| Pull-based state detection | Guild Master polls task files + agent context, doesn't wait for agents to report |
| Reaction engine with escalation | Auto-responses when tasks stall, reviews idle, or CI fails |
| Flat-file metadata + atomic writes | `.guild/tasks/` files as session metadata |
| Fingerprinting for dedup | Hash of memory decisions to avoid re-discussing resolved patterns |
| Activity timeout → stuck → escalate | Guild Master detects stalled tasks and sends unblock messages |
| Workspace hooks | Agents write to context files on tool use; Guild Master reads |
| Layered prompt composition | Charter + AGENTS.md + task context assembled per agent call |
