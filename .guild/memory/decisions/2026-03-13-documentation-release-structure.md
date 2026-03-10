# Documentation and Release Structure — Guild Standard

**Decision Date:** 2026-03-13  
**Status:** Decided  
**Audience:** All Agents, All Contributors, Guild Master
**Related Decisions:** 2026-03-09 (portable file authoring), 2026-03-11 (orchestration tracking)

---

## Context

Guild is generating extensive documentation artifacts with each initiative:
- Decision documents (.guild/memory/decisions/)
- Skill updates and version changes
- Release notes and executive summaries
- Temporary implementation guides
- Insights and domain knowledge

These artifacts are valuable but scattered without clear structure, making it difficult to:
1. **Find release history** — "What changed in v0.4.0?"
2. **Understand feature narrative** — How did this feature evolve?
3. **Onboard new team members** — Where should they look for recent changes?
4. **Track version progression** — What was the timeline of major releases?
5. **Maintain version control** — Are release artifacts in the repo or ephemeral?

Example current state:
- BREAKING_CHANGES.md at root (v0.3.0, v0.2.0)
- ORCHESTRATE_UPDATE_EXECUTIVE_SUMMARY.md at root (temporary, agent-created)
- DELIVERY_SUMMARY.md at root (agent-created summary)
- Decisions buried in .guild/memory/decisions/
- Skill changelogs in individual SKILL.md files
- No central changelog or version index

This creates ambiguity for:
- Users wondering "is this feature in the version I'm using?"
- Contributors asking "where should my release notes go?"
- Auditors tracking "what was promised vs. what was delivered?"
- Decision history ("why did we choose this approach?")

## Decision

Guild SHALL adopt a **Release-Driven Documentation Structure** where release artifacts are first-class, version-tracked citizens. All documentation is organized around releases, with clear lineage from decisions through to release notes.

### 1. Release Folder Structure

Create docs/releases/ with versioned subdirectories:

`
docs/
  releases/
    v0.4.0/
      RELEASE_NOTES.md       # User-facing release notes (required)
      CHANGELOG.md           # Technical changelog (generated)
      BREAKING_CHANGES.md    # Breaking changes, if any (required if breaking)
      DECISIONS.md           # Decisions that shipped (reference list)
      MIGRATION_GUIDE.md     # How to upgrade (required if breaking)
      skill-updates/         # Skill version updates (optional)
        orchestrate-v0.4.md  # Skill changelog
    v0.3.0/
      RELEASE_NOTES.md
      CHANGELOG.md
      BREAKING_CHANGES.md
      DECISIONS.md
      MIGRATION_GUIDE.md
    v0.2.0/
      RELEASE_NOTES.md
      CHANGELOG.md
      ...
`

**Rationale:**
- Releases are the unit of visibility for users
- Each release directory is immutable once tagged
- Tools can scrape docs/releases/*/RELEASE_NOTES.md for a version index
- Clear folder structure makes it obvious "where did v0.X release artifacts go?"

### 2. Root-Level Changelog (Single Source of Truth)

Create a single CHANGELOG.md at repo root that:
- Lists all releases in reverse chronological order
- Summarizes each release (2-3 lines)
- Links to detailed release notes in docs/releases/vX.Y.Z/

`markdown
# Changelog

All notable changes to Guild are documented here. See [Release History](#releases) for version-specific details.

## [0.4.0] — 2026-03-13

**Major Update:** Guild Master lifecycle formalized with explicit monitoring checkpoints. [Full Release Notes →](docs/releases/v0.4.0/RELEASE_NOTES.md)

- Orchestrate skill v0.3 → v0.4 with Issue Lifecycle Management
- Breaking changes: none
- New decision: Guild Master lifecycle ownership

[See full details in v0.4.0 release folder](docs/releases/v0.4.0/)

## [0.3.0] — 2026-03-10

**Major Update:** Agents renamed with thematic branding. [Full Release Notes →](docs/releases/v0.3.0/RELEASE_NOTES.md)

- product-owner → charter
- skill-writer → smith
- reviewer → auditor
- copilot-cli → invoker
- **Breaking Change:** Agent file paths changed

[See full details in v0.3.0 release folder](docs/releases/v0.3.0/) | [Migration Guide](docs/releases/v0.3.0/MIGRATION_GUIDE.md)

## Releases

Complete history: [docs/releases/](docs/releases/)
`

**Rationale:**
- Root CHANGELOG.md is the first place users look
- Each release has a summary line + links to detail
- Version skew is immediately visible
- Build tools can scrape this for a version index

### 3. How Decisions Become Release Notes

**The Flow:**

`
Charter writes user story
  ↓
Engineer implements
  ↓
Decision document created (if policy/pattern decision)
  ↓
Guild Master closes work item
  ↓
Skill version updated (if applicable)
  ↓
Release branch created with version
  ↓
Charter curates RELEASE_NOTES.md for the version
  ↓
RELEASE_NOTES.md links to decision docs (optional reference)
  ↓
docs/releases/vX.Y.Z/ created
  ↓
CHANGELOG.md updated with version entry + link
  ↓
Tag created; release published
`

**Release Notes Curation (Charter's Job):**

Release notes are **NOT auto-generated** from decisions or commit messages. Charter decides what users need to know:

- **What features shipped** (user-facing)
- **What broke** (if anything)
- **Why it matters** (value proposition)
- **Where to get help** (migration guides, documentation links)

**Reference Links (Optional):**
Release notes MAY link to decision documents for:
- Major architectural changes ("See the decision for detailed rationale")
- Policy changes that affect team behavior ("See decision: Guild Master lifecycle")
- Experimental features ("See decision for known limitations")

But RELEASE_NOTES.md is the primary user-facing document. Decisions are reference material, not the release narrative.

**Example Release Notes Entry:**

`markdown
## Issue Lifecycle Management (Orchestrate Skill v0.4)

Guild Master now has explicit monitoring checkpoints for delegated work. This prevents issues from stalling silently and gives the team clear visibility into when to expect updates.

**What Changed:**
- Orchestrate skill v0.3 → v0.4
- New section: "Issue Lifecycle Management" (5 steps, 5 checkpoints, escalation rules)
- Default SLAs: claim 1h, stall check 4h-24h, review 4h, commit 2h

**Why This Matters:**
- Issues can no longer drift in "in-progress" state
- Guild Master has explicit actions at each checkpoint
- Auditors can verify monitoring compliance
- Team knows when to expect status updates

**Migration:**
No breaking changes. Guild Master should read the [Monitoring Quick Card](../../.github/skills/orchestrate/MONITORING_QUICK_CARD.md) and apply checkpoints on the next session.

**For More Details:**
- [Full decision document](.guild/memory/decisions/2026-03-12-guild-master-lifecycle-ownership.md)
- [Lifecycle implementation guide](../../.github/skills/orchestrate/LIFECYCLE_UPDATE_SUMMARY.md)
`

### 4. Breaking Changes Documentation

Breaking changes get their own section in each versioned release folder.

**File:** docs/releases/vX.Y.Z/BREAKING_CHANGES.md

`markdown
# Breaking Changes in v0.4.0

None in v0.4.0. This release is fully backward compatible.

---

## Upgrade Path

No action required. Deploy at your convenience.
`

OR (if breaking):

`markdown
# Breaking Changes in v0.3.0

## Agent File Paths Changed

Old → New:
- .github/agents/product-owner.agent.md → .github/agents/charter.agent.md
- .github/agents/skill-writer.agent.md → .github/agents/smith.agent.md
- .github/agents/reviewer.agent.md → .github/agents/auditor.agent.md
- .github/agents/copilot-cli.agent.md → .github/agents/invoker.agent.md

### How to Upgrade

[See MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
`

**Rationale:**
- Breaking changes are flagged early (right in the version folder)
- Migration paths are explicit and discoverable
- Teams can assess risk before upgrading
- Clear before/after examples

### 5. Skill Version Updates

When a skill version increments (e.g., orchestrate v0.3 → v0.4):

**In the skill itself (SKILL.md):**
- Frontmatter version: field updated
- No changelog section in SKILL.md (see rationale below)

yaml
---
name: orchestrate
description: Orchestrate work and delegate to specialists
version: 0.4
updated: 2026-03-13
---

# ... skill content ...


**Skill version history is tracked via:**
- Git log (commit history for the skill file)
- Root CHANGELOG.md (summarizes all version changes by release)
- docs/releases/vX.Y.Z/CHANGELOG.md (technical details per release)

**In the release folder (required for significant changes):**
- docs/releases/vX.Y.Z/skill-updates/orchestrate-v0.4.md for detailed changelog (if skill changed)
- Links from RELEASE_NOTES.md

**Rationale:**
- Skill files are loaded as agent context during execution — changelog tables waste context tokens
- Agents do not need version history; they only need the current skill definition
- Version history is maintained in CHANGELOG.md (permanent, queryable record)
- Git log provides full commit history for any skill version
- Release notes link to detailed change logs for user reference

### 6. Artifact Cleanup: What Stays, What Goes

**STAYS in repo (version-controlled):**
- docs/releases/vX.Y.Z/ (everything)
- CHANGELOG.md (root)
- BREAKING_CHANGES.md (root) — now a redirect/summary
- Decision documents in .guild/memory/decisions/
- Skill SKILL.md files (without changelog sections)
- .guild/memory/insights/ (domain knowledge)

**TEMPORARY (deleted after release):**
- Agent-created executive summaries (e.g., ORCHESTRATE_UPDATE_EXECUTIVE_SUMMARY.md)
- Implementation guides that are only for the immediate team (e.g., LIFECYCLE_UPDATE_SUMMARY.md)
- Work-in-progress documentation

**Criterion for "stays":**
- Is it needed by future users?
- Is it part of the permanent record?
- Can it be discovered from CHANGELOG.md?

**Criterion for "goes":**
- Is it internal scaffolding?
- Was it created for one implementation cycle?
- Will it confuse new contributors?

**Example:**
- ✓ docs/releases/v0.4.0/RELEASE_NOTES.md — STAYS (users need this)
- ✓ .guild/memory/decisions/2026-03-12-guild-master-lifecycle-ownership.md — STAYS (decision history)
- ✗ ORCHESTRATE_UPDATE_EXECUTIVE_SUMMARY.md — DELETE (was internal; content goes to release notes)
- ✗ .github/skills/orchestrate/LIFECYCLE_UPDATE_SUMMARY.md — REFACTOR (move to skill references or delete if redundant)

### 7. README Linkage

Update README.md (root) to point users to recent releases:

`markdown
# Guild

> Craft, not configuration.

---

## Latest Release

[**v0.4.0**](docs/releases/v0.4.0/RELEASE_NOTES.md) — Guild Master lifecycle formalized. [All releases →](CHANGELOG.md)

---

## What It Is

...

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and [release notes](docs/releases/) for detailed changes per version.
`

**Rationale:**
- New users see recent activity immediately
- Links point to permanent, version-controlled artifacts
- CHANGELOG.md is the hub for version history

### 8. Version Numbering Scheme

Guild uses **Semantic Versioning (semver):** MAJOR.MINOR.PATCH

- **MAJOR** — Breaking changes to agent names, skill names, or core APIs
- **MINOR** — New features, skill updates, non-breaking decision changes
- **PATCH** — Bug fixes, documentation clarifications

Examples:
- v0.1.0 → v0.2.0 — New minor (skill namespace renamed)
- v0.2.0 → v0.3.0 — New minor (agent naming overhaul)
- v0.3.0 → v0.4.0 — New minor (skill version, lifecycle feature)

**Note:** v0.x indicates pre-1.0 (API may change). Once v1.0, breaking changes require a major version bump.

---

## Acceptance Criteria

- [ ] docs/releases/ folder structure created
- [ ] CHANGELOG.md created at root with entry format and links to versioned releases
- [ ] Versioned release folders exist for v0.2.0, v0.3.0, v0.4.0 (with RELEASE_NOTES.md, BREAKING_CHANGES.md, DECISIONS.md)
- [ ] SKILL.md files do NOT contain changelog sections; version history is in git log and root CHANGELOG.md
- [ ] README.md updated to link to latest release and CHANGELOG.md
- [ ] Decision: breaking changes are documented in docs/releases/vX.Y.Z/BREAKING_CHANGES.md
- [ ] Decision: release notes are curated by Charter (not auto-generated)
- [ ] Decision: executive summaries and implementation guides are temporary (deleted after release)
- [ ] BREAKING_CHANGES.md (root) refactored as a summary page linking to versioned releases
- [ ] Example release folder (v0.4.0) populated with RELEASE_NOTES.md, CHANGELOG.md, DECISIONS.md
- [ ] All agents understand: when releasing, create docs/releases/vX.Y.Z/RELEASE_NOTES.md

---

## How This Works in Practice

### When Charter Ships a Feature

1. Feature ships (work closed, code merged)
2. Charter creates docs/releases/vX.Y.Z/RELEASE_NOTES.md entry for the feature
3. Links to decision doc (if policy/pattern related)
4. Summarizes: What Changed, Why It Matters, Migration (if breaking)

### When A New Version is Ready

1. Engineer updates skill ersion: field
2. Engineer updates root CHANGELOG.md with a summary entry for the release (no changelog section in SKILL.md)
3. Charter updates docs/releases/vX.Y.Z/CHANGELOG.md with technical details
4. Charter updates root CHANGELOG.md with summary + link
5. GitHub release is created (tag vX.Y.Z)
6. Release folder is complete and immutable

### When Someone Asks "What's New in v0.4.0?"

1. They check CHANGELOG.md (root)
2. Find entry for v0.4.0 with link to docs/releases/v0.4.0/RELEASE_NOTES.md
3. Read summary and links
4. Dive deeper into decision docs or migration guides as needed

### When Someone Joins the Team

1. They read README.md (points to latest release)
2. They check CHANGELOG.md for recent changes
3. They browse docs/releases/ for version history
4. They understand the feature timeline and why decisions were made

---

## Implementation Notes

1. **Retroactive Releases (v0.2.0, v0.3.0):** Create release folders for existing versions with release notes extracted from BREAKING_CHANGES.md and decision documents.

2. **BREAKING_CHANGES.md (root):** Refactor as a summary page:
   `markdown
   # Breaking Changes

   This page summarizes breaking changes across all Guild versions. For details, see the release folder for your version.

   - [v0.3.0 Breaking Changes](docs/releases/v0.3.0/BREAKING_CHANGES.md) — Agent naming changes
   - [v0.2.0 Breaking Changes](docs/releases/v0.2.0/BREAKING_CHANGES.md) — Skill namespace renames
   `

3. **DELIVERY_SUMMARY.md and ORCHESTRATE_UPDATE_EXECUTIVE_SUMMARY.md:** These become templates for post-release cleanup. Content migrates to release notes; files are deleted.

4. **Decisions in Memory:** Keep all decisions in .guild/memory/decisions/ (permanent record). Release notes optionally *reference* them, but decisions are not deprecated.

---

## Related Decisions

- **2026-03-11:** Orchestration tracking process — decisions trigger work items
- **2026-03-09:** Portable file authoring — decisions and docs must not hardcode paths
- Thematic agent naming (v0.3.0) — Breaking change documented in release notes

---

## Success Metrics

After implementation:
- [ ] User can find "what changed in v0.4.0?" within 30 seconds
- [ ] New contributor can understand feature timeline from CHANGELOG.md
- [ ] Auditor can verify what was decided vs. what was released
- [ ] Release notes are discoverable from README.md
- [ ] No temporary documents are left in root after release
- [ ] Version history is clear and complete


