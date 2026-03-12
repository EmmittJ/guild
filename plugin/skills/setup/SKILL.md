---
name: setup
description: >
  Bootstrap Guild into any repo — team scaffolding and optional component installation.
  Scaffolds AGENTS.md, the routing skill, the orchestrator agent, and optionally a full cast
  team. Also installs markdown-based memory, issue tracking, and inbox components, or switches
  to GitHub Issues as the task backend.
  Activate when: setting up Guild in a repo for the first time; adding the routing skill to
  an existing repo; casting a themed team from a universe; installing memory, issues, or inbox;
  the user says "/guild:setup" or "/setup".
license: MIT
metadata:
  version: "0.4"
---

## Asset Sources

| Installed file                          | Source asset                                                                                 |
| --------------------------------------- | -------------------------------------------------------------------------------------------- |
| `{skills-dir}/routing/SKILL.md`         | `assets/skills/routing/SKILL.md`                                                             |
| `{skills-dir}/markdown-memory/SKILL.md` | `assets/skills/markdown-memory/SKILL.md`                                                     |
| `{skills-dir}/markdown-inbox/SKILL.md`  | `assets/skills/markdown-inbox/SKILL.md`                                                      |
| `{skills-dir}/markdown-issues/SKILL.md` | `assets/skills/markdown-issues/SKILL.md`                                                     |
| `{skills-dir}/github-issues/SKILL.md`   | `assets/skills/github-issues/SKILL.md` ← replaces markdown issues if GitHub backend selected |
| `{agents-dir}/{name}.agent.md`          | `assets/agents/{orchestrator\|builder\|advisor\|scribe}.agent.md`                            |

**When editing the routing skill:** also update the asset. The routing skill's frontmatter has
`metadata.asset:` pointing to its asset counterpart — use that as the sync signal.

> **Variable defaults:** `{skills-dir}` = `.github/skills` · `{agents-dir}` = `.github/agents`
> Both can be changed when running `/guild:setup` — these are the defaults used when nothing is specified.

---

## What This Does

`/guild-setup` (or `/setup`) is interactive. Steps:

1. **Discover the codebase** — silent scan before asking anything
2. **Casting choice** — manual team definition or universe casting
3. **Team size** — how many agents (default 5 including orchestrator)
4. **Routing rules** — confirm or adjust routing patterns
5. **Install components** — markdown memory/issues/inbox and/or GitHub Issues backend

---

## Step 1: Discover the Codebase

Before prompting the user, silently scan:

| What to look for     | How                                                                                                          |
| -------------------- | ------------------------------------------------------------------------------------------------------------ |
| Language + framework | `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `composer.json`, `Gemfile`, `build.gradle`         |
| Architecture pattern | Directory structure: `src/`, `apps/`, `packages/`, `services/`, `infra/`, `Dockerfile`, `docker-compose.yml` |
| Test runner          | `jest`, `pytest`, `vitest`, `rspec`, `cargo test`, `go test` references in config files                      |
| CI system            | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml`                                 |
| Docs                 | `docs/`, `README.md`, `CONTRIBUTING.md`                                                                      |
| Security surface     | Auth files, public API routes, file uploads, user-controlled input patterns                                  |
| Existing agents      | `.github/agents/` — note covered roles; don't re-scaffold what exists                                        |

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
>
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

| Role                | Cast when                                            |
| ------------------- | ---------------------------------------------------- |
| Orchestrator        | Always — 1 per team                                  |
| Backend Engineer    | Server code, API routes, databases present           |
| Frontend Engineer   | UI components, CSS, React/Vue/Svelte/etc. present    |
| Full-stack Engineer | Small team + both frontend and backend present       |
| Data Engineer       | ORM migrations, analytics, ETL, heavy query patterns |
| Platform / DevOps   | Dockerfile, CI config, infra-as-code present         |
| Tester / QA         | Test directory present or notable gap                |
| Security Engineer   | Public API, auth code, sensitive data handling       |
| Technical Writer    | `docs/` present, SDK, developer-facing library       |
| Scribe              | Always valuable for commit/PR discipline             |

Present the proposed roles before casting:

> For a **{type}** project in **{stack}**, I'd cast these {N} roles:
>
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

| Character | Role         | Why                        |
| --------- | ------------ | -------------------------- |
| {name}    | Orchestrator | {one-sentence trait match} |
| {name}    | {role}       | {why}                      |

Ask: "Happy with this cast? Name any swaps."

### Select the template

Each role maps to a category template in `assets/agents/`. Pick the best fit:

| Role                                            | Category template       |
| ----------------------------------------------- | ----------------------- |
| Orchestrator                                    | `orchestrator.agent.md` |
| Backend / Frontend / Full-stack / Data Engineer | `builder.agent.md`      |
| Tester / QA                                     | `builder.agent.md`      |
| Security Engineer                               | `builder.agent.md`      |
| Platform / DevOps                               | `builder.agent.md`      |

Each template has structural sections already written. Only fill what's marked as a placeholder:

**All templates:**

| Placeholder                   | Replace with                                                                                                     |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `{CHARACTER_NAME}`            | Character's name (Title Case)                                                                                    |
| `{ONE_LINE_ROLE_DESCRIPTION}` | Functional role in one sentence                                                                                  |
| `{CHARACTER_VOICE_NOTE}`      | One phrase — e.g. "Han Solo's pragmatic get-it-done confidence"                                                  |
| `{BOUNDARIES_SUMMARY}`        | One-line summary of what this agent does NOT do                                                                  |
| `{CHARACTER_DESCRIPTION}`     | 1–2 sentences: who this character is in the universe                                                             |
| `{CHARACTER_STYLE_PARAGRAPH}` | 2–3 sentences: how this character works — speech patterns, decision style, what they say when they hit a problem |
| `{CORE_MISSION}`              | 2–3 sentences on what this agent exists to do. Concrete and specific.                                            |

**Advisor template additionally:**

| Placeholder                | Replace with                                                                                                     |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `{HANDOFF_PROMPT}`         | One sentence telling the reviewer what to check — e.g. "Review changes to {artifact} for correctness and style." |
| `{HANDOFF_LABEL}`          | Short label for the handoff button — e.g. "Escalate Decision"                                                    |
| `{EXPERTISE_ITEM}` (×7)    | One domain skill per bullet — be specific, not generic                                                           |
| `{CRITICAL_RULE}` (×3)     | Domain constraints that actually change behavior                                                                 |
| `{DELIVERABLE}` (×3)       | Concrete outputs this advisor produces                                                                           |
| `{SUCCESS_CRITERION}` (×2) | Measurable done-signals                                                                                          |

**Builder template additionally:**

| Placeholder                | Replace with                                                                                                     |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `{HANDOFF_PROMPT}`         | One sentence telling the reviewer what to check — e.g. "Review changes to {artifact} for correctness and style." |
| `{ARTIFACT_TYPE}`          | What this builder ships (e.g. "Feature", "Skill", "Script")                                                      |
| `{REPO_STRUCTURE_MAP}`     | File tree showing where things live in this repo                                                                 |
| `{CRITICAL_RULE}`          | One domain-specific constraint                                                                                   |
| `{DELIVERABLE}` (×3)       | Concrete outputs                                                                                                 |
| `{SUCCESS_CRITERION}` (×2) | Measurable done-signals                                                                                          |

**Orchestrator template additionally:**

| Placeholder                                  | Replace with                                    |
| -------------------------------------------- | ----------------------------------------------- |
| `{SPECIALIST_NAME}` / `{ROLE}` / `{USE_FOR}` | One row per team member in the delegation table |

**Scribe template additionally:**

| Placeholder       | Replace with                                                        |
| ----------------- | ------------------------------------------------------------------- |
| `{CRITICAL_RULE}` | One project-specific commit constraint (e.g. "Always tag releases") |

**File naming:** `{kebab-case-character-name}.agent.md` — e.g. `han-solo.agent.md`, `hermione-granger.agent.md`

The orchestrator replaces the generic `guild-master.agent.md` — write it as `{kebab-name}.agent.md` and note in AGENTS.md that this character IS the orchestrator.

---

## Step 3B: Manual Flow

If the user picks **B**:

### Ask for team size and roles

> How many agents do you want? (default: 5, including your orchestrator)
> For each team member, I'll need a **display name** and a **role**.

Collect the following for each member:

| Prompt                              | Example                                                   |
| ----------------------------------- | --------------------------------------------------------- |
| Display name (shown in chat picker) | `Alex`, `The Reviewer`, `Ops Bot`                         |
| Role / function in one sentence     | "Handles backend API development and database migrations" |

After collecting the full list, confirm before proceeding:

> Here's your team:
>
> | Name   | Role   |
> | ------ | ------ |
> | {name} | {role} |
> | ...    | ...    |
>
> Ready to scaffold? You can rename or swap roles before I start.

### Select the template

For each team member, map their role to the best-fit category template in `assets/agents/`:

| Role                                            | Category template       |
| ----------------------------------------------- | ----------------------- |
| Orchestrator                                    | `orchestrator.agent.md` |
| Backend / Frontend / Full-stack / Data Engineer | `builder.agent.md`      |
| Tester / QA                                     | `builder.agent.md`      |
| Security Engineer                               | `builder.agent.md`      |
| Platform / DevOps                               | `builder.agent.md`      |

### Fill placeholders

Use the same placeholder tables documented in Step 3A — **All templates**, **Advisor**, **Builder**, **Orchestrator**, and **Scribe** sections.

For manual teams, the character-flavored placeholders still apply — just use the team member's display name and role description instead of a fictional character:

- `{CHARACTER_NAME}` → the display name (e.g. `Alex`)
- `{CHARACTER_VOICE_NOTE}` → a brief working-style note (e.g. "direct and methodical")
- `{CHARACTER_DESCRIPTION}` → skip or write a one-liner about how this person approaches the role
- `{CHARACTER_STYLE_PARAGRAPH}` → describe tone and decision style in 2–3 sentences

