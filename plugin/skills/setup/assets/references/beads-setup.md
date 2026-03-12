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

## 1. Create Role Beads

One role bead per functional role on the team:

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
# Add system label so slot commands work
bd update {agent-id} --add-label "gt:agent" --json
# Link to role (mandatory)
bd slot set {agent-id} role {role-id}

# Verify
bd slot show {agent-id}
```

## 3. Register Later — Adding New Agents

When `train-agent` creates a new agent and beads is present, the train-agent skill
will prompt to register it. The workflow is the same as Step 2:

1. `bd list --type=role` — find or create the matching role
2. `bd create "{name}" --type=agent --description="..." --json` — create agent bead
3. `bd slot set {agent-id} role {role-id}` — hook to role

## Attaching Work

When an agent claims a task, attach it to the agent's hook slot:

```bash
bd slot set {agent-id} hook {issue-id}    # attach
bd slot clear {agent-id} hook             # detach when done
```

## Agent State Reporting

Agents self-report state during work:

| State      | When                         |
|------------|------------------------------|
| `idle`     | Waiting for work             |
| `working`  | Actively executing           |
| `stuck`    | Blocked, needs intervention  |
| `done`     | Completed current task       |

```bash
bd agent state {agent-id} working
bd agent heartbeat {agent-id}
```
