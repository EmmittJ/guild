# Agent Tooling Strategy: File Access & Execution Permissions

**Decision Date:** 2026-03-10  
**Decided By:** Charter (Product Owner)  
**Status:** DECIDED  
**Affected Agents:** All (Engineer, Smith, Invoker, Auditor, Scribe, Guild Master)  
**Audience:** All team members, especially Guild Master for agent routing  

---

## The Problem

Guild agents were provisioned with **execution tools only** (powershell, ash) but not **file manipulation tools** (create, dit, iew, delete). This creates a critical blocker:

- **Engineer can't edit code** — blocked on #13 and all implementation tasks
- **Smith can't write skills** — blocked on skill creation and updates
- **Invoker can't update manifests** — blocked on plugin.json and marketplace.json changes
- **Auditor can't review changes** — should be read-only anyway

**Root cause:** Agent configuration was incomplete; tool assignment was not systematically decided.

**Impact:** Agents are partially functional, with manual workarounds. Critical path work is blocked.

---

## Principles

Before defining tool access, we establish four guiding principles:

### 1. **Role-Based Access (RBAC)**
Tool access follows the agent's role, not vice versa:
- **Implementation agents** (Engineer, Smith, Invoker, Scribe): Need read + write
- **Coordination agents** (Guild Master): Need read + execute + decision-making
- **Review agents** (Auditor): Need read only
- **Specialized agents** (Charter): Need read + decision context

### 2. **Least Privilege for Safety**
Agents get tools needed for their role, nothing more:
- Auditor should not have edit access (prevents accidental commits)
- Engineer should not have commit/push access (Scribe handles git)
- Smith should not have skill deployment authority (Guild Master routes)
- Charter should not have execution access (clarity of concerns)

### 3. **Clear Failure Modes**
When an agent lacks a tool, it should:
- Recognize the limitation clearly
- Inform the user why it can't proceed
- Route to the correct specialist OR produce an artifact (e.g., a draft for another agent to edit)
- Never attempt workarounds that violate the principle

### 4. **Auditability**
All file modifications should be traceable:
- Implementation agents create/edit; Auditor reviews; Scribe commits with message
- No direct commits by implementation agents
- Clear log of "who changed what and why"

---

## Decisions

### A. Tool Assignment by Role

#### **Implementation Agents** (Need: read + write + execute)

**Engineer**
- **Current state:** ead, search, xecute
- **Missing:** create, dit, delete
- **Decision:** Grant create, dit, delete
- **Scope:** Creates files, edits code/scripts, deletes unused artifacts
- **Boundary:** Does NOT commit; does NOT modify agent files directly (routes to Guild Master); does NOT validate manifests (routes to Invoker)

**Smith (Skill Writer)**
- **Current state:** ead, search, 	odo
- **Missing:** create, dit, delete
- **Decision:** Grant create, dit, delete
- **Scope:** Writes SKILL.md files, creates/edits references/, scripts/, assets/
- **Boundary:** Does NOT implement the capability (routes to Engineer); does NOT create agent files

**Invoker (CLI Specialist)**
- **Current state:** ead, search, web
- **Missing:** create, dit, delete
- **Decision:** Grant create, dit, delete
- **Scope:** Writes plugin.json, marketplace.json, validates CLI compatibility
- **Boundary:** Does NOT implement skill content (routes to Smith); does NOT manage GitHub Actions/non-CLI work

**Scribe (Version Control)**
- **Current state:** (implied) xecute (git commands)
- **Missing:** Nothing — Scribe *only* commits; does not create arbitrary files
- **Decision:** Scribe keeps execute-only; use git commands to create/modify files during commit
- **Scope:** Commits, tags, branches, PRs; all changes are reviewed first
- **Boundary:** Does NOT implement; does NOT review (routes to Auditor before commit)

---

#### **Review Agent** (Need: read only)

**Auditor**
- **Current state:** ead, search
- **Decision:** Keep read-only; grant NO write access
- **Scope:** Reviews Engineer changes, Smith skills, Invoker manifests, scripts
- **Boundary:** Does NOT modify anything; does NOT implement
- **Rationale:** Auditor acts as quality gate. Write access creates conflict of interest (auditor reviews own changes). Gate effectiveness depends on independence.

---

#### **Coordination Agent** (Need: read + execute + memory)

**Guild Master**
- **Current state:** (assumed) ead, xecute, memory skills
- **Decision:** Keep as is; focus on orchestration, not file creation
- **Scope:** Routes work, monitors issue lifecycle, calls other agents
- **Boundary:** Does NOT implement code/skills directly (delegates to Engineer/Smith); does NOT commit (routes to Scribe)
- **Note:** Can read files for context; can execute scripts for diagnostics; can't modify code

---

