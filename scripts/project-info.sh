#!/bin/bash

# Project Info Script - Enhanced project overview with jq
# Usage: ./project-info.sh [path]

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-functions.sh"

# Function to detect nested projects
find_nested_projects() {
    local max_depth="${1:-3}"
    local nested_projects=()
    
    # Look for package.json files (Node.js)
    while IFS= read -r -d '' file; do
        local dir=$(dirname "$file")
        # Skip if it's the root project or in node_modules
        if [[ "$dir" != "." && "$dir" != *"node_modules"* ]]; then
            nested_projects+=("$dir")
        fi
    done < <(find . -maxdepth "$max_depth" -name "package.json" -not -path "*/node_modules/*" -print0 2>/dev/null)
    
    # Look for go.mod files (Go)
    while IFS= read -r -d '' file; do
        local dir=$(dirname "$file")
        if [[ "$dir" != "." && "$dir" != *"vendor"* ]]; then
            nested_projects+=("$dir")
        fi
    done < <(find . -maxdepth "$max_depth" -name "go.mod" -not -path "*/vendor/*" -print0 2>/dev/null)
    
    # Look for Cargo.toml files (Rust)
    while IFS= read -r -d '' file; do
        local dir=$(dirname "$file")
        if [[ "$dir" != "." && "$dir" != *"target"* ]]; then
            nested_projects+=("$dir")
        fi
    done < <(find . -maxdepth "$max_depth" -name "Cargo.toml" -not -path "*/target/*" -print0 2>/dev/null)
    
    # Look for requirements.txt or setup.py (Python)
    while IFS= read -r -d '' file; do
        local dir=$(dirname "$file")
        if [[ "$dir" != "." && "$dir" != *"venv"* && "$dir" != *"__pycache__"* ]]; then
            nested_projects+=("$dir")
        fi
    done < <(find . -maxdepth "$max_depth" \( -name "requirements.txt" -o -name "setup.py" -o -name "pyproject.toml" \) -not -path "*/venv/*" -not -path "*/__pycache__/*" -print0 2>/dev/null)
    
    # Remove duplicates and sort
    if [ ${#nested_projects[@]} -gt 0 ]; then
        printf '%s\n' "${nested_projects[@]}" | sort -u
    fi
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required for project analysis"
    echo "Install with: brew install jq"
    exit 1
fi

echo -e "${BLUE}=== PROJECT OVERVIEW ===${NC}"
echo "Path: $(pwd)"
echo "Name: $(basename "$(pwd)")"
echo ""

# Detect if this is a monorepo
echo -e "${BLUE}=== MONOREPO DETECTION ===${NC}"
MONOREPO_TYPE=""
MONOREPO_DETECTED=false

if [ -f "lerna.json" ]; then
    echo "✓ Lerna monorepo detected"
    MONOREPO_TYPE="lerna"
    MONOREPO_DETECTED=true
elif [ -f "nx.json" ]; then
    echo "✓ Nx monorepo detected"
    MONOREPO_TYPE="nx"
    MONOREPO_DETECTED=true
elif [ -f "pnpm-workspace.yaml" ] || [ -f "pnpm-workspace.yml" ]; then
    echo "✓ pnpm workspace detected"
    MONOREPO_TYPE="pnpm"
    MONOREPO_DETECTED=true
elif [ -f "rush.json" ]; then
    echo "✓ Rush monorepo detected"
    MONOREPO_TYPE="rush"
    MONOREPO_DETECTED=true
elif [ -f "package.json" ] && jq -e '.workspaces' package.json &>/dev/null; then
    echo "✓ Yarn/npm workspaces detected"
    MONOREPO_TYPE="yarn"
    MONOREPO_DETECTED=true
fi

if [ "$MONOREPO_DETECTED" = false ]; then
    echo "Not a monorepo"
else
    # List workspaces/packages in the monorepo
    echo ""
    echo "Workspaces/Packages:"
    
    case "$MONOREPO_TYPE" in
        "lerna")
            if command -v jq &> /dev/null && [ -f "lerna.json" ]; then
                PACKAGES=$(jq -r '.packages[]?' lerna.json 2>/dev/null)
                if [ -n "$PACKAGES" ]; then
                    echo "$PACKAGES" | while read -r pattern; do
                        find . -path "./$pattern" -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | while read -r pkg; do
                            PKG_DIR=$(dirname "$pkg")
                            PKG_NAME=$(jq -r '.name // ""' "$pkg" 2>/dev/null)
                            [ -n "$PKG_NAME" ] && echo "  - $PKG_NAME ($PKG_DIR)"
                        done
                    done
                fi
            fi
            ;;
        "nx")
            if [ -f "workspace.json" ] && command -v jq &> /dev/null; then
                jq -r '.projects | to_entries | .[] | "  - \(.key) (\(.value.root))"' workspace.json 2>/dev/null
            elif [ -d "packages" ] || [ -d "libs" ] || [ -d "apps" ]; then
                find . \( -path "./packages/*" -o -path "./libs/*" -o -path "./apps/*" \) -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | while read -r pkg; do
                    PKG_DIR=$(dirname "$pkg")
                    PKG_NAME=$(jq -r '.name // ""' "$pkg" 2>/dev/null)
                    [ -n "$PKG_NAME" ] && echo "  - $PKG_NAME ($PKG_DIR)"
                done
            fi
            ;;
        "pnpm")
            if [ -f "pnpm-workspace.yaml" ] || [ -f "pnpm-workspace.yml" ]; then
                # Simple pattern matching for common workspace patterns
                find . \( -path "./packages/*" -o -path "./apps/*" -o -path "./libs/*" \) -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | while read -r pkg; do
                    PKG_DIR=$(dirname "$pkg")
                    PKG_NAME=$(jq -r '.name // ""' "$pkg" 2>/dev/null)
                    [ -n "$PKG_NAME" ] && echo "  - $PKG_NAME ($PKG_DIR)"
                done
            fi
            ;;
        "yarn")
            if [ -f "package.json" ] && command -v jq &> /dev/null; then
                WORKSPACES=$(jq -r '.workspaces[]?' package.json 2>/dev/null)
                if [ -n "$WORKSPACES" ]; then
                    echo "$WORKSPACES" | while read -r pattern; do
                        find . -path "./$pattern" -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | while read -r pkg; do
                            PKG_DIR=$(dirname "$pkg")
                            PKG_NAME=$(jq -r '.name // ""' "$pkg" 2>/dev/null)
                            [ -n "$PKG_NAME" ] && echo "  - $PKG_NAME ($PKG_DIR)"
                        done
                    done
                fi
            fi
            ;;
        "rush")
            if [ -f "rush.json" ] && command -v jq &> /dev/null; then
                jq -r '.projects[]? | "  - \(.packageName) (\(.projectFolder))"' rush.json 2>/dev/null
            fi
            ;;
    esac
