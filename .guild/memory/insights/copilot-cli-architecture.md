# Copilot CLI Architecture Insights

A comprehensive map of how Copilot CLI agents, skills, plugins, and hooks work together — informed by GitHub official documentation.

## Plugin Architecture

**Plugin structure is composable and distribution-agnostic.**

Plugins are Git repository packages that bundle agents, skills, hooks, and MCP server configurations. The `plugin.json` manifest at the repo root (or in `.github/plugin/` / `.claude-plugin/`) tells Copilot what's inside. This means:

- A plugin can provide just agents, just skills, or a full toolkit combining all
- Plugins are discovered via marketplace registries, direct Git URLs, or local filesystem paths
- Once installed, Copilot CLI caches plugin contents in `~/.copilot/state/installed-plugins/` and must be explicitly reinstalled (`copilot plugin install ./path`) to pick up local changes
- **Implication for Guild:** Plugins are Guild's distribution unit. Skills and agents are composable modules; plugins let us package entire workflows for user installation.

## Agent Creation

**Agents are context-isolated subagents designed for task offloading.**

Custom agents are `.agent.md` files with YAML frontmatter (name, description, tools spec). When invoked—either via `/agent` command, explicit instruction ("use the security-auditor agent"), inference (prompts matching the agent's description), or programmatic flag—a temporary subagent spins up with isolated context to prevent bloating the main agent. Agents can restrict tool access via a `tools` field; by default all tools are available.

Agents live at:

- Project scope: `.github/agents/` (apply to a single repo)
- User scope: `~/.copilot/agents/` (available across all projects; user scope takes precedence if name conflict)

**Implication for Guild:** Subagents are why Guild's agents can specialize without drowning context. An agent like `charter` can focus on product without carrying the full team's context. This validates our team structure; each agent should be a standalone `.agent.md` defining its expertise and constraints.

## Skills Framework

**Skills are injected instruction sets, not agents.**

A skill is a `SKILL.md` file (YAML frontmatter + Markdown body) living in `.github/skills/{name}/` or `~/.copilot/skills/{name}/`. When Copilot determines a skill is relevant to a task—either via explicit slash invocation (`/skill-name`) or by inference from the prompt—the skill's instructions and supporting resources (scripts, examples) are injected into the agent's context.

Key distinction from custom instructions: use custom instructions (e.g., in `.copilot/instructions.md`) for broad, apply-everywhere guidelines; use skills for focused, deep domain expertise that should only load when relevant.

**Implication for Guild:** Our existing train-skill generator aligns perfectly. Skills let us package repeatable workflows (e.g., "fetch these docs, synthesize insights, save to memory") without creating new agents. The skill injection model is how Guild's skills seamlessly extend any agent's capability.

## Hooks System

**Hooks are lifecycle callbacks that execute shell commands at agent execution moments.**

A `hooks.json` file (in `.github/hooks/` for repos, or current working directory for CLI sessions) defines event handlers that fire at:

- `sessionStart` / `sessionEnd` — before/after a session
- `userPromptSubmitted` — after user enters a prompt
- `preToolUse` / `postToolUse` — around tool execution
- `errorOccurred` — when an error happens

Each hook is a command (bash or powershell) with optional working directory, environment variables, and timeout (default 30s). Hooks receive input as JSON on stdin and can output JSON to affect agent behavior.

**Implication for Guild:** Hooks are cross-platform event infrastructure. Guild could use hooks for session logging, automated validation (e.g., pre-commit checks), or reactive workflows that detect when agents hit problems. The sessionStart/sessionEnd hooks are natural places to load/save Guild state (memory, tasks, inbox messages).

## Marketplace Model

**Marketplaces are Git-backed plugin registries with pluggable discovery.**

A marketplace is a Git repository containing a `marketplace.json` file that catalogs available plugins with metadata (name, description, version, source path). Users can:

- Add a marketplace: `copilot plugin marketplace add OWNER/REPO` (GitHub.com), `copilot plugin marketplace add https://...` (any Git host), or `copilot plugin marketplace add /path` (local filesystem)
- Browse: `copilot plugin marketplace browse MARKETPLACE-NAME`
- Install: `copilot plugin install PLUGIN-NAME@MARKETPLACE-NAME`

Copilot CLI ships with two default registries: `copilot-plugins` and `awesome-copilot`. This creates a two-tier discovery: trusted defaults for discoverability, plus user-registered custom marketplaces for teams/orgs.

**Implication for Guild:** Guild can publish a plugin marketplace (`guild-plugins` or similar) and encourage users to add it with a single command. This is the canonical distribution path for Guild agents, skills, and hooks. The marketplace model solves the "how do people find and install Guild components?" problem elegantly.

## Technical Constraints

**Tool availability is restricted by agent context, not by capability.**

Agents can explicitly restrict which tools they have access to via a `tools` field in their `.agent.md` frontmatter. This is enforced at the CLI level — restricted agents cannot invoke forbidden tools even if asked. This protects specialized workflows (e.g., a security-auditor agent that should never execute arbitrary bash).

**Subagents isolate context to prevent pollution.** When a specialized agent is invoked, Copilot spins up a fresh subagent with its own context window. This prevents a large task from bloating the main agent's context and lets the main agent focus on orchestration while delegating work.

**Plugin caching requires explicit reload.** Plugins installed from local paths are cached; changes to local source don't auto-update. Users must reinstall to pick up edits. This is intentional — prevents flakiness from in-flight changes.

**User-scoped components shadow project-scoped.** If both `.github/agents/foo.agent.md` and `~/.copilot/agents/foo.agent.md` exist, the home directory version wins. This enables users to override project defaults but can cause surprises if not expected.

**Implication for Guild:** When packaging Guild agents for consumption, be explicit about tool restrictions to prevent misuse. Subagents validate our multi-agent orchestration model. Cache invalidation is a known limitation; users should reinstall plugins after source changes, or use symbolic links for development.

## Patterns and Antipatterns

**Progressive disclosure: start simple, escalate complexity.**

The customization hierarchy is: custom instructions (repo-wide, always on) → skills (domain-specific, loaded by inference) → custom agents (specialized subagents) → hooks (reactive infrastructure) → plugins (distribution packages). Most teams should start with instructions and skills, not agents. This matches how Guild is designed: the guild-master orchestrates, specialists are added only when needed.

**Skills and instructions are complementary, not competing.** Instructions are for "how we do things here" (coding standards, repo structure). Skills are for "how to do this specific task" (deploy the app, debug CI failures). A well-designed repo has both.

**Hooks are for observability and automation, not business logic.** Hooks execute shell commands, not arbitrary code. Use them for logging, validation, metrics collection, or triggering external systems — not for implementing core features. This keeps hooks lightweight and deterministic.

**Plugins bundle related components for distribution.** A plugin can include 1+ agents, 1+ skills, hooks, and MCP configs. The plugin boundary is the distribution unit: users install a plugin (e.g., "frontend-design-suite") and get a cohesive toolkit. This is why Guild's model of packaging agents+skills+hooks into plugins makes sense.

**Agents should be specialists, not generalists.** The point of subagents is isolation. If you define a custom agent, give it a narrow, deep expertise. Broad agents dilute the benefit of context isolation. Guild validates this with roles like charter (requirements), auditor (quality), engineer (implementation).

**Antipattern: agents without clear invocation semantics.** A custom agent should have a clear description of when/how to use it and trigger words or task types it should recognize. If users don't know when to invoke it, it won't be used.

**Implication for Guild:** The design is sound. Small, specialized agents with clear responsibilities, bundled with focused skills and reactive hooks, distributed as plugins. The question now is implementation: can Guild agents and skills be written to plug into the Copilot CLI ecosystem directly, or do they need wrapping? The answer is likely wrapping: Guild uses `.guild/` directories as local storage conventions; Copilot CLI expects `.github/agents/`, `.github/skills/`, `.github/hooks/`. A bridge is probably needed (an invoker agent that reads from `.guild/` and exposes to Copilot CLI).
