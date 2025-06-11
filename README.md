# 🚀 Claude Code Power Tools

<img src="howdy.png" alt="Claude Code Power Tools" width="200"/>

Supercharge your Claude Code experience with lightning-fast commands and intelligent workflows.

**🎯 19 Slash Commands** | **⚡ 17 Shell Tools** | **🐍 Python Support** | **🐹 Go Support** | **💰 50-80% Token Savings**

## 🪶 Ultra-Light Context Footprint

**We add only ~300 tokens to Claude's context** - that's it! Unlike other tools that bloat your context window with thousands of lines of documentation, our approach is surgically precise:

- ✅ **~300 tokens** added to your CLAUDE.md file
- ✅ **Everything else is environmental** - scripts live on your system, not in context
- ✅ **No context pollution** - Claude calls scripts as needed, not reads documentation
- ✅ **Maximum efficiency** - More room for your actual code and conversations

> 📚 **Based on [Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
>
> This toolkit implements Anthropic's recommended patterns for working with Claude Code, focusing on:
> - 🚀 **Reducing token usage** through batched operations
> - ⚡ **Improving speed** by scripting repetitive tasks
> - 🎯 **Ensuring consistency** with standardized workflows
> - 🪶 **Minimal context overhead** - just a few hundred tokens!

## 🚀 Quick Install (30 seconds)

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc

# Or if you prefer to review first:
git clone https://github.com/cassler/awesome-claude-code-setup.git && cd awesome-claude-code-setup && ./setup.sh && source ~/.zshrc
```

**That's it!** You now have instant access to powerful commands and workflows.

## 📝 Slash Commands - What You'll Actually Use

Type `/` in Claude to access these complete workflows:

### Development Workflows
- ✨ `/start-feature` - Create issue, branch, and draft PR automatically
- 🐛 `/debug-issue` - Systematic debugging with root cause analysis
- ✅ `/pre-review-check` - Ensure code is review-ready
- 🚢 `/pre-deploy-check` - Production readiness verification

### Analysis & Documentation
- 🧠 `/understand-codebase` - Get up to speed on any project quickly
- 📝 `/update-docs` - Keep documentation in sync with code
- 📚 `/gather-tech-docs` - Extract all technical documentation
- 🔍 `/explore-module` - Deep dive into module dependencies
- 📦 `/analyze-dependencies` - Comprehensive dependency audit
- 🌐 `/api-documenter` - Auto-generate API documentation
- 🔧 `/refactor-assistant` - Systematic refactoring workflow

### Testing & Quality
- 🧪 `/tdd` - Test-driven development workflow
- 🎨 `/visual-test` - Visual regression testing
- 💸 `/tech-debt-hunt` - Find and prioritize technical debt
- 🔒 `/security-audit` - Comprehensive security vulnerability scan
- ⚡ `/performance-check` - Find performance bottlenecks

### Process & Tracking
- 🔄 `/commit-and-push` - Complete git workflow with PR checks
- 📓 `/dev-diary` - Track development decisions
- 🚀 `/post-init-onboarding` - Systematic project onboarding

## 🎯 Shell Commands (How Claude Saves You Tokens)

These aliases are primarily for Claude to efficiently execute tasks without loading documentation into context, but you can use them directly too:

### Essential Shortcuts
- `chp` - **Project overview** - Get instant context about any codebase
- `chs find-code "pattern"` - **Lightning-fast search** using ripgrep
- `chg quick-commit "msg"` - **Git in 5 keystrokes** - stage, commit, push
- `ch` - **Main helper** - Access any tool with `ch [category] [command]`

### Command Categories

| Category | Alias | Key Commands | Purpose |
|----------|-------|--------------|---------|
| **project** | `p` | `chp` → full project overview | Instant codebase analysis |
| **search** | `s` | `find-code`, `find-file`, `search-imports` | Lightning-fast code search |
| **git** | `g` | `quick-commit`, `pr-ready`, `status` | Streamlined git workflows |
| **docker** | `d` | `ps`, `logs`, `shell`, `inspect` | Container management |
| **typescript** | `ts` | `deps`, `build`, `test`, `outdated` | Node.js/TypeScript tools |
| **python** | `py` | `deps`, `test`, `lint`, `venv`, `audit` | Complete Python toolkit |
| **go** | `go` | `deps`, `test`, `build`, `mod`, `audit` | Full Go development |
| **context** | `ctx` | `for-task`, `mdout`, `mdfm`, `mdh` | Smart context generation |
| **multi** | `m` | `read-many`, `read-pattern` | Batch file operations |
| **api** | - | `test`, `watch`, `benchmark` | API testing & monitoring |
| **interactive** | `i` | `select-file`, `select-branch` | Interactive selections |

> 💡 **Usage:** `ch [category] [command]` or use shortcuts like `chp`, `chs`, `chg`  
> 📚 **Full docs:** Run `ch [category] help` to see all commands for any category

## 💡 Why Use This?

### Token Usage Comparison

| Approach | Context Tokens | Example |
|----------|---------------|---------|
| **Other tools** | 5,000-15,000 tokens | Full documentation loaded in context |
| **Manual work** | 1,000+ tokens per task | Multiple file reads, repeated commands |
| **Claude Helpers** | **~300 tokens total** | Tiny config + environmental scripts |

### Without these tools:
- Claude makes multiple tool calls to gather project info
- You type long commands repeatedly
- Token usage adds up quickly
- Workflows vary between sessions

### With these tools:
- One command (`chp`) = complete project context
- Shortcuts for everything (`chg quick-commit "msg"`)
- Batched operations save 50-80% on tokens
- Consistent, reproducible workflows
- **Your context stays clean for actual work**

## 📦 What Gets Installed

1. **Helper scripts** → `~/.claude/scripts/`
2. **Slash commands** → `~/.claude/commands/`
3. **Shell aliases** → Added to your `.zshrc` or `.bashrc`
4. **Global config** → `~/.claude/CLAUDE.md` (auto-updated)

## 🔧 Required & Optional Tools

### Required
- **ripgrep** - Fast file searching (search-tools.sh)
- **jq** - JSON processing (project-info.sh, ts-helper.sh, api-helper.sh)

### Optional Enhancements
- **fzf** - Interactive fuzzy finder
- **bat** - Syntax highlighting
- **gum** - Beautiful CLI prompts
- **delta** - Enhanced git diffs
- **httpie** - Better HTTP client

The setup script will offer to install missing tools automatically.

## 🛠️ Customization

### Adding New Scripts
1. Create script in `scripts/my-helper.sh`
2. Run `./setup.sh` to install
3. Access via `ch myhelper` or add to main helper

### Adding New Commands
1. Create markdown in `commands/my-command.md`
2. Run `./setup.sh` to install
3. Use in Claude as `/my-command`

## 📚 Full Script Reference

For detailed documentation of all scripts and their options, see the [Script Reference Guide](#script-reference-guide) below.

---

<details>
<summary><h2>📖 Script Reference Guide</h2></summary>

### 🎯 Main Entry Point

#### **claude-helper.sh** (`ch`)
The main router providing access to all other scripts through simple shortcuts.

**Usage**: `ch <category> [command] [args]`

**Example**: `ch project`, `ch git status`, `ch search find-code "pattern"`

---

### 📊 Project Analysis

#### **project-info.sh** (`chp`)
Provides instant project overview including languages, dependencies, and structure.

**Usage**: `chp [path]`

**Output**: Languages, key files, dependencies, docker config, directory structure, git info, size metrics

---

### 🔍 Search Tools

#### **search-tools.sh** (`chs`)
Lightning-fast code searching using ripgrep.

**Commands**:
- `find-code <pattern>` - Find code pattern
- `find-file <pattern>` - Find files by name
- `find-type <ext>` - Find files by extension
- `search-imports <module>` - Search import statements
- `search-function <name>` - Search function definitions
- `search-class <name>` - Search class definitions
- `todo-comments` - Find TODO/FIXME comments
- `large-files [size]` - Find large files
- `recent-files [days]` - Find recently modified
- `count-lines` - Count lines by file type

---

### 🚀 Git Operations

#### **git-ops.sh** (`chg`)
Git operations and workflow helpers.

**Key Commands**:
- `status` - Quick status overview
- `quick-commit <message>` - Stage all & commit
- `pr-ready` - Check if ready for PR
- `pr-create <title> [body]` - Create PR with gh
- `recent [n]` - Show recent commits
- `file-history <file>` - Show file history

---

### 🐳 Docker Operations

#### **docker-quick.sh** (`ch d`)
Quick Docker operations and container management.

**Commands**:
- `ps` - Show running containers
- `logs <name>` - Tail logs for container
- `shell <name>` - Get shell in container
- `inspect <name>` - Inspect container (formatted)
- `clean` - Clean up Docker resources
- `compose-up` - Docker-compose up -d
- `compose-logs [service]` - Docker-compose logs

---

### 📦 TypeScript/Node.js

#### **ts-helper.sh** (`ch ts`)
TypeScript and Node.js project utilities.

**Commands**:
- `deps` - Show dependencies overview
- `scripts` - List available npm scripts
- `build` - Run build script
- `test` - Run tests
- `lint` - Run linter
- `typecheck` - Run TypeScript type check
- `outdated` - Check outdated packages
- `audit` - Security audit

---

### 📚 Multi-File Operations

#### **multi-file.sh** (`ch m`)
Operations on multiple files simultaneously to save tokens.

**Commands**:
- `read-many <file1> <file2> ...` - Read multiple files
- `read-pattern <pattern> [lines]` - Read files matching pattern
- `compare <file1> <file2>` - Compare two files
- `read-related <file>` - Read file and related files

---

### 🎯 Context Generation

#### **claude-context.sh** (`ch ctx`)
Generate optimal context for Claude by analyzing codebase.

**Commands**:
- `for-task <description>` - Generate context for specific task
- `summarize [--save]` - Create codebase summary
- `focus <directory> [depth]` - Focus on specific directory
- `prepare-migration <description>` - Prepare context for migration

---

### 🔗 Code Relationships

#### **code-relationships.sh** (`ch cr`)
Analyze dependencies and imports between files.

**Commands**:
- `imports-of <file>` - Show what a file imports
- `imported-by <file/module>` - Find who imports a file/module
- `dependency-tree <dir> [depth]` - Show dependency structure
- `circular [dir]` - Check for circular dependencies

---

### ✅ Code Quality

#### **code-quality.sh** (`ch cq`)
Find issues and improve code quality.

**Commands**:
- `todos [--with-context]` - Find TODO/FIXME/HACK comments
- `console-logs` - Find console.log statements
- `large-files [threshold]` - Find files exceeding line count
- `complexity [threshold]` - Find complex code patterns
- `secrets-scan` - Scan for potential secrets

---

### 🌐 API Testing

#### **api-helper.sh** (`ch api`)
Comprehensive API testing toolkit with JSON manipulation.

**Commands**:
- `test <endpoint>` - Send HTTP request
- `parse <file>` - Pretty-print JSON
- `compare <file1> <file2>` - Compare API responses
- `extract <file> <path>` - Extract data using jq
- `validate <file>` - Validate JSON structure

---

### 🎨 Interactive Tools

#### **interactive-helper.sh** (`ch i`)
Enhanced interactive selection using fzf and gum.

**Commands**:
- `select-file` - Interactive file selection with preview
- `select-files` - Select multiple files
- `select-script` - Choose and run npm/yarn script
- `select-branch` - Switch git branch interactively
- `search-and-edit` - Search code and edit files
- `quick-commit` - Interactive commit with preview

---

### 🔧 Environment Checks

#### **env-check.sh** (`ch env`)
Check development environment, tools, and requirements.

**Commands**:
- `tools` - Check common dev tools
- `node` - Node.js environment details
- `python` - Python environment details
- `docker` - Docker environment status
- `git` - Git configuration
- `ports` - Common ports status

---

### 🔌 MCP Helpers

#### **mcp-helper.sh** (`ch mcp`)
Shortcuts for MCP (Model Context Protocol) server operations.

**Commands**:
- `linear-issues` - List Linear issues
- `notion-search <query>` - Search Notion
- `browser-open <url>` - Open in browser
- `mastra-docs [topic]` - Mastra documentation

</details>

## 🤝 Contributing

1. Fork the repository
2. Add your scripts/commands
3. Submit a pull request
4. Share your improvements!

## 📄 License

MIT License - see LICENSE file for details