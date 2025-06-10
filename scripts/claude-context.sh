#!/bin/bash

# Claude Context Generator - Create optimal context for Claude
# Usage: ./claude-context.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

case "$1" in
    "for-task"|"task")
        # Generate context for a specific task
        TASK="$2"
        if [ -z "$TASK" ]; then
            echo "Usage: $0 for-task <task-description>"
            exit 1
        fi
        
        echo -e "${GREEN}=== GENERATING CONTEXT FOR: $TASK ===${NC}"
        echo ""
        
        # Find files related to the task keywords
        echo "=== RELATED FILES ==="
        for word in $TASK; do
            # Skip common words
            if [[ "$word" =~ ^(the|and|or|in|on|at|to|for|of|with|a|an)$ ]]; then
                continue
            fi
            
            echo "Files containing '$word':"
            if command -v rg &> /dev/null; then
                rg -l "$word" --type-add 'code:*.{js,jsx,ts,tsx,py,go,java,c,cpp,rs,rb,php}' -tcode 2>/dev/null | head -10
            else
                grep -r -l "$word" . --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
                    --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -10
            fi
            echo ""
        done
        
        echo "=== KEY DIRECTORIES ==="
        # Find directories that might be relevant
        for word in $TASK; do
            if [[ "$word" =~ ^(the|and|or|in|on|at|to|for|of|with|a|an)$ ]]; then
                continue
            fi
            find . -type d -name "*${word}*" 2>/dev/null | grep -v node_modules | grep -v ".git" | head -5
        done
        
        echo ""
        echo -e "${YELLOW}TIP: Use 'ch m read-many <files>' to read multiple files efficiently${NC}"
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
        DIR="$2"
        DEPTH="${3:-2}"
        
        if [ -z "$DIR" ]; then
            echo "Usage: $0 focus <directory> [depth]"
            exit 1
        fi
        
        echo -e "${GREEN}=== FOCUSED CONTEXT: $DIR ===${NC}"
        echo ""
        
        # Show directory structure
        echo "=== STRUCTURE ==="
        if command -v tree &> /dev/null; then
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
        MIGRATION="$2"
        
        if [ -z "$MIGRATION" ]; then
            echo "Usage: $0 prepare-migration <description>"
            exit 1
        fi
        
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
            cat package.json | jq '.dependencies' 2>/dev/null || grep -A20 '"dependencies"' package.json
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