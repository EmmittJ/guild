# Marketplace & Plugin Ecosystem Design Insights

Source: `claudeforge/marketplace` (Jan 2026)

## Centralized Registry as Single Source of Truth

A single `marketplace.json` aggregates all plugin metadata. It references each plugin by `source` path and carries enough metadata (name, description, version, category, keywords) for discovery without loading individual plugin.json files. This pattern enables:
- Programmatic generation (crawl all plugin.json → regenerate registry)
- Fast filtering by category/keyword without reading every plugin
- Clear audit trail of what's published

## Categories: Type + Domain Separation

Organize by primary type first (`agents/`, `commands/`, `super/`), then by domain within each. This keeps type cohesion clean while allowing domain discovery. Mixing type and domain into a flat structure creates friction for discovery.

## Convention-Over-Configuration Reduces Maintenance Burden

Auto-discovery (e.g., any `.md` in `commands/` is a command) eliminates duplication between plugin.json and the filesystem. Spec violations arise when contributors add explicit registration for auto-discovered things — enforce through linting/validation, not documentation alone.

## Versioned Compliance Fixes Are First-Class Releases

When the upstream spec changes or compliance bugs are found at scale, treat the fix as a proper version bump with changelog entry. The claudeforge v1.2.0 release fixed 65 command plugins that had an invalid `"commands"` field — released as a minor version with clear changelog. Don't silently fix spec issues.

## Practical > Generic for Plugin Adoption

v1.1 of claudeforge explicitly added 49 "practical" plugins (database-expert, docker-specialist, cache-strategist, git-workflow-expert, etc.) after observing that teams use targeted, immediately-useful tools over broad generalists. When designing agents/skills, favor specificity over breadth.

## Multi-Agent Orchestration as a Plugin Category

"Super" plugins that coordinate multiple agents + maintain state represent a distinct, high-value tier. They solve problems single agents can't: task decomposition, dependency tracking, cross-agent handoffs. Worth having a dedicated category and format for them. MCP servers are the right primitive for stateful coordination.

## Contribution Pipeline: Clear Review SLAs Matter

The claudeforge marketplace defines a 3-phase review with explicit timelines (2-3 days initial, 3-5 days community, 1-2 days final). Clear SLAs prevent stale PRs and set contributor expectations. Without them, contributions pile up unreviewed.

## Portable Path Variables for Cross-Platform Plugins

Using `${CLAUDE_PLUGIN_ROOT}` in hook commands and MCP server args makes plugins relocatable. Anyone installing the plugin to any path gets working scripts without manual path editing. Always use variable substitution rather than hardcoded absolute paths in plugin configurations.
