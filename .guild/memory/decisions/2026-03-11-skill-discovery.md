# Decision: Skill Discovery at Session Start

**Date:** 2026-03-11  
**Status:** proposed  
**Issue:** #35  

---

## Problem

`plugin/skills/orchestrate/SKILL.md` hardcodes installed skill names in the Guild Master
Initialization table (currently `guild-memory`, `guild-issues`, `guild-inbox`). When these
skills are renamed — as happened in the guild-* → markdown-* propagation — orchestrate's
initialization step silently fails to load the correct skills. There is no mechanism to
detect the mismatch. Fixing it requires hunting down every reference across orchestrate
and any consuming files.

The root cause is coupling: orchestrate owns the initialization procedure *and* the list
of what to initialize. That list belongs somewhere else.

---

## Options Considered

### Option A — Verb-based matching

Orchestrate's initialization table replaces skill names with activation verbs
(`memory:context:read`, `issue:ready`, `inbox:message:read`). At session start, the agent
pattern-matches against installed skill descriptions to find who handles each verb and
runs that skill's session-start procedure.

**What works:** Verb-based dispatch is already how agents load skills for casual
invocations — the description-matching mechanism exists and is tested. Rename-tolerant
for the body of the skill.

**What doesn't:** The initialization table still couples to a fixed set of verbs. If two
skills both declare verbs in the `memory:*` namespace (e.g., a user adds a second memory
backend), verb matching produces ambiguous results. More critically, there is no
authoritative source for *which* skills must run at session start — the orchestrate
initialization table remains the implicit inventory, just encoded differently.

**Change required:** Rewrite the initialization table rows to reference verbs instead of
names. Low effort, but doesn't solve the underlying "who does what" ownership problem.

---

### Option B — Directory scan at session start

Orchestrate's initialization step says: "scan `{skills-dir}/` and apply every installed
skill that declares a session-start section." No names, no verbs — whatever is installed
gets applied.

**What works:** Fully rename-resilient. Installing or removing a skill automatically
changes initialization behavior. No orchestrate edits needed on skill changes.

**What doesn't:** Requires every skill to have a self-contained, parseable session-start
section — currently only markdown-memory has a formal one. Skills like `routing` have no
session-start procedure at all. Silent skips are undetectable. Application order is
undefined unless skills declare explicit priority, which is new schema. Implementation
burden falls on every skill author.

**Change required:** Session-start section schema + compliance across all installed skills.
High implementation cost before this is safe to rely on.

---

### Option C — Routing as the installed-skills inventory

`routing/SKILL.md` adds an explicit "Installed Skills" table listing each installed skill,
its session-start activation, and its initialization order. Orchestrate's initialization
step becomes: "load routing, then apply each skill listed under Installed Skills, in order."
Routing is already read at step 4 of initialization and is already host-owned — the user
already goes there to configure their team.

**What works:** The coupling does not disappear — it moves to the right file. Routing is
already the host's designated configuration surface. When a user renames or swaps a skill,
they update routing; they do not touch orchestrate. Ordering is explicit and auditable.
The orchestrate initialization table becomes a single line of instruction rather than a
maintained list.

**What doesn't:** Routing becomes slightly heavier. Adding skills still requires a manual
update to routing (though that's already true for team roster changes). If routing is not
installed, orchestrate needs a fallback.

**Change required:** Two targeted edits (routing + orchestrate) and the same update to the
plugin asset routing file. No per-skill implementation work required.

---

## Decision

**Option C — Routing as the installed-skills inventory.**

The key insight: routing is already loaded, already host-owned, and already the place
where a user configures their installation. Making it the single source of truth for
*which skills are installed and in what order* is a natural extension of its existing
responsibility, not a new one.

Option A improves tolerance for renames in the body of orchestrate but leaves the
initialization table as an implicit inventory — the problem recurs the next time a verb
changes or a skill is added/removed. Option B is the ideal end-state for a fully automated
system but requires per-skill work that currently has no enforcement path.

Option C requires the least change to orchestrate and aligns with the principle that
host-owned files are where host-specific configuration lives. The tradeoff — routing
becomes heavier — is acceptable because it is already the designated sync point.

**Fallback rule (when routing is absent):** Orchestrate falls back to verb-based dispatch
(Option A behavior) — attempt `memory:context:read`, `issue:ready`, `inbox:message:read`
in order. This preserves current implicit behavior for bare installations.

---

## Consequences

**Gets easier:**
- Renaming or swapping a skill requires updating routing only — not orchestrate.
- The initialization table in orchestrate becomes stable; it describes a procedure, not
  a directory listing.
- The installed skill inventory is auditable in one place (routing) alongside the team roster.

**What changes:**
- `routing/SKILL.md` grows an "Installed Skills" section. This section is host-owned.
- `orchestrate/SKILL.md` initialization table collapses to a delegation statement:
  "apply each skill in routing's Installed Skills table, in order."
- The plugin asset `plugin/skills/setup/assets/skills/routing/SKILL.md` gets the same
  Installed Skills table scaffolded with the standard skill set (markdown-memory,
  github-issues, markdown-inbox) so that `/guild:setup` provisions it correctly for
  new installs.

**Risks that remain:**
- Routing still requires manual updates when skills are installed or renamed. This is
  intentional (host owns the config) but is still a human step.
- If a user omits a skill from routing's table, initialization silently skips it.
  Mitigation: routing's table should be the checklist the user fills in at setup time.
- The fallback (Option A verb dispatch) relies on LLM description-matching accuracy. It
  should be treated as a best-effort recovery, not a primary path.

---

## Implementation

Three concrete changes are required. None of them are the architect's to make — these are
engineer / smith scope. Recording here for implementation handoff.

1. **`routing/SKILL.md`** — Add an "Installed Skills" section after the Model Tiers table.
   Schema: a table with columns `Order | Skill | Session-Start Action`. Populate with the
   skills currently active in this repo (markdown-memory, github-issues, markdown-inbox),
   with their session-start activation verbs. Mark the section as host-owned.

2. **`orchestrate/SKILL.md`** — Rewrite the Guild Master Initialization table. Replace the
   four hardcoded rows with a single procedural statement: "Read routing's Installed Skills
   table and apply each skill in listed order. If routing is not installed, run the
   fallback sequence." Retain the routing step (step 4) but fold the other steps into this
   dynamic dispatch. The fallback sequence is the current hardcoded table, preserved as a
   code block or comment for reference.

3. **`plugin/skills/setup/assets/skills/routing/SKILL.md`** — Mirror change #1. The
   scaffolded Installed Skills table should use standard skill names
   (markdown-memory, github-issues, markdown-inbox) as defaults so new installs are
   provisioned correctly without orchestrate changes.
