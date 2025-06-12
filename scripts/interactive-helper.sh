#!/bin/bash

# Interactive helper using optional tools for enhanced UX

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# Help function
show_help() {
    echo "Interactive Claude Helper"
    echo ""
    echo "Usage: $(basename "$0") <command> [options]"
    echo ""
    echo "Commands:"
    echo "  select-file        Interactive file selection"
    echo "  select-files       Select multiple files"
    echo "  select-script      Choose and run npm/yarn script"
    echo "  select-branch      Switch git branch interactively"
    echo "  search-and-edit    Search for code and edit files"
    echo "  quick-commit       Interactive commit with preview"
    echo "  help              Show this help message"
    echo ""
    
    # Show tool availability
    echo "Optional Tools Status:"
    check_optional_tool "fzf" "Interactive selection" false
    check_optional_tool "bat" "Syntax highlighting" false
    check_optional_tool "gum" "Beautiful prompts" false
    check_optional_tool "delta" "Enhanced diffs" false
}

# Interactive file selection with preview
select_file() {
    if should_use_interactive "$@" && command -v fzf &> /dev/null && command -v bat &> /dev/null; then
        # Enhanced experience with fzf and bat
        find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' | \
            fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
                --preview-window=right:60% \
                --header="Select a file (arrows to navigate, enter to select)"
    elif should_use_interactive "$@" && command -v fzf &> /dev/null; then
        # fzf without bat
        find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' | \
            fzf --preview 'head -50 {}' \
                --preview-window=right:50% \
                --header="Select a file"
    else
        # Fallback to numbered list (works in non-TTY)
        echo "Select a file:" >&2
        local files=()
        while IFS= read -r file; do
            files+=("$file")
        done < <(find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' | head -20)
        
        for i in "${!files[@]}"; do
            echo "$((i+1)). ${files[$i]}" >&2
        done
        
        if is_interactive; then
            echo -n "Enter number (1-${#files[@]}): " >&2
            read -r num
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#files[@]}" ]; then
                echo "${files[$((num-1))]}"
            fi
        else
            echo "" >&2
            echo "Note: Non-interactive mode - listing files only" >&2
            return 1
        fi
    fi
}

# Select multiple files
select_files() {
    if should_use_interactive "$@" && command -v fzf &> /dev/null; then
        find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' | \
            fzf --multi \
                --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || head -50 {}' \
                --preview-window=right:50% \
                --header="Select files (tab to select multiple, enter when done)"
    elif ! should_use_interactive "$@"; then
        echo "=== FILE LIST (top 30) ===" >&2
        find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' | head -30
        echo "" >&2
        echo "Note: Multi-file selection disabled in non-interactive mode" >&2
        return 1
    else
        echo "⚠️  Multi-file selection requires fzf"
        suggest_install_tool "fzf"
        echo ""
        echo "Falling back to single file selection..."
        select_file "$@"
    fi
}

# Interactive npm/yarn script selection
select_script() {
    if [ ! -f "package.json" ]; then
        echo "❌ No package.json found in current directory"
        return 1
    fi
    
    # Extract scripts from package.json
    local scripts=$(jq -r '.scripts | to_entries | .[] | "\(.key): \(.value)"' package.json 2>/dev/null || \
                   grep -A 100 '"scripts"' package.json | grep -E '^\s*"[^"]+":' | sed 's/[",]//g' | sed 's/^\s*//')
    
    if [ -z "$scripts" ]; then
        echo "❌ No scripts found in package.json"
        return 1
    fi
    
    if command -v fzf &> /dev/null; then
        # Use fzf for selection
        local selected=$(echo "$scripts" | fzf --header="Select script to run" --preview-window=hidden)
        if [ -n "$selected" ]; then
            local script_name=$(echo "$selected" | cut -d: -f1 | xargs)
            echo "Running: npm run $script_name"
            npm run "$script_name"
        fi
    elif command -v gum &> /dev/null; then
        # Use gum for selection
        local script_names=$(echo "$scripts" | cut -d: -f1 | xargs -n1)
        local selected=$(echo "$script_names" | gum choose --header "Select script to run")
        if [ -n "$selected" ]; then
            echo "Running: npm run $selected"
            npm run "$selected"
        fi
    else
        # Fallback to numbered list
        echo "Available scripts:"
        local script_array=()
        while IFS= read -r line; do
            script_array+=("$line")
            echo "$((${#script_array[@]})). $line"
        done <<< "$scripts"
        
        echo -n "Enter number: "
        read -r num
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#script_array[@]}" ]; then
            local script_name=$(echo "${script_array[$((num-1))]}" | cut -d: -f1 | xargs)
            echo "Running: npm run $script_name"
            npm run "$script_name"
        fi
    fi
}

# Interactive branch switching
select_branch() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    local branches=$(git branch -a | sed 's/^[* ]*//' | grep -v 'HEAD ->' | sort -u)
    
    if should_use_interactive "$@" && command -v fzf &> /dev/null; then
        local selected=$(echo "$branches" | fzf --header="Select branch to switch to" \
                        --preview 'git log --oneline --graph --color=always {}..HEAD' \
                        --preview-window=right:50%)
        if [ -n "$selected" ]; then
            # Handle remote branches
            if [[ "$selected" == remotes/* ]]; then
                local branch_name=$(echo "$selected" | sed 's|remotes/[^/]*/||')
                git checkout -b "$branch_name" "$selected" 2>/dev/null || git checkout "$branch_name"
            else
                git checkout "$selected"
            fi
        fi
    elif ! should_use_interactive "$@"; then
        # Non-interactive mode - just list branches
        echo "=== AVAILABLE BRANCHES ==="
        echo "$branches"
        echo ""
        echo "Note: Branch selection disabled in non-interactive mode"
        echo "Use: git checkout <branch-name>"
        return 1
    else
        # Fallback with numbered list
        echo "Available branches:"
        local branch_array=()
        while IFS= read -r branch; do
            branch_array+=("$branch")
            echo "$((${#branch_array[@]})). $branch"
        done <<< "$branches"
        
        echo -n "Enter number: "
        read -r num
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#branch_array[@]}" ]; then
            local selected="${branch_array[$((num-1))]}"
            if [[ "$selected" == remotes/* ]]; then
                local branch_name=$(echo "$selected" | sed 's|remotes/[^/]*/||')
                git checkout -b "$branch_name" "$selected" 2>/dev/null || git checkout "$branch_name"
            else
                git checkout "$selected"
            fi
        fi
    fi
}

# Search and edit workflow
search_and_edit() {
    local pattern="$1"
    if [ -z "$pattern" ]; then
        if should_use_interactive "$@" && command -v gum &> /dev/null; then
            pattern=$(gum input --placeholder "Enter search pattern")
        elif is_interactive; then
            echo -n "Enter search pattern: "
            read -r pattern
        else
            echo "❌ Pattern required in non-interactive mode"
            echo "Usage: search-and-edit <pattern>"
            return 1
        fi
    fi
    
    if [ -z "$pattern" ]; then
        echo "❌ No pattern provided"
        return 1
    fi
    
    # Search for files containing pattern
    local results=$(rg -l "$pattern" 2>/dev/null || grep -r -l "$pattern" . 2>/dev/null)
    
    if [ -z "$results" ]; then
        echo "❌ No files found containing '$pattern'"
        return 1
    fi
    
    if should_use_interactive "$@" && command -v fzf &> /dev/null && command -v bat &> /dev/null; then
        # Enhanced selection with preview highlighting matches
        local selected=$(echo "$results" | fzf \
            --preview "bat --color=always --style=numbers --highlight-line {2} {1} | rg --color=always '$pattern' || bat --color=always {1}" \
            --preview-window=right:60% \
            --header="Select file to edit (pattern: $pattern)")
        
        if [ -n "$selected" ]; then
            echo "Selected: $selected"
            # Could open in editor here
        fi
    elif ! should_use_interactive "$@"; then
        # Non-interactive mode - just list matches
        echo "=== FILES CONTAINING: $pattern ==="
        echo "$results"
        echo ""
        echo "Note: File selection disabled in non-interactive mode"
        return 1
    else
        # Basic selection
        echo "Files containing '$pattern':"
        local files_array=()
        while IFS= read -r file; do
            files_array+=("$file")
            echo "$((${#files_array[@]})). $file"
        done <<< "$results"
        
        echo -n "Enter number: "
        read -r num
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#files_array[@]}" ]; then
            echo "Selected: ${files_array[$((num-1))]}"
        fi
    fi
}

# Interactive commit with diff preview
quick_commit() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    # Check for changes
    if [ -z "$(git status --porcelain)" ]; then
        echo "✅ No changes to commit"
        return 0
    fi
    
    # Show status
    echo "📝 Current changes:"
    git status --short
    echo ""
    
    # Show diff with enhanced viewer if available
    if command -v delta &> /dev/null; then
        git diff --staged | delta
    elif command -v bat &> /dev/null; then
        git diff --staged | bat --language=diff --style=plain
    else
        git diff --staged
    fi
    
    echo ""
    
    # Get commit message
    local message
    if should_use_interactive "$@" && command -v gum &> /dev/null; then
        message=$(gum input --placeholder "Enter commit message" --width 80)
    elif is_interactive; then
        echo -n "Enter commit message: "
        read -r message
    else
        echo "❌ Cannot get commit message in non-interactive mode"
        echo "Use: git commit -m 'your message' instead"
        return 1
    fi
    
    if [ -z "$message" ]; then
        echo "❌ Commit cancelled (no message)"
        return 1
    fi
    
    # Confirm
    if should_use_interactive "$@" && command -v gum &> /dev/null; then
        gum confirm "Commit with message: $message" && git add -A && git commit -m "$message"
    elif is_interactive; then
        echo -n "Commit with message: $message? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git add -A && git commit -m "$message"
        fi
    fi
}

# Main execution
case "$1" in
    select-file)
        select_file
        ;;
    select-files)
        select_files
        ;;
    select-script)
        select_script
        ;;
    select-branch)
        select_branch
        ;;
    search-and-edit)
        search_and_edit "$2"
        ;;
    quick-commit)
        quick_commit
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac