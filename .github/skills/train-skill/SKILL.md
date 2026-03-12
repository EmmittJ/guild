---
name: train-skill
description: >
  Scaffold a new SKILL.md file following the agentskills.io open format. Use when asked to
  create a new skill, package a capability, or codify a process. Produces a correctly structured
  skill with frontmatter, progressive disclosure, and optional references directory.
license: MIT
metadata:
  asset: ../../../plugin/skills/train-skill/SKILL.md
  version: "0.1"
---

## When to Activate

- "create a skill for {capability}"
- "package {process} as a skill"
- "train the team to {do something}"
- "add a skill that teaches {topic}"

---

## What to Ask First

Before writing anything:

1. **Purpose** — what does this skill teach agents to do?
2. **Activation** — when should an agent load this skill? (used for the description field)
3. **Scope** — is this a short reference (~50 lines) or does it need a `references/` directory?
4. **Install location** — project-level or plugin?

---

## Skill File Format

```markdown
---
name: { kebab-case — must match the directory name }
description: >
  {Max ~1024 chars. Keyword-rich — this is what agents use to decide whether to activate
  the skill. Include: what it does, when to use it, what NOT to use it for.}
license: MIT
compatibility: { optional — tool/platform requirements }
metadata:
  version: "0.1"
allowed-tools: # optional — restrict which tools this skill permits
  - bash
  - read
---

{Body — what agents need to know to apply this skill.}
```

---

## Progressive Disclosure

Skills load in layers:

| What loads             | When                       | Token budget            |
| ---------------------- | -------------------------- | ----------------------- |
| `name` + `description` | Always, at startup         | ~100 tokens             |
| Full `SKILL.md` body   | When skill is activated    | ~500–2000 tokens        |
| `references/` files    | On demand, when referenced | Load only what's needed |
| `scripts/`, `assets/`  | On demand                  | Load only what's needed |

**Rules:**

- Keep `SKILL.md` under **500 lines** — move detail to `references/`
- The description must make sense alone — agents use it to decide whether to activate
- Heavy content (templates, examples, reference tables) goes in `references/`

---

## Directory Structure

```
skills/{name}/
  SKILL.md              ← required
  references/           ← optional: detailed docs, templates, lookup tables
    {topic}.md
  scripts/              ← optional: runnable scripts the skill uses
    {script}.sh
  assets/               ← optional: templates, config examples
    {template}.md
```

---

## Writing a Good Description

The description is the skill's activation key — agents match it against the current task.

```yaml
# Bad — vague, no keywords
description: Helps with code review.

# Good — specific, keyword-rich, includes DO NOT USE FOR
description: >
  GitHub PR review: comment style, suggest changes, identify security issues and logic bugs.
  Activate for: reviewing pull requests, checking diffs, giving code feedback.
  DO NOT USE FOR: implementing changes — use the engineer agent for that.
```

---

## After Writing the Skill

1. If the skill is long, move detailed sections to `references/` and link from SKILL.md
2. Add the skill to the `AGENTS.md` skills section if it's project-specific
3. If the skill should ship as a plugin, add it to `.github/plugin/marketplace.json`
