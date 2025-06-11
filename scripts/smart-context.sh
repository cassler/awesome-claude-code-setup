#!/bin/bash

# Smart Context Generator - Multi-language aware context generation
# Usage: ./smart-context.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common-functions.sh"

# Configuration
DEFAULT_MAX_TOKENS=3000
DEFAULT_DETAIL_LEVEL="normal"  # minimal, normal, full

# Cache variables
RECENT_FILES_CACHE=""

# Language detection based on file extensions and config files
detect_project_languages() {
    local languages=()
    
    # JavaScript/TypeScript
    if find . -name "package.json" -o -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" 2>/dev/null | head -1 | grep -q .; then
        languages+=("javascript")
    fi
    
    # Python
    if find . -name "requirements.txt" -o -name "setup.py" -o -name "pyproject.toml" -o -name "*.py" 2>/dev/null | head -1 | grep -q .; then
        languages+=("python")
    fi
    
    # Go
    if find . -name "go.mod" -o -name "*.go" 2>/dev/null | head -1 | grep -q .; then
        languages+=("go")
    fi
    
    # Rust
    if find . -name "Cargo.toml" -o -name "*.rs" 2>/dev/null | head -1 | grep -q .; then
        languages+=("rust")
    fi
    
    # Bash/Shell scripts
    if find . -name "*.sh" -o -name "*.bash" 2>/dev/null | head -1 | grep -q .; then
        languages+=("bash")
    fi
    
    # Return languages
    if [[ ${#languages[@]} -gt 0 ]]; then
        printf '%s\n' "${languages[@]}"
    fi
}

# Parse imports for JavaScript/TypeScript
parse_js_imports() {
    local file="$1"
    
    # ES6 imports
    grep -E "^import .* from ['\"].*['\"]" "$file" 2>/dev/null | \
        sed -E "s/.*from ['\"]([^'\"]+)['\"].*/\1/" | \
        grep -v "^[\.\/]" | sort -u
    
    # CommonJS requires
    grep -E "require\(['\"].*['\"]\)" "$file" 2>/dev/null | \
        sed -E "s/.*require\(['\"]([^'\"]+)['\"]\).*/\1/" | \
        grep -v "^[\.\/]" | sort -u
    
    # Local imports (relative paths)
    grep -E "from ['\"][\.\/].*['\"]" "$file" 2>/dev/null | \
        sed -E "s/.*from ['\"]([^'\"]+)['\"].*/\1/"
}

# Parse imports for Python
parse_python_imports() {
    local file="$1"
    
    # Standard imports
    grep -E "^import " "$file" 2>/dev/null | \
        sed -E "s/import ([^ ]+).*/\1/" | \
        cut -d'.' -f1 | sort -u
    
    # From imports
    grep -E "^from .* import" "$file" 2>/dev/null | \
        sed -E "s/from ([^ ]+) import.*/\1/" | \
        cut -d'.' -f1 | sort -u
}

# Parse imports for Go
parse_go_imports() {
    local file="$1"
    
    # Extract import block
    awk '/^import \(/{flag=1;next}/^\)/{flag=0}flag' "$file" 2>/dev/null | \
        sed -E 's/^[[:space:]]*"([^"]+)".*/\1/' | \
        grep -v "^$"
    
    # Single line imports
    grep -E '^import "[^"]+"' "$file" 2>/dev/null | \
        sed -E 's/import "([^"]+)".*/\1/'
}

# Parse imports for Rust
parse_rust_imports() {
    local file="$1"
    
    # Use statements
    grep -E "^use " "$file" 2>/dev/null | \
        sed -E "s/use ([^:;{]+).*/\1/" | \
        sed 's/::/\//g' | sort -u
}

# Calculate relevance score for a file
calculate_relevance_score() {
    local file="$1"
    local task="$2"
    local score=0
    
    # Convert task to lowercase for matching
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    # Direct filename match (10 points)
    local basename=$(basename "$file" | tr '[:upper:]' '[:lower:]')
    local filename_without_ext="${basename%.*}"
    
    # Check each word in the task against the filename
    for word in $task_lower; do
        if ! is_stop_word "$word" && [[ "$filename_without_ext" == *"$word"* ]]; then
            ((score += 10))
            break
        fi
    done
    
    # Path relevance (5 points if path contains task word)
    local dirpath=$(dirname "$file" | tr '[:upper:]' '[:lower:]')
    for word in $task_lower; do
        if ! is_stop_word "$word" && [[ "$dirpath" == *"$word"* ]]; then
            ((score += 5))
            break
        fi
    done
    
    # File was already found by grep/rg so it contains keywords (base 5 points)
    ((score += 5))
    
    # Recent changes bonus (3 points) - cache this for performance
    if [[ -z "$RECENT_FILES_CACHE" ]]; then
        RECENT_FILES_CACHE=$(git log --since="7 days ago" --name-only 2>/dev/null | sort -u)
    fi
    if echo "$RECENT_FILES_CACHE" | grep -q "^$file$"; then
        ((score += 3))
    fi
    
    echo "$score"
}

# Detect task type from description
detect_task_type() {
    local task="$1"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    # Check for keywords
    if echo "$task_lower" | grep -qE "test|spec|tdd"; then
        echo "test"
    elif echo "$task_lower" | grep -qE "refactor|clean|improve|optimize"; then
        echo "refactor"
    elif echo "$task_lower" | grep -qE "bug|fix|issue|error|problem"; then
        echo "bug"
    elif echo "$task_lower" | grep -qE "feature|add|implement|create|new"; then
        echo "feature"
    elif echo "$task_lower" | grep -qE "api|endpoint|route|controller"; then
        echo "api"
    elif echo "$task_lower" | grep -qE "doc|document|readme|comment"; then
        echo "docs"
    else
        echo "general"
    fi
}

# Get file patterns to include/exclude based on task type
get_task_patterns() {
    local task_type="$1"
    
    case "$task_type" in
        test)
            echo "include:test|spec|fixture"
            echo "exclude:node_modules|vendor|dist"
            ;;
        refactor)
            echo "include:src|lib|app"
            echo "exclude:test|spec|doc|dist"
            ;;
        bug)
            echo "include:src|lib|app|log"
            echo "exclude:test|doc|dist"
            ;;
        feature)
            echo "include:src|lib|app|test"
            echo "exclude:dist|vendor"
            ;;
        api)
            echo "include:route|controller|api|model|middleware"
            echo "exclude:ui|style|component"
            ;;
        docs)
            echo "include:README|doc|md"
            echo "exclude:test|dist"
            ;;
        *)
            echo "include:src|lib|app"
            echo "exclude:node_modules|vendor|dist"
            ;;
    esac
}

