# Decision Summary

- **2026-03-11** — Guild Master orchestration: Always create tracking issues for delegated work that produces artifacts (code, docs, decisions, memory). Issues use standard structure (What/Done When/Context) with priority labels. Ownership model: Guild Master creates → Specialist claims/works → closes → Auditor reviews (if needed) → Scribe commits. See 2026-03-11-orchestration-tracking-process.md.
- **2026-03-11** — Task labeling strategy: status labels are optional descriptive markers, not required gates. Readiness is "open issue without blocked label." Charter doesn't add open label at creation. Priority labels are optional. See 2026-03-11-task-labeling-strategy.md.
- **2026-03-10** — Thematic agent naming **implemented and released as v0.3.0**. All agents renamed (charter, smith, auditor, invoker) with role column in routing table. See 2026-03-10-agent-naming-decision-implemented.md.
- **2026-03-10** — Adopt thematic agent naming strategy (charter, smith, auditor, invoker, scribe) with a role column in routing table to map names to functional roles. See 2026-03-10-thematic-agent-naming.md.
- **2026-03-09** — Files authored here are marketplace artifacts: no hardcoded local paths, no repo-specific references. Source refs use owner/repo form; instructions reference roles and skills, not paths. See 2026-03-09-portable-file-authoring.md.

- **2026-03-13** — **Documentation and Release Structure:** All documentation organized around releases in docs/releases/vX.Y.Z/ with versioned RELEASE_NOTES.md, CHANGELOG.md, and BREAKING_CHANGES.md. Root CHANGELOG.md is single source of truth for version history. Release notes curated by Charter (not auto-generated). Decisions are reference material, not release narrative. Temporary artifacts (executive summaries, implementation guides) deleted after release. See 2026-03-13-documentation-release-structure.md.

