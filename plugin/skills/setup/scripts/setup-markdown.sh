#!/usr/bin/env sh
# setup.sh — interactive Guild markdown backend setup
# Usage: sh setup.sh <repo-root> [-y]
#   repo-root   absolute path to the repository root (required)
# With -y: reads GUILD_COMPONENTS (markdown-memory|markdown-issues|markdown-inbox|all) and GUILD_SKILLS_DIR from env

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

# ── Component selection ──────────────────────────────────────────────────────

if [ "$NON_INTERACTIVE" = "1" ]; then
  COMPONENTS="${GUILD_COMPONENTS:-all}"
else
  echo ""
  echo "Guild Markdown Setup"
  echo "──────────────────────────────────"
  echo "Which components do you want to install?"
  echo "  1) memory  — decisions, insights, context"
  echo "  2) tasks   — open/in_progress/closed task files"
  echo "  3) inbox   — async agent-to-agent messaging"
  echo "  4) all     (default)"
  echo ""
  printf "Select [1/2/3/4]: "
  read -r choice
  case "$choice" in
    1) COMPONENTS="markdown-memory" ;;
    2) COMPONENTS="markdown-issues" ;;
    3) COMPONENTS="markdown-inbox" ;;
    *) COMPONENTS="all" ;;
  esac
fi

# ── Skills directory ─────────────────────────────────────────────────────────

if [ "$NON_INTERACTIVE" = "1" ]; then
  SKILLS_DIR="${GUILD_SKILLS_DIR:-.github/skills}"
else
  echo ""
  printf "Skills directory [.github/skills]: "
  read -r input_dir
  SKILLS_DIR="${input_dir:-.github/skills}"
fi

SKILLS_ABS="$REPO_ROOT/$SKILLS_DIR"

# ── Helpers ──────────────────────────────────────────────────────────────────

ensure_dir() {
  [ -d "$1" ] && return
  mkdir -p "$1"
  echo "  created $1"
}

copy_skill() {
  local name="$1"
  local root_path="$2"
  local dest="$SKILLS_ABS/$name/SKILL.md"
  if [ -f "$dest" ]; then
    echo "  skipped $SKILLS_DIR/$name/SKILL.md (already exists)"
    return
  fi
  mkdir -p "$SKILLS_ABS/$name"
  sed "s|\${${name}_root}|$root_path|g" "$ASSETS_DIR/$name/SKILL.md" > "$dest"
  echo "  copied  $SKILLS_DIR/$name/SKILL.md (root: $root_path)"
}

# Add an entry to the guild-managed block in .gitignore
# Creates the block if it doesn't exist; skips if entry already present
gitignore_add() {
  local entry="$1"
  local gitignore="$REPO_ROOT/.gitignore"
  local marker_start="# guild-managed"
  local marker_end="# end guild-managed"

  # Already present anywhere in the file — skip
  if grep -qF "$entry" "$gitignore" 2>/dev/null; then
    return
  fi

  if grep -qF "$marker_start" "$gitignore" 2>/dev/null; then
    # Block exists — insert entry before the end marker
    tmp="$(mktemp)"
    sed "s|$marker_end|$entry\n$marker_end|" "$gitignore" > "$tmp"
    mv "$tmp" "$gitignore"
  else
    # No block yet — append one
    printf '\n%s\n%s\n%s\n' "$marker_start" "$entry" "$marker_end" >> "$gitignore"
  fi
  echo "  added   $entry to .gitignore"
}

# ── Install memory ───────────────────────────────────────────────────────────

