#!/bin/bash

# Project Info Script - Quick project overview
# Usage: ./project-info.sh [path]

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

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
    
    # Extract key info from package.json
    if command -v jq &> /dev/null; then
        NAME=$(jq -r '.name // "N/A"' package.json)
        VERSION=$(jq -r '.version // "N/A"' package.json)
        echo "Name: $NAME"
        echo "Version: $VERSION"
        echo ""
        echo "Scripts:"
        jq -r '.scripts // {} | to_entries | .[] | "  \(.key): \(.value)"' package.json 2>/dev/null | head -10
        echo ""
        echo "Key Dependencies:"
        jq -r '.dependencies // {} | to_entries | .[] | "  \(.key): \(.value)"' package.json 2>/dev/null | head -5
        [ -f "package.json" ] && jq -e '.devDependencies' package.json &>/dev/null && echo "  ... and $(jq -r '.devDependencies | length' package.json) dev dependencies"
    else
        echo "Install jq for detailed package.json analysis"
        echo "Scripts: $(grep -A5 '"scripts"' package.json | grep -E '^\s*"' | cut -d'"' -f2 | tr '\n' ', ' | sed 's/,$//')"
    fi
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