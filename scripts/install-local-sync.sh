#!/usr/bin/env bash
# One-time setup per machine: link everything now and install a macOS LaunchAgent
# that re-runs scripts/sync-local.sh at login and every 5 minutes.
#
# Run from the main clone that ~/.codex/skills points at (not from a worktree):
#   bash scripts/install-local-sync.sh
# Remove with:
#   launchctl bootout "gui/$(id -u)/local.custom-skills.sync"
#   rm ~/Library/LaunchAgents/local.custom-skills.sync.plist
set -euo pipefail

SKILLS_REPO="${SKILLS_REPO:-$(cd "$(dirname "$0")/.." && pwd)}"
LAUNCH_AGENTS_DIR="${LAUNCH_AGENTS_DIR:-$HOME/Library/LaunchAgents}"
LABEL="local.custom-skills.sync"
PLIST="$LAUNCH_AGENTS_DIR/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs"
INTERVAL_SECONDS="${SYNC_INTERVAL_SECONDS:-300}"

SKILLS_REPO="$SKILLS_REPO" bash "$(dirname "$0")/sync-local.sh" || echo "Initial sync reported a problem; see output above."

mkdir -p "$LAUNCH_AGENTS_DIR" "$LOG_DIR"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$SKILLS_REPO/scripts/sync-local.sh</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>SKILLS_REPO</key>
    <string>$SKILLS_REPO</string>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>$INTERVAL_SECONDS</integer>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/custom-skills-sync.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/custom-skills-sync.log</string>
</dict>
</plist>
EOF

if [ "${SKIP_LAUNCHCTL:-0}" != "1" ]; then
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST"
  echo "LaunchAgent $LABEL loaded; log at $LOG_DIR/custom-skills-sync.log"
fi
echo "Installed $PLIST"
