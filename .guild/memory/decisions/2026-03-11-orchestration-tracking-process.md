# Guild Master Orchestration: Tracking Issue Process

**Decision Date:** 2026-03-11  
**Status:** Decided  
**Audience:** Guild Master, All Agents, Auditor

## Context

Guild Master routes, briefs, tracks, and synthesizes work across the agent network. To maintain visibility, accountability, and an auditable history of delegated work, we formalize **when and how tracking issues are created**.

Previously, issue creation was implicit. This decision makes it explicit, enabling agents to see the backlog and prioritize accordingly, and future auditors to trace every artifact to its origin.

## Decision

**Guild Master SHALL create a tracking issue for any delegated work that produces a concrete artifact.**

### When to Create a Tracking Issue

| Scenario | Create Issue? | Example |
|----------|:---:|---------|
| Delegated code change | ✅ Yes | "Update Smith skills for new language" |
| Delegated documentation | ✅ Yes | "Document the new CLI syntax in README" |
| Delegated formal decision | ✅ Yes | "Formalize the API versioning strategy" |
| Delegated process/spec | ✅ Yes | "Define the CI/CD workflow" |
| Delegated memory artifact (insight, decision) | ✅ Yes | "Capture domain model gotchas in memory" |
| Quick clarification or info request (no artifact) | ❌ No | "Engineer, what's the status of the PR?" |
| Inline guidance during a session | ❌ No | "Scribe, can you also fix the formatting?" |
| Ask for an investigation that may not produce code | ⚠️ Maybe | Create if results get captured; skip if it's exploratory advice |

**Rule of Thumb:** If the outcome is something we'd want to find again, version, audit, or hand off to another agent — create an issue.

---

## Issue Structure

Guild Master SHALL use this structure for all tracking issues:

`markdown
## What
[1–3 sentences. What are we building and why? What problem does it solve?]

## Done When
- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2
- [ ] Acceptance criterion 3

## Context
[Background, related decisions, dependencies, or constraints the specialist needs to know.]
`

### Labels

- **Priority:** Always label with exactly one of:
  - priority:high — blocks other work or is urgent
  - priority:medium — important but not blocking
  - priority:low — nice-to-have or deferred
  
- **Other labels:** As appropriate (e.g., 	ype:decision, 	ype:documentation, 	ype:code, equires-review:auditor)

