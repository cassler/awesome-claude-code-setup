#!/bin/bash

# Search Tools Script - Efficient code searching with optional tool enhancements
# Usage: ./search-tools.sh [command] [args]

# Source common functions
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/common-functions.sh"

# Use ripgrep if available, fallback to grep
RG_PATH="/Users/darin/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg"
if [ -x "$RG_PATH" ]; then
    RG="$RG_PATH"
elif command -v rg &> /dev/null; then
    RG="rg"
else
    RG=""
    # Suggest installing ripgrep for better performance
    if [[ -t 0 ]]; then
        check_optional_tool "rg" "true" > /dev/null 2>&1
    fi
fi

# Check for optional tools that enhance search experience
FZF_AVAILABLE=$(check_command fzf && echo "true" || echo "false")
BAT_AVAILABLE=$(check_command bat && echo "true" || echo "false")

case "$1" in
    "find-code"|"fc")
        # Find code pattern efficiently
        PATTERN="$2"
        if [ -z "$PATTERN" ]; then
            echo "Usage: $0 find-code <pattern>"
            exit 1
        fi
        
        if [ -n "$RG" ]; then
            $RG "$PATTERN" --type-list | head -5
            echo "=== SEARCHING FOR: $PATTERN ==="
            $RG "$PATTERN" -n --max-count=3 --max-columns=150
        else
            echo "=== SEARCHING FOR: $PATTERN ==="
            grep -rn "$PATTERN" . --exclude-dir={node_modules,.git,dist,build} | head -20
        fi
        ;;
    
    "find-file"|"ff")
        # Find files by name pattern
        PATTERN="$2"
        if [ -z "$PATTERN" ]; then
            echo "Usage: $0 find-file <pattern>"
            exit 1
        fi
        
        echo "=== FILES MATCHING: $PATTERN ==="
        find . -type f -name "*$PATTERN*" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -20
        ;;
    
    "find-type"|"ft")
        # Find files by extension
        EXT="$2"
        if [ -z "$EXT" ]; then
            echo "Common types: js ts tsx jsx py go rs rb java cpp h"
            echo "Usage: $0 find-type <extension>"
            exit 1
        fi
        
        echo "=== .$EXT FILES ==="
        find . -type f -name "*.$EXT" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -30
        ;;
    
    "search-imports"|"si")
        # Search for import statements
        MODULE="$2"
        if [ -z "$MODULE" ]; then
            echo "Usage: $0 search-imports <module-name>"
            exit 1
        fi
        
        echo "=== IMPORTS OF: $MODULE ==="
        if [ -n "$RG" ]; then
            $RG "(import|require).*['\"].*$MODULE.*['\"]" -n --max-columns=150
        else
            grep -rn -E "(import|require).*['\"].*$MODULE.*['\"]" . --exclude-dir={node_modules,.git}
        fi
        ;;
    
    "search-function"|"sf")
        # Search for function definitions
        FUNC="$2"
        if [ -z "$FUNC" ]; then
            echo "Usage: $0 search-function <function-name>"
            exit 1
        fi
        
        echo "=== FUNCTION: $FUNC ==="
        if [ -n "$RG" ]; then
            $RG "(function|const|let|var|def|fn).*$FUNC" -n --max-columns=150
        else
            grep -rn -E "(function|const|let|var|def|fn).*$FUNC" . --exclude-dir={node_modules,.git}
        fi
        ;;
    
    "search-class"|"sc")
        # Search for class definitions
        CLASS="$2"
        if [ -z "$CLASS" ]; then
            echo "Usage: $0 search-class <class-name>"
            exit 1
        fi
        
        echo "=== CLASS: $CLASS ==="
        if [ -n "$RG" ]; then
            $RG "(class|interface|struct).*$CLASS" -n --max-columns=150
        else
            grep -rn -E "(class|interface|struct).*$CLASS" . --exclude-dir={node_modules,.git}
        fi
        ;;
    
    "todo-comments"|"todo")
        # Find TODO/FIXME comments
        echo "=== TODO/FIXME COMMENTS ==="
        if [ -n "$RG" ]; then
            $RG "(TODO|FIXME|HACK|XXX|BUG):" -n --max-columns=150
        else
            grep -rn -E "(TODO|FIXME|HACK|XXX|BUG):" . --exclude-dir={node_modules,.git}
        fi
        ;;
    
    "large-files"|"lf")
        # Find large files
        SIZE="${2:-1M}"
        echo "=== FILES LARGER THAN $SIZE ==="
        find . -type f -size +$SIZE -not -path "*/node_modules/*" -not -path "*/.git/*" -exec ls -lh {} \; | awk '{print $5 "\t" $9}'
        ;;
    
    "recent-files"|"rf")
        # Find recently modified files
        DAYS="${2:-1}"
        echo "=== FILES MODIFIED IN LAST $DAYS DAY(S) ==="
        find . -type f -mtime -$DAYS -not -path "*/node_modules/*" -not -path "*/.git/*" | head -20
        ;;
    
    "interactive"|"i")
        # Interactive file search with fzf
        if [[ "$FZF_AVAILABLE" == "true" ]]; then
            echo "=== INTERACTIVE FILE SEARCH (ESC to cancel) ==="
            if [[ "$BAT_AVAILABLE" == "true" ]]; then
                # Use bat for preview if available
                find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" | \
                    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' \
                        --preview-window=right:60%:wrap
            else
                # Fallback to head for preview
                find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" | \
                    fzf --preview 'head -100 {}' --preview-window=right:60%:wrap
            fi
        else
            echo "This feature requires fzf. Install it for interactive search."
            check_optional_tool "fzf" "true"
        fi
        ;;
    
    "count-lines"|"cl")
        # Count lines of code by file type
        echo "=== LINES OF CODE BY TYPE ==="
        for ext in js ts tsx jsx py go rs rb java cpp h css scss html; do
            COUNT=$(find . -name "*.$ext" -not -path "*/node_modules/*" -not -path "*/.git/*" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
            [ "$COUNT" != "" ] && [ "$COUNT" != "0" ] && echo ".$ext: $COUNT lines"
        done
        ;;
    
    "search-all"|"sa")
        # Search everything (slower but thorough)
        PATTERN="$2"
        if [ -z "$PATTERN" ]; then
            echo "Usage: $0 search-all <pattern>"
            exit 1
        fi
        
        echo "=== COMPREHENSIVE SEARCH: $PATTERN ==="
        echo ""
        echo "Files containing pattern:"
        if [ -n "$RG" ]; then
            $RG -l "$PATTERN" | head -10
        else
            grep -rl "$PATTERN" . --exclude-dir={node_modules,.git} | head -10
        fi
        echo ""
        echo "File names matching:"
        find . -type f -name "*$PATTERN*" -not -path "*/node_modules/*" | head -5
        echo ""
        echo "First few occurrences:"
        if [ -n "$RG" ]; then
            $RG "$PATTERN" -n --max-count=2 --max-columns=100 | head -10
        else
            grep -rn "$PATTERN" . --exclude-dir={node_modules,.git} | head -10
        fi
        ;;
    
    *)
        echo "Search Tools Commands:"
        echo "  $0 find-code|fc <pattern>      - Find code pattern"
        echo "  $0 find-file|ff <pattern>      - Find files by name"
        echo "  $0 find-type|ft <ext>          - Find files by extension"
        echo "  $0 search-imports|si <module>  - Search import statements"
        echo "  $0 search-function|sf <name>   - Search function definitions"
        echo "  $0 search-class|sc <name>      - Search class definitions"
        echo "  $0 todo-comments|todo          - Find TODO/FIXME comments"
        echo "  $0 large-files|lf [size]       - Find large files"
        echo "  $0 recent-files|rf [days]      - Find recently modified"
        echo "  $0 count-lines|cl              - Count lines by file type"
        echo "  $0 search-all|sa <pattern>     - Comprehensive search"
        echo "  $0 interactive|i               - Interactive file search (requires fzf)"
        echo ""
        echo "Optional tool status:"
        [ -n "$RG" ] && echo "  ✓ ripgrep (fast searching)"
        [[ "$FZF_AVAILABLE" == "true" ]] && echo "  ✓ fzf (interactive search)"
        [[ "$BAT_AVAILABLE" == "true" ]] && echo "  ✓ bat (syntax highlighting)"
        echo ""
        echo "Install optional tools for enhanced features."
        ;;
esac