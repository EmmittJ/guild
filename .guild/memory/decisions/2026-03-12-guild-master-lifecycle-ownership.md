# Guild Master Lifecycle Ownership: Monitoring & Closure

**Decision Date:** 2026-03-12  
**Status:** Decided  
**Audience:** Guild Master, All Agents, Auditor

## Context

Guild Master's responsibility to "track work" has been implicit — mentioned in the agent description but not operationalized in the orchestrate skill. As a result, Guild Master doesn't have explicit checkpoints, intervention criteria, or escalation rules for delegated work.

Previously:
- Guild Master creates tracking issues ✓ (formalized in 2026-03-11 decision)
- Guild Master delegates work ✓ (covered in orchestrate skill)
- Guild Master monitors progress ❓ (not formalized — assumed passive)
- Guild Master ensures closure ❓ (not formalized — happens implicitly)

This gap means issues can stall silently. Specialists don't know when/whether Guild Master is checking. Auditors can't audit Guild Master's monitoring behavior. The team has no SLA for how long work can sit in "in-progress" before someone intervenes.

## Decision

**Guild Master owns the full lifecycle of every delegated tracking issue until it closes.** This ownership includes:

1. **Monitoring** — active polling at explicit checkpoints, not passive waiting
2. **Intervention** — escalation rules for when specialist is stuck, auditor is slow, or scribe hasn't committed
3. **Closure** — verification that all "Done When" criteria were met before the issue closes

### What Changed

Updated the orchestrate skill (version 0.3 → 0.4) to include a new **"Issue Lifecycle Management"** section that codifies:

- **The 5-Step Lifecycle:** Create → Delegate → Monitor → Review → Commit
- **Monitoring Checkpoints:** Claim Check (1 hr), Progress Check (daily/2d/3d), Stall Check (4h/8h/24h), Review Check (4h), Commit Check (2h+)
- **Intervention Rules:** Four explicit escalation cases with trigger conditions and actions
- **Guild Master's Role in Each Phase:** Checklists for Create, Delegate, Monitor, Review, and Commit phases
- **Thresholds & Timing:** Default SLAs for small/medium/large issues
- **Escalation Criteria:** When to escalate to user vs. trying to unblock within Guild Master's authority

### Key Responsibilities Made Explicit

| Lifecycle Phase | Guild Master's Responsibility | Consequence of Drift |
|---|---|---|
| **Create** | Define auditable acceptance criteria; ensure realistic scope | Specialist doesn't know what "done" means; scope creep |
| **Delegate** | Brief clearly; verify specialist understands; note start time | Specialist starts late or in wrong direction |
| **Monitor** | Poll at checkpoints; ask "what's blocking?" if stalled; intervene | Issues stall silently; team doesn't know why work is slow |
| **Review** | Coordinate auditor review; ensure it doesn't become a bottleneck | Review takes >24 hours with no update; delays closure |
| **Commit** | Verify work is ready; remind scribe; confirm closure | Work lingers in "ready to commit" state; issue doesn't close |

### Monitoring Checkpoints (Not Optional)

Guild Master SHALL check issue status at these explicit points:

1. **Claim Check** (within 1 hour) — "Has specialist started?"
2. **Progress Check** (daily/2d/3d per complexity) — "What's the progress update?"
3. **Stall Check** (4h/8h/24h per complexity) — "Why is this quiet? Blocker?"
4. **Review Check** (when ready) — "Has auditor started reviewing?"
5. **Commit Check** (when approved) — "Is scribe preparing to merge?"

If a threshold passes without activity, Guild Master posts in the issue asking for status. This is not optional or discretionary.

### Intervention Rules (Clear Escalation)

**Case 1: Specialist hasn't claimed (1h)**
- Action: Post "When can you start?"
- Escalate if: No claim within 2 hours total

**Case 2: Specialist is stuck (threshold time)**
- Action: Post "What's blocking?"
- Escalate if: Still stuck after 4 more hours

**Case 3: Auditor review stalled (4h)**
- Action: Summarize what needs review; mention auditor
- Escalate if: No review start within 8h total

**Case 4: Scribe waiting (auditor approved)**
- Action: Post "Ready to commit. Scribe: please merge with issue-closing reference"
- Escalate if: No commit within 4 hours

**Escalate to user when:**
1. Specialist is blocked on something outside Guild Master's scope (e.g., waiting for security approval)
2. Work is stalled >24h with no known blocker
3. Scope creep discovered mid-work
4. Work conflicts with higher-priority tasks
5. Specialist is overwhelmed with parallel work

### Memory & Context Requirement

Guild Master SHALL trigger memory:context:update at each checkpoint or intervention to record:
- Which issues are actively being monitored
- Any blockers and how they were resolved
- Any process gaps (e.g., "auditor review consistently slow")
- Team velocity and specialist capacity insights

This ensures continuity between Guild Master sessions.

---

## Why This Matters

| Benefit | How |
|---------|-----|
| **Predictability** | Specialists know when Guild Master will check. Auditors and users can predict how long an issue will stay in-progress before escalation. |
| **No Silent Stalls** | If an issue has been quiet for the threshold time, Guild Master asks why. Team visibility is guaranteed. |
| **Auditability** | Guild Master's monitoring behavior is now checkable: "Did you check claim within 1 hour? Did you ask about the stall?" |
| **Faster Resolution** | Early intervention (at 4h stall, not 24h) means blockers are surfaced quickly. Users get escalations with context, not surprise delays. |
| **Team Capacity** | By tracking which issues are being monitored and noting bottlenecks (e.g., slow auditor reviews), the team learns where to invest. |

---

## Thresholds (Adjustable by Team)

These are *defaults*. A team can override them by creating a separate decision (e.g., "Our small issues have 2-hour stall threshold, not 4 hours").

| Activity | Small | Medium | Large |
|---|---|---|---|
| Claim Check | 1h | 1h | 2h |
| Progress Cadence | Daily | Every 2d | Every 3d |
| Stall Threshold | 4h | 8h | 24h |
| Review Start SLA | 4h | 4h | 8h |
| Commit SLA | 2h | 4h | 8h |

---

## Enforcement

- **Guild Master** applies the checkpoints. If a session doesn't have time to complete all checkpoints, memory:context:update notes which issues need checking next.
- **Auditor** may review Guild Master decisions to verify: "For this issue, were checkpoints applied? Were intervention thresholds honored?"
- **Users** receive escalation messages only after Guild Master has attempted to unblock (except for external blockers like "waiting for vendor docs").

---

## Related Decisions

- [2026-03-11 Orchestration Tracking Process](./2026-03-11-orchestration-tracking-process.md) — when and how to create tracking issues
- [2026-03-11 Task Labeling Strategy](./2026-03-11-task-labeling-strategy.md) — issue labels
- [2026-03-10 Agent Naming Decision](./2026-03-10-agent-naming-decision-implemented.md) — agent roles and boundaries

---

## Implementation Notes

- This decision updates orchestrate skill version 0.3 → 0.4
- The skill now includes explicit checkpoints and checklists for each phase
- Guild Master should read the new "Issue Lifecycle Management" section at the start of every session to ensure ongoing issues are on the radar
- If the team's working cadence differs (e.g., all issues are large and span weeks), create a follow-up decision documenting the custom thresholds

