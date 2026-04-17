# Hooks Guide

Hooks let you set up things that run automatically whenever Claude does something. Think of them like IFTTT for Claude Code — "when Claude edits a file, run my formatter" or "when Claude finishes a task, send me a notification."

You don't need to know much about them to benefit from them. The two hooks that come with this setup (auto-format and task notifications) just work out of the box after running `setup.sh`.

This guide is for when you want to go further and build your own.

---

## How It Works

Hooks live in a `settings.json` file in your Claude config folder. When something happens — Claude edits a file, runs a command, finishes a task — Claude Code checks if any hooks match and runs them.

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

This says: "After Claude edits or writes a file, run `post-edit.sh`. When Claude finishes a task, run `notify.sh`."

---

## When Hooks Can Fire

| Event | When it fires | Good for |
|---|---|---|
| `PreToolUse` | *Before* Claude runs a tool | Blocking dangerous commands, validating inputs |
| `PostToolUse` | *After* Claude runs a tool | Auto-formatting, updating indexes, linting |
| `Notification` | When Claude sends you a message | Forwarding to Slack, sending a push notification |
| `Stop` | When Claude finishes its turn | Desktop notification, logging, triggering CI |

---

## Matching the Right Events

The `matcher` field lets you be specific about which tool calls trigger your hook. You can match broadly or precisely:

```json
"matcher": "Edit"           // fires only when Claude edits a file
"matcher": "Edit|Write"     // fires for edits OR new file writes
"matcher": "Bash"           // fires for any shell command Claude runs
"matcher": "Bash(rm *)"     // fires only for shell commands that start with "rm "
```

You can also match MCP plugin actions:
```json
"matcher": "mcp__playwright__*"      // any Playwright action
"matcher": "mcp__github__create_*"   // only GitHub "create" actions
```

Leave out the `matcher` entirely to catch everything for that event type.

---

## Extra Filtering with `if`

Sometimes you need the matcher to be even more specific. The `if` field adds a second check:

```json
{
  "matcher": "Bash",
  "if": "Bash(git push*)",
  "hooks": [{ "type": "command", "command": "~/.claude/scripts/pre-push-check.sh" }]
}
```

This only triggers for Bash commands that start with `git push`.

---

## What Your Hook Script Can Read

Claude passes context to your hook script through environment variables:

| Variable | Available when | What's in it |
|---|---|---|
| `CLAUDE_TOOL_NAME` | Always | Which tool fired the hook (`Edit`, `Bash`, etc.) |
| `CLAUDE_TOOL_INPUT_FILE_PATH` | Edit / Write hooks | The full path of the file Claude just touched |
| `CLAUDE_TOOL_INPUT_COMMAND` | Bash hooks | The exact command Claude is about to run or just ran |
| `CLAUDE_NOTIFICATION_MESSAGE` | Notification / Stop hooks | The message Claude is surfacing to you |

---

## What Your Script Should Return

Your script's exit code tells Claude what to do next:

| Exit code | What it means |
|---|---|
| `0` | All good — Claude continues normally |
| `1` | Something went wrong — Claude logs it and continues anyway |
| `2` | **Block this action** (PreToolUse only) — Claude skips the tool call entirely |

Exit code `2` is how you prevent Claude from doing something. It only works on `PreToolUse` hooks — you can't stop something that's already happened.

---

## Example Hooks

### Auto-format files after Claude edits them

This one's already included at `scripts/post-edit.sh`. It checks the file extension and runs the right formatter — Prettier for JS/TS, Ruff for Python, gofmt for Go, rustfmt for Rust. If none of those are installed, it does nothing.

### Desktop notification when Claude finishes

Also already included at `scripts/notify.sh`. It pops up a system notification when Claude is done with a task — so you can step away from your desk without having to check back constantly.

### Block accidental force-pushes

This one prevents Claude from ever running `git push --force`, which can overwrite your teammates' work:

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

Then add it to your `settings.json`:
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

### Keep a log of every file Claude touches

Useful if you want to review what changed during a long session:

```bash
# ~/.claude/scripts/audit-log.sh
#!/bin/bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) EDIT ${CLAUDE_TOOL_INPUT_FILE_PATH:-}" \
  >> ~/.claude/audit.log
exit 0
```

---

## Getting Started (Already Done If You Ran setup.sh)

`setup.sh` copies `post-edit.sh` and `notify.sh` to `~/.claude/scripts/`,
makes them executable, and installs `~/.claude/settings.json` automatically
if it does not already exist.

If `~/.claude/settings.json` is already present, `setup.sh` skips replacing
it to preserve your existing Claude Code settings. In that case, manually
merge the hook entries from `config/settings.json` into your existing file,
then restart Claude Code.

---

## Further Reading

- [Claude Code Hooks Reference](https://docs.anthropic.com/claude-code/hooks)
- [Permission Rule Syntax](https://docs.anthropic.com/claude-code/settings#permissions)
