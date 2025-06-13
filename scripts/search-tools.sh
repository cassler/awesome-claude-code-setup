#!/bin/bash

# Search Tools Script - Enhanced code searching with fzf, bat, and ripgrep
# Usage: ./search-tools.sh [command] [args]

# Source common functions
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/common-functions.sh"

# Check for ripgrep
RG_PATH="/Users/darin/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg"
if [ -x "$RG_PATH" ]; then
    RG="$RG_PATH"
elif command -v rg &> /dev/null; then
    RG="rg"
else
    echo "❌ ripgrep (rg) is required for search tools"
    echo "Install with: brew install ripgrep"
    exit 1
fi

case "$1" in
    "find-code"|"fc")
        # Find code pattern with interactive selection
        PATTERN="${2:-}"
        if [ -z "$PATTERN" ]; then
            echo "Usage: $0 find-code <pattern>"
            exit 1
        fi
        
        if should_use_interactive "$@" && command -v fzf &> /dev/null && command -v bat &> /dev/null; then
            # Interactive mode with fzf and bat
            echo "=== INTERACTIVE SEARCH: $PATTERN ==="
            $RG "$PATTERN" -l | fzf --preview "$RG '$PATTERN' -n --color always {} | bat --color=always --style=plain --language=txt" \
                --preview-window=right:60%:wrap \
                --header="Select file to view (ESC to cancel)"
        else
            # Non-interactive search output
            echo "=== SEARCHING FOR: $PATTERN ==="
            $RG "$PATTERN" -n --max-count=3 --max-columns=150
        fi
        ;;
    
    "find-file"|"ff")
        # Find files by name with interactive selection
        PATTERN="${2:-}"
        if [ -z "$PATTERN" ]; then
            echo "Usage: $0 find-file <pattern>"
            exit 1
        fi
        
        if should_use_interactive "$@" && command -v fzf &> /dev/null; then
            # Interactive file selection
            find . -type f -name "*$PATTERN*" -not -path "*/node_modules/*" -not -path "*/.git/*" | \
                fzf --preview 'bat --color=always --style=numbers {} 2>/dev/null || head -50 {}' \
                    --preview-window=right:60%:wrap \
                    --header="Files matching: $PATTERN"
        else
            echo "=== FILES MATCHING: $PATTERN ==="
            find . -type f -name "*$PATTERN*" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -20
        fi
        ;;
    
    "find-type"|"ft")
        # Find files by extension
        EXT="${2:-}"
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
        MODULE="${2:-}"
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
        # Search for function definitions with context
        FUNC="${2:-}"
        if [ -z "$FUNC" ]; then
            echo "Usage: $0 search-function <function-name>"
            exit 1
        fi
        
        echo "=== FUNCTION: $FUNC ==="
        # Use ripgrep with context lines for better understanding
        $RG "(function|const|let|var|def|fn|func)\s+$FUNC" -A 3 -B 1 --max-columns=150
        ;;
    
    "search-class"|"sc")
        # Search for class definitions
        CLASS="${2:-}"
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
        # If SIZE is just a number, assume it's in KB
        if [[ "$SIZE" =~ ^[0-9]+$ ]]; then
            SIZE="${SIZE}k"
        fi
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
        # Interactive file search
        if ! should_use_interactive "$@"; then
            echo "=== FILE LIST (top 30) ==="
            $RG --files | head -30
            echo ""
            echo "Note: Interactive mode disabled (non-TTY environment)"
            echo "Use specific search commands like 'find-file' or 'find-code' instead"
        elif ! command -v fzf &> /dev/null; then
            echo "❌ fzf is required for interactive search"
            echo "Install with: brew install fzf"
            exit 1
        else
            echo "=== INTERACTIVE FILE SEARCH (ESC to cancel) ==="
            
            # Enhanced search with ripgrep for file listing (respects .gitignore)
            if command -v bat &> /dev/null; then
                $RG --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' \
                    --preview-window=right:60%:wrap \
                    --bind 'ctrl-/:change-preview-window(hidden|)'
            else
                $RG --files | fzf --preview 'head -100 {}' --preview-window=right:60%:wrap
            fi
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
        PATTERN="${2:-}"
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
        command -v fzf &> /dev/null && echo "  ✓ fzf (interactive search)"
        command -v bat &> /dev/null && echo "  ✓ bat (syntax highlighting)"
        echo ""
        echo "Install optional tools for enhanced features."
        ;;
esac