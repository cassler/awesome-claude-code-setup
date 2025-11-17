# Claude Code Updates 2024

This document tracks major Claude Code updates and how AwesomeClaude integrates them.

## November 2024 Updates (v2.0.41-2.0.42)

### ⏮️ Rewind Feature
**What it does**: Roll back code state and conversation context to previous points

**How to use**:
- Invoke with `/rewind` command or double-escape
- Specify how far back to rewind
- Affects both conversational context and working directory/project state

**Use cases**:
- Recover from errors or unwanted changes
- Safely experiment with different approaches
- Reset context when conversation becomes unfocused
- Undo edits while preserving earlier work

### 🔧 Enhanced Environment Variables
**New variables for improved workflow integration**:

- `CLAUDE_PROJECT_DIR` - Identifies root context for AI operations and relative path resolution
- `CLAUDE_PLUGIN_ROOT` - Enables plugin sharing and custom output styles

**How AwesomeClaude uses them**:
- Scripts automatically detect and use `CLAUDE_PROJECT_DIR` when available
- Helper commands respect project-scoped operations
- Enhanced bash command processing throughout the toolkit

### ⚙️ Slash Command Improvements
**What's new**:
- Ctrl-R history search fixes for slash commands
- SDK support for custom timeouts on hooks
- More git commands allowed to run safely without manual approval
- Plugins now support sharing and installing output styles
- Teleportation from web automatically sets upstream Git branch

**Impact on AwesomeClaude**:
- Slash commands in `commands/` directory work more reliably
- Better integration with git workflows
- Improved performance with custom timeouts

### 🔒 Security Enhancements
**Improvements**:
- Better documentation and onboarding trust dialogs
- Automated permissions with improved local settings control
- More granular approval controls for file operations

**AwesomeClaude alignment**:
- `/security-audit` command leverages enhanced security features
- `ch cq secrets-scan` provides additional security layer
- `/pre-review-check` includes security validations

### 🐛 Bug Fixes
- Correct computation of idleness for notifications
- Fixed menu navigation issues
- Plugin hook timeout crashes resolved
- VS Code extension respects `chat.fontSize` and `chat.fontFamily` instantly
- `DISABLE_AUTOUPDATER` environment variable works properly

## October 2024 Updates

### 🤖 New Models
**Claude Haiku 4.5**: 
- Small, fast model for code and computer tasks
- Matches larger model performance at lower cost
- Ideal for agent use cases

**Claude Sonnet 4.5**: 
- Advanced model for accurate coding
- Better real-world agent task performance
- Improved context handling

**AwesomeClaude optimization**:
- Token-saving helpers work even better with new models
- Faster responses with Haiku 4.5 for simple tasks
- Better accuracy with Sonnet 4.5 for complex refactoring

### 📄 File Operations
**New capabilities**:
- Direct create/edit for Excel, PowerPoint, docs, and PDFs
- Batch automation support
- Available on Claude for Pro plans and mobile

### 🧠 Memory Features
**What's new**:
- Memory summaries and recall for Max, Enterprise, Team, and Pro users
- Incognito chats keep conversations private from memory tracking

**How to leverage with AwesomeClaude**:
- Memory works alongside `ch ctx` commands
- Project-specific patterns are remembered across sessions
- `/dev-diary` command benefits from memory features

### 🛠️ Tool and SDK Improvements
**Python/TypeScript SDK enhancements**:
- Type-safe input validation
- Automated tool running in conversations
- Better error handling

### 🚀 Performance Improvements
**Native Fuzzy Finder**:
- Significant speed-up for file path suggestions
- Rust-based engine for faster searches
- Works seamlessly with AwesomeClaude's `fzf` integration

### 🔐 Code Execution Tool
**Secure Python sandbox**:
- Now available in Claude API/SDK
- Database and code operations support
- Expanded automation for CI flow

## 🤖 Subagents - Specialized AI Assistants

Subagents are one of Claude Code's most powerful features for managing complex workflows and context.

