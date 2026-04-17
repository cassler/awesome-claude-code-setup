#!/bin/bash
# Runs after Claude edits or writes a file.
# Reads the modified file path from CLAUDE_TOOL_INPUT_FILE_PATH env var.
# Silently skips if no formatter is available for the file type.

FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

EXT="${FILE##*.}"

case "$EXT" in
  js|jsx|ts|tsx|json|css|scss|html|md|yaml|yml)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE" &>/dev/null
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE" &>/dev/null
    elif command -v black &>/dev/null; then
      black --quiet "$FILE" &>/dev/null
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE" &>/dev/null
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE" &>/dev/null
    fi
    ;;
esac

exit 0
