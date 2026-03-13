# Guild Core Pillars

These are the five design commitments that explain everything Guild is, everything it refuses to be, and what makes it structurally different from other agent frameworks. They are constraints, not features. Violating any one of them would force Guild into a different product category.

Read these before proposing changes to the architecture, public APIs, or skill contracts.

---

## 1. Zero-Runtime Portability

Guild's product is files — nothing executes, installs, or runs at the user's machine before an agent starts working.

**What this explains:**

- Install via `curl` (file copy), `copilot plugin install` (Copilot CLI plugin), or VS Code — no npm, Python, Docker, or compiled binary required at any point in the setup path
- Works identically in Claude Code, GitHub Copilot CLI, VS Code, Cursor, or any future tool that reads `.agent.md` and skills directories (`.github/skills/`, `.claude/skills/`, or any path conforming to the [agentskills.io specification](https://agentskills.io/specification)) — the format is the contract, not the platform
- No vendor-specific API keys, model names, or cloud endpoints are embedded in any skill

**The test:** A proposal violates this pillar if it makes a runtime install _required_ to use the core framework. Optional integrations (e.g. beads, github cli) may have prerequisites — the distinction is _required_ vs _additive_.

**The road not taken:** Build a global CLI install, a compiled binary, or a hosted server — and gain a richer feature surface, an interactive REPL, dashboards, and a SaaS upgrade path. The cost is that every new adopter must install something before the first agent runs. Guild treats installation friction as a first-order tax on portability and refuses it at the core layer.

---

## 2. Config-First Team Design

Team structure, routing rules, and installed capabilities are version-controlled configuration files owned by the host repo — not code, not a service, not a registry.

**What this explains:**

- `routing.md` is the authoritative specification of who does what; you change team structure by editing a Markdown table, not by modifying code or re-installing anything
- `/guild:setup` produces files in your repo — the team it scaffolds belongs to you; Guild only ships the skill that creates it
- Adding a capability means copying a SKILL.md file; removing it means deleting it — no compilation, registration call, or service restart

**The test:** A proposal violates this pillar if changing team structure or adding a capability requires writing code rather than editing a config file.

**The road not taken:** Make agents first-class runtime objects — TypeScript classes, compiled personas, service-registered roles. The gain is type safety, IDE autocomplete, and programmatic composition. The cost is that changing the team requires a build step and anyone without SDK knowledge can't touch it. Guild puts team ownership in the repo, not the runtime.

---

## 3. Backend-Agnostic Verbs

Skills speak in stable verbs (`issue:ready`, `decision:create`, `message:read`) that dispatch to whichever backend is installed — skills don't know, and are not allowed to know, which tool handles them.

**What this explains:**

- `work-cycle` runs identically against beads, markdown-issues, or github-issues without modification; the verb contract is durable even as backends change
- Swapping backends requires updating routing config, not rewriting skills
- Skills authored for one repo are portable to any repo regardless of its backend choices — the verb is the unit of portability, not the implementation

**The test:** A proposal violates this pillar if a skill hardcodes a specific backend, CLI name, or API rather than dispatching through an abstract verb.

**The road not taken:** Bind workflow steps to named services or specific CLI calls. The gain is simplicity — no abstraction layer, no routing config. The cost is that swapping tools means rewriting skills, and skills become non-portable across repos with different backend choices. Guild's verbs decouple workflow logic from tool choice permanently.

---

## 4. Compaction-First Reliability

Context loss is a normal operating condition — every workflow is explicitly designed to survive it, not to hope it doesn't happen.

**What this explains:**

- The `preCompact` hook fires before any context compression and saves in-progress issue state; an agent resuming after compaction finds exactly where it was
- `work-cycle`'s orient/claim/land structure means a fresh agent with no prior context can reconstruct working state from beads, inbox, and memory — session continuity is never assumed
- The `sessionEnd` hook blocks the agent from finishing if git is dirty or unpushed; "done" means clean remote state, not a local declaration

**The test:** A proposal violates this pillar if it assumes continuous memory across a session — if a fresh agent running it with no prior context would produce incorrect results or lose work.

**The road not taken:** Hold state in a running process — in-memory routing tables, server-side session objects, long-lived agent contexts. The gain is simplicity: no explicit compaction handling, no orient/claim/land discipline. The cost is that a crash, restart, or context reset loses everything. Guild treats compaction as the default, not the exception.

---

## 5. Uncapped Role Composability

Any agent can wield any skill — role defines default routing, not capability boundaries.

**What this explains:**

- Skills declare verbs and conditions, not `requiredRole` or `authorizedAgents`; a wright reaching for a memory skill or a scribe using orchestrate is expected and correct
- Capability grows by adding skills, not by adding specialist roles for each new capability — a five-agent team with ten skills is more capable than a ten-agent team with five
- The routing table is a default, not a lock; any agent can override it when task context warrants

**The test:** A proposal violates this pillar if it restricts which agents can invoke a skill based on their role rather than task context.

**The road not taken:** Gate skill access by role — only the coder can write code, only the reviewer can approve. The gain is predictability and auditability: you always know who did what. The cost is brittleness: remove a role and its capabilities disappear with it; add a capability and you may need a new specialist. Guild's model makes the team more capable as skills accumulate, regardless of who's in the room.

---

## Decisions

**Verb patterns are a convention, not a contract.** Colon-namespaced verbs (`issue:ready`, `decision:create`) are a routing idiom that skills have adopted as a useful abstraction — not a formal specification or external standard. Skills use them because they work, not because a contract requires them.

**Guild stays files-only. No companion service.** The product is files. If better backends emerge they can be slotted in as optional integrations (same model as beads and github-issues) — but a service layer will not be introduced at the framework level.

**Routing structure is up to the host.** Guild cannot and does not enforce how `routing.md` is structured — including whether it uses static tables or more dynamic patterns. These are agents reading markdown; the format is a convention the host owns.

---

_Pillars defined by the steward, 2026-03-13._
