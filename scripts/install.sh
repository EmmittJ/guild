#!/usr/bin/env sh
# install.sh — copy Guild plugin skills into the current repo
# Usage: sh scripts/install.sh [target-dir]
#   target-dir defaults to .github/skills
#
# Requires git 2.25+ (sparse-checkout support)

set -e

TARGET="${1:-.github/skills}"
TMP=$(mktemp -d)

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

git clone --depth=1 --filter=blob:none --sparse \
  https://github.com/EmmittJ/guild.git "$TMP"

git -C "$TMP" sparse-checkout set \
  plugin/skills/orchestrate \
  plugin/skills/train-agent \
  plugin/skills/train-skill \
  plugin/skills/work-cycle \
  plugin/skills/setup

mkdir -p "$TARGET"
cp -r "$TMP/plugin/skills/." "$TARGET/"

echo "Guild skills installed to $TARGET"
echo "Run /setup in any agent chat to scaffold your team."
