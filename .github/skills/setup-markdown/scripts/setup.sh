#!/usr/bin/env sh
# setup.sh — interactive Guild markdown backend setup
# Usage: sh setup.sh <repo-root> [-y]
#   repo-root   absolute path to the repository root (required)
# With -y: reads GUILD_COMPONENTS (memory|tasks|inbox|all) and GUILD_SKILLS_DIR from env

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
    1) COMPONENTS="memory" ;;
    2) COMPONENTS="tasks" ;;
    3) COMPONENTS="inbox" ;;
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

install_memory() {
  echo ""
  echo "Installing memory..."
  if [ "$NON_INTERACTIVE" = "1" ]; then
    MEMORY_ROOT="${GUILD_MEMORY_ROOT:-.guild/memory}"
  else
    printf "  Memory root [.guild/memory]: "
    read -r input
    MEMORY_ROOT="${input:-.guild/memory}"
  fi
  ensure_dir "$REPO_ROOT/$MEMORY_ROOT/decisions"
  ensure_dir "$REPO_ROOT/$MEMORY_ROOT/insights"
  ensure_dir "$REPO_ROOT/$MEMORY_ROOT/context"
  ensure_dir "$REPO_ROOT/$MEMORY_ROOT/inbox"

  # Keep dirs in git
  for dir in decisions insights inbox; do
    local keep="$REPO_ROOT/$MEMORY_ROOT/$dir/.gitkeep"
    [ -f "$keep" ] || { touch "$keep" && echo "  created $MEMORY_ROOT/$dir/.gitkeep"; }
  done

  # Context files are ephemeral — keep out of git
  gitignore_add "$MEMORY_ROOT/context/"

  # Seed _summary.md if not present
  local summary="$REPO_ROOT/$MEMORY_ROOT/decisions/_summary.md"
  if [ ! -f "$summary" ]; then
    printf '# Decision Summary\n\n_No decisions recorded yet._\n' > "$summary"
    echo "  created $MEMORY_ROOT/decisions/_summary.md"
  fi

  copy_skill "memory" "$MEMORY_ROOT"
}

# ── Install tasks ────────────────────────────────────────────────────────────

install_tasks() {
  echo ""
  echo "Installing tasks..."
  if [ "$NON_INTERACTIVE" = "1" ]; then
    TASKS_ROOT="${GUILD_TASKS_ROOT:-.guild/tasks}"
  else
    printf "  Tasks root [.guild/tasks]: "
    read -r input
    TASKS_ROOT="${input:-.guild/tasks}"
  fi
  ensure_dir "$REPO_ROOT/$TASKS_ROOT/open"
  ensure_dir "$REPO_ROOT/$TASKS_ROOT/in_progress"
  ensure_dir "$REPO_ROOT/$TASKS_ROOT/closed"

  # Keep dirs in git
  for dir in open in_progress closed; do
    local keep="$REPO_ROOT/$TASKS_ROOT/$dir/.gitkeep"
    [ -f "$keep" ] || touch "$keep" && echo "  created $TASKS_ROOT/$dir/.gitkeep"
  done

  copy_skill "tasks" "$TASKS_ROOT"
}

# ── Install inbox ────────────────────────────────────────────────────────────

install_inbox() {
  echo ""
  echo "Installing inbox..."
  if [ "$NON_INTERACTIVE" = "1" ]; then
    INBOX_ROOT="${GUILD_INBOX_ROOT:-.guild/inbox}"
  else
    printf "  Inbox root [.guild/inbox]: "
    read -r input
    INBOX_ROOT="${input:-.guild/inbox}"
  fi
  ensure_dir "$REPO_ROOT/$INBOX_ROOT"

  # Inbox messages are ephemeral — keep out of git
  gitignore_add "$INBOX_ROOT/"

  copy_skill "inbox" "$INBOX_ROOT"
}

# ── Run ──────────────────────────────────────────────────────────────────────

case "$COMPONENTS" in
  memory) install_memory ;;
  tasks)  install_tasks ;;
  inbox)  install_inbox ;;
  *)      install_memory; install_tasks; install_inbox ;;
esac

echo ""
echo "Done. Next: add the installed skills to your plugin.json or AGENTS.md:"
echo ""
case "$COMPONENTS" in
  memory) echo "  \"skills\": [\"$SKILLS_DIR/memory\"]"
          echo ""
          echo "  Memory root: $MEMORY_ROOT" ;;
  tasks)  echo "  \"skills\": [\"$SKILLS_DIR/tasks\"]"
          echo ""
          echo "  Tasks root:  $TASKS_ROOT" ;;
  inbox)  echo "  \"skills\": [\"$SKILLS_DIR/inbox\"]"
          echo ""
          echo "  Inbox root:  $INBOX_ROOT" ;;
  *)      echo "  \"skills\": [\"$SKILLS_DIR/memory\", \"$SKILLS_DIR/tasks\", \"$SKILLS_DIR/inbox\"]"
          echo ""
          echo "  Memory root: $MEMORY_ROOT"
          echo "  Tasks root:  $TASKS_ROOT"
          echo "  Inbox root:  $INBOX_ROOT" ;;
esac
echo ""
