# Agent Tooling Strategy — Decision Summary

**Decided:** 2026-03-10  
**Status:** DECIDED  
**Owner:** Charter (decision maker); Guild Master (enforcement)  
**Blocking Issue:** #13 (Engineer can't edit code)

---

## In One Sentence

**Every agent gets exactly the tools they need for their role, no more, no less.**

---

## The Problem

- Engineer has ead, search, xecute but NOT create, dit, delete — can't implement code
- Smith has ead, search but NOT create, dit — can't write skills
- Invoker has ead, search but NOT create, dit, delete — can't update manifests
- Auditor should be read-only but status was unclear
- No systematic way to decide tool access for new agents

**Impact:** Critical implementation work is blocked; agent roles are ambiguous.

---

## What Was Decided

### Tool Assignment by Role

| Role | Tools | Why |
|------|-------|-----|
| **Engineer** | read, search, create, edit, delete, execute | Implements code, creates files, edits scripts |
| **Smith** | read, search, create, edit, delete | Writes skills, creates references, designs protocols |
| **Invoker** | read, search, create, edit, delete, execute | Writes/validates manifests, CLI compatibility |
| **Auditor** | read, search ONLY | Reviews work independently; no conflicts of interest |
| **Scribe** | execute (git only) | Commits after review; doesn't implement |
| **Guild Master** | read, execute, memory, task | Orchestrates; routes work; doesn't implement |
| **Charter** | read, memory, task | Defines requirements; doesn't implement |

### Four Core Principles

1. **Role-Based Access:** Tool access follows role, not the other way
2. **Least Privilege:** Each agent gets exactly what they need
3. **Clear Failure Modes:** When lacking a tool, agents route to the right specialist
4. **Auditability:** All changes traced (implement → review → commit)

### How It Works

`
Engineer creates/edits code
    ↓
Auditor reviews (read-only; can't modify)
    ↓
Scribe commits (execute only; no file modification)
    ↓
Git history: clean audit trail
`

---

## What This Unblocks

✓ **#13:** Engineer can now create and edit code files  
✓ **#14+:** Smith can write new skills  
✓ **#15+:** Invoker can manage manifests  
✓ **All implementation work:** Clear path from task → implementation → review → commit  

---

## Implementation (Quick Timeline)

1. **Phase 1 (1-2 hours):** Update agent config files with 	ools: section
   - Add to each agent's .agent.md file
   - Add "Tools & Boundaries" instructions
   - Example: Engineer frontmatter now declares create, dit, delete

2. **Phase 2 (30 min):** Update train-agent skill with tooling checklist
   - New agents can follow a clear pattern
   - Includes decision framework

3. **Phase 3 (30 min):** Update AGENTS.md with tool matrix
   - Documentation shows who has what
   - Includes error handling patterns

4. **Phase 4 (1-2 hours):** Test everything
   - Engineer can create files ✓
   - Smith can write skills ✓
   - Auditor stays read-only ✓
   - Full workflow works ✓

**Total time to unblock:** ~4-5 hours  
**Expected completion:** Same day (if Engineer picks up after Phase 3)

---

## Key Decisions

### **Engineer Gets create, dit, delete**
Engineers need these to implement code, edit scripts, and manage files. They do NOT get git access (Scribe commits).

**Boundary:** Engineer produces code; Auditor reviews; Scribe commits.

### **Auditor Stays Read-Only**
Auditor should have no write access to maintain independence and prevent conflicts of interest. If Auditor finds a bug, they report it; Engineer fixes it; Auditor reviews again.

**Boundary:** Auditor reviews but never modifies.

### **Scribe Handles Git Only**
Scribe has xecute (git commands only), not create/dit. Changes are already approved by Auditor; Scribe just commits them.

**Boundary:** Scribe commits what's already reviewed; no implementation.

### **Smith Writes Skills, Not Code**
Smith writes SKILL.md files (protocol), not implementation code. If a skill needs code, Engineer implements it.

