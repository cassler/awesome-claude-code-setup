#!/bin/bash

# TypeScript/Node.js Helper Script - Enhanced with jq
# Usage: ./ts-helper.sh [command] [args]

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required for TypeScript/Node.js analysis"
    echo "Install with: brew install jq"
    exit 1
fi

case "$1" in
    "deps"|"dependencies")
        echo "=== DEPENDENCIES OVERVIEW ==="
        if [ -f "package.json" ]; then
            DEPS=$(jq -r '.dependencies | length' package.json)
            DEV_DEPS=$(jq -r '.devDependencies | length' package.json)
            PEER_DEPS=$(jq -r '.peerDependencies | length' package.json 2>/dev/null || echo "0")
            
            echo "Production dependencies: $DEPS"
            echo "Dev dependencies: $DEV_DEPS"
            [ "$PEER_DEPS" != "0" ] && echo "Peer dependencies: $PEER_DEPS"
            
            # Check for outdated packages
            if command -v npm &> /dev/null; then
                echo ""
                echo "Checking for outdated packages..."
                npm outdated --depth=0 2>/dev/null | head -10 || echo "  All packages up to date"
            fi
            
            echo ""
            echo "Key Production Dependencies:"
            jq -r '.dependencies | to_entries | sort_by(.key) | .[:10] | .[] | "  \(.key): \(.value)"' package.json
            
            # Show security audit summary if available
            if [ -f "package-lock.json" ] && command -v npm &> /dev/null; then
                echo ""
                echo "Security Audit:"
                npm audit --json 2>/dev/null | jq -r '
                    if .metadata then
                        "  Vulnerabilities: \(.metadata.vulnerabilities | to_entries | map("\(.value) \(.key)") | join(", "))"
                    else
                        "  No audit data available"
                    end'
            fi
        else
            echo "No package.json found"
        fi
        ;;
    
    "scripts")
        echo "=== AVAILABLE SCRIPTS ==="
        if [ -f "package.json" ]; then
            # Group scripts by category
            echo "Build & Development:"
            jq -r '.scripts | to_entries | .[] | select(.key | test("^(build|dev|start|serve|watch)")) | "  \(.key): \(.value)"' package.json
            
            echo ""
            echo "Testing & Quality:"
            jq -r '.scripts | to_entries | .[] | select(.key | test("^(test|lint|format|check|typecheck)")) | "  \(.key): \(.value)"' package.json
            
            echo ""
            echo "Other Scripts:"
            jq -r '.scripts | to_entries | .[] | select(.key | test("^(build|dev|start|serve|watch|test|lint|format|check|typecheck)") | not) | "  \(.key): \(.value)"' package.json
            
            # Show shortcuts
            echo ""
            echo "Quick Commands:"
            jq -e '.scripts.dev' package.json &>/dev/null && echo "  npm run dev     # Start development server"
            jq -e '.scripts.build' package.json &>/dev/null && echo "  npm run build   # Build for production"
            jq -e '.scripts.test' package.json &>/dev/null && echo "  npm test        # Run tests"
            jq -e '.scripts.lint' package.json &>/dev/null && echo "  npm run lint    # Check code quality"
        else
            echo "No package.json found"
        fi
        ;;
    
    "quick-install"|"qi")
        # Quick install with appropriate package manager
        if [ -f "pnpm-lock.yaml" ]; then
            echo "Using pnpm..."
            pnpm install
        elif [ -f "yarn.lock" ]; then
            echo "Using yarn..."
            yarn install
        elif [ -f "package-lock.json" ]; then
            echo "Using npm..."
            npm install
        else
            echo "Using npm (no lock file found)..."
            npm install
        fi
        ;;
    
    "build")
        # Run build with error checking
        if [ -f "package.json" ]; then
            if grep -q '"build"' package.json; then
                npm run build
            else
                echo "No build script found in package.json"
            fi
        fi
        ;;
    
    "test")
        # Run tests
        if [ -f "package.json" ]; then
            if grep -q '"test"' package.json; then
                npm test
            else
                echo "No test script found in package.json"
            fi
        fi
        ;;
    
    "lint")
        # Run linter
        if [ -f "package.json" ]; then
            if grep -q '"lint"' package.json; then
                npm run lint
            elif grep -q '"eslint"' package.json; then
                npm run eslint
            else
                echo "No lint script found in package.json"
            fi
        fi
        ;;
    
    "typecheck"|"tc")
        # Run TypeScript type checking
        if [ -f "tsconfig.json" ]; then
            if grep -q '"typecheck"' package.json 2>/dev/null; then
                npm run typecheck
            elif command -v tsc &> /dev/null; then
                tsc --noEmit
            else
                echo "TypeScript compiler not found"
            fi
        else
            echo "No tsconfig.json found"
        fi
        ;;
    
    "outdated")
        # Check for outdated packages
        echo "=== OUTDATED PACKAGES ==="
        npm outdated || true
        ;;
    
    "audit")
        # Security audit
        echo "=== SECURITY AUDIT ==="
        npm audit --production
        ;;
    
    "clean")
        # Clean common directories
        echo "=== CLEANING PROJECT ==="
        rm -rf node_modules dist build coverage .next out
        echo "Cleaned: node_modules, dist, build, coverage, .next, out"
        ;;
    
    "size")
        # Check bundle/package sizes
        echo "=== PACKAGE SIZES ==="
        if [ -d "node_modules" ]; then
            echo "node_modules: $(du -sh node_modules | cut -f1)"
        fi
        if [ -d "dist" ]; then
            echo "dist: $(du -sh dist | cut -f1)"
        fi
        if [ -d "build" ]; then
            echo "build: $(du -sh build | cut -f1)"
        fi
        if [ -f "package.json" ]; then
            echo ""
            echo "=== LARGEST DEPENDENCIES ==="
            find node_modules -maxdepth 1 -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -10
        fi
        ;;
    
    "dev")
        # Run dev server
        if grep -q '"dev"' package.json 2>/dev/null; then
            npm run dev
        elif grep -q '"start"' package.json 2>/dev/null; then
            npm start
        else
            echo "No dev or start script found"
        fi
        ;;
    
    "quick-add"|"qa")
        # Quick add dependency
        PKG="$2"
        if [ -z "$PKG" ]; then
            echo "Usage: $0 quick-add <package-name>"
            exit 1
        fi
        
        if [ -f "pnpm-lock.yaml" ]; then
            pnpm add "$PKG"
        elif [ -f "yarn.lock" ]; then
            yarn add "$PKG"
        else
            npm install "$PKG"
        fi
        ;;
    
    "analyze"|"structure")
        # Analyze project structure
        echo "=== PROJECT STRUCTURE ANALYSIS ==="
        if [ -f "package.json" ]; then
            # Check project type
            echo "Project Type:"
            if [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
                echo "  ✓ Next.js Application"
            elif jq -e '.dependencies.react' package.json &>/dev/null; then
                echo "  ✓ React Application"
            elif jq -e '.dependencies.express' package.json &>/dev/null; then
                echo "  ✓ Express Server"
            elif jq -e '.type == "module"' package.json &>/dev/null; then
                echo "  ✓ ES Module Project"
            else
                echo "  ✓ Node.js Project"
            fi
            
            # Check configuration files
            echo ""
            echo "Configuration:"
            [ -f "tsconfig.json" ] && echo "  ✓ TypeScript configured" && {
                TS_TARGET=$(jq -r '.compilerOptions.target // "not set"' tsconfig.json)
                echo "    Target: $TS_TARGET"
            }
            [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ] && echo "  ✓ ESLint configured"
            [ -f ".prettierrc" ] || [ -f "prettier.config.js" ] && echo "  ✓ Prettier configured"
            [ -f "jest.config.js" ] || [ -f "vitest.config.js" ] && echo "  ✓ Testing configured"
            
            # Analyze source structure
            echo ""
            echo "Source Structure:"
            [ -d "src" ] && echo "  ✓ src/ directory" && {
                find src -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | wc -l | xargs echo "    Files:"
            }
            [ -d "pages" ] && echo "  ✓ pages/ directory (Next.js routing)"
            [ -d "app" ] && echo "  ✓ app/ directory (Next.js App Router)"
            [ -d "components" ] && echo "  ✓ components/ directory"
            [ -d "lib" ] && echo "  ✓ lib/ directory"
            [ -d "utils" ] && echo "  ✓ utils/ directory"
            [ -d "tests" ] || [ -d "__tests__" ] && echo "  ✓ tests/ directory"
            
            # Module resolution
            echo ""
            echo "Module System:"
            if jq -e '.type == "module"' package.json &>/dev/null; then
                echo "  Using ES Modules (import/export)"
            else
                echo "  Using CommonJS (require/module.exports)"
            fi
            
            # Check for monorepo
            if [ -f "lerna.json" ] || [ -f "pnpm-workspace.yaml" ] || [ -d "packages" ]; then
                echo ""
                echo "Monorepo Structure:"
                echo "  ✓ Monorepo detected"
                [ -d "packages" ] && find packages -maxdepth 1 -type d | tail -n +2 | wc -l | xargs echo "    Packages:"
            fi
        else
            echo "No package.json found"
        fi
        ;;
    
    *)
        echo "TypeScript/Node.js Helper Commands:"
        echo "  $0 deps|dependencies    - Show dependencies overview"
        echo "  $0 scripts              - List available npm scripts"
        echo "  $0 quick-install|qi     - Install with detected package manager"
        echo "  $0 build                - Run build script"
        echo "  $0 test                 - Run tests"
        echo "  $0 lint                 - Run linter"
        echo "  $0 typecheck|tc         - Run TypeScript type check"
        echo "  $0 outdated             - Check outdated packages"
        echo "  $0 audit                - Security audit"
        echo "  $0 clean                - Clean build artifacts"
        echo "  $0 size                 - Check package sizes"
        echo "  $0 dev                  - Run dev server"
        echo "  $0 quick-add|qa <pkg>   - Quick add package"
        ;;
esac