# Estimate token count for content
estimate_tokens() {
    local content="$1"
    # Rough estimate: 1 token ≈ 4 characters
    local chars=$(echo -n "$content" | wc -c | tr -d ' ')
    echo $((chars / 4))
}

# Main context generation function
generate_smart_context() {
    local task="$1"
    local max_tokens="${2:-$DEFAULT_MAX_TOKENS}"
    local detail_level="${3:-$DEFAULT_DETAIL_LEVEL}"
    
    echo -e "${GREEN}=== SMART CONTEXT GENERATION ===${NC}"
    echo "Task: $task"
    echo "Max tokens: $max_tokens"
    echo "Detail level: $detail_level"
    echo ""
    
    # Detect languages
    echo "=== PROJECT ANALYSIS ==="
    echo "Detected languages:"
    local languages=()
    while IFS= read -r lang; do
        languages+=("$lang")
    done < <(detect_project_languages)
    
    if [[ ${#languages[@]} -gt 0 ]]; then
        printf '%s\n' "${languages[@]}"
    else
        echo "No supported languages detected"
    fi
    echo ""
    
    # Detect task type
    local task_type=$(detect_task_type "$task")
    echo "Task type: $task_type"
    echo ""
    
    # Get include/exclude patterns
    local patterns=()
    while IFS= read -r pattern; do
        patterns+=("$pattern")
    done < <(get_task_patterns "$task_type")
    
    # Find and score relevant files
    echo "=== ANALYZING FILES ==="
    local scored_files=()
    
    # Search for files based on task keywords and patterns
    local files=()
    
    # Use ripgrep if available for faster searching
    if check_command rg; then
        # Get files containing task keywords
        echo "Searching for files..."
        for word in $task; do
            if ! is_stop_word "$word"; then
                echo "  Searching for '$word'..."
                local count=0
                # Use a simpler approach - capture output first
                local search_results=$(rg -l "$word" --type-add 'code:*.{js,jsx,ts,tsx,py,go,rs,rb,java,sh,bash}' -tcode 2>/dev/null | head -50 || true)
                if [[ -n "$search_results" ]]; then
                    while IFS= read -r file; do
                        files+=("$file")
                        ((count++))
                    done <<< "$search_results"
                fi
                echo "    Found $count files"
            fi
        done
    else
        # Fallback to find/grep
        for word in $task; do
            if ! is_stop_word "$word"; then
                while IFS= read -r file; do
                    files+=("$file")
                done < <(grep -r -l "$word" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.sh" 2>/dev/null | head -50)
            fi
        done
    fi
    
    # Remove duplicates
    local unique_files=()
    if [[ ${#files[@]} -gt 0 ]]; then
        while IFS= read -r file; do
            unique_files+=("$file")
        done < <(printf '%s\n' "${files[@]}" | sort -u)
        files=("${unique_files[@]}")
    fi
    
    # Score each file
    echo "Scoring ${#files[@]} potentially relevant files..."
    if [[ ${#files[@]} -gt 0 ]]; then
        for file in "${files[@]}"; do
            local score=$(calculate_relevance_score "$file" "$task")
            if [[ "$score" -gt 0 ]]; then
                scored_files+=("$score:$file")
            fi
        done
    fi
    
    # Sort by score
    local sorted_files=()
    if [[ ${#scored_files[@]} -gt 0 ]]; then
        while IFS= read -r line; do
            sorted_files+=("$line")
        done < <(printf '%s\n' "${scored_files[@]}" | sort -rn)
        scored_files=("${sorted_files[@]}")
    fi
    
    # Generate context within token budget
    echo ""
    echo "=== CONTEXT ==="
    local total_tokens=0
    local included_files=0
    
    if [[ ${#scored_files[@]} -gt 0 ]]; then
        for scored_file in "${scored_files[@]}"; do
            local score="${scored_file%%:*}"
            local file="${scored_file#*:}"
            
            # Check if we have token budget
            if [[ "$total_tokens" -ge "$max_tokens" ]]; then
                echo ""
                echo "Token budget reached. Included $included_files files."
                break
            fi
            
            # Read file content based on detail level
            local content=""
            case "$detail_level" in
                minimal)
                    # Just file path and key functions/classes
                    content="File: $file (relevance: $score)"
                    if check_command rg; then
                        local functions=$(rg "^(function|def|func|class)" "$file" 2>/dev/null | head -5)
                        if [[ -n "$functions" ]]; then
                            content="$content\nKey elements:\n$functions"
                        fi
                    fi
                    ;;
                normal)
                    # File path and first 50 lines
                    content="=== File: $file (relevance: $score) ===\n"
                    content="$content$(head -50 "$file" 2>/dev/null)"
                    ;;
                full)
                    # Complete file
                    content="=== File: $file (relevance: $score) ===\n"
                    content="$content$(cat "$file" 2>/dev/null)"
                    ;;
            esac
            
            # Check token count
            local file_tokens=$(estimate_tokens "$content")
            if [[ $((total_tokens + file_tokens)) -le "$max_tokens" ]]; then
                echo -e "$content"
                echo ""
                ((total_tokens += file_tokens))
                ((included_files++))
            fi
        done
    fi
    
    echo ""
    echo "=== SUMMARY ==="
    echo "Files analyzed: ${#files[@]}"
    echo "Files included: $included_files"
    echo "Tokens used: $total_tokens / $max_tokens"
    echo ""
    echo -e "${YELLOW}TIP: Use --max-tokens to adjust context size${NC}"
    echo -e "${YELLOW}TIP: Use --detail [minimal|normal|full] to control detail level${NC}"
}

# Parse command line arguments
case "$1" in
    "for-task"|"task")
        shift
        TASK=""
        MAX_TOKENS="$DEFAULT_MAX_TOKENS"
        DETAIL_LEVEL="$DEFAULT_DETAIL_LEVEL"
        
        # Parse arguments
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --max-tokens)
                    MAX_TOKENS="$2"
                    shift 2
                    ;;
                --detail)
                    DETAIL_LEVEL="$2"
                    shift 2
                    ;;
                *)
                    if [ -z "$TASK" ]; then
                        TASK="$1"
                    else
                        TASK="$TASK $1"
                    fi
                    shift
                    ;;
            esac
        done
        
        if [[ -z "$TASK" ]]; then
            error_exit "Usage: $0 for-task <description> [--max-tokens N] [--detail minimal|normal|full]"
        fi
        
        # Basic safety check - no shell special characters
        if [[ "$TASK" =~ [\;\|\&\$\`] ]]; then
            error_exit "Invalid characters in task description. Please avoid shell special characters."
        fi
        
        generate_smart_context "$TASK" "$MAX_TOKENS" "$DETAIL_LEVEL"
        ;;
    
    "test")
        # Test the scoring and detection functions
        echo "Testing language detection..."
        detect_project_languages
        echo ""
        
        echo "Testing task type detection..."
        echo "Task 'refactor auth module': $(detect_task_type 'refactor auth module')"
        echo "Task 'fix login bug': $(detect_task_type 'fix login bug')"
        echo "Task 'add new feature': $(detect_task_type 'add new feature')"
        echo "Task 'write tests': $(detect_task_type 'write tests')"
        ;;
    
    "help"|"")
        echo "=== SMART CONTEXT GENERATOR ==="
        echo ""
        echo "Usage: $0 for-task <description> [options]"
        echo ""
        echo "Options:"
        echo "  --max-tokens N    Maximum tokens for context (default: $DEFAULT_MAX_TOKENS)"
        echo "  --detail LEVEL    Detail level: minimal, normal, full (default: $DEFAULT_DETAIL_LEVEL)"
        echo ""
        echo "Examples:"
        echo "  $0 for-task 'refactor authentication'"
        echo "  $0 for-task 'fix login bug' --max-tokens 2000"
        echo "  $0 for-task 'add payment feature' --detail minimal"
        echo ""
        echo "Features:"
        echo "  - Multi-language support (JS/TS, Python, Go, Rust)"
        echo "  - Relevance scoring based on task description"
        echo "  - Token budget management"
        echo "  - Task-aware filtering"
        ;;
    
    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac