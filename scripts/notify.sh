#!/bin/bash
# Sends a desktop notification when Claude finishes a task (Stop hook).

TITLE="Claude Code"
MESSAGE="${CLAUDE_NOTIFICATION_MESSAGE:-Task complete}"

if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" &>/dev/null
elif command -v notify-send &>/dev/null; then
  notify-send "$TITLE" "$MESSAGE" &>/dev/null
fi

exit 0
