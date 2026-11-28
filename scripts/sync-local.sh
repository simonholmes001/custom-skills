#!/usr/bin/env bash
# Keep this machine's Codex and Claude configuration in step with this repository.
#
# 1. Fast-forwards the local clone to origin/main (only when it is on main).
# 2. Links ~/.codex/AGENTS.md and ~/.claude/CLAUDE.md to global-instructions/.
# 3. Links every skill (top-level directory containing SKILL.md) into ~/.claude/skills/
#    and prunes links to skills that no longer exist. Codex needs no per-skill links
#    when ~/.codex/skills is itself a symlink to this clone.
#
# Safe to run repeatedly. Existing regular files are backed up, never overwritten.
# Exits non-zero if the update failed; linking still runs so the machine stays usable.
set -uo pipefail

SKILLS_REPO="${SKILLS_REPO:-$(cd "$(dirname "$0")/.." && pwd)}"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME_DIR="${CLAUDE_HOME:-$HOME/.claude}"
status=0

log() { printf '%s custom-skills-sync: %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$*"; }

update_clone() {
  local branch
  branch="$(git -C "$SKILLS_REPO" symbolic-ref --quiet --short HEAD 2>/dev/null || echo detached)"
  if [ "$branch" != "main" ]; then
    log "clone is on '$branch', not main; skipping update"
    return 0
  fi
  if ! git -C "$SKILLS_REPO" fetch --quiet --prune origin; then
    log "ERROR: fetch from origin failed"
    return 1
  fi
  if ! git -C "$SKILLS_REPO" merge --quiet --ff-only origin/main; then
    log "ERROR: cannot fast-forward main to origin/main (local commits or conflicting local edits); resolve manually"
    return 1
  fi
  log "clone at $(git -C "$SKILLS_REPO" rev-parse --short HEAD)"
}

link() { # target link_path
  local target="$1" path="$2"
  mkdir -p "$(dirname "$path")"
  if [ -L "$path" ]; then
    [ "$(readlink "$path")" = "$target" ] && return 0
    rm "$path"
  elif [ -e "$path" ]; then
    local backup
    backup="$path.backup-$(date '+%Y%m%d%H%M%S')"
    mv "$path" "$backup"
    log "backed up existing $path to $backup"
  fi
  ln -s "$target" "$path"
  log "linked $path -> $target"
}

link_skills() {
  local skills_dir="$CLAUDE_HOME_DIR/skills" dir name entry target
  mkdir -p "$skills_dir"
  for dir in "$SKILLS_REPO"/*/; do
    dir="${dir%/}"
    name="$(basename "$dir")"
    [ -f "$dir/SKILL.md" ] || continue
    link "$dir" "$skills_dir/$name"
  done
  for entry in "$skills_dir"/*; do
    [ -L "$entry" ] || continue
    target="$(readlink "$entry")"
    case "$target" in
      "$SKILLS_REPO"/*)
        if [ ! -e "$entry" ]; then
          rm "$entry"
          log "pruned dangling link $entry"
        fi
        ;;
    esac
  done
}

update_clone || status=1
link "$SKILLS_REPO/global-instructions/AGENTS.md" "$CODEX_HOME_DIR/AGENTS.md"
link "$SKILLS_REPO/global-instructions/CLAUDE.md" "$CLAUDE_HOME_DIR/CLAUDE.md"
link_skills
exit "$status"
