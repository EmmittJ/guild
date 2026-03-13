# Agent Beads

> Gas Town propulsion architecture for persistent agent identity and work dispatch.

**v0.40+**: First-class support for agent tracking via `type=agent` and `type=role` beads.

## When to Use Agent Beads

| Scenario                            | Agent Bead? | Why                                           |
| ----------------------------------- | ----------- | --------------------------------------------- |
| Multi-agent orchestration           | Yes         | Persistent identity, hook-based work dispatch |
| Single-session throwaway work       | No          | Overkill—just use regular beads               |
| Long-running background agents      | Yes         | Heartbeats enable liveness detection          |
| Role-based agent systems            | Yes         | Shared role beads define capabilities once    |
| Agents that survive across sessions | Yes         | Agent bead carries state between sessions     |

## Bead Types

| Type    | Purpose                   | Has Slots?       | Pinned? |
| ------- | ------------------------- | ---------------- | ------- |
| `agent` | Persistent agent identity | Yes (hook, role) | Yes     |
| `role`  | Shared role definition    | No               | Yes     |

Other types (`task`, `bug`, `feature`, `epic`) remain unchanged — they are regular work beads.

### Pinned Beads

Both `agent` and `role` beads are **pinned** — they float like sticky notes in the data plane. They are never closed like regular issues, never appear in `bd ready`, and are treated specially by the system. They represent persistent infrastructure, not transient work.

## Roles as Persistent Shared Definitions

A **Role Bead** is a domain definition — it describes a functional position, not a specific agent filling it. A role carries:

- **Priming information** — context and instructions for the role
- **Capability definitions** — what this role can do
- **Boundaries** — what this role should not do

Roles are **shared**. Multiple agents can point to the same role bead. When you add a new agent that fills an existing functional role, slot it to the **same** role bead — don't create a new one.

```bash
# Create a role once
bd create "wright" --type=role --description="Builder role: creates files, edits skills, writes scripts" --json

# Multiple agents can share it
bd slot set bd-agent-1 role bd-role-wright
bd slot set bd-agent-2 role bd-role-wright
```

## Agents as Persistent Identities

An **Agent Bead** is the agent's persistent identity. Sessions are ephemeral (cattle); agents are persistent (pets). The agent bead carries:

- **State** — current lifecycle state (idle, running, stuck, etc.)
- **Hook** — the work currently attached to this agent
- **Role** — pointer to the role bead this agent fills
- **History** — state transitions and work attribution across sessions

```bash
# Create an agent and label it
bd create "wright-1" --type=agent --description="Primary builder agent" --json
bd update bd-42 --add-label "gt:agent"

# Attach its role
bd slot set bd-42 role bd-role-wright
```

> **Required label**: Agent beads need the `gt:agent` label for slot commands to work. After creating with `--type=agent`, run `bd update {id} --add-label "gt:agent"`.

## State Machine

Agent beads track lifecycle state for coordination:

```
idle → spawning → running/working → done → idle
                       ↓
                    stuck → (needs intervention)
```

**Key states**: `idle`, `spawning`, `running`, `working`, `stuck`, `done`, `stopped`, `dead`

The `dead` state is set by Witness (monitoring system) via heartbeat timeout — agents don't set this themselves.

## Slot Architecture

Slots are named references from agent beads to other beads:

| Slot   | Cardinality | Purpose                                  |
| ------ | ----------- | ---------------------------------------- |
| `hook` | 0..1        | Current work item attached to this agent |
| `role` | 1           | Role definition bead (required, shared)  |

### The Hook

The hook is where work gets attached. Every agent has a single hook slot (0..1 cardinality).

```bash
# Attach work to an agent
bd slot set bd-42 hook bd-issue-99

# When work is done, clear the hook
bd slot clear bd-42 hook
```

**Why slots?** They enforce constraints (one work item at a time) and enable queries like "what is agent X working on?" or "which agent has this work?"

### GUPP — Gas Town Universal Propulsion Principle

> **If there is work on your hook, YOU MUST RUN IT.**

This is the core propulsion mechanism. On startup, an agent checks its hook. If work is attached, the agent begins working on it immediately — no polling, no queue, no scheduler. The hook **is** the dispatch.

## Monitoring Integration

Agent beads enable:

- **Witness System**: Monitors agent health via heartbeats; sets `dead` state on timeout
- **State Coordination**: State machine for multi-agent lifecycle management
- **Work Attribution**: Track which agent owns which work via hook slots
- **Liveness Detection**: Heartbeat-based health checks for long-running agents

## CLI Reference

```bash
# Agent lifecycle
bd agent --help          # state/heartbeat/show commands
bd create --type=agent   # create an agent bead
bd create --type=role    # create a role bead

# Slots
bd slot set {agent} hook {issue}   # attach work
bd slot clear {agent} hook         # detach work
bd slot set {agent} role {role}    # assign role
bd slot show {agent}               # inspect slots

# Labels
bd update {id} --add-label "gt:agent"  # required for slot commands
```
