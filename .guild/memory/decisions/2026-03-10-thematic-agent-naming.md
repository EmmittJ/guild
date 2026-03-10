# Adopt thematic agent naming and add role column to routing

Date: 2026-03-10
Agents: Guild Master, Product Owner

## Context

Guild recently adopted the `guild-*` prefix for installable data skills (issue #11) to avoid namespace collisions. This established a clear naming convention. However, the agent names remain mixed — some functional (product-owner, engineer), others thematic (scribe). 

Additionally, the routing table lacks a column mapping agent names to their functional roles, creating confusion between identity and responsibility.

## Decision

1. **Rename agents with thematic names** (Option B from issue #12):
   - product-owner → `charter`
   - engineer → `engineer` (kept — already thematic/generic)
   - skill-writer → `smith`
   - reviewer → `auditor`
   - scribe → `scribe` (kept — already thematic)
   - copilot-cli → `invoker`
   - guild-master → `guild-master` (unchanged — core agent)

2. **Add role column to routing table** to map thematic names to functional roles:
   - Agents have thematic identities (charter, smith, auditor, etc.)
   - Roles capture functional purpose (product-owner, engineer, reviewer, etc.)
   - Routing rules can reference roles; users see thematic names in output

## Alternatives Considered

- **Option A (Conservative)**: Prefix all agents with `guild-` (guild-engineer, guild-product-owner, etc.) — predictable, matches skills convention from #11. Rejected: too verbose, less thematic branding.
- **No agent renaming**: Keep current names, just fix inconsistency. Rejected: doesn't improve branding or clarity.
- **Thematic names without role column**: Rename agents but leave routing ambiguous. Rejected: creates operational confusion about which agent handles what role.

## Outcome

Implementation plan (issue #12) updated to include thematic naming + role column. Next phase: dispatch to engineer and skill-writer for refactoring (5 phases covering agent files, routing, documentation, setup skills, agent content). Marked as breaking change (v0.3.0).

Naming establishes clear distinction: **thematic identity** (what humans see and interact with) vs. **functional role** (what the system uses for routing and dispatch).
