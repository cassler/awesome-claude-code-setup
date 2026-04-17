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

You have these MCP servers configured globally:
- **Playwright**: Browser automation for visual testing and UI interactions
- **Context7**: Up-to-date documentation for libraries and frameworks
- **Filesystem**: Structured file access with path sandboxing
- **GitHub**: Issues, PRs, repos, code search (requires `GITHUB_TOKEN`)
- **Sequential Thinking**: Structured multi-step reasoning for complex problems

MCP servers are **lazy-loaded** — they only consume context tokens when you
first invoke them. Enable all servers freely without impacting performance on
unrelated tasks.

## Scoped Rules (.claude/rules/)

This project uses scoped CLAUDE.md rules that auto-load based on the files
Claude is working with:

- `.claude/rules/typescript.md` — TypeScript/JS conventions (loads for `*.ts`, `*.tsx`, `*.js`, `*.jsx`)
- `.claude/rules/python.md` — Python conventions (loads for `*.py`)
- `.claude/rules/testing.md` — Testing conventions (loads for test files)

To add a new scoped rule:
1. Create `.claude/rules/your-rule.md`
2. Add front matter: `globs: "**/*.ext"`
3. Write your rules in the body — Claude will load them automatically
