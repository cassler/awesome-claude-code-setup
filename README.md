# 🚀 Claude Code Power Tools

**TLDR:** `curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc`

<img src="howdy.png" alt="Claude Code Power Tools" width="200"/>

## What, Why, and How

### 🎯 What
A collection of power tools that supercharge Claude Code with instant commands for common development tasks. Instead of typing the same commands repeatedly or having Claude make multiple tool calls, you get lightning-fast shortcuts that save 50-80% of your context tokens.

### 🤔 Why
**The Problem:** Claude wastes tokens on repetitive tasks. Reading 5 files? That's 5 separate tool calls. Running git status, then diff, then log? More wasted tokens. Other tools "solve" this by loading thousands of tokens of documentation into your context.

**Our Solution:** Ultra-light scripts (~300 tokens total) that live in your environment, not your context. Claude calls them as needed, keeping your conversation focused on actual work.

### 🛠️ How
Based on [Anthropic's official best practices](https://www.anthropic.com/engineering/claude-code-best-practices), we use:
- **Batched operations** - One command instead of many
- **Structured output** - Optimized for Claude's parsing
- **Environmental scripts** - Tools live on your system, not in context
- **Smart shortcuts** - Common workflows in 5 keystrokes or less

## 🚀 Quick Install

```bash
# One-line install (30 seconds)
curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc

# Or clone and review first:
git clone https://github.com/cassler/awesome-claude-code-setup.git
cd awesome-claude-code-setup
./setup.sh
source ~/.zshrc
```

## 📋 Commands Reference

### Slash Commands - Complete Workflows

Type `/` in Claude Code to access these intelligent workflows:

| Command | What it does & When to use |
|---------|----------------------------|
| `/start-feature` | Creates issue, branch, and draft PR. Use when beginning new feature work. |
| `/debug-issue` | Systematic debugging with root cause analysis. Use for complex bugs. |
| `/understand-codebase` | Get comprehensive project overview. Use when starting on a new project. |
| `/tdd` | Test-driven development workflow. Use to write tests before implementation. |
| `/visual-test` | Browser automation and screenshot testing. Use for UI regression testing. |
| `/pre-deploy-check` | Verify production readiness. Use before any deployment. |
| `/commit-and-push` | Complete git workflow with PR checks. Use when work is ready to share. |
| `/tech-debt-hunt` | Find and prioritize technical debt. Use for cleanup planning. |
| `/security-audit` | Scan for vulnerabilities. Use periodically or before releases. |
| `/api-documenter` | Generate API documentation. Use after API changes. |
| `/analyze-dependencies` | Audit all dependencies. Use to check for updates/vulnerabilities. |
| `/refactor-assistant` | Guide systematic refactoring. Use when improving code structure. |
| `/update-docs` | Sync documentation with code. Use after significant changes. |
| `/performance-check` | Find bottlenecks. Use when experiencing slow performance. |
| `/explore-module` | Deep dive into dependencies. Use to understand complex modules. |
| `/gather-tech-docs` | Extract all technical docs. Use for documentation review. |
| `/dev-diary` | Track decisions. Use to document important choices. |
| `/pre-review-check` | Ensure PR readiness. Use before requesting code review. |
| `/post-init-onboarding` | Project onboarding. Use when joining existing project. |

### Shell Scripts & Aliases - Top 10 Most Useful

These are the commands that save the most tokens and time:

| Command | What it does & When to use |
|---------|----------------------------|
| `chp` | **Project overview in one shot.** Use ALWAYS when starting work on any project. Saves 10+ manual commands. |
| `ch nlp tokens file.txt` | **Check token count before reading.** Use to avoid accidentally flooding context with large files. |
| `ch m read-many f1 f2 f3` | **Batch read multiple files.** Use instead of multiple Read tool calls. Saves 50-80% tokens. |
| `chs find-code "pattern"` | **Lightning-fast code search.** Use instead of grep. Returns structured results optimized for Claude. |
| `ch nlp overview file.py` | **Complete code analysis.** Use to get complexity, security, docs, and smells in ONE command. |
| `ch ctx for-task "migration"` | **Generate focused context.** Use to get only relevant files/info for specific task. |
| `ch cr imported-by module` | **Find import dependencies.** Use to understand what depends on a module before changes. |
| `ch m list-structure src/` | **See directory contents.** Use BEFORE reading files to know what's there. |
| `ch cq secrets-scan` | **Security vulnerability scan.** Use periodically to catch exposed secrets/keys. |
| `ch i select-files` | **Interactive file picker.** Use when you need specific files but unsure of exact names. |

**Access pattern:** Most commands follow `ch [category] [command]` format, with shortcuts for the most common ones (`chp`, `chs`, `chg`).

## 🔧 Technical Details

### What Gets Installed
- **Helper scripts** → `~/.claude/scripts/` (17 shell scripts)
- **Slash commands** → `~/.claude/commands/` (19 markdown workflows)  
- **Shell aliases** → Added to `.zshrc`/`.bashrc` (4 shortcuts)
- **Global config** → `~/.claude/CLAUDE.md` (~300 tokens)

### MCP Server Integration
Setup automatically configures:
- **Playwright MCP** - Browser automation and visual testing
- **Context7 MCP** - Real-time documentation for 1000+ libraries

### Dependencies
**Required:**
- `ripgrep` - Fast file searching
- `jq` - JSON processing

**Optional (but recommended):**
- `fzf` - Interactive file selection
- `bat` - Syntax highlighting
- `gum` - Beautiful prompts
- `delta` - Better diffs

### Token Efficiency
| Without Helpers | With Helpers | Savings |
|----------------|--------------|---------|
| 5 file reads = 5 tool calls | `ch m read-many` = 1 call | 80% |
| Load full docs = 5000+ tokens | Scripts in environment = 0 tokens | 100% |
| Manual git workflow = 8+ commands | `chg quick-commit` = 1 command | 87% |

### Customization
Add your own tools:
```bash
# New script
echo '#!/bin/bash' > scripts/my-tool.sh
./setup.sh

# New command  
echo '# My Command' > commands/my-workflow.md
./setup.sh
```

## 🚀 Full Command Reference

For complete documentation of all 17 shell scripts and their 100+ commands, run:
```bash
ch help              # See all categories
ch [category] help   # See commands for specific category
```

## 🤝 Contributing

Found a useful pattern? Share it! PRs welcome at [github.com/cassler/awesome-claude-code-setup](https://github.com/cassler/awesome-claude-code-setup)

## 📄 License

MIT License - Because great tools should be free.