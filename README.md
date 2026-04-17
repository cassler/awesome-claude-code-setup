<p align="center">
<img src="docs/media/howdy.png" alt="Claude Code Power Tools" width="200"/><br />
</p>

<p align="center"><b>
Supercharge your Claude Code experience with lightning-fast commands and intelligent workflows.
</b></p>

<p align="center">
🎯 21 Slash Commands &bull; ⚡ 17 Shell Tools<br />
🧠 NLP Analysis &bull; 🤖 MCP Servers &bull; 🪝 Hooks &bull; 💰 50-80% Token Savings<br />
📦 TypeScript/JS &bull; 🐍 Python &bull; 🐹 Go &bull; 🦀 Rust<br /><br />
Brought to you by<br />
<a href='https://pressw.ai&utm_source=github&utm_medium=readme&utm_campaign=claude-code-power-tools'>
  <img src="docs/media/pressw.png" alt="Claude Code Power Tools" width="100"/>
</a>
</p>

<p align="center">
<img src="https://github.com/cassler/awesome-claude-code-setup/actions/workflows/smoke-test-macos.yml/badge.svg" alt="macOS Tests" />
<img src="https://github.com/cassler/awesome-claude-code-setup/actions/workflows/smoke-test-linux.yml/badge.svg" alt="Linux Tests" />
</p>

## 🪶 What is AwesomeClaude?

AwesomeClaude is **based on
[Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)** -
implementing their recommended patterns for reducing token usage through batched
operations, improving speed by scripting repetitive tasks, ensuring consistency
with standardized workflows, and maintaining minimal context overhead. **Like a
seasoned engineer, we focus on mastering the environment Claude works in** - not
just adding more tools, but building the right foundation. **We add only ~300
tokens to Claude's context** while providing professional-grade capabilities:

- ✅ **Token-Conscious Bash** - scripts, automations, and cli tools to minimize
  token usage while maximizing power.
- ✅ **NLP-Powered Code Analysis** - static analysis, code quality, and
  documentation insights without external dependencies.
- ✅ **Thoughtful Batching** - We keep complex business logic where it belongs:
  in code, not in Claude's context.
- ✅ **SDLC Best-Practices** - We provide complete workflows for feature
  development, debugging, testing, documentation, git ops and deployment with
  simple slash commands.
- ✅ **Hooks & Automation** - Auto-format files after edits, send notifications
  on task completion, and enforce policies without lifting a finger.
- ✅ **MCP Server Integration** - Playwright, Context7, GitHub, Filesystem, and
  Sequential Thinking — lazy-loaded so they never bloat your context.

## 🚀 Quick Install (30 seconds)

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc

# Or if you prefer to review first:
git clone https://github.com/cassler/awesome-claude-code-setup.git && cd awesome-claude-code-setup && ./setup.sh && source ~/.zshrc
```

**That's it!** You now have instant access to powerful commands and workflows.
Setup handles everything automatically!

- Detects existing servers to avoid duplicates
- Installs only what you need
- Works at user level - available in all projects
- Falls back to manual instructions if needed

### 📦 What Gets Installed?

1. **Helper scripts** → `~/.claude/scripts/`
2. **Slash commands** → `~/.claude/commands/`
3. **Shell aliases** → Added to your `.zshrc` or `.bashrc`
4. **Global config** → `~/.claude/CLAUDE.md` (auto-updated)
5. **Hooks config** → `~/.claude/settings.json`
6. **Scoped rules** → `~/.claude/rules/` (auto-loaded by file type)

---

## 🤖 Claude 4.x Model Reference

| Model | ID | Best For |
|---|---|---|
| **Opus 4.7** | `claude-opus-4-7` | Complex agentic coding, large refactors, multi-step reasoning |
| **Sonnet 4.6** | `claude-sonnet-4-6` | Daily driver — fast, capable, excellent value |
| **Haiku 4.5** | `claude-haiku-4-5-20251001` | Quick edits, lookups, high-volume batch tasks |

> Claude Code defaults to Sonnet 4.6. Switch models with `/model` or the model picker in the desktop app.

---

## 🪝 Hooks — Automation Without Lifting a Finger

Hooks run shell commands automatically in response to Claude's actions. This
repo ships two ready-to-use hooks and a `settings.json` template to activate them.

### Included Hooks

| Hook | Trigger | What it does |
|---|---|---|
| `post-edit.sh` | After every `Edit` or `Write` | Auto-formats the file (Prettier, Ruff, gofmt, rustfmt) |
| `notify.sh` | When Claude finishes a task | Desktop notification via `osascript` (macOS) or `notify-send` (Linux) |

### Activating Hooks

```bash
cp config/settings.json ~/.claude/settings.json
# Restart Claude Code
```

The `settings.json` also includes a curated `permissions.allow` list so Claude
can run common git, npm, make, pytest, and go commands without prompting you
every time.

→ **Full documentation:** [docs/hooks-guide.md](docs/hooks-guide.md)

---

## 🧠 Scoped Rules (.claude/rules/)

Rules in `.claude/rules/` are CLAUDE.md files that **only load when Claude
works with matching file types** — keeping context lean while ensuring
language-specific guidance is always available.

| Rule file | Loads for | Covers |
|---|---|---|
| `typescript.md` | `*.ts`, `*.tsx`, `*.js`, `*.jsx` | Type safety, async patterns, no-`any` policy |
| `python.md` | `*.py` | Type hints, pathlib, ruff, dataclasses |
| `testing.md` | Test files (`*.test.*`, `test_*.py`, etc.) | Deterministic tests, one-assertion-per-test |

Add your own by creating `.claude/rules/my-rule.md` with a `globs:` front matter field.

---

## 🤖 MCP Servers — Lazy-Loaded, Zero Context Cost

Claude Code **lazy-loads** MCP servers — they only consume context tokens when
first invoked. You can enable all servers without any overhead on unrelated tasks.

| Server | Package | Purpose |
|---|---|---|
| **Playwright** | `@playwright/mcp` | Browser automation, visual testing, screenshots |
| **Context7** | `@upstash/context7-mcp` | Up-to-date library & framework docs |
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Structured file access with path sandboxing |
| **GitHub** | `@modelcontextprotocol/server-github` | Issues, PRs, code search (needs `GITHUB_TOKEN`) |
| **Sequential Thinking** | `@modelcontextprotocol/server-sequential-thinking` | Structured multi-step reasoning |

Config lives in `config/mcp.json`. Copy to `~/.claude/mcp.json` or let
`setup.sh` handle it.

---

## 🆕 2025-2026 Claude Code Features

### Auto Mode

Run Claude with autonomous permission decisions — a safety classifier reviews
actions before execution and blocks truly risky operations (mass deletion, data
exfiltration):

```bash
claude --enable-auto-mode
```

A safer alternative to `--dangerously-skip-permissions` for long autonomous tasks.

### Plan Mode

Draft a step-by-step plan before Claude writes any code. Review and edit the
plan, then approve execution. Activate with `/plan` in Claude Code or via the
web editor.

### Routines (Pro/Max/Team/Enterprise)

Bundle a prompt, repository, and connectors into a reusable configuration that
runs on a schedule, fires from an API call, or triggers off GitHub events.
Execution happens on Anthropic's infrastructure — no laptop required.

### Desktop App & VS Code

- **Desktop app** (Mac/Windows): Manage multiple parallel sessions from one window,
  with a sidebar, drag-and-drop layout, integrated terminal, rebuilt diff viewer,
  and a side-chat shortcut (**Cmd+;**) for branching questions.
- **VS Code extension**: Inline diffs in a dedicated sidebar panel with real-time
  visibility of Claude's changes.

---

## 📝 Slash Commands — What You'll Actually Use

Type `/` in Claude to access these complete workflows:

### Development Workflows

- ✨ `/start-feature` - Create issue, branch, and draft PR automatically
- 🐛 `/debug-issue` - Systematic debugging with root cause analysis
- ✅ `/pre-review-check` - Ensure code is review-ready
- 🚢 `/pre-deploy-check` - Production readiness verification
- 🔁 `/autofix-pr` - **New** — automatically fix CI failures and review feedback

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
- 🔬 `/ultrareview` - **New** — deep multi-agent code review on a branch diff

### Process & Tracking

- 🔄 `/commit-and-push` - Complete git workflow with PR checks
- 📓 `/dev-diary` - Track development decisions
- 🚀 `/post-init-onboarding` - Systematic project onboarding

---

## 🎯 Shell Commands (How Claude Saves You Tokens)

These aliases are primarily for Claude to efficiently execute tasks without
loading documentation into context, but you can use them directly too:

### Essential Shortcuts

- `chp` - **Project overview** - Get instant context about any codebase
- `chs find-code "pattern"` - **Lightning-fast search** using ripgrep
- `ch` - **Main helper** - Access any tool with `ch [category] [command]`

### Command Categories

| Category        | Alias  | Key Commands                                 | Purpose                     |
| --------------- | ------ | -------------------------------------------- | --------------------------- |
| **project**     | `p`    | `chp` → full project overview                | Instant codebase analysis   |
| **search**      | `s`    | `find-code`, `find-file`, `search-imports`   | Lightning-fast code search  |
| **git**         | `g`    | `quick-commit`, `pr-ready`, `status`         | Streamlined git workflows   |
| **docker**      | `d`    | `ps`, `logs`, `shell`, `inspect`             | Container management        |
| **typescript**  | `ts`   | `deps`, `build`, `test`, `outdated`          | Node.js/TypeScript tools    |
| **python**      | `py`   | `deps`, `test`, `lint`, `venv`, `audit`      | Complete Python toolkit     |
| **go**          | `go`   | `deps`, `test`, `build`, `mod`, `audit`      | Full Go development         |
| **context**     | `ctx`  | `for-task`, `mdout`, `mdfm`, `mdh`           | Smart context generation    |
| **multi**       | `m`    | `read-many`, `read-pattern`                  | Batch file operations       |
| **api**         | -      | `test`, `watch`, `benchmark`                 | API testing & monitoring    |
| **interactive** | `i`    | `select-file`, `select-branch`               | Interactive selections      |
| **nlp**         | `text` | `tokens`, `complexity`, `security`, `smells` | 🧠 AI-powered code analysis |

> 💡 **Usage:** `ch [category] [command]` or use shortcuts like `chp`, `chs` 📚
> **Full docs:** Run `ch [category] help` to see all commands for any category

## 🧠 NLP & Code Analysis - Your AI-Powered Code Review

**Powerful static analysis without external dependencies!** Our NLP toolkit uses
only Python's standard library to provide:

### 📊 Token Management

- **`ch nlp tokens file.py`** - Know the cost before reading files
- **Smart batching** - Check multiple files: `ch nlp tokens src/*.js`
- **Prevent context bloat** - Never accidentally load massive files

### 🔍 Code Quality Analysis

- **`ch nlp complexity file.py`** - Cyclomatic complexity scoring
- **`ch nlp security code.py`** - Find SQL injection, hardcoded secrets, unsafe
  operations
- **`ch nlp smells code.py`** - Detect long functions, deep nesting, magic
  numbers
- **`ch nlp duplicates src/ 5`** - Find duplicate code blocks (5+ lines)
- **`ch nlp docs module.py`** - Documentation coverage analysis

### 📝 Text Processing

- **`ch nlp summary README.md`** - Extract key points from documentation
- **`ch nlp keywords article.md 20`** - Extract top keywords
- **`ch nlp readability docs.md`** - Calculate readability scores
- **`ch nlp sentiment "review text"`** - Analyze text sentiment

### 🎯 One Command, Complete Analysis

```bash
ch nlp overview app.py
```

Returns everything: complexity scores, security issues, code smells,
documentation coverage, and improvement suggestions - all in one structured
output!

## 💡 Why Use This?

### Token Usage Comparison

| Approach           | Context Tokens         | Example                                |
| ------------------ | ---------------------- | -------------------------------------- |
| **Other tools**    | 5,000-15,000 tokens    | Full documentation loaded in context   |
| **Manual work**    | 1,000+ tokens per task | Multiple file reads, repeated commands |
| **Claude Helpers** | **~300 tokens total**  | Tiny config + environmental scripts    |

### Without these tools:

- Claude makes multiple tool calls to gather project info
- You type long commands repeatedly
- Token usage adds up quickly
- Workflows vary between sessions

### With these tools:

- One command (`chp`) = complete project context
- Shortcuts for everything (`chs find-code "pattern"`)
- Batched operations save 50-80% on tokens
- AI-powered analysis (`ch nlp overview file.py` = complexity + security +
  quality)
- Token awareness (`ch nlp tokens` before reading large files)
- Consistent, reproducible workflows
- **Your context stays clean for actual work**

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

### Adding Scoped Rules

1. Create `.claude/rules/my-rule.md`
2. Add front matter: `---\nglobs: "**/*.ext"\n---`
3. Write your rules — Claude loads them automatically for matching files

## 🤝 Contributing

1. Fork the repository
2. Add your scripts/commands
3. Submit a pull request
4. Share your improvements!

## 📄 License

MIT License - see LICENSE file for details