### What are Subagents?
Subagents are pre-configured AI personalities that Claude Code can delegate tasks to. Each subagent:

- **Specific purpose and expertise** - Focused on particular types of tasks
- **Separate context window** - Operates independently from main conversation
- **Custom tools** - Can be configured with specific tools it's allowed to use
- **Custom system prompt** - Includes detailed instructions that guide its behavior

### Key Benefits

**Context Preservation**
- Each subagent operates in its own context
- Prevents pollution of main conversation
- Keeps main thread focused on high-level objectives

**Specialized Expertise**
- Fine-tuned with detailed instructions for specific domains
- Higher success rates on designated tasks
- Can use different models for different tasks (Sonnet, Opus, Haiku)

**Reusability**
- Once created, can be used across different projects
- Shareable with your team for consistent workflows
- Version control with your project

**Flexible Permissions**
- Each subagent can have different tool access levels
- Limit powerful tools to specific subagent types
- Better security and focus

### Creating Subagents

**Using `/agents` command (Recommended)**:
```bash
/agents
```

This opens an interactive interface where you can:
- View all available subagents (built-in, user, and project)
- Create new subagents with guided setup
- Edit existing subagents, including tool access
- Delete custom subagents
- Manage tool permissions with complete list of available tools

**File-based configuration**:
Subagents are stored as Markdown files with YAML frontmatter:

**Project-level**: `.claude/agents/` (available in current project, highest priority)
**User-level**: `~/.claude/agents/` (available across all projects)

Example subagent file:
```markdown
---
name: code-reviewer
description: Expert code reviewer. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is simple and readable
- Functions and variables are well-named
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Input validation implemented
```

### Built-in Subagents

**Plan Subagent**:
- Used automatically during plan mode (non-execution mode)
- Uses Sonnet for capable analysis
- Has Read, Glob, Grep, and Bash tools
- Searches files, analyzes code structure, gathers context
- Prevents infinite nesting of agents

### Using Subagents

**Automatic delegation**:
Claude Code proactively delegates based on:
- Task description in your request
- Description field in subagent configurations
- Current context and available tools

Tip: Include phrases like "use PROACTIVELY" or "MUST BE USED" in description field.

**Explicit invocation**:
```
> Use the test-runner subagent to fix failing tests
> Have the code-reviewer subagent look at my recent changes
> Ask the debugger subagent to investigate this error
```

**Resumable subagents**:
Continue previous conversations for long-running tasks:
```
> Use the code-analyzer agent to start reviewing the authentication module
[Agent returns agentId: "abc123"]

> Resume agent abc123 and now analyze the authorization logic
```

### How AwesomeClaude Leverages Subagents

**Slash Commands as Subagent Templates**:
Many of our slash commands (like `/security-audit`, `/debug-issue`, `/code-reviewer`) follow patterns that work excellently as subagent definitions. You can:

1. Create a subagent based on a slash command workflow
2. Use the subagent for automatic, proactive task handling
3. Maintain slash command for explicit, guided workflows

**Recommended Subagents for AwesomeClaude**:

Create these in `.claude/agents/` for your projects:

**code-quality.md** - Proactive code review using our analysis tools
**debugger.md** - Systematic debugging with our helper scripts
**security-scanner.md** - Automatic security checks using `ch nlp security`
**test-runner.md** - Runs tests and fixes failures proactively

Each subagent can leverage AwesomeClaude's helper commands like `chp`, `chs`, `ch nlp`, etc.

### Best Practices

1. **Start with Claude-generated agents** - Generate initial subagent with Claude, then customize
2. **Design focused subagents** - Single, clear responsibilities
3. **Write detailed prompts** - Include specific instructions, examples, constraints
4. **Limit tool access** - Only grant necessary tools
5. **Version control** - Check project subagents into version control
6. **Use descriptive names** - Clear naming helps Claude select appropriate subagent
7. **Leverage AwesomeClaude helpers** - Include our efficient commands in subagent workflows

