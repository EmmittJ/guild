#!/usr/bin/env sh
# sync-skills.sh — copy skills from plugin sources to .github/skills/
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

# skill:source_relative_to_repo pairs
SKILL_ENTRIES="orchestrate:plugin/skills/orchestrate train-agent:plugin/skills/train-agent train-skill:plugin/skills/train-skill beads:plugin/skills/setup/assets/skills/beads"

# ── Verify sources ────────────────────────────────────────────────────────────

for entry in $SKILL_ENTRIES; do
  skill="${entry%%:*}"
  src_rel="${entry#*:}"
  if [ ! -d "$REPO_ROOT/$src_rel" ]; then
    echo "Error: source directory not found: $REPO_ROOT/$src_rel" >&2
    exit 1
  fi
done

# ── Ensure destination exists ─────────────────────────────────────────────────

mkdir -p "$DST_DIR"

# ── Stamp metadata.asset in installed SKILL.md copies ────────────────────────

stamp_asset() {
  file="$DST_DIR/$1/SKILL.md"
  asset="$2"
  [ -f "$file" ] || return 0
  awk -v asset="$asset" '
    BEGIN { n=0; delim=0 }
    /^---$/ {
      delim++
      if (delim == 1) { print; next }
      has_meta=0; has_asset=0
      for (i=1;i<=n;i++) {
        if (buf[i] ~ /^metadata:/)  has_meta=1
        if (buf[i] ~ /^  asset:/)   has_asset=1
      }
      for (i=1;i<=n;i++) {
        if (buf[i] ~ /^  asset:/) { print "  asset: " asset; next }
        print buf[i]
        if (buf[i] ~ /^metadata:/ && !has_asset) {
          print "  asset: " asset; has_asset=1
        }
      }
      if (!has_meta) { print "metadata:"; print "  asset: " asset }
      print "---"; next
    }
    delim==1 { buf[++n]=$0; next }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# ── Copy skills ───────────────────────────────────────────────────────────────

for entry in $SKILL_ENTRIES; do
  skill="${entry%%:*}"
  src_rel="${entry#*:}"
  # asset path: from .github/skills/{name}/SKILL.md back to repo root (3 levels) then to source
  asset_rel="../../../$src_rel/SKILL.md"
  cp -r "$REPO_ROOT/$src_rel" "$DST_DIR/"
  stamp_asset "$skill" "$asset_rel"
  echo "Synced $skill -> .github/skills/$skill"
done

exit 0
