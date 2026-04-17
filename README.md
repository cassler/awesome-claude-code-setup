<p align="center">
<img src="docs/media/howdy.png" alt="Claude Code Power Tools" width="200"/><br />
</p>

<p align="center"><b>
Give Claude Code a head start — it'll feel like it's been on your team for years.
</b></p>

<p align="center">
🎯 21 Slash Commands &bull; ⚡ 17 Shell Tools<br />
🧠 Code Analysis &bull; 🤖 MCP Plugins &bull; 🪝 Automation Hooks<br />
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

## 👋 What is AwesomeClaude?

Claude Code is already incredible — but out of the box, it doesn't know anything about *your* project. Every new session, you're starting from scratch. **AwesomeClaude fixes that.**

One install gives Claude an instant understanding of your codebase, a library of ready-to-use workflows, and smart automations that run quietly in the background. It's built on [Anthropic's own Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) and installs in under a minute.

- ✅ **Instant project understanding** — One command (`chp`) gives Claude everything it needs to know about your project. No explaining, no re-reading files every session.
- ✅ **Complete workflows as slash commands** — `/start-feature`, `/debug-issue`, `/pre-deploy-check` — whole multi-step workflows in a single command.
- ✅ **Catches problems early** — Automatically spots security issues, overly complex code, and common bug patterns before they ship.
- ✅ **Runs quietly in the background** — Auto-formats your files after every edit, notifies you when a long task finishes. Set it once, forget about it.
- ✅ **Connects to your tools** — Browser automation, live docs, GitHub, and more — available when you need them, out of the way when you don't.

## 🚀 Quick Install (30 seconds)

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/cassler/awesome-claude-code-setup/main/setup.sh | bash && source ~/.zshrc

