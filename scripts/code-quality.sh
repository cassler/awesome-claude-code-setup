#!/bin/bash

# Code Quality Checker - Find issues and improve code quality
# Usage: ./code-quality.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common-functions.sh"

# Check optional dependencies
check_dependencies rg

case "$1" in
    "todos")
        # Find TODO, FIXME, HACK, XXX comments
        WITH_CONTEXT="${2:-}"
        
        echo -e "${GREEN}=== TODO/FIXME/HACK COMMENTS ===${NC}"
        echo ""
        
        if check_command rg; then
            if [ "$WITH_CONTEXT" == "--with-context" ]; then
                rg "TODO|FIXME|HACK|XXX" -C 2 --type-add 'code:*.{js,jsx,ts,tsx,py,go,java,c,cpp,rs,rb,php}' -tcode
            else
                rg "TODO|FIXME|HACK|XXX" --type-add 'code:*.{js,jsx,ts,tsx,py,go,java,c,cpp,rs,rb,php}' -tcode
            fi
        else
            if [ "$WITH_CONTEXT" == "--with-context" ]; then
                grep -r -n -C 2 "TODO\|FIXME\|HACK\|XXX" . \
                    --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
                    --include="*.py" --include="*.go" --include="*.java" 2>/dev/null
            else
                grep -r -n "TODO\|FIXME\|HACK\|XXX" . \
                    --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
                    --include="*.py" --include="*.go" --include="*.java" 2>/dev/null
            fi
        fi
        ;;
    
    "console-logs")
        # Find console.log statements
        echo -e "${GREEN}=== CONSOLE.LOG STATEMENTS ===${NC}"
        echo ""
        
        if check_command rg; then
            rg "console\.(log|error|warn|debug)" \
                --type-add 'code:*.{js,jsx,ts,tsx}' -tcode \
                -g '!*.test.*' -g '!*.spec.*' -g '!node_modules'
        else
            grep -r -n "console\.\(log\|error\|warn\|debug\)" . \
                --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
                --exclude="*.test.*" --exclude="*.spec.*" 2>/dev/null | \
                grep -v node_modules
        fi
        ;;
    
    "large-files")
        # Find files exceeding line count
        THRESHOLD="${2:-500}"
        
        echo -e "${GREEN}=== FILES EXCEEDING $THRESHOLD LINES ===${NC}"
        echo ""
        
        find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
            -o -name "*.py" -o -name "*.go" -o -name "*.java" \) \
            ! -path "*/node_modules/*" ! -name "*.min.*" -exec wc -l {} + | \
            awk -v threshold="$THRESHOLD" '$1 > threshold {print}' | \
            sort -rn | head -20
        ;;
    
    "complexity")
        # Find complex code patterns
        MAX_COMPLEXITY="${2:-15}"
        
        echo -e "${GREEN}=== POTENTIALLY COMPLEX CODE ===${NC}"
        echo ""
        
        echo "Deeply nested code (16+ spaces):"
        if check_command rg; then
            rg "^[ ]{16,}" --type-add 'code:*.{js,jsx,ts,tsx,py,go,java}' -tcode -l | head -10
        else
            grep -r -l "^[ ]\{16,\}" . --include="*.js" --include="*.ts" --include="*.py" 2>/dev/null | head -10
        fi
        
        echo ""
        echo "Long functions (500+ chars between braces):"
        if check_command rg; then
            rg "function.*\{[\s\S]{500,}\}" --multiline --files-with-matches \
                --type-add 'code:*.{js,jsx,ts,tsx}' -tcode | head -10
        fi
        
        echo ""
        echo -e "${YELLOW}Note: For accurate complexity analysis, consider using language-specific tools${NC}"
        ;;
    
    "secrets-scan")
        # Scan for potential secrets
        echo -e "${GREEN}=== SCANNING FOR POTENTIAL SECRETS ===${NC}"
        echo ""
        
        patterns=(
            "password\s*=\s*['\"][^'\"]{8,}['\"]"
            "api[_-]?key\s*=\s*['\"][^'\"]{20,}['\"]"
            "secret\s*=\s*['\"][^'\"]{8,}['\"]"
            "token\s*=\s*['\"][^'\"]{20,}['\"]"
            "private[_-]?key"
            "BEGIN RSA PRIVATE KEY"
            "BEGIN OPENSSH PRIVATE KEY"
            "aws_access_key_id"
            "aws_secret_access_key"
        )
        
        for pattern in "${patterns[@]}"; do
            echo "Checking for: $pattern"
            if check_command rg; then
                rg -i "$pattern" --type-add 'code:*.{js,jsx,ts,tsx,py,go,java,env,yml,yaml,json}' -tcode \
                    -g '!*.test.*' -g '!*.spec.*' -g '!*.example' -g '!*sample*' | head -5
            else
                grep -r -i "$pattern" . \
                    --include="*.js" --include="*.py" --include="*.env" --include="*.yml" \
                    --exclude="*.test.*" --exclude="*.example" 2>/dev/null | head -5
            fi
            echo ""
        done
        
        echo -e "${YELLOW}Note: Review matches carefully - some may be false positives${NC}"
        ;;
    
    "help"|"")
        echo "=== CODE QUALITY CHECKER ==="
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  todos [--with-context]    - Find TODO/FIXME/HACK comments"
        echo "  console-logs              - Find console.log statements"
        echo "  large-files [threshold]   - Find files exceeding line count"
        echo "  complexity [threshold]    - Find complex code patterns"
        echo "  secrets-scan              - Scan for potential secrets"
        echo ""
        echo "Examples:"
        echo "  $0 todos --with-context"
        echo "  $0 large-files 300"
        echo "  $0 complexity 10"
        echo "  $0 secrets-scan"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac