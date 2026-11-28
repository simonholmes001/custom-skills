#!/usr/bin/env bash
# Behaviour tests for scripts/sync-local.sh and scripts/install-local-sync.sh.
# Every test runs against a throwaway HOME and a throwaway git remote.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SYNC="$SCRIPT_DIR/sync-local.sh"
INSTALL="$SCRIPT_DIR/install-local-sync.sh"

# Hooks export GIT_DIR/GIT_INDEX_FILE; do not leak them into fixture repositories.
for git_variable in $(git rev-parse --local-env-vars); do unset "$git_variable"; done

failures=0
tests=0

fail() { echo "  FAIL: $*"; failures=$((failures + 1)); }
assert_link() { # path expected_target
  if [ ! -L "$1" ]; then fail "$1 is not a symlink"; return; fi
  [ "$(readlink "$1")" = "$2" ] || fail "$1 -> $(readlink "$1"), expected $2"
}

new_fixture() {
  WORK="$(mktemp -d)"
  export HOME="$WORK/home"
  mkdir -p "$HOME"
  git init -q --bare -b main "$WORK/remote.git"
  git clone -q "$WORK/remote.git" "$WORK/seed" 2>/dev/null
  (
    cd "$WORK/seed"
    git config user.email t@example.invalid && git config user.name t
    mkdir -p global-instructions skill-a skill-b not-a-skill
    echo "agents v1" > global-instructions/AGENTS.md
    echo "claude v1" > global-instructions/CLAUDE.md
    echo "---" > skill-a/SKILL.md
    echo "---" > skill-b/SKILL.md
    echo "x" > not-a-skill/README.md
    git add -A && git commit -qm init && git push -q origin main
  )
  git clone -q "$WORK/remote.git" "$WORK/clone"
  export SKILLS_REPO="$WORK/clone"
}

run_test() {
  tests=$((tests + 1))
  echo "- $1"
  new_fixture
  "$1"
  rm -rf "$WORK"
}

test_links_global_instruction_files() {
  bash "$SYNC" >/dev/null
  assert_link "$HOME/.codex/AGENTS.md" "$SKILLS_REPO/global-instructions/AGENTS.md"
  assert_link "$HOME/.claude/CLAUDE.md" "$SKILLS_REPO/global-instructions/CLAUDE.md"
}

test_links_every_skill_for_claude_only() {
  bash "$SYNC" >/dev/null
  assert_link "$HOME/.claude/skills/skill-a" "$SKILLS_REPO/skill-a"
  assert_link "$HOME/.claude/skills/skill-b" "$SKILLS_REPO/skill-b"
  [ ! -e "$HOME/.claude/skills/not-a-skill" ] || fail "directory without SKILL.md was linked"
  [ ! -e "$HOME/.claude/skills/global-instructions" ] || fail "global-instructions was linked as a skill"
}

test_backs_up_existing_regular_file() {
  mkdir -p "$HOME/.codex"
  echo "hand written" > "$HOME/.codex/AGENTS.md"
  bash "$SYNC" >/dev/null
  assert_link "$HOME/.codex/AGENTS.md" "$SKILLS_REPO/global-instructions/AGENTS.md"
  # shellcheck disable=SC2012
  backup="$(ls "$HOME/.codex"/AGENTS.md.backup-* 2>/dev/null | head -1)"
  [ -n "$backup" ] && [ "$(cat "$backup")" = "hand written" ] || fail "original file was not backed up"
}

test_preserves_unmanaged_skill_entries_and_prunes_dangling_links() {
  mkdir -p "$HOME/.claude/skills/my-local-skill"
  ln -s "$SKILLS_REPO/removed-skill" "$HOME/.claude/skills/removed-skill"
  ln -s /somewhere/else "$HOME/.claude/skills/foreign-link"
  bash "$SYNC" >/dev/null
  [ -d "$HOME/.claude/skills/my-local-skill" ] || fail "unmanaged directory was removed"
  [ ! -L "$HOME/.claude/skills/removed-skill" ] || fail "dangling repo link was not pruned"
  [ -L "$HOME/.claude/skills/foreign-link" ] || fail "link outside the repo was removed"
}

test_pulls_new_commits_on_main() {
  (
    cd "$WORK/seed"
    mkdir -p skill-c && echo "---" > skill-c/SKILL.md
    echo "agents v2" > global-instructions/AGENTS.md
    git add -A && git commit -qm update && git push -q origin main
  )
  bash "$SYNC" >/dev/null
  [ "$(cat "$HOME/.codex/AGENTS.md")" = "agents v2" ] || fail "AGENTS.md was not updated from remote"
  assert_link "$HOME/.claude/skills/skill-c" "$SKILLS_REPO/skill-c"
}

test_does_not_pull_when_not_on_main() {
  git -C "$SKILLS_REPO" switch -q -c feature/x
  (
    cd "$WORK/seed"
    echo "agents v2" > global-instructions/AGENTS.md
    git commit -qam update && git push -q origin main
  )
  bash "$SYNC" >/dev/null 2>&1 || true
  [ "$(cat "$SKILLS_REPO/global-instructions/AGENTS.md")" = "agents v1" ] || fail "pulled while not on main"
}

test_reports_failure_when_fast_forward_is_impossible_but_still_links() {
  (
    cd "$SKILLS_REPO"
    git config user.email t@example.invalid && git config user.name t
    echo "local" > skill-a/local.md && git add -A && git commit -qm local
  )
  (
    cd "$WORK/seed"
    echo "remote" > skill-b/remote.md && git add -A && git commit -qm remote && git push -q origin main
  )
  if bash "$SYNC" >/dev/null 2>&1; then fail "diverged main should exit non-zero"; fi
  assert_link "$HOME/.codex/AGENTS.md" "$SKILLS_REPO/global-instructions/AGENTS.md"
}

test_is_idempotent() {
  bash "$SYNC" >/dev/null
  bash "$SYNC" >/dev/null
  for f in "$HOME/.codex"/*.backup-*; do [ -e "$f" ] && fail "second run created backup $f"; done
  assert_link "$HOME/.claude/skills/skill-a" "$SKILLS_REPO/skill-a"
}

test_installer_writes_launch_agent() {
  export LAUNCH_AGENTS_DIR="$WORK/LaunchAgents" SKIP_LAUNCHCTL=1
  bash "$INSTALL" >/dev/null
  plist="$LAUNCH_AGENTS_DIR/local.custom-skills.sync.plist"
  [ -f "$plist" ] || { fail "plist not written"; return; }
  grep -q "$SKILLS_REPO/scripts/sync-local.sh" "$plist" || fail "plist does not run sync-local.sh"
  grep -q "<key>StartInterval</key>" "$plist" || fail "plist has no interval"
  grep -q "<key>RunAtLoad</key>" "$plist" || fail "plist does not run at load"
  assert_link "$HOME/.codex/AGENTS.md" "$SKILLS_REPO/global-instructions/AGENTS.md"
  unset LAUNCH_AGENTS_DIR SKIP_LAUNCHCTL
}

for t in $(declare -F | awk '{print $3}' | grep '^test_'); do run_test "$t"; done

if [ "$tests" -eq 0 ]; then echo "No tests discovered"; exit 1; fi
if [ "$failures" -ne 0 ]; then echo "$failures failure(s) across $tests tests"; exit 1; fi
echo "All $tests sync tests passed."
