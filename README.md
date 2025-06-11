# 🚀 Claude Code Power Tools

<img src="howdy.png" alt="Claude Code Power Tools" width="200"/>

Supercharge your Claude Code experience with lightning-fast commands and
intelligent workflows.

**🎯 14 Slash Commands** | **⚡ 13 Shell Tools** | **💰 50-80% Token Savings**

> 📚 **Based on
> [Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
>
> This toolkit implements Anthropic's recommended patterns for working with
> Claude Code, focusing on:
>
> - 🚀 **Reducing token usage** through batched operations
> - ⚡ **Improving speed** by scripting repetitive tasks
> - 🎯 **Ensuring consistency** with standardized workflows

### 💡 What developers are saying:

> "I used to type `git add . && git commit -m 'msg' && git push`... now it's
> just `chg quick-commit 'msg'`"

> "The `/understand-codebase` command saved me hours on my new project"

> "`chp` gives me instant project context - it's the first thing I run now"

> "The API testing tools replaced my need for Postman in most cases"

> "Interactive file selection with `ch i select-file` is a game changer"

## 🚀 Quick Install (30 seconds)

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc

# Or if you prefer to review first:
git clone https://github.com/cassler/awesome-claude-code-setup.git && cd awesome-claude-code-setup && ./setup.sh && source ~/.zshrc
```

**That's it!** You now have:

- ✅ **Instant commands** like `chp` (full project analysis in 1 second)
- ✅ **14 Slash commands** in Claude like `/start-feature` (complete workflows)
- ✅ **Zero config** - everything just works

## 🎯 Slash Commands - Your New Superpowers

Type `/` in Claude to access these complete workflows:

### 🚀 Development Workflows

| Command                | What it does                      | Perfect for                                       |
| ---------------------- | --------------------------------- | ------------------------------------------------- |
| ✨ `/start-feature`    | **Feature development kickstart** | Creates issue, branch, draft PR automatically     |
| 🐛 `/debug-issue`      | **Systematic debugging**          | Traces errors, finds root cause, creates fix PR   |
| ✅ `/pre-review-check` | **Code review readiness**         | Quality checks, removes debug code, updates PR    |
| 🔍 `/explore-module`   | **Deep code analysis**            | Understand any module's structure & dependencies  |
| 💸 `/tech-debt-hunt`   | **Debt discovery**                | Find and prioritize technical debt with estimates |
| 🚢 `/pre-deploy-check` | **Deployment safety**             | Security scans, build verification, rollback plan |

### 📝 Documentation & Testing

| Command                   | What it does                | Perfect for                               |
| ------------------------- | --------------------------- | ----------------------------------------- |
| 🧠 `/understand-codebase` | **AI code analysis**        | Get up to speed on any project in minutes |
| 🧪 `/tdd`                 | **Test-driven development** | Red → Green → Refactor workflow           |
| 📝 `/update-docs`         | **Smart documentation**     | Keep docs in sync with code changes       |
| 🎨 `/visual-test`         | **Visual testing**          | Screenshot comparisons and visual QA      |
| 📚 `/gather-tech-docs`    | **Doc compilation**         | Extract all technical documentation       |

### 🔄 Git & Process

| Command                    | What it does              | Perfect for                             |
| -------------------------- | ------------------------- | --------------------------------------- |
| 🔄 `/commit-and-push`      | **Complete git workflow** | Review, commit, push, check PR feedback |
| 📓 `/dev-diary`            | **Development journal**   | Track decisions, progress, and blockers |
| 🚀 `/post-init-onboarding` | **Project onboarding**    | Understand new codebases systematically |

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

## ⚡ Shell Commands - Lightning Fast Operations

Run these in your terminal for instant results:

| Command               | What it does                  | Example                                           |
| --------------------- | ----------------------------- | ------------------------------------------------- |
| 🔍 `chp`              | **Instant project overview**  | See languages, deps, structure in 1 second        |
| 🔎 `chs find-code`    | **Search at light speed**     | `chs find-code "TODO"` - uses ripgrep!            |
| 🚀 `chg quick-commit` | **Commit in 5 keystrokes**    | `chg quick-commit "Fixed the bug"`                |
| 🐳 `ch d ps`          | **Docker at your fingertips** | Container status without the typing               |
| 📦 `ch ts build`      | **Node.js shortcuts**         | Build, test, lint with less typing                |
| 📚 `ch m read-many`   | **Read multiple files**       | Save tokens, get context fast                     |
| 🎯 `ch ctx for-task`  | **Smart context generation**  | `ch ctx for-task "refactor auth"` - instant focus |
| 🔗 `ch cr imports-of` | **Code relationships**        | Trace dependencies and imports                    |
| ✅ `ch cq todos`      | **Code quality checks**       | Find TODOs, debug code, complexity                |
| 🌐 `ch api test`      | **API testing toolkit**       | Test REST APIs with httpie/curl                   |
| 🎨 `ch i select-file` | **Interactive selection**     | Use fzf/gum for beautiful file picking            |

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

2. **Add to main helper** (optional): Edit `scripts/claude-helper.sh` to add a
   new case:

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

## 🎯 Optional Tools Enhancement

The scripts now include intelligent support for optional tools that enhance functionality while maintaining fallback options:

### Enhanced Experience Tools

| Tool | Purpose | Scripts That Use It | Install Command |
| ---- | ------- | ------------------- | --------------- |
| **fzf** | Interactive fuzzy finder | Interactive helper, search tools | `brew install fzf` |
| **bat** | Syntax highlighting | File viewing, interactive selection | `brew install bat` |
| **gum** | Beautiful CLI prompts | Interactive tools, API helper | `brew install gum` |
| **delta** | Enhanced diffs | Git operations, file comparison | `brew install git-delta` |
| **httpie** | Better HTTP client | API testing | `brew install httpie` |
| **jq** ⚠️ | JSON processor | API helper, project info | `brew install jq` |
| **ripgrep** | Fast searching | Search tools | `brew install ripgrep` |

⚠️ **Note**: `jq` is currently required for several scripts to function properly. Please install it using the command shown above. We're working on adding fallbacks in [issue #22](https://github.com/cassler/awesome-claude-code-setup/issues/22).

### How It Works

1. **Automatic Detection** - Scripts check for optional tools at runtime
2. **Graceful Degradation** - Falls back to basic alternatives if not installed
3. **Install Suggestions** - Prompts with install commands when beneficial
4. **Cross-Platform** - Works on macOS, Linux, and WSL

Example behavior:
```bash
# With fzf installed
ch i select-file  # Beautiful interactive file picker with preview

# Without fzf
ch i select-file  # Falls back to numbered list selection
```

## 🔧 Complete Command Reference

### All Available Commands

| Command                    | What it does                                               |
| -------------------------- | ---------------------------------------------------------- |
| **Shell Commands**         |                                                            |
| 🎯 `ch`                    | Main command router - access any tool with 2 letters       |
| 📊 `chp`                   | Instant project overview - languages, deps, structure      |
| 🔍 `chs`                   | Lightning-fast code search powered by ripgrep              |
| 🚀 `chg`                   | Git shortcuts - commit, push, PR in seconds                |
| 🐳 `ch d`                  | Docker management with one-letter shortcuts                |
| 📦 `ch ts`                 | Node.js/TypeScript - build, test, lint, audit              |
| 📚 `ch m`                  | Read multiple files efficiently, save tokens               |
| 🔧 `ch env`                | Environment health checks and tool verification            |
| 🔌 `ch mcp`                | MCP integrations - Linear, Notion, browser                 |
| 🎯 `ch ctx`                | Generate optimal context, reduce token usage               |
| 🔗 `ch cr`                 | Analyze code relationships and dependencies                |
| ✅ `ch cq`                 | Check code quality - TODOs, complexity, secrets            |
| 🌐 `ch api`                | API testing toolkit - test, parse, compare responses       |
| 🎨 `ch i`                  | Interactive tools - file selection with fzf/gum            |
| **Slash Commands**         |                                                            |
| 🔄 `/commit-and-push`      | Complete git workflow - review, commit, push, check PRs    |
| 🧠 `/understand-codebase`  | AI-powered analysis to understand any project in minutes   |
| 🧪 `/tdd`                  | Test-driven development workflow - Red → Green → Refactor  |
| 📝 `/update-docs`          | Keep documentation in sync with code changes               |
| 🎨 `/visual-test`          | Visual regression testing and screenshot comparisons       |
| 📓 `/dev-diary`            | Track development decisions and progress                   |
| 📚 `/gather-tech-docs`     | Extract and compile all technical documentation            |
| 🚀 `/post-init-onboarding` | Systematic project onboarding for productivity             |
| ✨ `/start-feature`        | Kickstart features with issue, branch, and draft PR        |
| 🐛 `/debug-issue`          | Systematic debugging with error tracing and fix workflow   |
| ✅ `/pre-review-check`     | Ensure code is review-ready with quality checks            |
| 🔍 `/explore-module`       | Deep dive into any module's structure and dependencies     |
| 💸 `/tech-debt-hunt`       | Discover and prioritize technical debt with estimates      |
| 🚢 `/pre-deploy-check`     | Verify production readiness with security and build checks |

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

## 📚 Script Reference Guide - Complete Documentation

This section provides detailed documentation for every script, including all
arguments and usage examples.

### 🎯 Main Entry Point

#### **claude-helper.sh** (`ch`)

The main router that provides access to all other scripts through simple
shortcuts.

**Usage**: `ch <category> [command] [args]`

**Categories**:

- `project|p` - Project overview and analysis
- `docker|d` - Docker operations
- `git|g` - Git operations
- `search|s` - Code searching tools
- `ts|typescript|node` - TypeScript/Node.js helpers
- `multi|m` - Multi-file operations
- `env|e` - Environment checks
- `mcp` - MCP server helpers
- `context|ctx` - Claude context generation
- `code-relationships|cr` - Analyze code dependencies
- `code-quality|cq` - Check code quality

**Examples**:

```bash
ch p                    # Project overview
ch g status             # Git status
ch s find-code pattern  # Search code
ch ts deps              # Show dependencies
```

---

### 📊 Project Analysis Scripts

#### **project-info.sh** (`chp`)

Provides instant project overview including languages, dependencies, and
structure.

**Usage**: `chp [path]`

**Arguments**:

- `path` (optional) - Path to analyze (default: current directory)

**Output includes**:

- Languages detected
- Key files (README, package.json, etc.)
- Node.js project info (dependencies, scripts)
- Docker configuration
- Directory structure
- Git information
- Project size metrics

**Example**:

```bash
chp                    # Analyze current directory
chp /path/to/project   # Analyze specific project
```

---

#### **claude-context.sh** (`ch ctx`)

Generate optimal context for Claude by analyzing codebase and creating focused
summaries.

**Usage**: `ch ctx <command> [args]`

**Commands**:

- `for-task|task <description>` - Generate context for specific task
- `summarize [--save]` - Create codebase summary (optionally save to CLAUDE.md)
- `focus <directory> [depth]` - Focus on specific directory (default depth: 2)
- `prepare-migration <description>` - Prepare context for migration

**Examples**:

```bash
ch ctx for-task "refactor authentication"
ch ctx summarize --save
ch ctx focus src/api 3
ch ctx prepare-migration "upgrade to react 18"
```

---

### 🔍 Search and Analysis Scripts

#### **search-tools.sh** (`chs`)

Lightning-fast code searching using ripgrep (falls back to grep if unavailable).

**Usage**: `chs <command> [args]`

**Commands**:

- `find-code|fc <pattern>` - Find code pattern
- `find-file|ff <pattern>` - Find files by name
- `find-type|ft <ext>` - Find files by extension
- `search-imports|si <module>` - Search import statements
- `search-function|sf <name>` - Search function definitions
- `search-class|sc <name>` - Search class definitions
- `todo-comments|todo` - Find TODO/FIXME comments
- `large-files|lf [size]` - Find large files (default: 1M)
- `recent-files|rf [days]` - Recently modified (default: 1 day)
- `count-lines|cl` - Count lines by file type
- `search-all|sa <pattern>` - Comprehensive search

**Examples**:

```bash
chs find-code "handleRequest"
chs find-file "*.test.ts"
chs search-imports "express"
chs recent-files 7
chs large-files 500K
```

---

#### **code-relationships.sh** (`ch cr`)

Analyze dependencies and imports between files.

**Usage**: `ch cr <command> [args]`

**Commands**:

- `imports-of <file>` - Show what a file imports
- `imported-by <file/module>` - Find who imports a file/module
- `dependency-tree <dir> [depth]` - Show dependency structure (default depth: 3)
- `circular [dir]` - Check for circular dependencies

**Examples**:

```bash
ch cr imports-of src/index.js
ch cr imported-by utils
ch cr dependency-tree src/components 2
ch cr circular src
```

---

#### **code-quality.sh** (`ch cq`)

Find issues and improve code quality.

**Usage**: `ch cq <command> [args]`

**Commands**:

- `todos [--with-context]` - Find TODO/FIXME/HACK comments
- `console-logs` - Find console.log statements
- `large-files [threshold]` - Find files exceeding line count (default: 500)
- `complexity [threshold]` - Find complex code patterns (default: 15)
- `secrets-scan` - Scan for potential secrets

**Examples**:

```bash
ch cq todos --with-context
ch cq large-files 300
ch cq complexity 10
ch cq secrets-scan
```

---

### 🚀 Git Operations

#### **git-ops.sh** (`chg`)

Git operations and workflow helpers.

**Usage**: `chg <command> [args]`

**Commands**:

- `status|st` - Quick status overview
- `info` - Detailed git information
- `branches|br` - List branches with details
- `quick-commit|qc <message>` - Stage all & commit
- `amend` - Amend last commit (keep message)
- `unstage` - Unstage all files
- `discard <file>|--all` - Discard changes
- `stash-quick|sq [message]` - Quick stash
- `pr-ready` - Check if ready for PR
- `pr-create <title> [body]` - Create PR with gh
- `recent [n]` - Show recent commits (default: 10)
- `diff-stat [ref]` - Show diff statistics
- `contributors` - Show top contributors
- `file-history <file>` - Show file history
- `undo-last` - Undo last commit (keep changes)
- `remote-sync` - Sync with remote

**Examples**:

```bash
chg quick-commit "Fix: resolved type errors"
chg pr-ready
chg pr-create "Add new feature" "This PR adds..."
chg file-history src/app.js
chg recent 20
```

---

### 🐳 Docker Operations

#### **docker-quick.sh** (`ch d`)

Quick Docker operations and container management.

**Usage**: `ch d <command> [args]`

**Commands**:

- `ps|list` - Show running containers
- `all` - Show all containers (including stopped)
- `images` - List Docker images
- `logs <name>` - Tail logs for container
- `shell|exec <name> [command]` - Get shell in container
- `inspect <name>` - Inspect container (formatted)
- `clean|cleanup` - Clean up Docker resources
- `stats` - Show container statistics
- `compose-up` - Docker-compose up -d
- `compose-down` - Docker-compose down
- `compose-logs [service]` - Docker-compose logs
- `volumes` - List volumes
- `networks` - List networks
- `quick-run <image> [command]` - Quick run container
- `build [tag]` - Build Dockerfile in current dir

**Examples**:

```bash
ch d ps
ch d logs myapp
ch d shell myapp /bin/bash
ch d clean
ch d compose-up
ch d quick-run ubuntu:latest /bin/bash
```

---

### 📦 TypeScript/Node.js Helpers

#### **ts-helper.sh** (`ch ts`)

TypeScript and Node.js project utilities.

**Usage**: `ch ts <command> [args]`

**Commands**:

- `deps|dependencies` - Show dependencies overview
- `scripts` - List available npm scripts
- `quick-install|qi` - Install with detected package manager
- `build` - Run build script
- `test` - Run tests
- `lint` - Run linter
- `typecheck|tc` - Run TypeScript type check
- `outdated` - Check outdated packages
- `audit` - Security audit
- `clean` - Clean build artifacts
- `size` - Check package sizes
- `dev` - Run dev server
- `quick-add|qa <pkg>` - Quick add package

**Examples**:

```bash
ch ts deps
ch ts scripts
ch ts quick-install
ch ts quick-add lodash
ch ts outdated
ch ts typecheck
```

---

### 📚 Multi-File Operations

#### **multi-file.sh** (`ch m`)

Operations on multiple files simultaneously to save tokens.

**Usage**: `ch m <command> [args]`

**Commands**:

- `read-many|rm <file1> <file2> ...` - Read multiple files
- `read-pattern|rp <pattern> [lines]` - Read files matching pattern
- `list-structure|ls [dir]` - List files with structure info
- `grep-many|gm <pattern> <file1> ...` - Grep in specific files
- `compare|cmp <file1> <file2>` - Compare two files
- `find-similar|fs <base-name>` - Find similar filenames
- `batch-rename|br <old> <new>` - Preview batch rename
- `read-related|rr <file>` - Read file and related files
- `create-many|cm <type> <file1> ...` - Preview creating files

**Examples**:

```bash
ch m read-many src/index.ts src/app.ts src/config.ts
ch m read-pattern "*.config.js" 100
ch m compare file1.ts file2.ts
ch m read-related src/components/Button.tsx
ch m create-many ts src/new-file.ts src/another.ts
```

---

### 🔧 Environment Checks

#### **env-check.sh** (`ch env`)

Check development environment, tools, and project requirements.

**Usage**: `ch env <command>`

**Commands**:

- `tools` (default) - Check common dev tools
- `node` - Node.js environment details
- `python` - Python environment details
- `docker` - Docker environment status
- `git` - Git configuration
- `ports` - Common ports status (3000, 8080, etc.)
- `env` - Environment variables
- `system` - System information
- `project` - Project-specific requirements

**Examples**:

```bash
ch env tools
ch env node
ch env ports
ch env project
```

---

### 🔌 MCP Helpers

#### **mcp-helper.sh** (`ch mcp`)

Shortcuts for MCP (Model Context Protocol) server operations.

**Usage**: `ch mcp <command> [args]`

**Commands**:

- `linear-issues|li` - List Linear issues overview
- `linear-search|ls <query>` - Search Linear
- `notion-search|ns <query>` - Search Notion
- `notion-page|np <id>` - View Notion page
- `browser-open|bo <url>` - Open in browser
- `browser-screenshot|bs [filename]` - Take screenshot
- `mastra-docs|md [topic]` - Mastra documentation
- `context7|c7 <library>` - Library docs lookup
- `mcp-list|list` - List all MCP servers
- `quick-task|qt <title>` - Task creation helper

**Examples**:

```bash
ch mcp linear-search "authentication bug"
ch mcp notion-search "API documentation"
ch mcp browser-open "https://example.com"
ch mcp mastra-docs agents
```

---

### 🌐 API Testing Tools

#### **api-helper.sh** (`ch api`)

Comprehensive API testing and development toolkit with JSON manipulation.

**Usage**: `ch api <command> [args] [options]`

**Commands**:

- `test <endpoint>` - Send HTTP request to endpoint
- `parse <file>` - Parse and pretty-print JSON
- `compare <file1> <file2>` - Compare two API responses
- `extract <file> <path>` - Extract data using jq path
- `validate <file>` - Validate JSON structure
- `save-headers <file>` - Save reusable headers

**Options**:

- `--base-url URL` - Set base URL for requests
- `--headers FILE` - Use headers from JSON file
- `--method METHOD` - HTTP method (GET, POST, etc.)
- `--data DATA` - Request body data
- `--save` - Save response to timestamped file

**Examples**:

```bash
ch api test /users --base-url https://api.example.com
ch api test /users --method POST --data '{"name":"John"}' --save
ch api parse response.json
ch api extract response.json '.data.users[0]'
ch api compare response1.json response2.json
ch api validate data.json
ch api save-headers auth-headers.json
```

---

### 🎨 Interactive Tools

#### **interactive-helper.sh** (`ch i`)

Enhanced interactive selection and workflow tools using fzf and gum.

**Usage**: `ch i <command> [args]`

**Commands**:

- `select-file` - Interactive file selection with preview
- `select-files` - Select multiple files (requires fzf)
- `select-script` - Choose and run npm/yarn script
- `select-branch` - Switch git branch interactively
- `search-and-edit` - Search code and edit files
- `quick-commit` - Interactive commit with preview

**Examples**:

```bash
ch i select-file           # Pick a file with preview
ch i select-files          # Select multiple files
ch i select-script         # Run npm script interactively
ch i select-branch         # Switch branches with preview
ch i search-and-edit       # Find and edit code
ch i quick-commit          # Commit with interactive staging
```

**Tool Support**:
- Works best with `fzf` for fuzzy finding
- Uses `bat` for syntax highlighting
- Falls back to `gum` for prompts
- Degrades gracefully to basic selection

---

### 🛠️ Common Functions Library

#### **common-functions.sh**

Shared utility functions used by all scripts (not directly executable).

**Key Functions**:

- Error handling: `error_exit`, `warn`, `success`
- Command checking: `check_command`, `check_dependencies`
- Text utilities: `slugify`, `validate_input`, `is_stop_word`
- Git utilities: `check_git_repo`, `get_current_branch`
- File utilities: `check_file`, `ensure_dir`, `quote_path`

This script is sourced by other scripts to provide common functionality.

---

### 💡 Pro Tips

1. **Chain commands** for complex workflows:

   ```bash
   chg pr-ready && ch cq todos && ch ts typecheck
   ```

2. **Use aliases** for even faster access:

   ```bash
   alias qc="chg quick-commit"
   alias todo="chs todo-comments"
   ```

3. **Combine with shell features**:

   ```bash
   ch m read-pattern "*.ts" | grep "interface"
   ```

4. **Save token usage** with multi-file operations:

   ```bash
   # Instead of reading files one by one
   ch m read-many $(find src -name "*.config.ts")
   ```

5. **Quick project analysis pipeline**:
   ```bash
   chp && ch cr dependency-tree src && ch cq todos
   ```

## 📄 License

MIT License - see LICENSE file for details
