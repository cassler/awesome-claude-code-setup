# Hooks Guide

Claude Code hooks let you run shell commands automatically in response to
Claude's actions. Use them to auto-format files after edits, send notifications
when tasks complete, enforce policies, or integrate with external tools.

## How Hooks Work

Hooks are defined in `~/.claude/settings.json` (user-level) or
`.claude/settings.json` (project-level). Claude Code runs them as subprocesses
at the specified lifecycle points.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "~/.claude/scripts/post-edit.sh" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/scripts/notify.sh" }]
      }
    ]
  }
}
```

## Hook Events

| Event | Fires When | Common Uses |
|---|---|---|
| `PreToolUse` | Before Claude calls a tool | Validation, logging, blocking dangerous ops |
| `PostToolUse` | After a tool call completes | Auto-format, lint, update indexes |
| `Notification` | Claude sends a user notification | Forward to Slack, mobile push |
| `Stop` | Main agent turn finishes | Desktop notification, logging, CI trigger |

## Matchers

The `matcher` field filters which tool calls trigger the hook. It uses
permission-rule syntax.

**Tool name matching:**
```json
"matcher": "Edit"           // only Edit tool
"matcher": "Edit|Write"     // Edit or Write
"matcher": "Bash"           // any Bash call
"matcher": "Bash(rm *)"     // only Bash calls starting with "rm "
```

**MCP tool matching:**
```json
"matcher": "mcp__playwright__*"      // any Playwright MCP tool
"matcher": "mcp__github__create_*"   // GitHub create operations only
```

**No matcher** (omit the field) matches all tool calls for that event.

## The `if` Field (Conditional Hooks)

Narrow hook execution further with the `if` field using the same syntax as
permission rules:

```json
{
  "matcher": "Bash",
  "if": "Bash(git push*)",
  "hooks": [{ "type": "command", "command": "~/.claude/scripts/pre-push-check.sh" }]
}
```

## Environment Variables

Claude Code injects context into hook processes:

| Variable | Set For | Value |
|---|---|---|
| `CLAUDE_TOOL_NAME` | All hooks | Tool that triggered the hook (`Edit`, `Bash`, etc.) |
| `CLAUDE_TOOL_INPUT_FILE_PATH` | Edit/Write | Absolute path of the modified file |
| `CLAUDE_TOOL_INPUT_COMMAND` | Bash | The command string being run |
| `CLAUDE_NOTIFICATION_MESSAGE` | Notification/Stop | Message from Claude |

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success — Claude continues normally |
| `1` | Error — logged but Claude continues |
| `2` | **Block** (PreToolUse only) — Claude skips the tool call |

## Examples

### Auto-format after file edits

Already included at `scripts/post-edit.sh`. Runs Prettier, Ruff/Black, gofmt,
or rustfmt depending on the file extension. No-ops silently if no formatter is
found.

### Desktop notification on task completion

Already included at `scripts/notify.sh`. Uses `osascript` on macOS and
`notify-send` on Linux.

### Block accidental `git push --force` to main

```bash
# ~/.claude/scripts/block-force-push.sh
#!/bin/bash
CMD="${CLAUDE_TOOL_INPUT_COMMAND:-}"
if [[ "$CMD" == *"push"*"--force"* ]] || [[ "$CMD" == *"push"*"-f"* ]]; then
  echo "Blocked: force push is not allowed" >&2
  exit 2
fi
exit 0
```

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push*)",
        "hooks": [{ "type": "command", "command": "~/.claude/scripts/block-force-push.sh" }]
      }
    ]
  }
}
```

### Log every file Claude touches

```bash
# ~/.claude/scripts/audit-log.sh
#!/bin/bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) EDIT ${CLAUDE_TOOL_INPUT_FILE_PATH:-}" \
  >> ~/.claude/audit.log
exit 0
```

## Installing the Defaults

`setup.sh` copies `post-edit.sh` and `notify.sh` to `~/.claude/scripts/`,
makes them executable, and installs `~/.claude/settings.json` automatically
if it does not already exist.

If `~/.claude/settings.json` is already present, `setup.sh` skips replacing
it to preserve your existing Claude Code settings. In that case, manually
merge the hook entries from `config/settings.json` into your existing file,
then restart Claude Code.

## Further Reading

- [Claude Code Hooks Reference](https://docs.anthropic.com/claude-code/hooks)
- [Permission Rule Syntax](https://docs.anthropic.com/claude-code/settings#permissions)
