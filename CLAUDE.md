# Claude Helper Scripts

These helper scripts provide efficient shortcuts for common development workflows. They're designed to save tokens and time by bundling multiple operations into single commands.

<ch:why-use-helpers>
🎯 **Why these helpers are recommended:**
- Single commands that replace multiple manual steps
- Structured output optimized for Claude's understanding
- Automatic error handling and validation
- Token-efficient responses (less back-and-forth)
- Consistent patterns across different tech stacks
</ch:why-use-helpers>

<ch:aliases>
ch   → Main helper: ch [category] [command]
chp  → Project overview (highly recommended for new projects!)
chs  → Search tools: find-code, find-file, search-imports
chg  → Git ops: quick-commit, pr-ready, diff
</ch:aliases>

<ch:categories>
project|p         → Project analysis
docker|d          → Container ops: ps, logs, shell, inspect
git|g             → Git workflows
search|s          → Code search (needs: ripgrep)
ts|node           → TypeScript/Node.js (needs: jq)
python|py         → Python development (pip, poetry, pytest)
go|golang         → Go development (modules, testing, linting)
multi|m           → Multi-file ops (uses: bat)
env|e             → Environment checks
api               → API testing (needs: jq, httpie)
interactive|i     → Interactive tools (needs: fzf, gum)
context|ctx       → Context generation
code-relationships|cr → Dependency analysis
code-quality|cq   → Quality checks
mcp               → MCP server operations
nlp|text          → Static analysis & text processing (complexity, security, docs)
</ch:categories>

<ch:key-commands>
# 🚀 Recommended workflow for new projects:
chp                          # Get comprehensive project overview

# 🔍 Efficient alternatives to common tasks:
chs find-code "pattern"      # More efficient than grep
ch m read-many f1 f2 f3      # Batch file reading (saves tokens)
chg quick-commit "msg"       # Handles staging + commit + checks
ch i select-file             # Interactive file picker with preview
ch ctx for-task "desc"       # Generate focused context for specific tasks
ch api test /endpoint        # Test APIs with formatted output
ch nlp tokens README.md      # Count tokens before adding to context
ch nlp todos                 # Find all TODO/FIXME comments
ch nlp sentiment "text"      # Quick sentiment analysis
ch nlp security code.py      # Security vulnerability scan
ch nlp complexity code.py    # Cyclomatic complexity analysis
ch nlp smells code.py        # Detect code smells (long functions, etc)
ch nlp docs code.py          # Check documentation coverage
ch nlp overview file.py      # Comprehensive analysis (all above + more)

# 💡 These helpers handle many steps in one command, reducing the need
# for multiple tool calls and providing better structured output.
</ch:key-commands>

<ch:required-tools>
ripgrep → search-tools.sh
jq      → project-info.sh, ts-helper.sh, api-helper.sh
fzf     → interactive selections
bat     → syntax highlighting
gum     → interactive prompts
delta   → enhanced diffs
</ch:required-tools>

<ch:paths>
Scripts: ~/.claude/scripts/
Commands: ~/.claude/commands/
</ch:paths>

<ch:user-customizations>
<!-- Project-specific for claude-helpers -->
This is the claude-helpers project itself. Key points:
- Main entry: setup.sh
- Scripts in scripts/ directory
- Commands in commands/ directory
- Use bash best practices
- Maintain backwards compatibility

## MCP Servers
Project includes .mcp.json with:
- Playwright: For visual testing demos
- Context7: For documentation lookups
</ch:user-customizations>