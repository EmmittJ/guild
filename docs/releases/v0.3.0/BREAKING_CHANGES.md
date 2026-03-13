# Breaking Changes

## v0.3.0 — Agent Thematic Naming

**Breaking Change:** Guild agents renamed to thematic names for brand cohesion.

### What Changed

| Old Name | New Name | Role |
| --- | --- | --- |
| product-owner | charter | Product owner — requirements, user stories, backlog |
| skill-writer | smith | Skill writer — writes and reviews SKILL.md files |
| reviewer | auditor | Quality reviewer — signs off before committing |
| copilot-cli | invoker | CLI integration — plugin manifests and marketplace |
| engineer | engineer | **Unchanged** — implementation and file creation |
| scribe | scribe | **Unchanged** — version control and commits |
| guild-master | guild-master | **Unchanged** — orchestration and delegation |

### Why

Thematic naming creates brand cohesion with Guild's craftsmanship aesthetic:
- **charter** = the guiding mission and requirements
- **smith** = craftsmanship and skill development
- **auditor** = quality assurance and validation
- **invoker** = activation and integration

### Migration

1. **If you're starting fresh:** No action needed — new agents already use thematic names.

2. **If you have an existing Guild installation:**
   - Re-run `/guild-setup-markdown` or `/guild-setup-github` to install agents under new names
   - Old agent files (product-owner.agent.md, skill-writer.agent.md, etc.) can be safely deleted
   - All agent trigger patterns and routing rules still work — only filenames changed

3. **Custom agent references:** Update any hardcoded agent paths or routing rules:
   - `.github/agents/product-owner.agent.md` → `.github/agents/charter.agent.md`
   - `.github/agents/skill-writer.agent.md` → `.github/agents/smith.agent.md`
   - `.github/agents/reviewer.agent.md` → `.github/agents/auditor.agent.md`
   - `.github/agents/copilot-cli.agent.md` → `.github/agents/invoker.agent.md`

### No API Changes

- All agent trigger patterns remain the same
- All skill commands remain the same (e.g., `decision:create`, `task:item:read`)
- Memory and task storage is unchanged
- Only the underlying agent filenames in `.github/agents/` changed

### Refer to AGENTS.md

See AGENTS.md for the current team roster with thematic names and functional roles.

---

## v0.2.0

See [v0.2.0 Breaking Changes](../v0.2.0/BREAKING_CHANGES.md).
