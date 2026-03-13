# v0.2.0 — Guild Skill Namespace Rename

Released: 2026-03-10

## What's New

All built-in Guild skills now use the `guild-` prefix to avoid namespace collisions with other skill ecosystems (Copilot CLI, third-party plugins, etc.).

| Old Name | New Name       |
| -------- | -------------- |
| `memory` | `guild-memory` |
| `tasks`  | `guild-tasks`  |
| `inbox`  | `guild-inbox`  |

## Why This Matters

The original names (`memory`, `tasks`, `inbox`) are generic and can conflict with commands or skill names used by other tools. Prefixing with `guild-` scopes all Guild skills under a clear, unambiguous namespace and ensures the plugin coexists cleanly alongside other tools.

## Breaking Changes

See [BREAKING_CHANGES.md](BREAKING_CHANGES.md).
