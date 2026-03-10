# Thematic Agent Naming Implementation Complete

Date: 2026-03-10
Agents: Guild Master, Engineer, Skill Writer, Reviewer, Scribe

## Context

Following the decision to adopt thematic agent names (issue #12), the team executed a comprehensive 4-phase refactoring to rename all guild agents from functional names (product-owner, engineer, skill-writer, etc.) to thematic names aligned with Guild's craftsmanship aesthetic (charter, engineer, smith, auditor, scribe, invoker, guild-master).

## Decision

Fully implemented **Option B: Thematic Naming** with **role column in routing table**.

**Final Agent Names:**
- charter (product-owner role)
- engineer (engineer role)
- smith (skill-writer role)
- auditor (reviewer role)
- scribe (scribe role)
- invoker (copilot-cli role)
- guild-master (guild-master role)

## Implementation Summary

**Phase 1 — Agent File Renames** (Engineer)
- Renamed 6 agent files to thematic names
- Updated YAML frontmatter `name:` fields
- Fixed handoff references across all 7 agents

**Phase 2 — Routing Skill Update** (Skill Writer)
- Added **Role** column to routing team table
- Maps thematic agent names to functional roles
- Updated routing rules with role clarifications
- Bumped version to 0.2
- Synchronized asset template

**Phase 3 — Documentation Updates** (Engineer)
- Updated AGENTS.md with new agent roster
- Updated README.md "What Ships" section
- Added v0.3.0 breaking change documentation with migration guide
- Verified plugin.json (no changes needed)

**Phase 4 — Agent Instructions** (Engineer)
- Updated all 7 agent instruction files
- Clarified thematic names + functional roles in parentheses
- Consistent cross-agent references using thematic names
- Updated boundary sections

**Review & Commit** (Reviewer + Scribe)
- All changes reviewed and approved
- Committed as v0.3.0 breaking change (commit: 22a4a64)
- Tagged v0.3.0
- Issue #12 closed

## Outcome

**Completed and Released:**
- All guild agents now use thematic, craftsmanship-aligned names
- Routing table clearly maps thematic names to functional roles
- Breaking changes documented with migration guidance
- Teams can identify agents by theme (charter, smith, auditor) while systems route by role

**Key Distinction Established:**
- **Thematic names** (user-facing): what humans see and interact with
- **Functional roles** (system-level): what routing rules and dispatching use

This mirrors the guild-* naming convention established for skills in issue #11, creating a cohesive naming strategy across both agents and skills.

## Notes

- No data directories or trigger patterns changed — only agent file names and references
- Backward compatibility: Existing consumer repos will need to re-run setup scripts to get new agent files
- The distinction between thematic identity and functional role is now explicit throughout documentation
