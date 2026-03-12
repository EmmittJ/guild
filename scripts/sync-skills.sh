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

# beads lives in a different source location
BEADS_SRC="$REPO_ROOT/plugin/skills/setup/assets/skills/beads"

# ── Verify sources ────────────────────────────────────────────────────────────

for skill in $SKILLS; do
  if [ ! -d "$SRC_DIR/$skill" ]; then
    echo "Error: source directory not found: $SRC_DIR/$skill" >&2
    exit 1
  fi
done
if [ ! -d "$BEADS_SRC" ]; then
  echo "Error: source directory not found: $BEADS_SRC" >&2
  exit 1
fi

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

for skill in $SKILLS; do
  cp -r "$SRC_DIR/$skill" "$DST_DIR/"
  stamp_asset "$skill" "../../../plugin/skills/$skill/SKILL.md"
  echo "Synced $skill -> .github/skills/$skill"
done

# Sync beads from its asset location
cp -r "$BEADS_SRC" "$DST_DIR/"
stamp_asset "beads" "../../../plugin/skills/setup/assets/skills/beads/SKILL.md"
echo "Synced beads -> .github/skills/beads"

exit 0
