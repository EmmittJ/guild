#!/usr/bin/env sh
# setup.sh — interactive Guild GitHub Issues backend setup
# Usage: sh setup.sh <repo-root> [-y]
#   repo-root   absolute path to the repository root (required)
# With -y: reads GUILD_SKILLS_DIR and GUILD_REPO from env

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SKILL_DIR/assets/skills"

# Repo root must be passed explicitly
REPO_ROOT="$1"
if [ -z "$REPO_ROOT" ]; then
  echo "Error: repo root is required." >&2
  echo "Usage: sh setup.sh <repo-root> [-y]" >&2
  exit 1
fi
shift

NON_INTERACTIVE=0
[ "$1" = "-y" ] && NON_INTERACTIVE=1

# ── Auth check ───────────────────────────────────────────────────────────────

if ! command -v gh > /dev/null 2>&1; then
  echo "Error: gh CLI is required. Install from https://cli.github.com" >&2
  exit 1
fi

if ! gh auth status > /dev/null 2>&1; then
  echo "Error: gh CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

# ── Skills directory ─────────────────────────────────────────────────────────

if [ "$NON_INTERACTIVE" = "1" ]; then
  SKILLS_DIR="${GUILD_SKILLS_DIR:-.github/skills}"
else
  echo ""
  echo "Guild GitHub Setup"
  echo "──────────────────────────────────"
  echo ""
  printf "Skills directory [.github/skills]: "
  read -r input_dir
  SKILLS_DIR="${input_dir:-.github/skills}"
fi

SKILLS_ABS="$REPO_ROOT/$SKILLS_DIR"

# ── Repo slug ────────────────────────────────────────────────────────────────

if [ "$NON_INTERACTIVE" = "1" ]; then
  GITHUB_REPO="${GUILD_REPO:-}"
  if [ -z "$GITHUB_REPO" ]; then
    echo "Error: GUILD_REPO is required in CI mode (e.g. owner/repo)" >&2
    exit 1
  fi
else
  DETECTED_REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")"
  if [ -n "$DETECTED_REPO" ]; then
    printf "Repo (owner/repo) [%s]: " "$DETECTED_REPO"
  else
    printf "Repo (owner/repo): "
  fi
  read -r input_repo
  GITHUB_REPO="${input_repo:-$DETECTED_REPO}"
  if [ -z "$GITHUB_REPO" ]; then
    echo "Error: repo slug is required (e.g. owner/repo)" >&2
    exit 1
  fi
fi

# ── Create labels ────────────────────────────────────────────────────────────

echo ""
echo "Creating labels..."
gh label create "open"            --color "#0075ca" --force -R "$GITHUB_REPO" && echo "  done    open"
gh label create "in-progress"    --color "#e4e669" --force -R "$GITHUB_REPO" && echo "  done    in-progress"
gh label create "blocked"        --color "#d73a4a" --force -R "$GITHUB_REPO" && echo "  done    blocked"
gh label create "priority:high"   --color "#b60205" --force -R "$GITHUB_REPO" && echo "  done    priority:high"
gh label create "priority:medium" --color "#fbca04" --force -R "$GITHUB_REPO" && echo "  done    priority:medium"
gh label create "priority:low"    --color "#cfd3d7" --force -R "$GITHUB_REPO" && echo "  done    priority:low"

# ── Install tasks skill ──────────────────────────────────────────────────────

echo ""
echo "Installing tasks skill..."
DEST="$SKILLS_ABS/tasks/SKILL.md"
mkdir -p "$SKILLS_ABS/tasks"
if [ -f "$DEST" ]; then
  sed "s|\${github_repo}|$GITHUB_REPO|g" "$ASSETS_DIR/tasks/SKILL.md" > "$DEST"
  echo "  replaced $SKILLS_DIR/tasks/SKILL.md with GitHub Issues backend (repo: $GITHUB_REPO)"
else
  sed "s|\${github_repo}|$GITHUB_REPO|g" "$ASSETS_DIR/tasks/SKILL.md" > "$DEST"
  echo "  copied   $SKILLS_DIR/tasks/SKILL.md (repo: $GITHUB_REPO)"
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "Done. Add the installed skill to your plugin.json or AGENTS.md:"
echo ""
echo "  \"skills\": [\"$SKILLS_DIR/tasks\"]"
echo ""
echo "  Repo: $GITHUB_REPO"
echo ""
echo "For memory and inbox, run: /guild-setup-markdown"
echo ""
