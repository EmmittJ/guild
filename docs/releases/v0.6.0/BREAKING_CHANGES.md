# v0.6.0 Breaking Changes

## `.guild/` renamed to `.agents/`

The memory, decisions, and inbox directories that lived under `.guild/` are now expected at
`.agents/`. This affects any agent files that reference `.guild/memory/`, `.guild/decisions/`,
or `.guild/inbox/` paths, as well as any installed skill files that hardcode those paths.

**Migration:**

1. Rename the directory:
   ```bash
   mv .guild .agents
   ```
2. Update every agent file (`*.agent.md`) that references `.guild/` — replace all occurrences
   with `.agents/`.
3. Update any installed skill files (e.g., `markdown-memory`, `markdown-inbox`) that contain
   hardcoded `.guild/` paths.

## Setup simplified to cast-only flow

Step 3B, the manual team-definition step that let you describe your team and have the setup
skill generate agent files from a written description, has been removed. The setup flow now
proceeds directly from cast selection to skill installation. Teams are defined by the cast
templates; customization is done by editing the generated agent files afterward.

**Migration:** No file changes required. If you were relying on the manual team-definition
input to generate custom agent files, write your customizations directly into the generated
`.github/agents/*.agent.md` files after running `/guild:setup`.

## `plugin.json` removed — `marketplace.json` is the canonical manifest

The `plugin.json` file has been removed. `marketplace.json` is now the single authoritative
plugin manifest for all guild plugin definitions.

**Migration:** Delete any local `plugin.json` file. If you have scripts or tooling that
reference `plugin.json`, update them to use `marketplace.json` instead.
