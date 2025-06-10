#!/bin/bash

# Code Relationships - Analyze dependencies and imports
# Usage: ./code-relationships.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common-functions.sh"

# Check optional dependencies
check_dependencies rg

case "$1" in
    "imports-of")
        # Find what a file imports
        FILE="${2:-}"
        if [ -z "$FILE" ]; then
            error_exit "Usage: $0 imports-of <file>"
        fi
        
        check_file "$FILE"
        
        echo -e "${GREEN}=== IMPORTS IN: $FILE ===${NC}"
        echo ""
        
        # JavaScript/TypeScript imports
        if [[ "$FILE" =~ \.(js|jsx|ts|tsx)$ ]]; then
            echo "ES6 imports:"
            grep -E "^import .* from|^import \{" "$FILE" || echo "  None found"
            echo ""
            echo "CommonJS requires:"
            grep -E "require\(['\"]" "$FILE" || echo "  None found"
        fi
        
        # Python imports
        if [[ "$FILE" =~ \.py$ ]]; then
            echo "Python imports:"
            grep -E "^import |^from .* import" "$FILE" || echo "  None found"
        fi
        
        # Go imports
        if [[ "$FILE" =~ \.go$ ]]; then
            echo "Go imports:"
            grep -A20 "^import (" "$FILE" | head -21 || grep "^import " "$FILE" || echo "  None found"
        fi
        ;;
    
    "imported-by")
        # Find who imports a file/module
        MODULE="${2:-}"
        if [ -z "$MODULE" ]; then
            error_exit "Usage: $0 imported-by <file-or-module>"
        fi
        
        # Extract module name from path
        MODULE_NAME=$(basename "$MODULE" | sed 's/\.[^.]*$//')
        
        echo -e "${GREEN}=== FILES IMPORTING: $MODULE_NAME ===${NC}"
        echo ""
        
        if check_command rg; then
            # Search for various import patterns
            echo "Direct imports:"
            rg -l "from ['\"].*${MODULE_NAME}['\"]|require\(['\"].*${MODULE_NAME}['\"]" \
                --type-add 'code:*.{js,jsx,ts,tsx,py,go}' -tcode 2>/dev/null | head -20
        else
            echo "Direct imports:"
            grep -r -l "${MODULE_NAME}" . \
                --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
                --include="*.py" --include="*.go" 2>/dev/null | \
                xargs grep -E -l "import.*${MODULE_NAME}|from.*${MODULE_NAME}|require.*${MODULE_NAME}" 2>/dev/null | head -20
        fi
        ;;
    
    "dependency-tree")
        # Show dependency tree for a directory
        DIR="${2:-.}"
        DEPTH="${3:-3}"
        
        if [ ! -d "$DIR" ]; then
            error_exit "Directory not found: $DIR"
        fi
        
        echo -e "${GREEN}=== DEPENDENCY TREE: $DIR ===${NC}"
        echo ""
        
        # Find entry points
        echo "Entry points:"
        find "$DIR" -maxdepth 1 -name "index.*" -o -name "main.*" | head -10
        echo ""
        
        # Show internal dependencies
        echo "Internal module structure:"
        if check_command tree; then
            tree "$DIR" -P "*.js|*.jsx|*.ts|*.tsx|*.py|*.go" -I "node_modules|__pycache__|*.test.*|*.spec.*" -L "$DEPTH"
        else
            find "$DIR" -maxdepth "$DEPTH" -type f \
                \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
                -o -name "*.py" -o -name "*.go" \) \
                ! -name "*.test.*" ! -name "*.spec.*" | sort
        fi
        ;;
    
    "circular")
        # Check for circular dependencies
        DIR="${2:-.}"
        
        echo -e "${GREEN}=== CHECKING FOR CIRCULAR DEPENDENCIES ===${NC}"
        echo ""
        
        # This is a simplified check - looks for files that import each other
        echo "Potential circular imports (requires manual verification):"
        
        # Find all code files
        find "$DIR" -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) \
            ! -path "*/node_modules/*" ! -name "*.test.*" ! -name "*.spec.*" | while read -r file1; do
            
            # Get what this file imports
            imports=$(grep -E "import.*from|require\(" "$file1" 2>/dev/null | grep -oE "['\"][^'\"]+['\"]" | tr -d "\"'" | grep -v "^[./]")
            
            for import in $imports; do
                # Check if any imported file also imports the current file
                import_base=$(basename "$file1" .js | sed 's/\.[^.]*$//')
                if check_command rg; then
                    matches=$(rg -l "$import_base" --type-add 'code:*.{js,jsx,ts,tsx}' -tcode 2>/dev/null | grep "$import")
                    if [ -n "$matches" ]; then
                        echo "  Potential circular: $file1 <-> $matches"
                    fi
                fi
            done
        done | sort -u | head -20
        
        echo ""
        echo -e "${YELLOW}Note: This is a heuristic check. Manual verification recommended.${NC}"
        ;;
    
    "help"|"")
        echo "=== CODE RELATIONSHIPS ANALYZER ==="
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  imports-of <file>         - Show what a file imports"
        echo "  imported-by <file/module> - Find who imports a file/module"
        echo "  dependency-tree <dir>     - Show dependency structure"
        echo "  circular [dir]            - Check for circular dependencies"
        echo ""
        echo "Examples:"
        echo "  $0 imports-of src/index.js"
        echo "  $0 imported-by utils"
        echo "  $0 dependency-tree src/components 2"
        echo "  $0 circular src"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac