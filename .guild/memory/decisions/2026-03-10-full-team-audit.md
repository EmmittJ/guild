# Full Team Audit — Memory/Codebase Validation Consensus

Date: 2026-03-10
Agents: architect, charter, engineer, smith, invoker, auditor, scribe (all 7 ran in parallel)

## Context

All seven specialists independently read every insight and decision file, validated each against
the live codebase, and cast votes. This records their consensus.

## What the Codebase Is (unanimous)

Guild is a portable AI team-in-a-box — a set of `.agent.md` and `SKILL.md` files in the
agentskills.io format that, when installed via Copilot CLI plugin or direct file copy, instantiates
a complete role-separated development team (guild-master + 7 specialists) with encoded process
contracts. No runtime code — pure agent instructions and skill protocols.

## Decision Vote Summary

| Decision File | Verdict | Confidence |
|---|---|---|
| `_summary.md` | VALID | 6/7 |
| `2026-03-09-portable-file-authoring.md` | VALID | 7/7 unanimous |
| `2026-03-10-agent-naming-decision-implemented.md` | VALID | 5/7 (2 noted architect added post-v0.3.0) |
| `2026-03-10-agent-tooling-implementation-guide.md` | DELETE | 7/7 unanimous — temp artifact not cleaned up |
| `2026-03-10-agent-tooling-strategy.md` | NEEDS_UPDATE | 7/7 unanimous — auditor RBAC violated in live files |
| `2026-03-10-AGENT-TOOLING-SUMMARY.md` | NEEDS_UPDATE | 7/7 unanimous — same RBAC contradiction |
| `2026-03-10-thematic-agent-naming.md` | VALID | 6/7 |
| `2026-03-10.md` | VALID | 7/7 unanimous |
| `2026-03-11-orchestration-tracking-process.md` | VALID | 7/7 unanimous |
| `2026-03-11-task-labeling-strategy.md` | VALID | 7/7 unanimous |
| `2026-03-12-guild-master-lifecycle-ownership.md` | VALID | 7/7 unanimous |
| `2026-03-13-documentation-release-structure.md` | NEEDS_UPDATE | 5/7 — folders exist but schema incomplete |

## Insight Vote Summary

All 11 insight files voted VALID by 7/7. Two exceptions:
- `claude-code-plugins.md` — 2/7 flagged NEEDS_UPDATE: conflates Claude Code and Copilot CLI plugin schemas; useful ecosystem context but risky if applied directly to manifest authoring
- `marketplace-design.md` — 1/7 flagged: note that marketplace.json already has phantom entries that violate the convention-over-configuration principle described here

## Critical Issues (5+ agents flagged independently)

1. **RBAC violation — auditor.agent.md** (7/7): `edit` and `execute` tools present despite unanimous
   least-privilege decision. Quality gate is compromised at the tooling level.

2. **marketplace.json ↔ plugin.json mismatch** (5/7): `markdown-memory@guild` and
   `guild-setup-github@guild` are registered in marketplace.json but have no plugin definitions in
   plugin.json. Both install handles silently fail.

3. **Specialist agents absent from plugin.json** (4/7): Only `guild-master.agent.md` in core plugin.
   Seven specialists are invisible to Copilot CLI runtime after `plugin install core@guild`.

4. **agent-tooling-implementation-guide.md not deleted** (7/7): Temp artifact per 2026-03-13 policy.
   Should be removed.

5. **No v0.4.0 release cut** (4/7): Eight substantive commits since v0.3.0 — architect agent,
   orchestrate v0.4, lifecycle tracking, task labeling v2, docs structure — with no tag, no
   CHANGELOG entry, no release folder.

6. **guild-setup/assets/agents/ is empty** (2/7): Setup skill documents copying guild-master.agent.md
   into consumer repos; source asset doesn't exist. Primary onboarding flow is broken.

7. **charter.agent.md also over-provisioned** (3/7): Has `edit` and `execute` but RBAC decision says
   read, memory, task only.

## Agreed Direction

Priority 1 — Enforce RBAC: remove edit/execute from auditor; rationalize charter tool list;
  reconcile tooling strategy/summary decisions with actual implementation.

Priority 2 — Fix distribution: all 8 agents in plugin.json; resolve marketplace/plugin mismatch;
  add version field; fix README install syntax.

Priority 3 — Cut v0.4.0: write architect decision; docs/releases/v0.4.0/; update CHANGELOG; tag.

Priority 4 — Convert open insight gaps to tasks: observability (JSONL log), human-in-the-loop
  (approval gate), testing (routing correctness fixture).

## Outcome

This audit establishes shared team understanding. The memory system is broadly healthy — most
decisions are correctly implemented, all insights are still valid. The three NEEDS_UPDATE decision
files (tooling strategy, tooling summary, tooling guide) represent a single coherent problem: the
RBAC implementation diverged from the decision without an amendment. That is the highest-priority
reconciliation task.
