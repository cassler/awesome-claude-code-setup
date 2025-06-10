# Claude Helper Scripts

A collection of bash scripts designed to help Claude (and developers) work more efficiently with common development tasks.

## Quick Start

```bash
./scripts/claude-helper.sh help
```

## Available Scripts

### Main Entry Point
- `claude-helper.sh` - Main script that routes to all other helpers

### Individual Scripts

1. **project-info.sh** - Quick project overview
   - Language detection
   - Dependencies analysis
   - Directory structure
   - Git status

2. **docker-quick.sh** - Docker operations
   - Container management
   - Image operations
   - Docker-compose shortcuts
   - Cleanup utilities

3. **git-ops.sh** - Git operations
   - Status overviews
   - Quick commits
   - PR creation
   - Branch management

4. **search-tools.sh** - Efficient code searching
   - Uses ripgrep when available
   - Find patterns, files, imports
   - TODO comment search
   - Code statistics

5. **ts-helper.sh** - TypeScript/Node.js helpers
   - Dependency management
   - Build/test/lint shortcuts
   - Package auditing
   - Size analysis

6. **multi-file.sh** - Batch file operations
   - Read multiple files
   - Pattern-based operations
   - File comparison
   - Structure analysis

7. **env-check.sh** - Environment validation
   - Tool availability checks
   - Version information
   - Port status
   - Project requirements

8. **mcp-helper.sh** - MCP server shortcuts
   - Linear integration hints
   - Notion helpers
   - Browser automation guides
   - Documentation lookups

## Usage Examples

```bash
# Project overview
./scripts/project-info.sh

# Docker containers status
./scripts/docker-quick.sh ps

# Git quick commit
./scripts/git-ops.sh quick-commit "Fix: resolved type errors"

# Search for a pattern
./scripts/search-tools.sh find-code "TODO"

# Check Node.js dependencies
./scripts/ts-helper.sh deps

# Read multiple files
./scripts/multi-file.sh read-many src/index.ts src/app.ts

# Check development environment
./scripts/env-check.sh tools

# Or use the main helper
./scripts/claude-helper.sh git status
./scripts/claude-helper.sh search find-code "pattern"
```

## Benefits for Claude

These scripts help Claude be more efficient by:
- Reducing the need for multiple tool calls
- Providing consolidated information quickly
- Offering shortcuts for common operations
- Minimizing token usage through efficient data gathering

## Adding New Scripts

To add a new helper script:
1. Create a new `.sh` file in the `scripts/` directory
2. Make it executable: `chmod +x scripts/new-script.sh`
3. Add a new case in `claude-helper.sh` to route to it
4. Update this README with the new script's documentation