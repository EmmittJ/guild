# v0.5.0 Breaking Changes

## Installed skill directories renamed

`.github/skills/guild-memory/` → `.github/skills/markdown-memory/`  
`.github/skills/guild-inbox/` → `.github/skills/markdown-inbox/`  
`.github/skills/guild-issues/` → `.github/skills/github-issues/`

If you are upgrading from v0.4.x, either re-run `/guild:setup` to reinstall under the new
names, or rename the directories manually and update any agent files that reference the old
paths in their "At Session Start" sections.

## Plugin skills moved out of `.github/skills/`

Plugin-bundled skills (`orchestrate`, `train-agent`, `train-skill`) have moved from
`.github/skills/` to `plugin/skills/`. Any agent file that referenced these skills by the old
installed path needs to be updated to use the plugin path or the skill verb instead.

## Setup commands consolidated

`guild-setup`, `guild-setup-markdown`, and `guild-setup-github` have been merged into a single
`setup` skill. The entry point is now `/guild:setup` — the three separate commands no longer
exist.
