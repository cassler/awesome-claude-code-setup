# Claude Helper Scripts

<ch:aliases>
ch   → Main helper: ch [category] [command]
chp  → Project overview (run first in new projects)
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
</ch:categories>

<ch:key-commands>
# Start with project overview
chp

# Use helpers not raw commands
chs find-code "pattern"      # not grep
ch m read-many f1 f2 f3      # not multiple cats
chg quick-commit "msg"       # not git add && commit
ch i select-file             # interactive file picker
ch ctx for-task "desc"       # generate focused context
ch api test /endpoint        # test APIs
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
</ch:user-customizations>