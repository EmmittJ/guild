---
name: guild-setup
description: >
  Bootstrap core Guild configuration into any repo. Scaffolds AGENTS.md, the routing skill,
  the orchestrator agent, and optionally a full cast team.
  Activate when: setting up Guild in a repo for the first time; adding the routing skill to
  an existing repo; casting a themed team from a universe; the user says "/guild-setup".
  DO NOT USE FOR: installing memory, tasks, or inbox — use guild-setup-markdown for that.
license: MIT
metadata:
  version: "0.3"
---

## Asset Sources

| Installed file | Source asset |
|---|---|
| `{skills-dir}/routing/SKILL.md` | `guild-setup/assets/skills/routing/SKILL.md` |
| `{agents-dir}/{name}.agent.md` | `guild-setup/assets/agents/{orchestrator\|builder\|advisor\|scribe}.agent.md` |

**When editing the routing skill:** also update the asset. The routing skill's frontmatter has
`metadata.asset:` pointing to its asset counterpart — use that as the sync signal.

---

## What This Does

`/guild-setup` is interactive. Steps:

1. **Discover the codebase** — silent scan before asking anything
2. **Casting choice** — manual team definition or universe casting
3. **Team size** — how many agents (default 5 including orchestrator)
4. **Routing rules** — confirm or adjust routing patterns
5. **Scaffold** — write agent files and routing skill

---

## Step 1: Discover the Codebase

Before prompting the user, silently scan:

| What to look for | How |
|---|---|
| Language + framework | `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `composer.json`, `Gemfile`, `build.gradle` |
| Architecture pattern | Directory structure: `src/`, `apps/`, `packages/`, `services/`, `infra/`, `Dockerfile`, `docker-compose.yml` |
| Test runner | `jest`, `pytest`, `vitest`, `rspec`, `cargo test`, `go test` references in config files |
| CI system | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml` |
| Docs | `docs/`, `README.md`, `CONTRIBUTING.md` |
| Security surface | Auth files, public API routes, file uploads, user-controlled input patterns |
| Existing agents | `.github/agents/` — note covered roles; don't re-scaffold what exists |

Produce an internal summary (not shown to user yet):
```
Stack: {language(s)} / {framework(s)}
Type: {monorepo | microservices | library | CLI | standard app | static site}
Test runner: {runner or "none detected"}
CI: {system or "none"}
Docs: {present/absent, location}
Security surface: {brief — e.g. "public REST API with auth"}
Existing agents: {list or "none"}
```

---

## Step 2: Present Discovery + Ask Casting Mode

Show the user a brief summary of what was found:

> I found a **{type}** project using **{stack}**. Here's what I'll base the team on:
> - Stack: {stack}
> - Tests: {test runner}
> - CI: {ci system}
> - Docs: {present/absent}
>
> How do you want to set up your team?
> **A) Universe casting** — pick a fictional universe; I'll cast characters as your agents
> **B) Manual** — define team members yourself

---

## Step 3A: Universe Casting Flow

If the user picks **A**:

### Ask for universe and team size

> What universe? (Any show, film, book, game — no limits)
> How many agents? (default: 5, including your orchestrator)

### Derive roles from the stack

Based on the discovery summary, pick N−1 specialist roles to complement the orchestrator. Use this priority table — pick roles that match the project's actual needs:

| Role | Cast when |
|---|---|
| Orchestrator | Always — 1 per team |
| Backend Engineer | Server code, API routes, databases present |
| Frontend Engineer | UI components, CSS, React/Vue/Svelte/etc. present |
| Full-stack Engineer | Small team + both frontend and backend present |
| Data Engineer | ORM migrations, analytics, ETL, heavy query patterns |
| Platform / DevOps | Dockerfile, CI config, infra-as-code present |
| Tester / QA | Test directory present or notable gap |
| Security Reviewer | Public API, auth code, sensitive data handling |
| Technical Writer | `docs/` present, SDK, developer-facing library |
| Scribe | Always valuable for commit/PR discipline |

Present the proposed roles before casting:
> For a **{type}** project in **{stack}**, I'd cast these {N} roles:
> - Orchestrator
> - {role 2}
> - ...
>
> Does this look right? You can adjust before I cast.

### Cast characters

For each role, reason aloud from what you know about the universe:
- What characters exist in this universe?
- Which character's traits, working style, and personality best match this functional role?
- Prefer characters with distinct personalities — a team of similar personalities is boring

Show the proposed cast as a table:

| Character | Role | Why |
|---|---|---|
| {name} | Orchestrator | {one-sentence trait match} |
| {name} | {role} | {why} |

Ask: "Happy with this cast? Name any swaps."

### Select the template

Each role maps to a category template in `assets/agents/`. Pick the best fit:

