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
2. **Universe + team size** — pick a fictional universe and team size
3. **Cast the team** — derive roles from stack, cast characters, scaffold agents
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
Agent path detected: {.github/agents | .claude/agents | .agents | none}
```

Use the detected agent path to set `{agents-dir}`. If `.claude/agents/` exists (Claude Code), default to that. If `.github/agents/` exists, default to that. If neither exists, default to `.github/agents/`.

---

## Step 2: Present Discovery + Ask for Universe

Show the user a brief summary of what was found, then ask for their universe and team size:

> I found a **{type}** project using **{stack}**. Here's what I'll base the team on:
>
> - Stack: {stack}
> - Tests: {test runner}
> - CI: {ci system}
> - Docs: {present/absent}
> - Agent files will go in: `{agents-dir}` ← change this if wrong (e.g. `.claude/agents/` for Claude Code)
>
> What universe do you want your team cast from? (Any show, film, book, game — no limits)
> How many agents? (default: 5, including your orchestrator)

---

## Step 3: Cast the Team

Once you have a universe and team size:

### Suggest roles from the stack

Based on the discovery summary, suggest N−1 specialist roles to complement the orchestrator. Use the table below as a menu of common roles — propose whichever ones fit the project, but the user can pick, drop, or invent roles freely:

| Role                | Good fit when                                        |
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

Present suggestions and let the user shape the final roster:

> Based on your **{type}** project in **{stack}**, here are my suggested roles:
>
> - Orchestrator
> - {role 2}
> - ...
>
> Add, drop, or swap any of these before I cast.

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

Pick the best-fit template from `assets/agents/` based on what the role does:

- **`orchestrator.agent.md`** — the team lead; routes work, tracks decisions, delegates to specialists. Use for exactly one agent per team.
- **`builder.agent.md`** — any agent that directly produces artifacts: code, scripts, configs, infrastructure. Use for engineers, QA, DevOps, security, and similar hands-on roles.
- **`advisor.agent.md`** — any agent whose primary output is guidance, review, or domain expertise rather than production artifacts.
- **`scribe.agent.md`** — the agent that owns version control: commits, branches, pull requests.

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
| `{ORCHESTRATOR_NAME}`      | The orchestrator agent's name, e.g. guild-master or your themed name                                            |
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

## Step 4: Update Routing

After scaffolding agents, update `{skills-dir}/routing/SKILL.md`:

- Add each agent to the Team table: `{character name} | {role} | {filename} | {use for}`
- Add routing rules based on role type
- Update the Default Flow line

---

## Step 5: Install Components

After scaffolding the team, ask which persistence components to install. Issue tracking, memory, and inbox are separate concerns — choose the combination that fits your team. Beads covers all three; markdown components are à la carte; GitHub Issues covers task tracking only and pairs with markdown memory + inbox.

### Step 5A: Beads (Recommended)

> Do you want to use **beads** for issue tracking and memory?
> Beads stores decisions, insights, and issues in a Dolt database with Git-like version control.
> Requires: `bd` CLI v0.47.0+ (`bd --version`)

If yes:

1. **Verify prerequisites**: `bd --version` must return v0.47.0+
2. **Initialize** (if not already done): `bd init`
3. **Enable custom types**: `bd config set types.custom "agent,role,decision,insight"`
4. **Enable auto-commit**: `bd config set dolt.auto-commit on`
5. **Configure Dolt remote** for data persistence across clones:

```bash
# Use the same GitHub repo (stores data under refs/dolt/data, separate from git refs)
bd dolt remote add origin https://github.com/{owner}/{repo}.git

# Or use SSH if the repo uses SSH
bd dolt remote add origin git+ssh://git@github.com/{owner}/{repo}.git

# Push initial data
bd dolt push
```

6. **Register agents and roles** — see [references/beads-setup.md](assets/references/beads-setup.md) for the full workflow
7. **Install the beads skill**:

```
{skills-dir}/beads/SKILL.md    ← from assets/skills/beads/
```

> **Why a Dolt remote?** Without one, `.beads/dolt/` is gitignored and local-only.
> On a fresh clone, `bd list` auto-bootstraps from the Dolt remote — all issues,
> decisions, and agent registrations are preserved.

### Step 5B: Markdown Components (Lightweight)

> Do you want to use markdown-based memory, issues, or inbox components instead?
> (none / memory / issues / inbox / all)

For each selected component, prompt for:

- **Where skills live** — default `.github/skills`
- **Root path** for each component:
  - Memory → `.agents/memory`
  - Issues → `.agents/issues`
  - Inbox → `.agents/inbox`

**Memory component:**

```
.agents/memory/
  decisions/_summary.md
  insights/
  context/
{skills-dir}/markdown-memory/SKILL.md
```

**Issues component:**

```
.agents/issues/
  open/
  in_progress/
  closed/
{skills-dir}/markdown-issues/SKILL.md
```

**Inbox component:**

```
.agents/inbox/              ← agent subdirs created on first message
{skills-dir}/markdown-inbox/SKILL.md
```

### Step 5C: GitHub Issues (issue tracking component)

> Do you want to use GitHub Issues for task tracking?
> GitHub Issues covers tasks and work items only — it has no equivalent for memory (decisions, insights, context) or agent inbox. If you need those, also install memory and inbox from Step 5B alongside this.
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

# From Step 5A (beads — recommended):
{skills-dir}/beads/SKILL.md                ← beads skill (from assets/skills/beads/)
.beads/                                    ← Dolt database (initialized by bd init)

# From Step 5B (markdown — lightweight):
.agents/memory/decisions/_summary.md        ← memory component
.agents/memory/insights/
.agents/memory/context/
{skills-dir}/markdown-memory/SKILL.md

.agents/issues/open/                        ← issues component
.agents/issues/in_progress/
.agents/issues/closed/
{skills-dir}/markdown-issues/SKILL.md

.agents/inbox/                              ← inbox component (subdirs on first message)
{skills-dir}/markdown-inbox/SKILL.md

# From Step 5C (GitHub Issues — issue tracking only; pair with Step 5B memory + inbox for full persistence):
{skills-dir}/github-issues/SKILL.md        ← GitHub-backed, repo slug baked in
```

---

## After Setup

Guild Master applies all installed skills automatically at session start — no registration or AGENTS.md updates needed.

The routing skill drives orchestration. Edit `.github/skills/routing/SKILL.md` to adjust your team roster or routing rules.
