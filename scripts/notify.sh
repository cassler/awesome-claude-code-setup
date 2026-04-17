#!/bin/bash
# Sends a desktop notification when Claude finishes a task (Stop hook).

TITLE="Claude Code"
MESSAGE="${CLAUDE_NOTIFICATION_MESSAGE:-Task complete}"

if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript - "$MESSAGE" "$TITLE" &>/dev/null <<'APPLESCRIPT'
on run argv
  display notification (item 1 of argv) with title (item 2 of argv)
end run
APPLESCRIPT
elif command -v notify-send &>/dev/null; then
  notify-send "$TITLE" "$MESSAGE" &>/dev/null
fi

exit 0
