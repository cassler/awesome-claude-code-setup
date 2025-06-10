# Claude Helper Scripts - Quick Reference

You have helper scripts available with shell aliases for quick access!

## 🚀 Quick Access (Shell Aliases)

```bash
# Main helper (shows all categories)
ch

# Project overview - ALWAYS run this first in new projects!
chp

# Search tools - Use this instead of grep/find
chs find-code "pattern"
chs find-file "*.ts"
chs search-function "functionName"

# Git operations
chg status
chg quick-commit "your commit message"
chg pr-ready
```

## 📁 Full Paths (if aliases aren't available)

All scripts are located at: `~/.claude/scripts/`

## 🎯 Common Workflows

### Starting a new project
```bash
# First, get project overview
chp

# Generate focused context for your task
ch ctx for-task "implement user authentication"

# Check environment and tools
ch env tools

# See available npm scripts
ch ts scripts
```

### Searching code efficiently
```bash
# Find code patterns (uses ripgrep for speed)
chs find-code "TODO"
chs search-imports "express"
chs search-function "handleRequest"
chs search-class "UserModel"

# Find files
chs find-file "*.test.ts"
chs find-type "tsx"
```

### Git operations
```bash
# Quick status
chg status

# Quick commit (stages all and commits)
chg quick-commit "Fix: resolved type errors"

# Check if ready for PR
chg pr-ready

# Create PR
chg pr-create "Add new feature"
```

### Docker operations
```bash
ch d ps          # List containers
ch d logs app    # View logs
ch d clean       # Cleanup
ch d shell app   # Get shell in container
```

### Multi-file operations
```bash
# Read multiple files at once (saves tokens!)
ch m read-many src/index.ts src/app.ts src/config.ts

# Read all files matching pattern
ch m read-pattern "*.config.js"

# Compare files
ch m compare file1.ts file2.ts
```

### TypeScript/Node.js
```bash
ch ts deps       # Show dependencies
ch ts scripts    # List npm scripts
ch ts build      # Run build
ch ts lint       # Run linter
ch ts typecheck  # Type checking
```

### Context Generation (NEW!)
```bash
# Generate context for specific tasks
ch ctx for-task "refactor database layer"

# Create and save project summary
ch ctx summarize --save

# Focus on specific directory
ch ctx focus src/api 3

# Prepare migration context
ch ctx prepare-migration "upgrade to next.js 14"
```

## 💡 Key Benefits for Claude

1. **Token Efficiency** - These scripts consolidate multiple operations
2. **Speed** - Uses fast tools like ripgrep when available
3. **Consistency** - Standardized output format
4. **Context** - Provides relevant context in one command

## 📋 All Available Commands

Run `ch help` to see all categories, or:
- `ch project` - Project analysis
- `ch docker` - Docker operations
- `ch git` - Git helpers
- `ch search` - Code searching
- `ch ts` - TypeScript/Node.js
- `ch multi` - Multi-file operations
- `ch env` - Environment checks
- `ch mcp` - MCP server helpers

## 🔧 Setup for New Projects

When starting a new project, copy the template:
```bash
cp /Users/darin/Code/claude-helpers/CLAUDE_TEMPLATE.md ./CLAUDE.md
```

Then customize it with project-specific instructions.