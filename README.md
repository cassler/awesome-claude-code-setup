# 🚀 Claude Code Power Tools

Supercharge your Claude Code experience with lightning-fast commands and intelligent workflows.

> 📚 **Based on [Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
> 
> This toolkit implements Anthropic's recommended patterns for working with Claude Code, focusing on:
> - 🚀 **Reducing token usage** through batched operations
> - ⚡ **Improving speed** by scripting repetitive tasks
> - 🎯 **Ensuring consistency** with standardized workflows

### 💡 What developers are saying:
> "I used to type `git add . && git commit -m 'msg' && git push`... now it's just `chg quick-commit 'msg'`" 

> "The `/understand-codebase` command saved me hours on my new project"

> "`chp` gives me instant project context - it's the first thing I run now"

## 🚀 Quick Install (30 seconds)

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc

# Or if you prefer to review first:
git clone https://github.com/cassler/awesome-claude-code-setup.git && cd awesome-claude-code-setup && ./setup.sh && source ~/.zshrc
```

**That's it!** You now have:
- ✅ **Instant commands** like `chp` (full project analysis in 1 second)
- ✅ **Slash commands** in Claude like `/commit-and-push` (complete git workflow)
- ✅ **Zero config** - everything just works

### 🎉 What you'll get:
- ⚡ **10x faster workflows** - Stop typing long commands
- 🧠 **Smarter Claude** - Give it superpowers with these tools
- 💰 **Save tokens** - Batch operations = fewer API calls
- 🚀 **Pro shortcuts** - Work like a 10x developer

### 📖 Why This Exists

Following Anthropic's best practices, these tools solve real problems:

**Without these tools:**
- Claude makes multiple tool calls to gather project info
- You type long commands repeatedly
- Token usage adds up quickly
- Workflows vary between sessions

**With these tools:**
- One command (`chp`) = complete project context
- Shortcuts for everything (`chg quick-commit "msg"`)
- Batched operations save 50-80% on tokens
- Consistent, reproducible workflows every time

## 🎯 Try It Now!

In any project directory:
```bash
# Get instant project overview
chp

# Search for TODOs
chs find-code "TODO"

# Quick commit
chg quick-commit "Fixed the thing"
```

In Claude, type `/` to see your new commands!

## 🌟 Why You'll Love This

### ⚡ Lightning-Fast Commands

| Command | What it does | Example |
|---------|--------------|---------|
| 🔍 `chp` | **Instant project overview** | See languages, deps, structure in 1 second |
| 🔎 `chs find-code` | **Search at light speed** | `chs find-code "TODO"` - uses ripgrep! |
| 🚀 `chg quick-commit` | **Commit in 5 keystrokes** | `chg quick-commit "Fixed the bug"` |
| 🐳 `ch d ps` | **Docker at your fingertips** | Container status without the typing |
| 📦 `ch ts build` | **Node.js shortcuts** | Build, test, lint with less typing |
| 📚 `ch m read-many` | **Read multiple files** | Save tokens, get context fast |

### 🎯 Game-Changing Slash Commands

| Type this | Get this magic | Why it's awesome |
|-----------|----------------|------------------|
| 🔄 `/commit-and-push` | **Complete git workflow** | Commits, pushes, checks PRs - all automated |
| 🧠 `/understand-codebase` | **AI code analysis** | Get up to speed on any project in minutes |
| 🧪 `/tdd` | **Test-driven flow** | Write tests → implement → refactor cycle |
| 📝 `/update-docs` | **Smart documentation** | Keeps docs in sync with your code |
| 🎨 `/visual-test` | **UI testing helper** | Screenshot comparisons and visual QA |
| 📓 `/dev-diary` | **Development notes** | Track decisions and progress |

## 📦 What Gets Installed (Technical Details)

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

### 🛠️ Complete Helper Scripts Collection

| Icon | Script | Alias | What it does | Power Feature |
|------|--------|-------|--------------|---------------|
| 🎯 | **claude-helper.sh** | `ch` | Command central | Route to any tool with 2 letters |
| 📊 | **project-info.sh** | `chp` | Instant project X-ray | Languages, deps, structure in 1 command |
| 🔍 | **search-tools.sh** | `chs` | Code search on steroids | Ripgrep-powered, blazing fast |
| 🚀 | **git-ops.sh** | `chg` | Git workflow accelerator | Commit, push, PR in seconds |
| 🐳 | **docker-quick.sh** | `ch d` | Docker without the hassle | One-letter shortcuts for everything |
| 📦 | **ts-helper.sh** | `ch ts` | Node.js productivity | Build, test, lint, audit in a snap |
| 📚 | **multi-file.sh** | `ch m` | Batch file wizard | Read 10 files as fast as 1 |
| 🔧 | **env-check.sh** | `ch env` | Environment doctor | Instant health check for your setup |
| 🔌 | **mcp-helper.sh** | `ch mcp` | Integration helper | Linear, Notion, browser automation |

### 🎨 Complete Slash Commands Collection

| Icon | Command | What it does | Perfect for |
|------|---------|--------------|-------------|
| 🔄 | `/commit-and-push` | **Git workflow automation** | Review → commit → push → PR check |
| 🧠 | `/understand-codebase` | **AI-powered code analysis** | New project? Understand it in minutes |
| 🧪 | `/tdd` | **Test-driven development** | Red → Green → Refactor workflow |
| 📝 | `/update-docs` | **Smart documentation sync** | Never let docs go stale again |
| 🎨 | `/visual-test` | **Visual regression testing** | Catch UI bugs before users do |
| 📓 | `/dev-diary` | **Development journaling** | Track decisions & progress |
| 📚 | `/gather-tech-docs` | **Doc compilation** | Extract all technical docs |
| 🚀 | `/post-init-onboarding` | **Project onboarding** | Get productive on day 1 |

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