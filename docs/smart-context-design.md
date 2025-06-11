# Smart Context Generation Design

## Goals
Create a context generation system that:
1. Provides highly relevant context for any task
2. Works across multiple languages (Node.js, Python, Go, Rust)
3. Respects token budgets
4. Learns from task patterns
5. Excludes irrelevant noise

## Core Concepts

### 1. Multi-Language Import Graph
Build a unified way to understand dependencies across languages:

```bash
# Node.js/TypeScript
import { foo } from './bar'
require('./baz')

# Python
import foo
from bar import baz
import bar.baz

# Go
import "fmt"
import "github.com/user/repo/pkg"

# Rust
use std::collections::HashMap;
use crate::module::Type;
```

### 2. Relevance Scoring Algorithm
Score files based on multiple factors:

1. **Direct match** (10 points): Task mentions file/module name
2. **Import relationship** (5 points): Imports or imported by relevant files
3. **Directory proximity** (3 points): Same directory as relevant files
4. **Recent changes** (3 points): Modified recently (likely active area)
5. **Type match** (2 points): Test files for test tasks, etc.
6. **Semantic similarity** (1-5 points): Content matches task keywords

### 3. Task-Aware Defaults

```yaml
refactor:
  include: [source, imports, dependents]
  exclude: [tests, docs]
  
test:
  include: [source, tests, fixtures]
  exclude: [docs, examples]
  
bug:
  include: [recent_changes, error_handlers, logs]
  exclude: [unrelated_tests]
  
feature:
  include: [similar_features, related_docs, tests]
  exclude: [unrelated_modules]

api:
  include: [routes, controllers, models, validators]
  exclude: [ui, styles]
```

### 4. Token Budget Management

```bash
ch ctx for-task "refactor auth" --max-tokens 2000
# Returns most relevant files that fit in budget

ch ctx for-task "add user feature" --detail minimal
# Returns file list with key functions only

ch ctx for-task "fix bug" --detail full
# Returns complete file contents for highest relevance files
```

### 5. Language Detection & Parsing

```bash
detect_language() {
  # Check multiple signals
  - File extensions
  - Package files (package.json, requirements.txt, go.mod, Cargo.toml)
  - Shebang lines
  - Import syntax patterns
}

parse_imports() {
  case $language in
    javascript|typescript)
      # Extract require/import statements
      ;;
    python)
      # Extract import/from statements
      ;;
    go)
      # Extract import blocks
      ;;
    rust)
      # Extract use statements
      ;;
  esac
}
```

## Implementation Plan

### Phase 1: Core Relevance Engine
- Build language-agnostic relevance scoring
- Implement basic import parsing for each language
- Create task-type detection from keywords

### Phase 2: Smart Filtering
- Token budget management
- Exclude pattern handling
- Directory proximity scoring

### Phase 3: Language-Specific Enhancements
- Language-specific weight adjustments
- Framework detection (React, Django, Gin, Actix)
- Build tool integration

### Phase 4: Learning & Optimization
- Cache import graphs for performance
- Learn from user selections
- Optimize for common patterns

## Example Usage

```bash
# Basic usage - auto-detects language and task type
ch ctx for-task "refactor user authentication"

# With options
ch ctx for-task "add payment processing" \
  --max-tokens 3000 \
  --include "stripe|payment" \
  --exclude "test|mock"

# Language-specific
ch ctx for-task "optimize database queries" \
  --language python \
  --framework django

# Multiple focus areas
ch ctx for-task "update API endpoints" \
  --focus "routes/*.py" \
  --focus "models/*.py" \
  --depth 2
```

## Success Metrics
- Relevant files appear in top 80% of results
- Token usage reduced by 50-70% vs current approach
- Works equally well for JS, Python, Go, Rust projects
- Task completion improved due to better context