# Claude Code Plugin Ecosystem Insights

Source: `claudeforge/marketplace` (161 plugins, Jan 2026)

## Plugin Types: Agents vs Commands vs Super

Three distinct plugin types with different structures and purposes:
- **Agents** — Specialized AI assistants. Markdown file in `agents/` with YAML frontmatter (`description`, `capabilities`, `version`). Plugin.json has explicit `"agents"` array with path references.
- **Commands** — Slash commands for instant tasks. Markdown file in `commands/` folder. **Auto-discovered** — do NOT add a `"commands"` field to plugin.json (this was a compliance bug fixed in v1.2.0 of claudeforge). Claude Code discovers them by convention.
- **Super Plugins** — Multi-component platforms combining agents + commands + hooks + MCP servers. Plugin.json explicitly lists all components.

## plugin.json Structure

Minimal required fields:
```json
{
  "name": "plugin-name",
  "description": "...",
  "version": "1.0.0",
  "author": { ... }
}
```
For agents, add: `"agents": [{ "name": "...", "path": "../agents/agent.md", "description": "..." }]`
For commands: **no explicit field** — auto-discovery from `commands/` directory.

## Agent Markdown Frontmatter

```yaml
---
description: "What the agent specializes in"
capabilities: ["cap1", "cap2"]
version: "1.0.0"
---
```

## Command Markdown Frontmatter

```yaml
---
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
description: "What this command does"
---
```

## Hooks & MCP Servers (Super Plugins Only)

Plugin.json hook pattern:
```json
"hooks": {
  "PostToolUse": [{
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"}]
  }]
}
```
- Use `${CLAUDE_PLUGIN_ROOT}` for portable paths — resolves to plugin install location.
- MCP servers are Node.js processes communicating via stdio, using MCP SDK.
- Persistent state stored in `~/.claude-*-state/` directories.

## Marketplace Registry Format

`.claude-plugin/marketplace.json` at repo root:
```json
{
  "name": "plugin-name",
  "source": "./plugins/agents/plugin-name",
  "description": "...",
  "version": "1.0.0",
  "category": "agents|commands|super",
  "author": { ... },
  "keywords": ["claudeforge", "type", "domain"]
}
```

## Auto-Discovery vs Explicit Registration

Claude Code auto-discovers files in `commands/` and `agents/` subdirectories. For commands this means plugin.json needs no reference to the markdown files — just having the file in the right folder is enough. Explicitly listing commands in plugin.json is a spec violation.

## Zero External Dependencies Policy

All plugins in the claudeforge marketplace are pure Markdown + optional shell/minimal Node.js (MCP SDK only). No npm packages, no pip packages. Keeps plugins lightweight, portable, and secure.

## Quality Bar for Agent Documentation

Effective agent markdown files are 200–700+ lines and include:
- Phase-based methodology (discrete steps with clear outputs)
- Real code examples in relevant languages
- Anti-patterns section (what NOT to do)
- Business impact framing (link technical choices to outcomes)

Vague, short agents are low-value. Depth = trust.
