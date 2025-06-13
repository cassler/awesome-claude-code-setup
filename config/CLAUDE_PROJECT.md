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

Use these servers when:
- Testing UI changes (Playwright can navigate, screenshot, and interact)
- Researching library APIs (Context7 provides current documentation)

Note: These are user-level servers available in all your projects.