# Or if you prefer to look before you leap:
git clone https://github.com/cassler/awesome-claude-code-setup.git && cd awesome-claude-code-setup && ./setup.sh && source ~/.zshrc
```

That's it! The setup script handles everything — it detects what you already have, installs only what's needed, and works across all your projects from day one.

### 📦 What Gets Installed?

1. **Helper scripts** → `~/.claude/scripts/` (the engine under the hood)
2. **Slash commands** → `~/.claude/commands/` (the workflows you'll actually type)
3. **Shell aliases** → Added to your `.zshrc` or `.bashrc` (short commands like `chp`)
4. **Global config** → `~/.claude/CLAUDE.md` (tells Claude about the tools available)
5. **Hooks config** → `~/.claude/settings.json` (auto-format + notifications, skipped if you already have one)
6. **Scoped rules** → `~/.claude/rules/` (language-specific guidance that loads automatically)

---

## 🤖 Which Claude Model Should I Use?

| Model | Best For |
|---|---|
| **Opus 4.7** | Big, complex tasks — large refactors, tricky bugs, deep reasoning |
| **Sonnet 4.6** | Your everyday go-to — fast, smart, handles most things great |
| **Haiku 4.5** | Quick questions, simple edits, when speed matters most |

> Switch models anytime with `/model` in Claude Code, or use the model picker in the desktop app. Sonnet 4.6 is the default and a great starting point.

---

## 📝 Slash Commands — Your Workflow Superpowers

Just type `/` in Claude Code to pull up any of these. They're full workflows — not just prompts — that walk Claude through each step automatically.

### Building Features

- ✨ `/start-feature` — Creates your GitHub issue, branch, and draft PR in one shot
- 🐛 `/debug-issue` — Traces a bug step by step with root cause analysis
- ✅ `/pre-review-check` — Makes sure your code is ready before asking for a review
- 🚢 `/pre-deploy-check` — Runs through a full production-readiness checklist
- 🔁 `/autofix-pr` — Reads CI failures and review feedback, fixes what it can, pushes

### Understanding Your Code

- 🧠 `/understand-codebase` — Get up to speed on any project quickly
- 🔍 `/explore-module` — Deep dive into how a specific module works
- 📦 `/analyze-dependencies` — See what your project depends on and flag anything risky
- 🌐 `/api-documenter` — Auto-generate documentation for your API endpoints
- 🔧 `/refactor-assistant` — Walk through a refactor safely, step by step

### Docs & Tracking

- 📝 `/update-docs` — Keep documentation in sync with your code
- 📚 `/gather-tech-docs` — Pull together all the technical documentation in a project
- 📓 `/dev-diary` — Track decisions and context as you build
- 🚀 `/post-init-onboarding` — Get oriented in a brand new codebase quickly

### Testing & Quality

- 🧪 `/tdd` — Write your tests first, then build to make them pass
- 🎨 `/visual-test` — Check for visual regressions using Playwright
- 🔒 `/security-audit` — Scan for common security vulnerabilities
- ⚡ `/performance-check` — Find the slow parts of your code
- 💸 `/tech-debt-hunt` — Surface the parts of the codebase that most need attention
- 🔬 `/ultrareview` — Run a thorough multi-angle review of everything on your branch

---

## 🪝 Background Automations (Hooks)

Hooks are little scripts that run automatically when Claude does something — like a formatter that fires every time Claude edits a file, or a notification that pops up when a long task finishes.

**Two hooks come included:**

| Hook | When it runs | What it does |
|---|---|---|
| Auto-format | Every time Claude edits a file | Runs Prettier, Ruff, gofmt, or rustfmt depending on the file type |
| Task done | When Claude finishes working | Sends you a desktop notification so you can step away without babysitting |

These activate automatically when `setup.sh` installs `~/.claude/settings.json`. If you already have that file, check out [docs/hooks-guide.md](docs/hooks-guide.md) to add them manually.

You can also write your own hooks — block certain commands, log everything Claude touches, post to Slack when something finishes. The guide covers all of it.

---

## 🧠 Scoped Rules — Claude Knows Your Style

Scoped rules are instructions for Claude that only activate when it's working on a specific type of file. So your TypeScript rules load when Claude opens a `.ts` file, your Python rules load for `.py` files, and so on — without cluttering up every conversation.

Three rules come built in:

| Rule | Activates for | What it covers |
|---|---|---|
| TypeScript | `.ts`, `.tsx`, `.js`, `.jsx` | Type safety, async best practices, things to avoid |
| Python | `.py` | Type hints, modern Python patterns, formatting |
| Testing | Test files | How to write reliable, maintainable tests |

**Where they live:**
- `~/.claude/rules/` — installed by `setup.sh`, apply across *all* your projects
- `.claude/rules/` in a repo — apply only to *that* project

To add your own rule, create a file with this at the top:

```
---
globs: "**/*.ext"
---
Your rules go here.
```

---

## 🤖 MCP Plugins — Connect Claude to More Tools

MCP plugins extend what Claude can do. The great thing is they only "wake up" when you actually use them — so having them installed doesn't slow anything down.

| Plugin | What it gives Claude |
|---|---|
| **Playwright** | Control a real browser — great for testing UI |
| **Context7** | Up-to-date docs for any library or framework |
| **Filesystem** | Structured access to your files (optional, manual setup) |
| **GitHub** | Read and write issues, PRs, and code on GitHub (needs a token) |
| **Sequential Thinking** | Step-by-step structured reasoning for complex problems |
| **[Not Human Search](https://nothumansearch.ai/mcp)** | Search 8,000+ MCP servers and agent-readable sites; includes `verify_mcp` live probe. Install: `claude mcp add --transport http nothumansearch https://nothumansearch.ai/mcp` |
| **[AI Dev Jobs](https://aidevboard.com/mcp)** | Query 8,400+ AI/ML engineering jobs. Install: `claude mcp add --transport http aidevboard https://aidevboard.com/mcp` |

`setup.sh` handles Playwright and Context7 automatically. The others need a quick manual setup — copy `config/mcp.json` to `~/.claude/mcp.json` and fill in your paths and tokens (there are notes in the file explaining each one).

---

## 🛠️ Shell Helpers — For Claude's Use (and Yours)

These are short commands that Claude uses behind the scenes to work faster in your project. You can run them yourself too!

- **`chp`** — Instant project overview. Run this first in any new project.
- **`chs find-code "something"`** — Search your codebase fast
- **`ch`** — Access any helper: `ch [category] [command]`

| Category | Alias | What it does |
|---|---|---|
| **project** | `p` | Full project overview (`chp`) |
| **search** | `s` | Fast code and file search |
| **git** | `g` | Streamlined git workflows |
| **docker** | `d` | Container management |
| **typescript** | `ts` | Node.js/TypeScript tools |
| **python** | `py` | Python environment and testing |
| **go** | `go` | Go modules and testing |
| **context** | `ctx` | Generate focused context for a specific task |
| **multi** | `m` | Read or process multiple files at once |
| **api** | — | Test HTTP endpoints |
| **interactive** | `i` | Pick files and branches interactively |
| **nlp** | `text` | Code analysis: complexity, security, duplication |

Run `ch [category] help` to see everything in any category.

---

## 🔍 Code Analysis — Spot Problems Before They Ship

The `ch nlp` tools let Claude (or you) analyze code without loading everything into the conversation. Run them before a PR to catch issues early.

```bash
ch nlp overview app.py      # Full picture: complexity, security, quality, docs
ch nlp security auth.py     # Check for accidental secrets or injection risks
ch nlp complexity utils.js  # Find functions that are getting too tangled
ch nlp tokens bigfile.ts    # See how large a file is before loading it
```

No extra tools needed — everything runs with Python's built-in libraries.

---

## 🔧 Required & Optional Tools

**Required** (most systems already have these):
- **ripgrep** — fast searching
- **jq** — JSON processing

**Optional** (setup script will offer to install):
- **fzf** — interactive file and branch picker
- **bat** — syntax-highlighted file viewing
- **gum** — nice-looking CLI prompts
- **delta** — better git diffs
- **httpie** — friendlier HTTP client

---

## ✏️ Make It Yours

**Add a new slash command:**
1. Create `commands/my-command.md` with instructions for Claude
2. Run `./setup.sh`
3. Use it as `/my-command` in Claude Code

**Add a scoped rule:**
1. Create `.claude/rules/my-rule.md`
2. Add `---\nglobs: "**/*.ext"\n---` at the top
3. Write your rules — Claude picks them up automatically

**Add a helper script:**
1. Create `scripts/my-helper.sh`
2. Run `./setup.sh`
3. Access it via `ch myhelper`

---

## 🤝 Contributing

Found a workflow that saves you time? A hook that's been useful? Add it and share it!

1. Fork the repo
2. Add your scripts or commands
3. Open a pull request

---

## 📄 License

MIT License — see LICENSE for details