All other structural placeholders (`{CORE_MISSION}`, `{DELIVERABLE}`, `{CRITICAL_RULE}`, etc.) fill the same way as in universe casting.

### File naming and orchestrator note

**File naming:** `{kebab-case-name}.agent.md` — e.g. `alex.agent.md`, `ops-bot.agent.md`

The orchestrator replaces the generic `guild-master.agent.md` — write it as `{kebab-name}.agent.md` and note in AGENTS.md that this agent IS the orchestrator.

---

## Step 4: Update Routing

After scaffolding agents, update `{skills-dir}/routing/SKILL.md`:

- Add each agent to the Team table: `{character name} | {role} | {filename} | {use for}`
- Add routing rules based on role type
- Update the Default Flow line

---

## Step 5: Install Components

After scaffolding the team, ask whether to install Guild components.

### Step 5A: Markdown Components

> Do you want to install markdown-based memory, issues, or inbox components?
> (none / memory / issues / inbox / all)

For each selected component, prompt for:

- **Where skills live** — default `.github/skills`
- **Root path** for each component:
  - Memory → `.guild/memory`
  - Issues → `.guild/issues`
  - Inbox → `.guild/inbox`

**Memory component:**

```
.guild/memory/
  decisions/_summary.md
  insights/
  context/
{skills-dir}/markdown-memory/SKILL.md
```

**Issues component:**

```
.guild/issues/
  open/
  in_progress/
  closed/
{skills-dir}/markdown-issues/SKILL.md
```

**Inbox component:**

```
.guild/inbox/              ← agent subdirs created on first message
{skills-dir}/markdown-inbox/SKILL.md
```

### Step 5B: GitHub Issues Backend (optional)

> Do you want to use GitHub Issues instead of markdown files for task tracking?
> Requires `gh` CLI.

If yes:

- Check prerequisites: `gh` CLI installed and authenticated (`gh auth status`)
- Prompt for:
  - **Where skills live** — default `.github/skills`
  - **Repo slug** (`owner/repo`) — auto-detect via `gh repo view --json nameWithOwner -q .nameWithOwner`; user may override
- Creates 5 GitHub labels (using `gh label create --force`):

| Label             | Color     | Meaning             |
| ----------------- | --------- | ------------------- |
| `in-progress`     | `#e4e669` | Claimed by an agent |
| `blocked`         | `#d73a4a` | Cannot proceed      |
| `priority:high`   | `#b60205` | Urgent              |
| `priority:medium` | `#fbca04` | Normal priority     |
| `priority:low`    | `#cfd3d7` | Nice-to-have        |

- Copies `github-issues/SKILL.md` with repo slug baked in (replaces any markdown issues skill)

### Running the Scripts

Step 5 is implemented via scripts in `setup/scripts/`:

| Script                                     | Purpose                                   |
| ------------------------------------------ | ----------------------------------------- |
| `setup-markdown.sh` / `setup-markdown.ps1` | Markdown components (memory/issues/inbox) |
| `setup-github.sh` / `setup-github.ps1`     | GitHub Issues backend                     |

**Unix / macOS / WSL:**

```sh
sh scripts/setup-markdown.sh /path/to/repo
sh scripts/setup-github.sh /path/to/repo
```

**Windows PowerShell:**

```powershell
.\scripts\setup-markdown.ps1 -RepoRoot C:\path\to\repo
.\scripts\setup-github.ps1 -RepoRoot C:\path\to\repo
```

**CI env vars for `setup-github`:** `GUILD_SKILLS_DIR`, `GUILD_REPO` (required in CI)

**CI env vars for `setup-markdown`:** `GUILD_COMPONENTS`, `GUILD_SKILLS_DIR`, `GUILD_MEMORY_ROOT`, `GUILD_ISSUES_ROOT`, `GUILD_INBOX_ROOT`

---

## What Gets Created

```
AGENTS.md                                  ← constitutional rules (if absent)
{agents-dir}/{orchestrator-name}.agent.md  ← in-character orchestrator
{agents-dir}/{character-name}.agent.md     ← one per cast role
{skills-dir}/routing/SKILL.md              ← team roster + routing rules

# Optional — from Step 5A:
.guild/memory/decisions/_summary.md        ← memory component
.guild/memory/insights/
.guild/memory/context/
{skills-dir}/markdown-memory/SKILL.md

.guild/issues/open/                        ← issues component
.guild/issues/in_progress/
.guild/issues/closed/
{skills-dir}/github-issues/SKILL.md

.guild/inbox/                              ← inbox component (subdirs on first message)
{skills-dir}/markdown-inbox/SKILL.md

# Optional — from Step 5B (replaces markdown issues):
{skills-dir}/github-issues/SKILL.md        ← GitHub-backed, repo slug baked in
```

---

## After Setup

Guild Master applies all installed skills automatically at session start — no registration or AGENTS.md updates needed.

The routing skill drives orchestration. Edit `.github/skills/routing/SKILL.md` to adjust your team roster or routing rules.
