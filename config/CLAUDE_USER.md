# Claude Helper Scripts

These helper scripts provide efficient shortcuts for common development
workflows. They're designed to save tokens and time by bundling multiple
operations into single commands.

<ch:why-use-helpers> 🎯 **Why these helpers are recommended:**

- Single commands that replace multiple manual steps
- Structured output optimized for Claude's understanding
- Automatic error handling and validation
- Token-efficient responses (less back-and-forth)
- Consistent patterns across different tech stacks </ch:why-use-helpers>

<ch:models>

## Recommended Models (Claude 4.x)

| Model | ID | Best For |
|---|---|---|
| **Opus 4.7** | `claude-opus-4-7` | Complex agentic coding, multi-step reasoning, large refactors |
| **Sonnet 4.6** | `claude-sonnet-4-6` | Daily driver — fast, capable, great for most tasks |
| **Haiku 4.5** | `claude-haiku-4-5-20251001` | Quick lookups, simple edits, high-volume batch work |

</ch:models>

<ch:aliases> ch → Main helper: ch [category] [command] chp → Project overview
(highly recommended for new projects!) chs → Search tools: find-code, find-file,
search-imports </ch:aliases>

<ch:categories> project|p → Project analysis docker|d → Container ops: ps, logs,
shell, inspect search|s → Code search (needs: ripgrep)
ts|node → TypeScript/Node.js (needs: jq) python|py → Python development (pip,
poetry, pytest) go|golang → Go development (modules, testing, linting) multi|m →
Multi-file ops (uses: bat) env|e → Environment checks api → API testing (needs:
jq, httpie) interactive|i → Interactive tools (needs: fzf, gum) context|ctx →
Context generation code-relationships|cr → Dependency analysis code-quality|cq →
Quality checks mcp → MCP server operations nlp|text → Static analysis & text
processing (complexity, security, docs) </ch:categories>

<ch:key-commands>

# 🚀 ESSENTIAL WORKFLOW - Start every project with these:
chp                          # ALWAYS run first - comprehensive project overview
ch ctx for-task "desc"       # Generate focused context for specific tasks
ch nlp tokens file.txt       # Check token count BEFORE adding to context

# 🔍 SEARCH & DISCOVERY (clear token savings):
chs find-code "pattern"      # More efficient than grep, structured output
ch s search-imports module   # Find where modules are imported
ch cr imported-by module     # Find who imports this module/file
ch cr dependency-tree dir    # Visualize dependency structure
ch cq console-logs           # Find debug statements quickly
ch cq secrets-scan           # Security scan for exposed secrets

# 📁 FILE OPERATIONS (use with specific files only):
ch m read-many f1 f2 f3      # Batch read SPECIFIC files in ONE call
ch m list-structure dir      # See what's in a directory first
ch nlp tokens file1 file2    # Check sizes before batch reading

# 📊 CODE ANALYSIS (use specific commands for what you need):
ch nlp complexity file.py    # Check cyclomatic complexity
ch nlp security code.py      # Security vulnerability scan
ch nlp smells code.py        # Detect long functions, magic numbers
ch nlp docs code.py          # Check documentation coverage
ch nlp duplicates file.py 5  # Find duplicate code blocks (5+ lines)
ch cq large-files 500        # Find files with 500+ lines

# 🧪 LANGUAGE-SPECIFIC (proven token savers):
ch py deps                   # Show Python dependencies
ch py test                   # Run Python tests
ch py lint                   # Run Python linter
ch go build                  # Build Go project
ch ts check                  # TypeScript type checking

# 🎯 CONTEXT MANAGEMENT (critical for token efficiency):
ch ctx for-task "migration"  # Get only relevant context
ch ctx summarize             # Create project summary
ch ctx focus src/ 2          # Focus on specific directory (depth 2)
ch ctx mdout                 # Extract all markdown outlines

# 💡 TOKEN-SAVING PATTERNS:
# 1. ALWAYS use chp first to understand the project
# 2. Use ch nlp tokens to check file sizes before reading
# 3. Batch operations with ch m read-many for specific files
# 4. Use specific analysis commands for what you need
# 5. Check structure with ch m list-structure before reading
# 6. Focus context with ch ctx for-task for specific work

</ch:key-commands>

<ch:token-efficiency-guide>

## 🎯 CRITICAL TOKEN-SAVING BEST PRACTICES

### When Starting a New Project:

1. **ALWAYS run `chp` first** - This gives comprehensive overview in one shot
2. **Check file sizes with `ch nlp tokens`** before reading large files
3. **Use `ch ctx for-task "description"`** to get focused context only

### Instead of Multiple Tool Calls:

❌ DON'T: Use Read tool 5 times for 5 files
✅ DO: `ch m read-many file1 file2 file3 file4 file5`

❌ DON'T: Run grep, then find, then check imports separately  
✅ DO: Use specific commands for what you need

❌ DON'T: Manually search through files with grep
✅ DO: `chs find-code "pattern"` for structured results

❌ DON'T: Read entire large files without checking size
✅ DO: `ch nlp tokens file.md` first, then decide

### Smart File Discovery:

- **Check first**: `ch m list-structure dir` to see what's there
- **Token count**: `ch nlp tokens file1 file2` before reading
- **Batch specific files**: `ch m read-many` when you know what you need
- **Dependencies**: `ch cr dependency-tree` for understanding structure

### Analysis Best Practices:

- **Use specific analysis**: `ch nlp complexity` instead of overview
- **Check file size first**: `ch nlp tokens` before any analysis
- **Import tracking**: `ch cr imported-by module` for precise results

### Remember:

- These helpers return structured data optimized for Claude's parsing
- Single command = less tokens + faster responses + better accuracy
- Interactive tools (ch i) prevent wrong file selections
  </ch:token-efficiency-guide>

<ch:required-tools> ripgrep → search-tools.sh jq → project-info.sh,
ts-helper.sh, api-helper.sh fzf → interactive selections bat → syntax
highlighting gum → interactive prompts delta → enhanced diffs
</ch:required-tools>

<ch:paths> Scripts: ~/.claude/scripts/ Commands: ~/.claude/commands/ </ch:paths>

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
- Filesystem: Structured file access with path sandboxing
- GitHub: Issues, PRs, and code search (requires GITHUB_TOKEN)
- Sequential Thinking: Structured reasoning for complex problems

Note: MCP servers are lazy-loaded — they only consume context when first used. </ch:user-customizations>
