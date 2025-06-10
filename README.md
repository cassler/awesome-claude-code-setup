# Claude Helper Scripts

A comprehensive collection of bash scripts and commands designed to enhance Claude Code's efficiency with common development tasks.

## 🚀 Installation

```bash
# Clone the repository
git clone git@github.com:cassler/awesome-claude-code-setup.git
cd awesome-claude-code-setup

# Run the setup script
./setup.sh

# Reload your shell configuration
source ~/.zshrc  # or ~/.bashrc
```

## 📦 What Gets Installed

Running `setup.sh` will:

1. **Install helper scripts** to `~/.claude/scripts/`
   - All bash scripts for various development tasks
   - Made executable and ready to use

2. **Install Claude commands** to `~/.claude/commands/`
   - Markdown files that appear as slash commands in Claude
   - Available via `/` in your Claude interface

3. **Add shell aliases** to your `.zshrc` or `.bashrc`
   - `ch` - Main claude helper
   - `chp` - Project info shortcut
   - `chs` - Search tools shortcut
   - `chg` - Git operations shortcut

4. **Create a template** at `CLAUDE_TEMPLATE.md`
   - Copy this to new projects as `CLAUDE.md` for project-specific instructions

## 🎯 How It Works in Claude

After installation, you'll have:

### Shell Aliases (for Claude to use)
```bash
# Quick project overview
chp

# Search for code patterns
chs find-code "TODO"

# Git operations
chg status
chg quick-commit "your message"

# Main helper for all commands
ch help
```

### Slash Commands (in Claude interface)
Type `/` in Claude to see available commands:
- `/commit-and-push` - Commit and push workflow
- `/dev-diary` - Development diary entries
- `/gather-tech-docs` - Collect technical documentation
- `/post-init-onboarding` - Project onboarding
- `/tdd` - Test-driven development workflow
- `/understand-codebase` - Codebase analysis
- `/update-docs` - Documentation updates
- `/visual-test` - Visual testing workflow

## 📂 Directory Structure After Installation

```
~/.claude/
├── scripts/          # Bash helper scripts
│   ├── claude-helper.sh
│   ├── project-info.sh
│   ├── search-tools.sh
│   ├── git-ops.sh
│   └── ... (more scripts)
├── commands/         # Slash commands for Claude
│   ├── commit-and-push.md
│   ├── dev-diary.md
│   └── ... (more commands)
└── CLAUDE.md        # Your global Claude instructions
```

## 🛠️ Customization Guide

### Adding New Scripts

1. **Create a new script**:
   ```bash
   # Create your script
   echo '#!/bin/bash' > scripts/my-helper.sh
   chmod +x scripts/my-helper.sh
   ```

2. **Add to main helper** (optional):
   Edit `scripts/claude-helper.sh` to add a new case:
   ```bash
   "myhelper"|"mh")
       shift
       "$SCRIPT_DIR/my-helper.sh" "$@"
       ;;
   ```

3. **Run setup again**:
   ```bash
   ./setup.sh
   ```

### Adding New Commands

1. **Create a markdown file** in `commands/`:
   ```markdown
   # My Custom Command
   
   Please help me with...
   ```

2. **Run setup**:
   ```bash
   ./setup.sh
   ```

3. **Command appears** in Claude as `/my-custom-command`

### Modifying Existing Scripts

1. **Edit the script** in this repository
2. **Run setup** to update: `./setup.sh`
3. Changes are immediately available

### Removing Scripts/Commands

1. **Delete the file** from `scripts/` or `commands/`
2. **Run setup** to clean up: `./setup.sh`
3. **Remove alias** from `.zshrc`/`.bashrc` if needed

## 🔧 Available Scripts

### Main Entry Point
- `claude-helper.sh` - Routes to all other helpers

### Individual Scripts

1. **project-info.sh** - Project overview
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

4. **search-tools.sh** - Code searching
   - Uses ripgrep when available
   - Find patterns, files, imports
   - TODO comment search
   - Code statistics

5. **ts-helper.sh** - TypeScript/Node.js
   - Dependency management
   - Build/test/lint shortcuts
   - Package auditing
   - Size analysis

6. **multi-file.sh** - Batch operations
   - Read multiple files
   - Pattern-based operations
   - File comparison
   - Structure analysis

7. **env-check.sh** - Environment validation
   - Tool availability checks
   - Version information
   - Port status
   - Project requirements

8. **mcp-helper.sh** - MCP server helpers
   - Linear integration hints
   - Notion helpers
   - Browser automation guides
   - Documentation lookups

## 💡 Usage Examples

```bash
# Project overview
chp

# Docker status
ch docker ps
ch d logs mycontainer

# Git operations
chg status
chg quick-commit "Fix: resolved type errors"
chg pr-ready

# Search operations
chs find-code "TODO"
chs search-imports "express"
chs find-file "*.test.ts"

# TypeScript/Node
ch ts deps
ch ts build
ch ts test

# Multi-file operations
ch m read-many src/index.ts src/app.ts
ch m read-pattern "*.config.js"

# Environment checks
ch env tools
ch env node
```

## 🤝 Sharing With Your Team

1. **Fork this repository**
2. **Add your custom scripts/commands**
3. **Share your fork** with team members
4. Team runs `./setup.sh` from your fork

## 🐛 Troubleshooting

### Aliases not working
```bash
# Reload your shell config
source ~/.zshrc  # or ~/.bashrc

# Check if aliases exist
alias | grep ch
```

### Scripts not found
```bash
# Check installation
ls ~/.claude/scripts/

# Re-run setup
./setup.sh
```

### Commands not appearing in Claude
1. Restart Claude Code
2. Check `~/.claude/commands/` for `.md` files
3. Ensure files have `.md` extension

## 🎉 Benefits for Claude

These scripts help Claude be more efficient by:
- Reducing multiple tool calls into single commands
- Providing consolidated information quickly
- Offering shortcuts for common operations
- Minimizing token usage through efficient data gathering
- Standardizing workflows across projects

## 📝 Contributing

1. Fork the repository
2. Add your scripts/commands
3. Submit a pull request
4. Share your improvements!

## 📄 License

MIT License - see LICENSE file for details