fi
echo ""

# Detect nested projects
echo -e "${BLUE}=== NESTED PROJECTS ===${NC}"
NESTED_PROJECTS=$(find_nested_projects 3)
if [ -n "$NESTED_PROJECTS" ]; then
    echo "Found nested projects:"
    echo "$NESTED_PROJECTS" | while read -r project; do
        # Detect type of nested project
        project_type=""
        if [ -f "$project/package.json" ]; then
            project_type="Node.js"
            if command -v jq &> /dev/null; then
                project_name=$(jq -r '.name // ""' "$project/package.json" 2>/dev/null)
                [ -n "$project_name" ] && project_type="$project_type: $project_name"
            fi
        elif [ -f "$project/go.mod" ]; then
            project_type="Go"
            module_name=$(grep "^module " "$project/go.mod" 2>/dev/null | awk '{print $2}')
            [ -n "$module_name" ] && project_type="$project_type: $module_name"
        elif [ -f "$project/Cargo.toml" ]; then
            project_type="Rust"
        elif [ -f "$project/requirements.txt" ] || [ -f "$project/setup.py" ] || [ -f "$project/pyproject.toml" ]; then
            project_type="Python"
        fi
        echo "  - $project ($project_type)"
    done
else
    echo "No nested projects detected"
fi
echo ""

