# Beads Setup Reference

When beads is selected as the persistence backend during `/guild:setup`, complete these
steps after scaffolding agents.

## Prerequisites

```bash
bd --version   # requires v0.47.0+
bd init        # run once by a human — agents must NOT run this
```

Enable custom types so roles and agents can be tracked:

```bash
bd config set types.custom "agent,role"
bd config set dolt.auto-commit on
```

## Key Concepts

**Roles are persistent shared definitions** — a role bead describes a functional position, not a
specific agent. It carries priming info, capability definitions, and boundaries. Multiple agents
can point to the same role bead. Create one role per distinct function, then reuse it.

**Agents are persistent identities** — an agent bead is the agent's persistent identity across
sessions. Sessions are ephemeral (cattle); agents persist (pets). Each agent has a hook slot
for work and a role slot pointing to its role definition.

**Both are pinned beads** — they never close, never appear in `bd ready`, and float as persistent
infrastructure in the data plane.

## 1. Create Role Beads

One role bead per **functional role** on the team — not per agent. If three agents all do
implementation, they all share one role bead.

```bash
bd create "orchestration" --type=role \
  --description="Routes, plans, delegates, synthesizes. Entry point for all requests." --json

bd create "implementation" --type=role \
  --description="Creates files, scripts, manifests. Works from a brief." --json

bd create "version-control" --type=role \
  --description="Commits, branches, pull requests. Never modifies content." --json

# Add more roles as needed — one per distinct function
```

Capture each returned `id`.

## 2. Create Agent Beads and Slot to Roles

For each agent scaffolded by `/guild:setup`:

```bash
# Create the agent bead
bd create "{agent-name}" --type=agent \
  --description="{one-liner from agent frontmatter description}" --json
# → returns {agent-id}

# Add system label (required for slot commands to work)
bd update {agent-id} --add-label "gt:agent" --json

# Slot to role — reuse an existing role bead, don't create a new one
bd slot set {agent-id} role {role-id}

# Verify
bd slot show {agent-id}
```

## 3. Register Later — Adding New Agents

When `train-agent` creates a new agent and beads is present, the train-agent skill
will prompt to register it. The workflow:

1. `bd list --type=role` — **find the existing role first**; only create if no match
2. `bd create "{name}" --type=agent --description="..." --json` — create agent bead
3. `bd update {agent-id} --add-label "gt:agent" --json` — required label
4. `bd slot set {agent-id} role {role-id}` — slot to role

## 4. Wire Dolt Remote (Recommended)

Wiring a remote lets beads issues survive machine loss, sync across environments, and push with
`bd sync`. Use the same GitHub repo the guild lives in — beads stores its data under
`refs/dolt/data` and doesn't interfere with normal git history.

**Requirements:**

- `git` must be installed and in `PATH`
- The GitHub repo must already have at least one commit (a completely empty repo won't work)

```bash
# HTTPS (use this if you don't have SSH keys configured)
bd dolt remote add origin https://github.com/ORG/REPO.git

# SSH (preferred if you have SSH keys)
bd dolt remote add origin git@github.com:ORG/REPO.git
```

**Verify the remote is fully wired** — it must show `[SQL + CLI]`, not `[CLI only]`:

```bash
bd dolt remote list
# Expected: origin [SQL + CLI]
# If you see [CLI only]: re-run the remote add command (it's idempotent), then check again
```

Once wired, push manually or let `bd sync` handle it:

```bash
bd dolt push --set-upstream origin main   # first push
bd sync                                   # subsequent syncs (pull + push)
```

> **Note:** `bd sync` is the preferred day-to-day sync command. Reserve `bd dolt push` for
> initial setup or when you need explicit control.

---

## Attaching Work (Hooks)

Every agent has a hook slot (0..1 cardinality) — this is where work is dispatched.

```bash
bd slot set {agent-id} hook {issue-id}    # attach work
bd slot clear {agent-id} hook             # detach when done
```

**GUPP:** If there is work on your hook, you must run it. Agents check their hook on startup
and begin working immediately.

## Agent State Reporting

Agents self-report state during work:

| State     | When                        |
| --------- | --------------------------- |
| `idle`    | Waiting for work            |
| `working` | Actively executing          |
| `stuck`   | Blocked, needs intervention |
| `done`    | Completed current task      |

```bash
bd agent state {agent-id} working
bd agent heartbeat {agent-id}
```