install_guild_memory() {
  echo ""
  echo "Installing memory..."
  if [ "$NON_INTERACTIVE" = "1" ]; then
    MEMORY_ROOT="${GUILD_MEMORY_ROOT:-.agents/memory}"
  else
    printf "  Memory root [.agents/memory]: "
    read -r input
    MEMORY_ROOT="${input:-.agents/memory}"
  fi
  ensure_dir "$REPO_ROOT/$GUILD_MEMORY_ROOT/decisions"
  ensure_dir "$REPO_ROOT/$GUILD_MEMORY_ROOT/insights"
  ensure_dir "$REPO_ROOT/$GUILD_MEMORY_ROOT/context"
  ensure_dir "$REPO_ROOT/$GUILD_MEMORY_ROOT/inbox"

  # Keep dirs in git
  for dir in decisions insights inbox; do
    local keep="$REPO_ROOT/$GUILD_MEMORY_ROOT/$dir/.gitkeep"
    [ -f "$keep" ] || { touch "$keep" && echo "  created $GUILD_MEMORY_ROOT/$dir/.gitkeep"; }
  done

  # Context files are ephemeral — keep out of git
  gitignore_add "$GUILD_MEMORY_ROOT/context/"

  # Seed _summary.md if not present
  local summary="$REPO_ROOT/$GUILD_MEMORY_ROOT/decisions/_summary.md"
  if [ ! -f "$summary" ]; then
    printf '# Decision Summary\n\n_No decisions recorded yet._\n' > "$summary"
    echo "  created $GUILD_MEMORY_ROOT/decisions/_summary.md"
  fi

  copy_skill "markdown-memory" "$GUILD_MEMORY_ROOT"
}

# ── Install tasks ────────────────────────────────────────────────────────────

install_guild_tasks() {
  echo ""
  echo "Installing tasks..."
  if [ "$NON_INTERACTIVE" = "1" ]; then
    TASKS_ROOT="${GUILD_TASKS_ROOT:-.agents/tasks}"
  else
    printf "  Tasks root [.agents/tasks]: "
    read -r input
    TASKS_ROOT="${input:-.agents/tasks}"
  fi
  ensure_dir "$REPO_ROOT/$GUILD_TASKS_ROOT/open"
  ensure_dir "$REPO_ROOT/$GUILD_TASKS_ROOT/in_progress"
  ensure_dir "$REPO_ROOT/$GUILD_TASKS_ROOT/closed"

  # Keep dirs in git
  for dir in open in_progress closed; do
    local keep="$REPO_ROOT/$GUILD_TASKS_ROOT/$dir/.gitkeep"
    [ -f "$keep" ] || touch "$keep" && echo "  created $GUILD_TASKS_ROOT/$dir/.gitkeep"
  done

  copy_skill "markdown-issues" "$GUILD_TASKS_ROOT"
}

# ── Install inbox ────────────────────────────────────────────────────────────

install_guild_inbox() {
  echo ""
  echo "Installing inbox..."
  if [ "$NON_INTERACTIVE" = "1" ]; then
    INBOX_ROOT="${GUILD_INBOX_ROOT:-.agents/inbox}"
  else
    printf "  Inbox root [.agents/inbox]: "
    read -r input
    INBOX_ROOT="${input:-.agents/inbox}"
  fi
  ensure_dir "$REPO_ROOT/$GUILD_INBOX_ROOT"

  # Inbox messages are ephemeral — keep out of git
  gitignore_add "$GUILD_INBOX_ROOT/"

  copy_skill "markdown-inbox" "$GUILD_INBOX_ROOT"
}

# ── Run ──────────────────────────────────────────────────────────────────────

case "$COMPONENTS" in
  markdown-memory) install_guild_memory ;;
  markdown-issues)  install_guild_tasks ;;
  markdown-inbox)  install_guild_inbox ;;
  *)      install_guild_memory; install_guild_tasks; install_guild_inbox ;;
esac

echo ""
echo "Done. Next: add the installed skills to your plugin.json or AGENTS.md:"
echo ""
case "$COMPONENTS" in
  markdown-memory) echo "  \"skills\": [\"$SKILLS_DIR/markdown-memory\"]"
          echo ""
          echo "  Memory root: $GUILD_MEMORY_ROOT" ;;
  markdown-issues)  echo "  \"skills\": [\"$SKILLS_DIR/markdown-issues\"]"
          echo ""
          echo "  Tasks root:  $GUILD_TASKS_ROOT" ;;
  markdown-inbox)  echo "  \"skills\": [\"$SKILLS_DIR/markdown-inbox\"]"
          echo ""
          echo "  Inbox root:  $GUILD_INBOX_ROOT" ;;
  *)      echo "  \"skills\": [\"$SKILLS_DIR/markdown-memory\", \"$SKILLS_DIR/markdown-issues\", \"$SKILLS_DIR/markdown-inbox\"]"
          echo ""
          echo "  Memory root: $GUILD_MEMORY_ROOT"
          echo "  Tasks root:  $GUILD_TASKS_ROOT"
          echo "  Inbox root:  $GUILD_INBOX_ROOT" ;;
esac
echo ""


