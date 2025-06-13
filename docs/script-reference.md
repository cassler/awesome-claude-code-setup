## 📚 Full Script Reference

For detailed documentation of all scripts and their options, see the
[Script Reference Guide](#script-reference-guide) below.

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

Provides instant project overview including languages, dependencies, and
structure.

**Usage**: `chp [path]`

**Output**: Languages, key files, dependencies, docker config, directory
structure, git info, size metrics

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

### 🧠 NLP & Static Analysis

#### **nlp-helper.sh** (`ch nlp`)

Comprehensive static analysis and text processing using Python stdlib.

**Text Analysis Commands**:

- `tokens <file>` - Count characters, words, and estimate tokens
- `summary <file>` - Extract headers and first paragraph
- `keywords <file> [n]` - Show top N keywords (default: 10)
- `questions <file>` - Extract all questions from text
- `sentiment "text"` - Analyze sentiment of text
- `readability <file>` - Calculate readability score
- `ngrams <n> <file>` - Extract n-grams (word pairs, triplets)
- `entities <file>` - Extract potential named entities

**Code Analysis Commands**:

- `overview <file>` - Comprehensive file analysis (combines all below)
- `analyze-complexity <file>` - Cyclomatic complexity analysis (Python)
- `security <file>` - Basic security vulnerability scan
- `imports <file>` - Analyze import dependencies
- `duplicates <file> [n]` - Find duplicate code blocks
- `docs <file>` - Analyze documentation quality
- `smells <file>` - Detect code smells (long functions, deep nesting, etc)

**Example**: `ch nlp overview app.py` - Get complete analysis including
complexity, security issues, code smells, and documentation coverage

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