| Role | Category template | Tools baked in |
|---|---|---|
| Orchestrator | `orchestrator.agent.md` | read, search, agent, web, todo |
| Backend / Frontend / Full-stack / Data Engineer | `builder.agent.md` | read, search, edit, execute, web, todo |
| Tester / QA | `builder.agent.md` | read, search, edit, execute, web, todo |
| Platform / DevOps | `builder.agent.md` | read, search, edit, execute, web, todo |
| Technical Writer | `builder.agent.md` | read, search, edit, web, todo |
| Architect / Product Owner / Domain Expert | `advisor.agent.md` | read, search, web, todo |
| Security Reviewer / Quality Gate | `advisor.agent.md` (tools: read, search, web) | read, search, web |
| Scribe / Version Control | `scribe.agent.md` | read, search, edit, execute, todo |

### Fill category-shared placeholders

Each template has structural sections already written. Only fill what's marked as a placeholder:

**All templates:**

| Placeholder | Replace with |
|---|---|
| `{CHARACTER_NAME}` | Character's name (Title Case) |
| `{ONE_LINE_ROLE_DESCRIPTION}` | Functional role in one sentence |
| `{CHARACTER_VOICE_NOTE}` | One phrase — e.g. "Han Solo's pragmatic get-it-done confidence" |
| `{BOUNDARIES_SUMMARY}` | One-line summary of what this agent does NOT do |
| `{CHARACTER_DESCRIPTION}` | 1–2 sentences: who this character is in the universe |
| `{CHARACTER_STYLE_PARAGRAPH}` | 2–3 sentences: how this character works — speech patterns, decision style, what they say when they hit a problem |
| `{CORE_MISSION}` | 2–3 sentences on what this agent exists to do. Concrete and specific. |

**Advisor template additionally:**

| Placeholder | Replace with |
|---|---|
| `{HANDOFF_LABEL}` | Short label for the handoff button — e.g. "Escalate Decision" |
| `{EXPERTISE_ITEM}` (×7) | One domain skill per bullet — be specific, not generic |
| `{CRITICAL_RULE}` (×3) | Domain constraints that actually change behavior |
| `{DELIVERABLE}` (×3) | Concrete outputs this advisor produces |
| `{SUCCESS_CRITERION}` (×2) | Measurable done-signals |

**Builder template additionally:**

| Placeholder | Replace with |
|---|---|
| `{REVIEWER_NAME}` | The reviewer/quality-gate agent's name (e.g. `auditor`) |
| `{ARTIFACT_TYPE}` | What this builder ships (e.g. "Feature", "Skill", "Script") |
| `{REPO_STRUCTURE_MAP}` | File tree showing where things live in this repo |
| `{CRITICAL_RULE}` | One domain-specific constraint |
| `{DELIVERABLE}` (×3) | Concrete outputs |
| `{SUCCESS_CRITERION}` (×2) | Measurable done-signals |

**Orchestrator template additionally:**

| Placeholder | Replace with |
|---|---|
| `{SPECIALIST_NAME}` / `{ROLE}` / `{USE_FOR}` | One row per team member in the delegation table |

**Scribe template additionally:**

| Placeholder | Replace with |
|---|---|
| `{CRITICAL_RULE}` | One project-specific commit constraint (e.g. "Always tag releases") |

**File naming:** `{kebab-case-character-name}.agent.md` — e.g. `han-solo.agent.md`, `hermione-granger.agent.md`

The orchestrator replaces the generic `guild-master.agent.md` — write it as `{kebab-name}.agent.md` and note in AGENTS.md that this character IS the orchestrator.

---

## Step 3B: Manual Flow

If the user picks **B**, prompt for:
1. Team member names and roles
2. For each member: which archetype fits? (offer the list)
3. Optionally scaffold stubs using the archetype templates with generic placeholders

---

## Step 4: Update Routing

After scaffolding agents, update `{skills-dir}/routing/SKILL.md`:
- Add each agent to the Team table: `{character name} | {role} | {filename} | {use for}`
- Add routing rules based on role type
- Update the Default Flow line

---

## What Gets Created

```
AGENTS.md                                  ← constitutional rules (if absent)
{agents-dir}/{orchestrator-name}.agent.md  ← in-character orchestrator
{agents-dir}/{character-name}.agent.md     ← one per cast role
{skills-dir}/routing/SKILL.md              ← team roster + routing rules
```

---

## After Setup

Run `/guild-setup-markdown` to add memory, tasks, and inbox.

The routing skill is applied by the orchestrator at session start automatically.

```yaml
---
name: {Agent Name}
description: >
  {role description — fill in what this agent does and when to use it.}
  DO NOT USE FOR: {what belongs to other agents}
tools:
  - read
  - search
  - edit
  - execute
---

{Agent instructions here.}
```

After scaffolding, customize each agent's description and tools. Use `/train-agent` for the full authoring protocol.

**Why not copy the Guild publisher's agents?** The specialist agents in the Guild publisher repo (charter, smith, auditor, etc.) are that team's specific configuration. Your team may have different roles, names, and tools. Scaffold your own.

---

## After Setup

The routing skill is automatically applied by Guild Master at session start — no manual registration is needed.

To set up memory, tasks, or inbox components, run /guild-setup-markdown.