**Boundary:** Smith designs; Engineer implements.

### **Invoker Validates Manifests**
Invoker writes and validates plugin.json and marketplace.json. They do not implement the skills/agents declared in the manifest.

**Boundary:** Invoker validates; Engineer/Smith implements.

---

## Handling Limitations

When an agent lacks a tool, they:

1. **Recognize it:** "I don't have [tool]"
2. **Explain:** "...because [reason]"
3. **Route or draft:** "I should [produce a draft] OR [route to specialist]"

Examples:

- **Engineer needs manifest validation:** "Manifest is created. Invoker should validate before I proceed."
- **Smith needs implementation:** "Skill designed. Engineer should implement the code."
- **Auditor finds a bug:** "Found issue on line 42. Engineer needs to fix; I'll review again."
- **Invoker finds code issues:** "Manifest valid. Skill code needs Engineer review."

---

## What Agents DON'T Do

| Agent | Does NOT... |
|-------|-----------|
| Engineer | Commit, write skills, validate manifests, review changes |
| Smith | Implement code, create agents, validate manifests, review |
| Invoker | Implement code, write skills, review changes |
| Auditor | Modify files, commit, implement, plan |
| Scribe | Implement, review, or make decisions about what to commit |
| Guild Master | Implement, write skills, commit, review |
| Charter | Implement, commit, make architecture decisions |

---

## Success (After Implementation)

✓ Engineer creates a file without asking permission  
✓ Smith writes a skill without workarounds  
✓ Invoker updates a manifest without manual help  
✓ Auditor reviews without being tempted to edit  
✓ Scribe commits with confidence (all pre-reviewed)  
✓ All workflows complete tool-provisioning-free  
✓ New agents created with clear tool checklist  
✓ #13 is unblocked  

---

## Documents Created

1. **Decision:** .guild/memory/decisions/2026-03-10-agent-tooling-strategy.md
   - Full rationale, principles, and acceptance criteria
   - Authoritative source for "what was decided"

2. **Implementation Guide:** .guild/memory/decisions/2026-03-10-agent-tooling-implementation-guide.md
   - Step-by-step updates to agent files
   - Testing procedures
   - Rollout plan

3. **This Summary:** Quick reference for the decision

---

## Related Work

- Update .github/agents/*.agent.md files with 	ools: section
- Update .github/skills/train-agent/SKILL.md with tool checklist
- Update AGENTS.md with tool access matrix
- Run tests (phases 4)
- Engineer picks up #13 (now unblocked)

---

## FAQ

**Q: Why can't Auditor edit?**  
A: Independence. If Auditor edits, they review their own changes (conflict of interest). Clarity and trust win.

**Q: Why does Engineer have delete?**  
A: Engineers need to remove old files, clean up scaffolding, and manage the repo. They use delete sparingly, but it's part of file management.

**Q: Can multiple agents have the same tools?**  
A: Yes. Engineer, Smith, and Invoker all have create/dit. Same tools, different scope (code vs. skills vs. manifests).

**Q: What if a new agent needs a tool we haven't defined?**  
A: Use the train-agent skill checklist to decide. New tool types should be rare; ask "why doesn't an existing tool work?"

**Q: Does this decision apply to all future agents?**  
A: Yes. Use the same RBAC framework for any new agent. Same principles, same "Tools & Boundaries" pattern.

---

## Next Steps

1. **Guild Master:** Review decision, schedule Phase 1 work
2. **Engineer:** Pick up Phase 1 (update agent configs) — ~2 hours
3. **Engineer:** Pick up Phase 2-3 (train-agent + docs) — ~1 hour
4. **Engineer:** Run Phase 4 tests — ~1-2 hours
5. **Engineer:** Pick up #13 (now unblocked!) — implement

**Timeline:** 4-5 hours to fully unblock #13 and all implementation work.

