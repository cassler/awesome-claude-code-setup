#!/bin/bash

# Project Info Script - Enhanced project overview with jq
# Usage: ./project-info.sh [path]

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required for project analysis"
    echo "Install with: brew install jq"
    exit 1
fi

echo "=== PROJECT OVERVIEW ==="
echo "Path: $(pwd)"
echo ""

# Detect primary languages
echo "=== LANGUAGES DETECTED ==="
if [ -f "package.json" ]; then
    echo "✓ Node.js/JavaScript/TypeScript"
    HAS_NODE=true
fi
if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "✓ Python"
    HAS_PYTHON=true
fi
if [ -f "Cargo.toml" ]; then
    echo "✓ Rust"
fi
if [ -f "go.mod" ]; then
    echo "✓ Go"
fi
if [ -f "Gemfile" ]; then
    echo "✓ Ruby"
fi
if [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    echo "✓ Java"
fi
echo ""

# Show package managers and key files
echo "=== KEY FILES ==="
[ -f "package.json" ] && echo "✓ package.json"
[ -f "package-lock.json" ] && echo "✓ package-lock.json"
[ -f "yarn.lock" ] && echo "✓ yarn.lock"
[ -f "pnpm-lock.yaml" ] && echo "✓ pnpm-lock.yaml"
[ -f "tsconfig.json" ] && echo "✓ tsconfig.json"
[ -f "Dockerfile" ] && echo "✓ Dockerfile"
[ -f "docker-compose.yml" ] && echo "✓ docker-compose.yml"
[ -f ".env" ] && echo "✓ .env"
[ -f ".env.example" ] && echo "✓ .env.example"
[ -f "Makefile" ] && echo "✓ Makefile"
[ -f ".github/workflows" ] && echo "✓ GitHub Actions workflows"
echo ""

# Node.js specific info
if [ "$HAS_NODE" = true ] && [ -f "package.json" ]; then
    echo "=== NODE.JS PROJECT INFO ==="
    
    # Extract comprehensive info from package.json
    NAME=$(jq -r '.name // "N/A"' package.json)
    VERSION=$(jq -r '.version // "N/A"' package.json)
    DESCRIPTION=$(jq -r '.description // ""' package.json)
    
    echo "Name: $NAME"
    echo "Version: $VERSION"
    [ -n "$DESCRIPTION" ] && echo "Description: $DESCRIPTION"
    
    # Detect framework
    if jq -e '.dependencies.next // .devDependencies.next' package.json &>/dev/null; then
        echo "Framework: Next.js $(jq -r '.dependencies.next // .devDependencies.next' package.json)"
    elif jq -e '.dependencies.react // .devDependencies.react' package.json &>/dev/null; then
        echo "Framework: React $(jq -r '.dependencies.react // .devDependencies.react' package.json)"
    elif jq -e '.dependencies.vue // .devDependencies.vue' package.json &>/dev/null; then
        echo "Framework: Vue.js $(jq -r '.dependencies.vue // .devDependencies.vue' package.json)"
    elif jq -e '.dependencies.express // .devDependencies.express' package.json &>/dev/null; then
        echo "Framework: Express $(jq -r '.dependencies.express // .devDependencies.express' package.json)"
    fi
    
    echo ""
    echo "Scripts:"
    jq -r '.scripts // {} | to_entries | .[] | "  \(.key): \(.value)"' package.json | head -10
    
    SCRIPT_COUNT=$(jq -r '.scripts // {} | length' package.json)
    [ $SCRIPT_COUNT -gt 10 ] && echo "  ... and $((SCRIPT_COUNT - 10)) more scripts"
    
    echo ""
    echo "Dependencies Summary:"
    DEP_COUNT=$(jq -r '.dependencies // {} | length' package.json)
    DEVDEP_COUNT=$(jq -r '.devDependencies // {} | length' package.json)
    echo "  Production: $DEP_COUNT packages"
    echo "  Development: $DEVDEP_COUNT packages"
    
    # Show key dependencies
    echo ""
    echo "Key Dependencies:"
    jq -r '.dependencies // {} | to_entries | sort_by(.key) | .[:5] | .[] | "  \(.key): \(.value)"' package.json
    
    # Check for common tools
    echo ""
    echo "Build Tools:"
    jq -e '.devDependencies.typescript' package.json &>/dev/null && echo "  ✓ TypeScript"
    jq -e '.devDependencies."@types/node"' package.json &>/dev/null && echo "  ✓ TypeScript Node types"
    jq -e '.devDependencies.eslint' package.json &>/dev/null && echo "  ✓ ESLint"
    jq -e '.devDependencies.prettier' package.json &>/dev/null && echo "  ✓ Prettier"
    jq -e '.devDependencies.jest // .devDependencies.vitest // .devDependencies.mocha' package.json &>/dev/null && echo "  ✓ Testing framework"
    echo ""
fi

# Docker info
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
    echo "=== DOCKER INFO ==="
    [ -f "Dockerfile" ] && echo "✓ Dockerfile present"
    [ -f "docker-compose.yml" ] && echo "✓ docker-compose.yml present"
    if [ -f "docker-compose.yml" ]; then
        echo "Services: $(grep -E '^\s*[a-zA-Z0-9_-]+:$' docker-compose.yml | sed 's/://g' | tr '\n' ', ' | sed 's/,$//')"
    fi
    echo ""
fi

# Quick directory structure
echo "=== DIRECTORY STRUCTURE ==="
find . -type d -name "node_modules" -prune -o -type d -name ".git" -prune -o -type d -print | grep -E "^\./[^/]+$" | sort | head -20
echo ""

# Git info
if [ -d ".git" ]; then
    echo "=== GIT INFO ==="
    BRANCH=$(git branch --show-current 2>/dev/null)
    echo "Current branch: ${BRANCH:-unknown}"
    REMOTE=$(git remote -v | head -1 | awk '{print $2}' 2>/dev/null)
    [ -n "$REMOTE" ] && echo "Remote: $REMOTE"
    echo "Status: $(git status --porcelain | wc -l) changes"
    echo ""
fi

# Quick size info
echo "=== PROJECT SIZE ==="
echo "Total files: $(find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)"
echo "Total size: $(du -sh . 2>/dev/null | cut -f1)"
[ -d "node_modules" ] && echo "node_modules size: $(du -sh node_modules 2>/dev/null | cut -f1)"