#### **Product Owner** (Need: read + memory + decision)

**Charter**
- **Current state:** (implied) read, memory skills, decision tools
- **Decision:** Keep as is; focus on requirements and decisions
- **Scope:** Defines user stories, acceptance criteria, backlog prioritization; makes product decisions
- **Boundary:** Does NOT implement code; does NOT commit; does NOT execute arbitrary commands
- **Note:** Can read files for context; can create decisions/insights via memory skills

---

### B. Tool Definitions (for all agents to understand)

| Tool | Purpose | Agents |
|------|---------|--------|
| ead | View file contents, list directories | All agents |
| search | Text search, code search, file glob | All agents except Charter |
| create | Write new files | Engineer, Smith, Invoker |
| dit | Modify existing files | Engineer, Smith, Invoker |
| delete | Remove files/directories | Engineer, Smith, Invoker |
| xecute (shell) | Run commands, scripts | Engineer, Scribe, Guild Master, Auditor (read-only scripts only) |
| memory:* | Read/create decisions, insights, etc. | All agents (read) + Charter, Guild Master (create) |
| 	ask:* | Read/create backlog items | All agents (read) + Charter, Guild Master (create) |
| inbox:* | Send/receive agent messages | All agents |

---

### C. Access Model: How Enforcement Works

**Responsibility: Agent Configuration (Declarative)**

Each agent's .agent.md file declares its tools in the frontmatter:

`yaml
---
name: engineer
tools:
  - read
  - search
  - create
  - edit
  - delete
  - execute
handoffs:
  - label: Review Changes
    agent: auditor
---
`

When an agent is invoked, the runtime provides only declared tools. Attempting to use an undeclared tool results in:
- Error message: "I don't have access to {tool}. I should route this to {specialist}."
- Clear guidance on next steps

**Responsibility: Agent Prompt Instructions (Behavioral)**

Each agent's instructions include a "Tools & Boundaries" section that describes:
1. What tools they have
2. Why they have each tool
3. What to do when they lack a tool
4. Who to route to for different types of work

Example:

`markdown
## My Tools & Boundaries

I have: ead, search, create, dit, delete, xecute

I use these to:
- Create and edit code files, scripts, and configuration
- Search the codebase for patterns and context
- Run builds and tests locally
- Hand off to Auditor for review before shipping

I DON'T have: git operations, manifest validation, skill design

If I need to:
- Validate a plugin.json → Route to invoker
- Design a skill structure → Route to smith
- Commit changes → Hand off to auditor, then scribe
`

---

### D. How Agents Handle Limitations

All agents should follow this pattern when encountering a limitation:

**Pattern: Limitation → Clarification → Route or Artifact**

`
I don't have [tool], which is needed to [action].

I should [produce an artifact OR route to specialist]:
1. Produce a draft and ask [specialist] to [complete the action]
2. Route to [specialist] with context about what's needed

For example:
- "I can't write the SKILL.md. Here's the structure and references. Route to Smith to finalize."
- "I can't validate the manifest. Invoker should check this plugin.json before I proceed."
- "I can't commit. Auditor will review these changes, then Scribe will commit."
`

**This ensures:**
- No workarounds that violate the access model
- Clear handoff points
- No ambiguity about who does what
- Agents stay in their lane

---

## Acceptance Criteria

This decision is complete when:

1. **Agent config files updated** — All .agent.md files have explicit 	ools: section
   - [ ] Engineer: has create, dit, delete
   - [ ] Smith: has create, dit, delete
   - [ ] Invoker: has create, dit, delete
   - [ ] Auditor: has NO create, dit, delete (read-only verified)
   - [ ] Scribe: has xecute (git commands only)
   - [ ] Guild Master: has ead, xecute, memory skills
   - [ ] Charter: has ead, memory, task skills

2. **Agent instructions updated** — Each agent has a "Tools & Boundaries" section in their agent file
   - [ ] Documents what tools they have
   - [ ] Explains what to do when lacking a tool
   - [ ] Routes to the correct specialist

3. **Agent training updated** — 	rain-agent skill updated with tooling checklist
   - [ ] New agents get clear guidance on tool assignment
   - [ ] Includes checklist: "Does this agent need create? Why?"
   - [ ] Includes example patterns for "I don't have X" messages

