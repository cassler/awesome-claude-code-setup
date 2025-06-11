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

You have helper scripts at `~/.claude/scripts/` with these aliases:
- `chp` - Project overview (run this first!)
- `chs find-code "pattern"` - Fast code search
- `chg quick-commit "msg"` - Git operations
- `ch ctx for-task "description"` - Generate focused context
- `ch py deps` - Python dependencies and tools
- `ch go test` - Go testing and development

Run `ch help` for all available commands.

## MCP Servers (User Level)

You have these MCP servers configured globally:
- **Playwright**: Browser automation for visual testing and UI interactions
- **Context7**: Up-to-date documentation for libraries and frameworks

Use these servers when:
- Testing UI changes (Playwright can navigate, screenshot, and interact)
- Researching library APIs (Context7 provides current documentation)

Note: These are user-level servers available in all your projects.