- **NOT required:** The open label is NOT added to new tracking issues (per decision [#13](../2026-03-11-task-labeling-strategy.md)). Issues are open by default.

### Title

- Clear, specific, and scannable in a list
- State what is being created/changed, not why
- Examples:
  - ✅ "Craft decision: API versioning strategy"
  - ✅ "Add skill for Rust code generation"
  - ✅ "Document CLI command reference"
  - ❌ "We need better versioning" (vague, why not what)

---

## Ownership & Workflow

1. **Guild Master creates** the tracking issue with complete structure
2. **Specialist claims** by adding in-progress label (or similar "started" indicator per project conventions)
3. **Specialist works** and may update the issue with progress
4. **Specialist completes** the work and opens a PR, creates a commit, or updates memory
5. **Auditor reviews** (if equires-review:auditor is set) and approves
6. **Scribe commits/merges** the work, and the commit message auto-links the issue (e.g., "closes #42" or "resolves #42")
7. **Issue auto-closes** or specialist closes it manually if not auto-linked

**Handoff rule:** Every issue should have a clear "done when" definition so the next agent knows exactly what success looks like.

---

## Why This Matters

| Benefit | How |
|---------|-----|
| **Visibility** | All delegated work appears on the board. Agents and stakeholders can query "what are we working on?" |
| **Prioritization** | Agents see the backlog and can claim work in priority order. Guild Master can re-prioritize without side-channel communication. |
| **Narrative** | Every artifact (code, decision, doc, skill) has an origin story. Future auditors can trace why something exists and what problem it solved. |
| **Handoff** | When work moves between agents, the issue is the source of truth: what needs doing, when it's done, and why it matters. |
| **Audit Trail** | Issue comments, reviews, and closures create a timestamped record for compliance and learning. |

---

## Examples

### Example 1: Code Change → Issue Required

**Scenario:** Engineer reports a bug in the prompt routing logic. Guild Master delegates a fix.

**Issue Created:**

`
Title: Fix prompt routing bug when agents exceed rate limit

## What
Engineer reported that when agents hit rate limits, prompts are routed to the wrong fallback handler. This causes user requests to fail instead of gracefully queuing. We need a code fix to ensure fallback routing respects the priority queue.

## Done When
- [ ] Root cause identified and documented in issue comment
- [ ] Fallback routing logic updated in src/routing.ts
- [ ] Unit tests added for rate-limit edge case
- [ ] Engineering review passed
- [ ] Merged to main

## Context
Related: Issue #38 (rate limiting feature), decision #2026-03-10-rate-limiting.md
This is blocking user experience on prod.
`

**Labels:** priority:high, 	ype:code, equires-review:auditor

---

### Example 2: Decision → Issue Required

**Scenario:** Team needs to decide on a new authentication model. Guild Master routes to Charter.

**Issue Created:**

`
Title: Craft decision: JWT vs. session-based authentication

## What
We need to decide on an authentication strategy for the public API. Current session-based approach doesn't scale to mobile clients. Decision should evaluate JWT, OAuth2, and session alternatives, recommend one, and document the tradeoffs.

## Done When
- [ ] Decision document written and reviewed
- [ ] Tradeoffs of 3 approaches documented
- [ ] Recommendation justified with rationale
- [ ] Saved to .guild/memory/decisions/
- [ ] Auditor signed off

## Context
Blocked: Issue #47 (mobile client support) depends on this decision.
Reference: decisions #2026-03-10-api-design.md, #2026-03-09-security.md
`

**Labels:** priority:high, 	ype:decision, equires-review:auditor

---

### Example 3: Quick Info Request → No Issue

**Scenario:** Guild Master needs to know what branch an Engineer is working on.

**NO ISSUE.** This is a quick synchronous question, not delegated work. Guild Master asks directly in the session or Slack.

---

### Example 4: Documentation → Issue Required

**Scenario:** Guild Master identifies that the onboarding guide is out of date.

**Issue Created:**

`
Title: Update onboarding guide for new agent architecture

## What
Onboarding guide references the old 3-agent model. We've migrated to the new 7-agent guild structure. Update guide with current roles, flow, and getting-started steps.

## Done When
- [ ] Roles section updated to reflect current agents
- [ ] Workflow diagrams redrawn
- [ ] Installation steps verified against current setup
- [ ] Link check: all cross-references valid
- [ ] Merged to main

## Context
Related: Issue #55 (agent architecture refactor). New agents: Smith, Invoker, Scribe, Auditor.
`

**Labels:** priority:medium, 	ype:documentation

---

### Example 5: Memory Insight → Issue Required

**Scenario:** Guild Master discovers a tricky gotcha about the framework's caching behavior while working.

**Issue Created:**

`
Title: Document framework caching gotcha in memory

## What
Discovered that the framework's cache invalidation is *implicit* after writes, not explicit. This has bitten engineers twice. Capture this gotcha and the safe patterns in memory/insights/ so future engineers see it.

## Done When
- [ ] Insight document written explaining the gotcha
- [ ] Safe usage patterns documented
- [ ] Saved to .guild/memory/insights/
- [ ] Example code added to wiki

## Context
Relates to: Issue #23, #51 (both were cache-related bugs)
`

**Labels:** priority:medium, 	ype:memory

---

## Exceptions & Edge Cases

1. **Exploratory work:** If the specialist is asked to investigate something (e.g., "what would it take to migrate to Postgres?") and the result might just be a chat summary or "not worth it," create an issue only if the specialist is expected to write up findings in memory or documentation.

2. **Immediate corrections:** If Guild Master is in a session with an agent and says "while you're at it, fix the typo on line 42," that's inline guidance, not a separate issue.

3. **Async cascades:** If one issue spawns a follow-up (e.g., code review feedback generates a refactor task), create a linked issue for the follow-up and reference the parent.

---

## Enforcement

- **Guild Master** is responsible for creating issues that fit the "artifacts get issues" rule.
- **Agents** should ask for clarification if a delegated task arrives without a tracking issue.
- **Auditor** may flag work discovered without a corresponding issue during reviews.

---

## Related Decisions

- [2026-03-11 Task Labeling Strategy](./2026-03-11-task-labeling-strategy.md) — labeling conventions
- [2026-03-10 Agent Naming Decision](./2026-03-10-agent-naming-decision-implemented.md) — agent roles and responsibilities
- [2026-03-09 Portable File Authoring](./2026-03-09-portable-file-authoring.md) — memory and artifact storage