# Detect primary languages with file counts
echo -e "${BLUE}=== LANGUAGES & FRAMEWORKS ===${NC}"
LANG_DETECTED=false

# Initialize language flags
HAS_NODE=false
HAS_PYTHON=false
HAS_GO=false
HAS_RUST=false
HAS_RUBY=false
HAS_JAVA=false

# Node.js/JavaScript/TypeScript
if [ -f "package.json" ]; then
    echo "✓ Node.js/JavaScript/TypeScript"
    HAS_NODE=true
    LANG_DETECTED=true
    
    # Count JS/TS files
    JS_COUNT=$(find . -name "*.js" -o -name "*.jsx" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    TS_COUNT=$(find . -name "*.ts" -o -name "*.tsx" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  - JavaScript files: $JS_COUNT"
    echo "  - TypeScript files: $TS_COUNT"
fi

# Python
if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
    echo "✓ Python"
    HAS_PYTHON=true
    LANG_DETECTED=true
    
    # Count Python files
    PY_COUNT=$(find . -name "*.py" -not -path "*/venv/*" -not -path "*/__pycache__/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  - Python files: $PY_COUNT"
    
    # Detect Python version if possible
    if [ -f ".python-version" ]; then
        echo "  - Python version: $(cat .python-version)"
    elif [ -f "runtime.txt" ]; then
        echo "  - Python version: $(cat runtime.txt)"
    fi
fi

# Go
if [ -f "go.mod" ]; then
    echo "✓ Go"
    HAS_GO=true
    LANG_DETECTED=true
    
    GO_COUNT=$(find . -name "*.go" -not -path "*/vendor/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  - Go files: $GO_COUNT"
    
    # Show Go version
    GO_VERSION=$(grep "^go " go.mod | awk '{print $2}')
    [ -n "$GO_VERSION" ] && echo "  - Go version: $GO_VERSION"
fi

# Rust
if [ -f "Cargo.toml" ]; then
    echo "✓ Rust"
    HAS_RUST=true
    LANG_DETECTED=true
    
    RS_COUNT=$(find . -name "*.rs" -not -path "*/target/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  - Rust files: $RS_COUNT"
fi

# Ruby
if [ -f "Gemfile" ]; then
    echo "✓ Ruby"
    HAS_RUBY=true
    LANG_DETECTED=true
    
    RB_COUNT=$(find . -name "*.rb" -not -path "*/vendor/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  - Ruby files: $RB_COUNT"
fi

# Java
if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    echo "✓ Java/Kotlin"
    HAS_JAVA=true
    LANG_DETECTED=true
    
    JAVA_COUNT=$(find . -name "*.java" -not -path "*/build/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  - Java files: $JAVA_COUNT"
fi

# Shell/Bash
SH_COUNT=$(find . -name "*.sh" -o -name "*.bash" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SH_COUNT" -gt 0 ]; then
    echo "✓ Shell/Bash"
    echo "  - Shell scripts: $SH_COUNT"
    LANG_DETECTED=true
fi

if [ "$LANG_DETECTED" = false ]; then
    echo "No standard project files detected"
fi

echo ""

# Show package managers and key files
echo -e "${BLUE}=== CONFIGURATION FILES ===${NC}"
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
[ -d ".github/workflows" ] && echo "✓ GitHub Actions workflows"
[ -f ".gitignore" ] && echo "✓ .gitignore"
[ -f ".editorconfig" ] && echo "✓ .editorconfig"
[ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] && echo "✓ ESLint config"
[ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] && echo "✓ Prettier config"
[ -f "jest.config.js" ] || [ -f "jest.config.ts" ] && echo "✓ Jest config"
[ -f "vite.config.js" ] || [ -f "vite.config.ts" ] && echo "✓ Vite config"
[ -f "webpack.config.js" ] && echo "✓ Webpack config"
[ -f "babel.config.js" ] || [ -f ".babelrc" ] && echo "✓ Babel config"
[ -f "requirements.txt" ] && echo "✓ requirements.txt"
[ -f "pyproject.toml" ] && echo "✓ pyproject.toml"
[ -f "setup.py" ] && echo "✓ setup.py"
[ -f "Pipfile" ] && echo "✓ Pipfile"
[ -f "go.mod" ] && echo "✓ go.mod"
[ -f "go.sum" ] && echo "✓ go.sum"
[ -f "Cargo.toml" ] && echo "✓ Cargo.toml"
[ -f "Cargo.lock" ] && echo "✓ Cargo.lock"
echo ""

# Node.js specific info
if [ "$HAS_NODE" = true ] && [ -f "package.json" ]; then
    echo -e "${BLUE}=== NODE.JS PROJECT DETAILS ===${NC}"
    
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
    echo -e "${BLUE}=== DOCKER CONFIGURATION ===${NC}"
    [ -f "Dockerfile" ] && echo "✓ Dockerfile present"
    [ -f "docker-compose.yml" ] && echo "✓ docker-compose.yml present"
    if [ -f "docker-compose.yml" ]; then
        echo "Services: $(grep -E '^\s*[a-zA-Z0-9_-]+:$' docker-compose.yml | sed 's/://g' | tr '\n' ', ' | sed 's/,$//')"
    fi
    echo ""
fi

# Quick directory structure
echo -e "${BLUE}=== DIRECTORY STRUCTURE ===${NC}"

# Show top-level directories with indicators for nested projects
echo "Top-level directories:"
find . -maxdepth 1 -type d -not -path "." -not -path "./.git" -not -path "./node_modules" -not -path "./vendor" -not -path "./venv" | sort | while read -r dir; do
    dir_name=$(basename "$dir")
    # Check if this directory contains a nested project
    if [ -f "$dir/package.json" ] || [ -f "$dir/go.mod" ] || [ -f "$dir/Cargo.toml" ] || [ -f "$dir/requirements.txt" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/pyproject.toml" ]; then
        echo "  $dir_name/ 📦"  # Package indicator
    else
        echo "  $dir_name/"
    fi
done

# If it's a monorepo, show the workspace structure
if [ "$MONOREPO_DETECTED" = true ]; then
    echo ""
    echo "Workspace structure:"
    case "$MONOREPO_TYPE" in
        "lerna"|"yarn"|"pnpm")
            # Show common monorepo directories
            [ -d "packages" ] && echo "  packages/" && find packages -maxdepth 1 -mindepth 1 -type d | sort | head -10 | sed 's/^/    /'
            [ -d "apps" ] && echo "  apps/" && find apps -maxdepth 1 -mindepth 1 -type d | sort | head -10 | sed 's/^/    /'
            [ -d "libs" ] && echo "  libs/" && find libs -maxdepth 1 -mindepth 1 -type d | sort | head -10 | sed 's/^/    /'
            ;;
        "nx")
            [ -d "packages" ] && echo "  packages/" && find packages -maxdepth 1 -mindepth 1 -type d | sort | head -10 | sed 's/^/    /'
            [ -d "apps" ] && echo "  apps/" && find apps -maxdepth 1 -mindepth 1 -type d | sort | head -10 | sed 's/^/    /'
            [ -d "libs" ] && echo "  libs/" && find libs -maxdepth 1 -mindepth 1 -type d | sort | head -10 | sed 's/^/    /'
            ;;
    esac
fi
echo ""

# Git info
if [ -d ".git" ]; then
    echo -e "${BLUE}=== GIT REPOSITORY ===${NC}"
    BRANCH=$(git branch --show-current 2>/dev/null)
    echo "Current branch: ${BRANCH:-unknown}"
    REMOTE=$(git remote -v | head -1 | awk '{print $2}' 2>/dev/null)
    [ -n "$REMOTE" ] && echo "Remote: $REMOTE"
    echo "Status: $(git status --porcelain | wc -l) changes"
    echo ""
fi

# Python specific info
if [ "$HAS_PYTHON" = true ]; then
    echo -e "${BLUE}=== PYTHON PROJECT DETAILS ===${NC}"
    
    # Package manager detection
    if [ -f "poetry.lock" ] || [ -f "pyproject.toml" ]; then
        echo "Package Manager: Poetry"
        if command -v poetry &> /dev/null && [ -f "pyproject.toml" ]; then
            echo "Project Name: $(poetry version | awk '{print $1}')"
            echo "Version: $(poetry version | awk '{print $2}')"
        fi
    elif [ -f "Pipfile" ]; then
        echo "Package Manager: Pipenv"
    elif [ -f "requirements.txt" ]; then
        echo "Package Manager: pip (requirements.txt)"
        REQ_COUNT=$(grep -v '^#' requirements.txt | grep -v '^$' | wc -l | tr -d ' ')
        echo "Dependencies: $REQ_COUNT packages"
    fi
    
    # Test framework detection
    if [ -f "pytest.ini" ] || grep -q "pytest" requirements.txt pyproject.toml 2>/dev/null; then
        echo "Test Framework: pytest"
    elif find . -name "test_*.py" -o -name "*_test.py" | head -1 | grep -q .; then
        echo "Test Framework: detected (test files found)"
    fi
    
    echo ""
fi

# Go specific info
if [ "$HAS_GO" = true ] && [ -f "go.mod" ]; then
    echo -e "${BLUE}=== GO PROJECT DETAILS ===${NC}"
    
    MODULE=$(grep "^module " go.mod | awk '{print $2}')
    echo "Module: $MODULE"
    
    # Count dependencies
    if [ -f "go.sum" ]; then
        DEP_COUNT=$(grep -c "^[^[:space:]]" go.sum)
        echo "Dependencies: ~$((DEP_COUNT / 2)) packages"
    fi
    
    echo ""
fi

# Rust specific info
if [ "$HAS_RUST" = true ] && [ -f "Cargo.toml" ]; then
    echo -e "${BLUE}=== RUST PROJECT DETAILS ===${NC}"
    
    # Basic cargo info
    if command -v cargo &> /dev/null; then
        CARGO_NAME=$(grep '^name' Cargo.toml | head -1 | cut -d'"' -f2)
        CARGO_VERSION=$(grep '^version' Cargo.toml | head -1 | cut -d'"' -f2)
        echo "Package: $CARGO_NAME v$CARGO_VERSION"
    fi
    
    echo ""
fi

# Testing & CI/CD
echo -e "${BLUE}=== TESTING & CI/CD ===${NC}"
TEST_FOUND=false

# GitHub Actions
if [ -d ".github/workflows" ]; then
    WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l | tr -d ' ')
    echo "✓ GitHub Actions ($WORKFLOW_COUNT workflows)"
    TEST_FOUND=true
fi

# GitLab CI
[ -f ".gitlab-ci.yml" ] && echo "✓ GitLab CI" && TEST_FOUND=true

# CircleCI
[ -d ".circleci" ] && echo "✓ CircleCI" && TEST_FOUND=true

# Jenkins
[ -f "Jenkinsfile" ] && echo "✓ Jenkins" && TEST_FOUND=true

# Test directories
[ -d "tests" ] && echo "✓ tests/ directory" && TEST_FOUND=true
[ -d "test" ] && echo "✓ test/ directory" && TEST_FOUND=true
[ -d "spec" ] && echo "✓ spec/ directory" && TEST_FOUND=true
[ -d "__tests__" ] && echo "✓ __tests__/ directory" && TEST_FOUND=true

[ "$TEST_FOUND" = false ] && echo "No test configuration detected"
echo ""

# Documentation
echo -e "${BLUE}=== DOCUMENTATION ===${NC}"
DOC_FOUND=false

[ -f "README.md" ] && echo "✓ README.md" && DOC_FOUND=true
[ -f "README.rst" ] && echo "✓ README.rst" && DOC_FOUND=true
[ -f "CONTRIBUTING.md" ] && echo "✓ CONTRIBUTING.md" && DOC_FOUND=true
[ -f "CHANGELOG.md" ] && echo "✓ CHANGELOG.md" && DOC_FOUND=true
[ -f "LICENSE" ] && echo "✓ LICENSE" && DOC_FOUND=true
[ -f "LICENSE.md" ] && echo "✓ LICENSE.md" && DOC_FOUND=true
[ -d "docs" ] && echo "✓ docs/ directory" && DOC_FOUND=true
[ -d "documentation" ] && echo "✓ documentation/ directory" && DOC_FOUND=true

[ "$DOC_FOUND" = false ] && echo "No documentation files found"
echo ""

# Quick size info
echo -e "${BLUE}=== PROJECT METRICS ===${NC}"
echo "Total files: $(find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*" -not -path "*/venv/*" | wc -l | tr -d ' ')"
echo "Total size: $(du -sh . 2>/dev/null | cut -f1)"
[ -d "node_modules" ] && echo "node_modules size: $(du -sh node_modules 2>/dev/null | cut -f1)"
[ -d "vendor" ] && echo "vendor size: $(du -sh vendor 2>/dev/null | cut -f1)"
[ -d "venv" ] && echo "venv size: $(du -sh venv 2>/dev/null | cut -f1)"

# Line count by language
echo ""
echo "Lines of code:"
if command -v cloc &> /dev/null; then
    cloc . --quiet --exclude-dir=node_modules,vendor,venv,.git,dist,build 2>/dev/null | tail -n +6
else
    echo "  (install 'cloc' for detailed code statistics)"
fi

echo ""
echo -e "${GREEN}=== QUICK START SUGGESTIONS ===${NC}"

# Monorepo-specific suggestions
if [ "$MONOREPO_DETECTED" = true ]; then
    echo "Monorepo detected ($MONOREPO_TYPE). Try:"
    
    case "$MONOREPO_TYPE" in
        "lerna")
            echo "  npx lerna bootstrap    # Install all dependencies"
            echo "  npx lerna run build    # Build all packages"
            echo "  npx lerna run test     # Test all packages"
            echo "  npx lerna list         # List all packages"
            ;;
        "nx")
            echo "  nx graph               # Visualize project graph"
            echo "  nx run-many -t build   # Build all projects"
            echo "  nx run-many -t test    # Test all projects"
            echo "  nx affected:build      # Build only affected projects"
            ;;
        "pnpm")
            echo "  pnpm install           # Install all dependencies"
            echo "  pnpm -r build          # Build all packages"
            echo "  pnpm -r test           # Test all packages"
            echo "  pnpm list --depth 0    # List workspace packages"
            ;;
        "yarn")
            echo "  yarn install           # Install all dependencies"
            echo "  yarn workspaces run build  # Build all workspaces"
            echo "  yarn workspaces run test   # Test all workspaces"
            echo "  yarn workspaces info   # Show workspace info"
            ;;
        "rush")
            echo "  rush install           # Install all dependencies"
            echo "  rush build             # Build all projects"
            echo "  rush test              # Test all projects"
            echo "  rush list              # List all projects"
            ;;
    esac
    echo ""
fi

# Suggest commands based on detected environment
if [ "$HAS_NODE" = true ] && [ -f "package.json" ]; then
    echo "Node.js detected. Try:"
    jq -r '.scripts // {} | to_entries | select(.key | test("^(dev|start|serve)")) | "  npm run \(.key)"' package.json 2>/dev/null | head -3
fi

if [ "$HAS_PYTHON" = true ]; then
    echo "Python detected. Try:"
    [ -f "requirements.txt" ] && echo "  pip install -r requirements.txt"
    [ -f "setup.py" ] && echo "  pip install -e ."
    [ -f "manage.py" ] && echo "  python manage.py runserver"
fi

if [ "$HAS_GO" = true ]; then
    echo "Go detected. Try:"
    echo "  go mod download"
    echo "  go run ."
fi

if [ -f "Makefile" ]; then
    echo "Makefile detected. Try:"
    echo "  make"
fi

echo ""
echo -e "${YELLOW}Tip: Run 'ch ctx for-task \"your task\"' to generate focused context${NC}"