### CLI-based Configuration

You can also define subagents dynamically:
```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

Priority: CLI-defined < user-level < project-level

## Token Optimization Best Practices (2024)

Based on Anthropic's recommendations and community feedback:

### 1. CLAUDE.md Usage
- **Define file/folder scope**: Specify which files to read or ignore
- **Use .gitignore patterns**: Exclude node_modules, dist, build artifacts
- **Keep it concise**: Focus on essential instructions only
- **Update regularly**: Keep it in sync with project evolution

### 2. Context Management
- **Compact files**: Maintain small, focused files for less context
- **Direct instructions**: Be specific about what needs changing
- **Minimize edits**: Batch related changes together
- **Clear organization**: Separation of concerns reduces token overhead

### 3. MCP Server Management
- **Disable unused servers**: Each server adds tool definitions to system prompt
- **Enable on demand**: Only activate what's needed for current task
- **Monitor overhead**: Check token usage with different server combinations

### 4. Semantic Search Integration
- **Vector databases**: Use for precise data retrieval
- **External memory servers**: Persistent data recall without repetition
- **Smart indexing**: Pre-process large codebases

### 5. Monitoring and Control
- **Track usage**: Use dashboards to identify bottlenecks
- **Set quotas**: Prevent unexpected costs
- **Analyze patterns**: Understand which operations consume most tokens

### 6. Prompt Design
- **Numbered steps**: Structure complex tasks clearly
- **"think" keywords**: Use judiciously for complex reasoning
  - `think` - thorough analysis
  - `think hard` / `ultrathink` - maximum reasoning budget
- **Context-aware**: Reference previous outputs instead of repeating

## How AwesomeClaude Implements Best Practices

### Token-Saving Architecture
1. **Helper scripts** (~300 tokens) replace large documentation
2. **Batched operations** via `ch m read-many` save 50-80% tokens
3. **Structured output** optimized for Claude's parsing
4. **Single commands** replace multiple tool calls

### Smart Context Generation
1. **`chp`** - Comprehensive project overview in one shot
2. **`ch ctx for-task`** - Generate focused context for specific work
3. **`ch nlp tokens`** - Check token count before reading files
4. **`ch m list-structure`** - See what's available before loading

### Automated Workflows
1. **Slash commands** encode complex workflows in ~100-500 tokens
2. **Consistent patterns** reduce need for repeated instructions
3. **Error handling** built into scripts prevents token waste on retries

### Security Integration
1. **`ch nlp security`** - Vulnerability detection without external tools
2. **`ch cq secrets-scan`** - Find exposed credentials quickly
3. **`/pre-review-check`** - Automated security validation

## CLI Reference and Settings

Understanding Claude Code's CLI and settings system enables powerful customization and automation.

### CLI Commands and Modes

**Interactive REPL**:
```bash
claude                    # Start interactive session
claude "initial query"    # Start with a prompt
```

**Non-Interactive (Print) Mode**:
```bash
claude -p "query"              # Print single answer and exit
cat file | claude -p "query"   # Pipe content for analysis
```

**Session Management**:
```bash
claude -c                      # Continue most recent conversation
claude -r <session-id> "query" # Resume specific session
```

**Configuration**:
```bash
claude mcp                     # Configure MCP servers
claude config list             # List all settings
claude config set <key> <val>  # Set a config value
claude config get <key>        # Get a config value
claude update                  # Update to latest version
```

### Key CLI Flags

**Directory and Context Control**:
- `--add-dir <path>` - Add directory to context
- `--system-prompt <text>` - Custom system prompt
- `--allowedTools <tools>` - Whitelist specific tools
- `--disallowedTools <tools>` - Blacklist specific tools

**Output and Display**:
- `--output-format <format>` - Output as plain, json, or stream
- `--verbose` - Detailed logging
- `-v` / `--version` - Show version

**Agent Configuration**:
- `--agents <json>` - Define subagents dynamically
- `--model <alias>` - Specify model (sonnet, opus, haiku)

### Settings System

Claude Code uses a layered settings system with clear precedence:

**Precedence Order (highest to lowest)**:
1. **Enterprise Policy** - System-wide, unchangeable (`/etc/claude-code/managed-settings.json`)
2. **CLI Arguments** - Override all for current invocation
3. **Project Local** - `.claude/settings.local.json` (personal, not shared)
4. **Project Shared** - `.claude/settings.json` (team-shared, version controlled)
5. **User Global** - `~/.claude/settings.json` (user defaults)

### Settings Configuration

**Example `.claude/settings.json`**:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test:*)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl:*)",
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  },
  "companyAnnouncements": [
    "Reminder: Code reviews required for all PRs"
  ],
  "defaultModel": "sonnet",
  "subagentModel": "sonnet"
}
```

