#!/bin/bash

# Claude Context Generator - Create optimal context for Claude
# Usage: ./claude-context.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common-functions.sh"

# Check optional dependencies
check_dependencies rg tree jq

case "$1" in
    "for-task"|"task")
        # Use the new smart context generator
        shift
        exec "$SCRIPT_DIR/smart-context.sh" for-task "$@"
        ;;
    
    "summarize")
        # Create a summary of the codebase
        echo -e "${GREEN}=== CODEBASE SUMMARY ===${NC}"
        echo ""
        
        # Get project info first
        "$SCRIPT_DIR/project-info.sh" | head -30
        
        echo ""
        echo "=== FILE STATISTICS ==="
        echo "Total files by type:"
        find . -type f -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
            -o -name "*.py" -o -name "*.go" -o -name "*.java" 2>/dev/null | \
            grep -v node_modules | grep -v ".git" | \
            awk -F. '{print $NF}' | sort | uniq -c | sort -rn
        
        echo ""
        echo "=== LARGEST FILES ==="
        find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
            -o -name "*.py" -o -name "*.go" -o -name "*.java" \) \
            -exec wc -l {} + 2>/dev/null | sort -rn | head -10
        
        if [ "$2" == "--save" ]; then
            # Save to CLAUDE.md
            {
                echo "# Project Context for Claude"
                echo ""
                echo "Generated on: $(date)"
                echo ""
                "$SCRIPT_DIR/project-info.sh"
            } > CLAUDE.md
            echo ""
            echo -e "${GREEN}✓ Context saved to CLAUDE.md${NC}"
        fi
        ;;
    
    "focus")
        # Focus on a specific directory
        DIR="${2:-}"
        DEPTH="${3:-2}"
        
        if [ -z "$DIR" ]; then
            error_exit "Usage: $0 focus <directory> [depth]"
        fi
        
        if [ ! -d "$DIR" ]; then
            error_exit "Directory not found: $DIR"
        fi
        
        echo -e "${GREEN}=== FOCUSED CONTEXT: $DIR ===${NC}"
        echo ""
        
        # Show directory structure
        echo "=== STRUCTURE ==="
        if check_command tree; then
            tree "$DIR" -L "$DEPTH" -I 'node_modules|__pycache__|*.pyc|.git'
        else
            find "$DIR" -maxdepth "$DEPTH" -type f | grep -v node_modules | sort
        fi
        
        echo ""
        echo "=== KEY FILES ==="
        # Show important files
        find "$DIR" -maxdepth "$DEPTH" -type f \
            \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
            -o -name "Makefile" -o -name "Dockerfile" \) \
            2>/dev/null | head -10
        
        echo ""
        echo "=== ENTRY POINTS ==="
        # Find main/index files
        find "$DIR" -maxdepth "$DEPTH" -type f \
            \( -name "main.*" -o -name "index.*" -o -name "app.*" -o -name "server.*" \) \
            2>/dev/null
        ;;
    
    "prepare-migration")
        # Prepare context for migration
        MIGRATION="${2:-}"
        
        if [ -z "$MIGRATION" ]; then
            error_exit "Usage: $0 prepare-migration <description>"
        fi
        
        # Validate input
        if ! validate_input "$MIGRATION"; then
            error_exit "Invalid migration description. Use only alphanumeric characters, spaces, and basic punctuation."
        fi
        
        check_git_repo
        
        echo -e "${GREEN}=== MIGRATION CONTEXT: $MIGRATION ===${NC}"
        echo ""
        
        # Show recent changes
        echo "=== RECENT CHANGES ==="
        git log --oneline -10
        
        echo ""
        echo "=== MODIFIED FILES ==="
        git diff --name-only HEAD~5
        
        echo ""
        echo "=== DEPENDENCIES ==="
        if [ -f "package.json" ]; then
            echo "Current dependencies:"
            if check_command jq; then
                jq '.dependencies' package.json 2>/dev/null
            else
                grep -A20 '"dependencies"' package.json
            fi
        fi
        
        echo ""
        echo "=== CONFIGURATION FILES ==="
        find . -maxdepth 2 -name "*.config.*" -o -name ".*rc" -o -name "*.env*" | grep -v node_modules
        ;;
    
    "help"|"")
        echo "=== CLAUDE CONTEXT GENERATOR ==="
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  for-task <description>    - Generate context for specific task"
        echo "  summarize [--save]        - Create codebase summary (save to CLAUDE.md)"
        echo "  focus <dir> [depth]       - Focus on specific directory"
        echo "  prepare-migration <desc>  - Prepare context for migration"
        echo ""
        echo "Examples:"
        echo "  $0 for-task 'refactor authentication'"
        echo "  $0 summarize --save"
        echo "  $0 focus src/api 3"
        echo "  $0 prepare-migration 'upgrade to react 18'"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac