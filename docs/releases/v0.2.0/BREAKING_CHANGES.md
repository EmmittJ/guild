# Breaking Changes

## v0.2.0 — Skill Namespace Renames

**Breaking Change:** Guild skill directories renamed to avoid namespace collisions with other skill ecosystems.

### What Changed

| Old Name | New Name |
| --- | --- |
| `memory` | `guild-memory` |
| `tasks` | `guild-tasks` |
| `inbox` | `guild-inbox` |

### Why

The original skill names (`memory`, `tasks`, `inbox`) are generic enough to collide with commands and skill names used by the Copilot CLI and other third-party plugin ecosystems. Prefixing with `guild-` scopes all Guild skills under a clear, unambiguous namespace and ensures the plugin coexists cleanly alongside other tools now and in the future.

### Migration

1. **If you're starting fresh:** No action needed — setup installs skills under the new names automatically.

2. **If you have an existing Guild installation:**
   - Re-run `/guild-setup-markdown` or `/guild-setup-github` to install skills under the new names.
   - Update `plugin.json` in your repo: replace any skill references that use the old names (`memory`, `tasks`, `inbox`) with the new names (`guild-memory`, `guild-tasks`, `guild-inbox`).
   - Update `AGENTS.md` in your repo: replace any slash-command or skill path references that use old names.

3. **Custom scripts or automation** that hardcode old skill directory names must be updated:
   - Replace `memory/` → `guild-memory/`
   - Replace `tasks/` → `guild-tasks/`
   - Replace `inbox/` → `guild-inbox/`

### Impact

- **Consumers of `memory`, `tasks`, or `inbox` by the old names** will find those skills no longer activate after upgrading. Re-running setup resolves this.
- **No data loss:** All content in `.guild/memory/`, `.guild/tasks/`, and `.guild/inbox/` is unaffected — only the skill names (used to invoke commands) changed, not the storage paths.
- **No behavioral API changes:** Commands such as `memory:decision:create`, `task:item:read`, and `inbox:message:send` work exactly as before — only the underlying skill directory names changed.

### Refer to AGENTS.md

See AGENTS.md for current skill command documentation and the full list of available slash commands.
