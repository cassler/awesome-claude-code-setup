#!/bin/bash

# Environment Check Script
# Usage: ./env-check.sh [check-type]

case "$1" in
    "tools"|"")
        echo "=== DEVELOPMENT TOOLS CHECK ==="
        
        # Check common tools
        TOOLS=(
            "git:Version control"
            "node:Node.js runtime"
            "npm:Node package manager"
            "docker:Container runtime"
            "python3:Python 3"
            "make:Build automation"
            "curl:HTTP client"
            "jq:JSON processor"
            "gh:GitHub CLI"
            "code:VS Code"
        )
        
        for tool_desc in "${TOOLS[@]}"; do
            IFS=':' read -r tool desc <<< "$tool_desc"
            if command -v "$tool" &> /dev/null; then
                VERSION=$("$tool" --version 2>&1 | head -1)
                echo "✓ $tool - $desc"
                echo "  $VERSION"
            else
                echo "✗ $tool - $desc (not found)"
            fi
        done
        ;;
    
    "node")
        echo "=== NODE.JS ENVIRONMENT ==="
        if command -v node &> /dev/null; then
            echo "Node: $(node --version)"
            echo "NPM: $(npm --version 2>/dev/null || echo 'not found')"
            [ -f "pnpm-lock.yaml" ] && echo "PNPM: $(pnpm --version 2>/dev/null || echo 'not found')"
            [ -f "yarn.lock" ] && echo "Yarn: $(yarn --version 2>/dev/null || echo 'not found')"
            echo ""
            echo "Global packages:"
            npm list -g --depth=0 2>/dev/null | grep -E "├──|└──" | head -10
        else
            echo "Node.js not installed"
        fi
        ;;
    
    "python")
        echo "=== PYTHON ENVIRONMENT ==="
        if command -v python3 &> /dev/null; then
            echo "Python: $(python3 --version)"
            echo "Pip: $(pip3 --version 2>/dev/null || echo 'not found')"
            echo ""
            if [ -n "$VIRTUAL_ENV" ]; then
                echo "Virtual env: $VIRTUAL_ENV"
            else
                echo "No virtual environment active"
            fi
            echo ""
            echo "Installed packages:"
            pip3 list 2>/dev/null | head -10
        else
            echo "Python 3 not installed"
        fi
        ;;
    
    "docker")
        echo "=== DOCKER ENVIRONMENT ==="
        if command -v docker &> /dev/null; then
            docker version --format 'Client: {{.Client.Version}}\nServer: {{.Server.Version}}' 2>/dev/null || echo "Docker daemon not running"
            echo ""
            if docker ps &>/dev/null; then
                echo "Containers running: $(docker ps -q | wc -l)"
                echo "Images available: $(docker images -q | wc -l)"
            fi
        else
            echo "Docker not installed"
        fi
        ;;
    
    "git")
        echo "=== GIT CONFIGURATION ==="
        if command -v git &> /dev/null; then
            echo "Git: $(git --version)"
            echo ""
            echo "User config:"
            echo "  Name: $(git config user.name || echo 'not set')"
            echo "  Email: $(git config user.email || echo 'not set')"
            echo ""
            echo "Global aliases:"
            git config --global --get-regexp alias | head -5
        else
            echo "Git not installed"
        fi
        ;;
    
    "ports")
        echo "=== COMMON PORTS STATUS ==="
        PORTS=(
            "3000:React/Next.js dev"
            "8000:Django/Python"
            "8080:Common web"
            "5432:PostgreSQL"
            "3306:MySQL"
            "6379:Redis"
            "27017:MongoDB"
            "9000:PHP-FPM"
        )
        
        for port_desc in "${PORTS[@]}"; do
            IFS=':' read -r port desc <<< "$port_desc"
            if lsof -i ":$port" &>/dev/null; then
                PROCESS=$(lsof -i ":$port" | grep LISTEN | awk '{print $1}' | head -1)
                echo "✓ Port $port ($desc) - Used by: $PROCESS"
            else
                echo "  Port $port ($desc) - Free"
            fi
        done
        ;;
    
    "env")
        echo "=== ENVIRONMENT VARIABLES ==="
        echo "PATH entries:"
        echo "$PATH" | tr ':' '\n' | head -10
        echo ""
        echo "Key variables:"
        env | grep -E "^(HOME|USER|SHELL|EDITOR|LANG|NODE_ENV|DATABASE_URL)" | sort
        echo ""
        if [ -f ".env" ]; then
            echo ".env file found with $(wc -l < .env) variables"
        fi
        ;;
    
    "system")
        echo "=== SYSTEM INFO ==="
        echo "OS: $(uname -s)"
        echo "Kernel: $(uname -r)"
        echo "Architecture: $(uname -m)"
        echo "Hostname: $(hostname)"
        echo ""
        echo "Memory:"
        if command -v free &> /dev/null; then
            free -h | grep Mem
        elif command -v vm_stat &> /dev/null; then
            vm_stat | head -5
        fi
        echo ""
        echo "Disk usage:"
        df -h . | tail -1
        ;;
    
    "project")
        echo "=== PROJECT REQUIREMENTS CHECK ==="
        
        # Check for requirement files
        [ -f "package.json" ] && echo "✓ package.json found"
        [ -f "requirements.txt" ] && echo "✓ requirements.txt found"
        [ -f "Gemfile" ] && echo "✓ Gemfile found"
        [ -f "go.mod" ] && echo "✓ go.mod found"
        [ -f "Cargo.toml" ] && echo "✓ Cargo.toml found"
        
        # Check for config files
        echo ""
        echo "Configuration files:"
        [ -f ".env" ] && echo "✓ .env"
        [ -f ".env.example" ] && echo "✓ .env.example"
        [ -f "tsconfig.json" ] && echo "✓ tsconfig.json"
        [ -f ".eslintrc.json" ] && echo "✓ .eslintrc.json"
        [ -f ".prettierrc" ] && echo "✓ .prettierrc"
        [ -f "Dockerfile" ] && echo "✓ Dockerfile"
        [ -f "docker-compose.yml" ] && echo "✓ docker-compose.yml"
        
        # Check for CI/CD
        echo ""
        echo "CI/CD:"
        [ -d ".github/workflows" ] && echo "✓ GitHub Actions"
        [ -f ".gitlab-ci.yml" ] && echo "✓ GitLab CI"
        [ -f ".circleci/config.yml" ] && echo "✓ CircleCI"
        [ -f "Jenkinsfile" ] && echo "✓ Jenkins"
        ;;
    
    *)
        echo "Environment Check Commands:"
        echo "  $0 [tools]     - Check common dev tools"
        echo "  $0 node        - Node.js environment"
        echo "  $0 python      - Python environment"
        echo "  $0 docker      - Docker environment"
        echo "  $0 git         - Git configuration"
        echo "  $0 ports       - Common ports status"
        echo "  $0 env         - Environment variables"
        echo "  $0 system      - System information"
        echo "  $0 project     - Project requirements"
        ;;
esac