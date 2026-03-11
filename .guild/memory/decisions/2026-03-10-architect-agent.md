# Architect Agent — Addition to Team Roster

Date: 2026-03-10
Agents: guild-master, charter

## Context

Guild v0.3.0 shipped with seven thematic agents. During early sessions using the team, a gap
emerged: both charter (product owner) and guild-master were handling architectural concerns
(design patterns, technical trade-offs, feasibility) informally. There was no specialist whose
job was to push back on product requirements from a technical angle, maintain architectural
standards, or own design decisions.

The charter-engineer handoff was too abrupt — "here are the requirements, go build it" — with no
technical design review between them. Complex tasks required Guild Master to make architectural
calls it wasn't positioned to make well.

## Decision

Add an `architect` agent as a full team member. The architect is the technical counterpart to
charter: they debate requirements, validate feasibility, surface trade-offs, and own architecture
decisions. Not an implementer — no file creation, no code writing.

Role: technical-architect  
File: `architect.agent.md`  
Tools: read, search, edit, execute, web, todo — needs edit/execute to write architecture decision
records to team memory.

## Default flow change

The canonical flow becomes:

```
guild-master → charter + architect (collaborate) → engineer/smith/invoker → auditor → scribe
```

Charter and architect are peers. Work can go product-first (charter → architect) or architecture-
first (architect → charter) depending on the task. Guild Master decides which based on whether
requirements or technical constraints are the binding constraint.

## Alternatives Considered

- **Guild Master handles architecture**: Guild Master already has enough on its plate as orchestrator.
  Mixing architectural judgment into orchestration creates an unclear responsibility boundary.
- **Engineer handles architecture**: Engineers implement what they're given. Requiring them to also
  architect what they implement conflates two distinct skills and creates bottlenecks.
- **No dedicated role**: Acceptable for small, low-stakes repos. But for repos where technical
  trade-offs matter, the gap produces poor implementations of good requirements.

## Outcome

Architect added to team. Routing skill updated to include the role. AGENTS.md updated. The
charter↔architect peer relationship is documented in the routing skill's Default Flow section.