4. **Blocking issues resolved** — Engineer can now:
   - [ ] Create files (task #13 unblocked)
   - [ ] Edit code files
   - [ ] Create scripts
   - [ ] All implementation work flows: Engineer → Auditor → Scribe → commit

5. **Documentation updated** — AGENTS.md reflects the new model
   - [ ] Tool access table added
   - [ ] Roles and boundaries clarified
   - [ ] Example handoff patterns shown

---

## Impact Analysis

### Who This Affects

- **Engineer:** ✓ Unblocked on all code creation/editing work
- **Smith:** ✓ Unblocked on skill writing
- **Invoker:** ✓ Unblocked on manifest management
- **Auditor:** ✓ Maintains independence (read-only verified)
- **Scribe:** ✓ Remains clear separation (git-only)
- **Guild Master:** ✓ Better routing based on tool availability
- **Charter:** ✓ Can focus on requirements, not implementation

### Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Engineer accidentally commits code | Scribe commits only; Engineer knows not to attempt git |
| Smith implements when designing | Smith instructions clarify boundary; route to Engineer for implementation |
| Auditor modifies code during review | Auditor has no edit tools; can't modify even if tempted |
| Agent misses tool and stalls | Clear error messages + routing guidance |
| Too many tool combinations | Use predefined patterns (e.g., "implementation agent" = read+write+execute) |

### Benefits

1. **Unblocks critical work** — Engineer, Smith, Invoker can all implement
2. **Clear boundaries** — No ambiguity about who does what
3. **Better auditing** — Every change flows through review gate
4. **Safer defaults** — Least privilege principle reduces risk
5. **Scalable** — New agents can follow the same pattern
6. **Self-documenting** — Agent files declare their capabilities

---

## Implementation Checklist

### Phase 1: Update Agent Configurations (Guild Master/Engineer)
- [ ] Update .github/agents/engineer.agent.md with tools + boundaries
- [ ] Update .github/agents/smith.agent.md with tools + boundaries
- [ ] Update .github/agents/invoker.agent.md with tools + boundaries
- [ ] Update .github/agents/auditor.agent.md with explicit "read-only" note
- [ ] Update .github/agents/scribe.agent.md with git-only scope
- [ ] Update .github/agents/guild-master.agent.md with orchestration-only scope
- [ ] Update .github/agents/charter.agent.md with decision/requirements scope

### Phase 2: Update Agent Training
- [ ] Update 	rain-agent skill with tool assignment checklist
- [ ] Add examples: "What tools should a linter agent have?"
- [ ] Document the pattern: "Implementation agent = read+write+execute"

### Phase 3: Update Documentation
- [ ] Update AGENTS.md with tool access table
- [ ] Add "Tools & Boundaries" section to AGENTS.md
- [ ] Create quick reference: "I need to [action], who should I route to?"

### Phase 4: Verify & Test
- [ ] Engineer attempts a code creation task (should succeed)
- [ ] Smith attempts a skill writing task (should succeed)
- [ ] Auditor attempts to edit a file (should fail with clear error)
- [ ] Full workflow: Engineer → Auditor → Scribe → commit (should complete)

---

## Related Decisions

- **Guild Master Lifecycle Ownership** (2026-03-12): Guild Master monitors issue states and routes work
- **Documentation Release Structure** (2026-03-13): Charter decides release notes; artifacts flow through review
- **Agent Training** (in progress): How new agents learn their role

---

## Questions & Answers

**Q: Why doesn't Auditor have edit access? They could fix small things.**  
A: Auditor's value is independence. If Auditor can edit, they review their own changes (conflict of interest). Clarity wins. If a small fix is needed, Engineer makes it, then Auditor reviews again.

**Q: What if Engineer needs to commit quickly?**  
A: They don't have commit access for a reason. If it's truly urgent, Scribe can fast-track the review. This maintains the gate and prevents accidental bad commits.

**Q: Can Smith implement part of a skill?**  
A: No. Smith designs the skill (SKILL.md + references). Engineer implements the capability (code/scripts). This keeps concerns separated and makes skills portable.

**Q: What if a new agent needs a tool not in the predefined set?**  
A: Use the 	rain-agent skill to decide. Ask: "What's their role? Can existing tools serve it? If not, why?" New tool types should be rare.

**Q: How do agents report "I don't have the tool I need"?**  
A: With a clear message: "I lack [tool] for [reason]. I should [action]." See "Limitation Handling Pattern" above.

---

## Success Criteria (What Done Looks Like)

After implementation:

✓ Engineer creates a file without asking permission (blocked on #13 is now unblocked)  
✓ Smith writes a new SKILL.md without workarounds  
✓ Invoker updates plugin.json without manual intervention  
✓ Auditor reviews changes but can't accidentally modify them  
✓ Scribe commits with confidence (all changes pre-reviewed)  
✓ New agent trained with clear tool checklist  
✓ Agent documentation is self-documenting (frontmatter shows capabilities)  
✓ All workflows complete without manual tool provisioning  

---

## References

- **AGENTS.md** — Current agent definitions (to be updated)
- **train-agent skill** — Agent creation and training
- **Agent files:** .github/agents/*.agent.md
- **Issue #13:** Blocking issue (Engineer can't edit)

