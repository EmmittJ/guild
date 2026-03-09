# Files authored in this repo are marketplace artifacts — no hardcoded local references

Date: 2026-03-09
Agents: Guild Master

## Context

This repo ships skills, agents, and scripts that are installed into other repos via the plugin marketplace. Files are read by AI agents in arbitrary environments — they cannot contain references specific to this repo's local structure (e.g. `/path/to/repo`, specific branch names, local tool paths).

During a research session we also found that insight files had been written with full local paths (`/path/to/repo`) as source references, which would be meaningless or misleading to agents reading them in other contexts.

## Decision

All files authored in this repo — skills, agents, scripts, memory files, and documentation — must be written as if they will be read in an unknown repo by an unknown agent. Specifically:

- No hardcoded local filesystem paths (e.g. `/path/to/repo`)
- No references to this repo's specific directory layout as ground truth
- Source references use `owner/repo` form, not local paths
- Instructions reference roles and skills, not specific file paths (paths go stale; roles don't)

## Alternatives Considered

- **Allowlist known safe paths**: Too brittle — breaks the moment a file moves or the repo is cloned elsewhere.
- **Document-level disclaimers**: Inconsistent — easy to forget, doesn't scale across 100+ files.

## Outcome

Applied immediately: sanitized path references in all insight files written this session. Reinforced in `AGENTS.md` (File Output Rules) and `orchestrate/SKILL.md` (File Output Discipline) using skill-based framing rather than path lists.
