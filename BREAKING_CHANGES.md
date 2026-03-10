# Breaking Changes

## v0.2.0: Skill Namespace Rename

### What Changed
Skills have been renamed to avoid namespace collisions with the Copilot CLI:
- memory → guild-memory
- 	asks → guild-tasks  
- inbox → guild-inbox

### Why
The Copilot CLI reserves /tasks and other common command names. This rename ensures the Guild plugin coexists cleanly with future CLI commands and third-party tools.

### Impact
- **Existing repositories** with old skill names will fail to activate after upgrade
- **Custom scripts** that hardcode old skill paths (memory/, 	asks/, inbox/) will break
- **No data loss**: All memory and task files remain in .guild/ directory — no migration needed

### How to Upgrade
1. **Re-run setup:**
   `
   /guild-setup-markdown
   `
   This installs skills under the new names.

2. **Update custom scripts** that reference the old paths:
   - Replace memory/ with guild-memory/
   - Replace 	asks/ with guild-tasks/
   - Replace inbox/ with guild-inbox/

3. **No API changes**: The behavioral API remains unchanged:
   - memory:decision:create, 	ask:item:read, etc. work exactly as before
   - Only the underlying directory structure (skill names) changed

### Need Help?
Refer to AGENTS.md for current skill documentation.
