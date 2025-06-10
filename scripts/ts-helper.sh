#!/bin/bash

# TypeScript/Node.js Helper Script
# Usage: ./ts-helper.sh [command] [args]

case "$1" in
    "deps"|"dependencies")
        echo "=== DEPENDENCIES OVERVIEW ==="
        if [ -f "package.json" ]; then
            if command -v jq &> /dev/null; then
                DEPS=$(jq -r '.dependencies | length' package.json 2>/dev/null || echo "0")
                DEV_DEPS=$(jq -r '.devDependencies | length' package.json 2>/dev/null || echo "0")
                echo "Production dependencies: $DEPS"
                echo "Dev dependencies: $DEV_DEPS"
                echo ""
                echo "Key dependencies:"
                jq -r '.dependencies | to_entries | .[] | "  \(.key): \(.value)"' package.json 2>/dev/null | head -10
            else
                echo "Dependencies:"
                grep -A20 '"dependencies"' package.json | grep -E '^\s*"' | head -10
            fi
        else
            echo "No package.json found"
        fi
        ;;
    
    "scripts")
        echo "=== AVAILABLE SCRIPTS ==="
        if [ -f "package.json" ] && command -v jq &> /dev/null; then
            jq -r '.scripts | to_entries | .[] | "\(.key)\n  \(.value)\n"' package.json 2>/dev/null
        else
            grep -A20 '"scripts"' package.json | grep -E '^\s*"' | sed 's/[",]//g'
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