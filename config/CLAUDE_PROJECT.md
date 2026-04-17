# Project-Specific Claude Instructions

<ch:project-context>
<!-- Add project-specific context here -->
- Project type: 
- Main technologies: 
- Key patterns to follow: 
</ch:project-context>

<ch:project-commands>
# Frequently used commands for this project
# Examples:
# npm run dev
# docker-compose up
# pytest tests/
</ch:project-commands>

<ch:project-notes>
<!-- Add important notes, gotchas, or special instructions -->
</ch:project-notes>

## Helper Scripts Available

You have access to efficient helper scripts that streamline common development tasks:

**🚀 Quick Start:**
```bash
chp  # Run this first! Provides comprehensive project analysis
```

**🔍 Common Tasks (more efficient than manual commands):**
- `chs find-code "pattern"` - Fast code search (better than grep)
- `ch m read-many file1 file2` - Batch file reading (saves tokens)
- `chg quick-commit "msg"` - Complete git workflow in one command
- `ch ctx for-task "description"` - Generate focused context for specific tasks

**📊 Language-Specific Helpers:**
- `ch ts deps` - Node.js/TypeScript analysis
- `ch py deps` - Python dependencies and environment
- `ch go test` - Go modules and testing

These helpers bundle multiple operations into single commands, providing:
✅ Structured output optimized for analysis
✅ Automatic error handling
✅ Token-efficient responses
✅ Consistent patterns across tech stacks

Run `ch help` to see all available commands and categories.

## MCP Servers (User Level)

The default setup (`setup.sh`) configures these MCP servers globally:
- **Playwright**: Browser automation for visual testing and UI interactions
- **Context7**: Up-to-date documentation for libraries and frameworks

Additional servers (Filesystem, GitHub, Sequential Thinking) are available in
`config/mcp.json` and can be added manually. See the README for details.

MCP servers are **lazy-loaded** — they only consume context tokens when you
first invoke them. Enable all servers freely without impacting performance on
unrelated tasks.

## Scoped Rules

Scoped rules auto-load based on the files Claude is working with. Two locations
are supported:

- **User-level** (`~/.claude/rules/`) — installed by `setup.sh`, apply across all projects
- **Project-level** (`.claude/rules/`) — place in your repo root, apply only to this project

The default rules installed at user level:
- `typescript.md` — TypeScript/JS conventions (loads for `*.ts`, `*.tsx`, `*.js`, `*.jsx`)
- `python.md` — Python conventions (loads for `*.py`)
- `testing.md` — Testing conventions (loads for test files)

To add a project-scoped rule:
1. Create `.claude/rules/your-rule.md` in your repo
2. Add front matter: `globs: "**/*.ext"`
3. Write your rules in the body — Claude will load them automatically for this project