**Key Settings Categories**:

**Permissions**:
- Control which tools and operations are allowed/denied
- Pattern matching for flexible rules
- Protect sensitive files and operations

**Environment Variables**:
- Set project-specific environment variables
- Available to all Claude Code operations
- Can include API keys, paths, etc.

**Model Configuration**:
- `defaultModel` - Model for main conversation
- `subagentModel` - Default model for subagents
- Model aliases: `sonnet`, `opus`, `haiku`

**Company/Team Settings**:
- Announcements displayed at startup
- Shared conventions and policies
- Cleanup policies for temporary files

### Using CLI with AwesomeClaude

**Combine AwesomeClaude helpers with CLI flags**:
```bash
# Start with project context loaded
claude --add-dir . "Run chp and explain the architecture"

# Use specific subagent with our tools
claude --agents '{
  "security": {
    "description": "Security scanner using AwesomeClaude tools",
    "prompt": "Use ch nlp security and ch cq secrets-scan",
    "tools": ["Bash", "Read"]
  }
}'

# Automated analysis
echo "src/auth.js" | claude -p "Run ch nlp security on this file"
```

**Settings for AwesomeClaude workflows**:
```json
{
  "permissions": {
    "allow": [
      "Bash(ch *)",
      "Bash(chp)",
      "Bash(chs *)",
      "Read(~/.claude/**)"
    ]
  },
  "env": {
    "CLAUDE_HELPERS": "$HOME/.claude/scripts"
  }
}
```

### Best Practices for CLI and Settings

1. **Use project settings for team consistency** - Check `.claude/settings.json` into version control
2. **Protect sensitive operations** - Use deny rules for dangerous commands
3. **Set up proper permissions** - Whitelist safe operations, blacklist risky ones
4. **Document team conventions** - Use companyAnnouncements for reminders
5. **Test CLI flags** - Use `--verbose` to debug issues
6. **Leverage session management** - Use `-c` to continue conversations efficiently

## Migration Guide

If you're upgrading from earlier versions:

### For Users
1. Pull latest changes: `cd awesome-claude-code-setup && git pull`
2. Run setup: `./setup.sh`
3. Reload shell: `source ~/.zshrc` or `source ~/.bashrc`
4. Verify: `ch help` should show all commands

### For Contributors
1. Review new environment variables in your scripts
2. Update slash commands to leverage new features
3. Test with both Haiku 4.5 and Sonnet 4.5
4. Add security checks where appropriate

## Resources

**Official Claude Code Documentation**:
- [Claude Code Overview](https://code.claude.com/docs/en/overview)
- [CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [Settings Documentation](https://code.claude.com/docs/en/settings)
- [Subagents Guide](https://code.claude.com/docs/en/sub-agents)
- [Official Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)

**Best Practices and Guides**:
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Release Notes](https://support.claude.com/en/articles/12138966-release-notes)
- [Token Optimization Guide](https://claudelog.com/faqs/how-to-optimize-claude-code-token-usage/)

## Stay Updated

AwesomeClaude is actively maintained to reflect Claude Code best practices. Follow the repository for updates:
- Watch releases on GitHub
- Check this document quarterly
- Join discussions in Issues
