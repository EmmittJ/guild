#!/usr/bin/env sh
# sync-skills.sh — copy orchestrate, train-agent, and train-skill from plugin/skills/ to .github/skills/
# Usage: sh sync-skills.sh
# Finds the repo root by walking up from CWD until it finds a directory containing plugin.json.

set -e

# ── Find repo root ────────────────────────────────────────────────────────────

REPO_ROOT="$(pwd)"
while [ "$REPO_ROOT" != "/" ]; do
  if [ -f "$REPO_ROOT/plugin.json" ]; then
    break
  fi
  REPO_ROOT="$(dirname "$REPO_ROOT")"
done

if [ ! -f "$REPO_ROOT/plugin.json" ]; then
  echo "Error: could not find repo root (no plugin.json found in any parent directory)" >&2
  exit 1
fi

# ── Paths ─────────────────────────────────────────────────────────────────────

SRC_DIR="$REPO_ROOT/plugin/skills"
DST_DIR="$REPO_ROOT/.github/skills"
SKILLS="orchestrate train-agent train-skill"

# ── Verify sources ────────────────────────────────────────────────────────────

for skill in $SKILLS; do
  if [ ! -d "$SRC_DIR/$skill" ]; then
    echo "Error: source directory not found: $SRC_DIR/$skill" >&2
    exit 1
  fi
done

# ── Ensure destination exists ─────────────────────────────────────────────────

mkdir -p "$DST_DIR"

# ── Copy skills ───────────────────────────────────────────────────────────────

for skill in $SKILLS; do
  cp -r "$SRC_DIR/$skill" "$DST_DIR/"
  echo "Synced $skill -> .github/skills/$skill"
done

exit 0
