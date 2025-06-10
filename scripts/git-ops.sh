#!/bin/bash

# Git Operations Script with optional tool enhancements
# Usage: ./git-ops.sh [command] [args]

# Source common functions
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/common-functions.sh"

# Check for optional tools
GUM_AVAILABLE=$(check_command gum && echo "true" || echo "false")
DELTA_AVAILABLE=$(check_command delta && echo "true" || echo "false")

case "$1" in
    "status"|"st")
        echo "=== GIT STATUS ==="
        echo "Branch: $(git branch --show-current)"
        echo ""
        git status -sb
        echo ""
        echo "=== RECENT COMMITS ==="
        git log --oneline -5
        ;;
    
    "info")
        echo "=== GIT INFO ==="
        echo "Current branch: $(git branch --show-current)"
        echo "Remote: $(git remote -v | head -1 | awk '{print $2}')"
        echo "Last commit: $(git log -1 --pretty=format:'%h - %s (%cr by %an)')"
        echo ""
        echo "=== BRANCH TRACKING ==="
        git branch -vv | grep "^*"
        echo ""
        echo "=== FILE CHANGES ==="
        echo "Modified: $(git status --porcelain | grep -c "^ M")"
        echo "Untracked: $(git status --porcelain | grep -c "^??")"
        echo "Staged: $(git status --porcelain | grep -c "^[AM]")"
        ;;
    
    "branches"|"br")
        echo "=== LOCAL BRANCHES ==="
        git branch -v
        echo ""
        echo "=== REMOTE BRANCHES ==="
        git branch -r | head -10
        ;;
    
    "switch"|"sw")
        # Interactive branch switching with fzf
        if command -v fzf &> /dev/null; then
            echo "🌿 Interactive Branch Switch"
            local branch=$(git branch -a | sed 's/^[* ]*//' | grep -v 'HEAD ->' | sort -u | fzf --header="Select branch to switch to")
            if [ -n "$branch" ]; then
                # Handle remote branches
                if [[ "$branch" == remotes/* ]]; then
                    local branch_name=$(echo "$branch" | sed 's|remotes/[^/]*/||')
                    git checkout -b "$branch_name" "$branch" 2>/dev/null || git checkout "$branch_name"
                else
                    git checkout "$branch"
                fi
            fi
        else
            echo "❌ fzf is required for interactive branch switching"
            echo "Install with: brew install fzf"
            echo ""
            echo "Use: git checkout <branch-name>"
        fi
        ;;
    
    "quick-commit"|"qc")
        if [ -z "$2" ]; then
            if [[ "$GUM_AVAILABLE" == "true" ]]; then
                # Use gum for interactive commit message
                echo "Enter commit message:"
                MESSAGE=$(gum input --placeholder "feat: Add new feature" --width 60)
                if [ -z "$MESSAGE" ]; then
                    echo "Commit cancelled."
                    exit 1
                fi
            else
                echo "Usage: $0 quick-commit <message>"
                echo "Tip: Install 'gum' for interactive commit messages"
                check_optional_tool "gum" "false" > /dev/null 2>&1
                exit 1
            fi
        else
            shift
            MESSAGE="$*"
        fi
        git add -A
        git commit -m "$MESSAGE"
        ;;
    
    "amend")
        git add -A
        git commit --amend --no-edit
        ;;
    
    "unstage")
        git reset HEAD
        ;;
    
    "discard")
        if [ -z "$2" ]; then
            echo "Usage: $0 discard <file>"
            echo "   or: $0 discard --all"
            exit 1
        fi
        if [ "$2" = "--all" ]; then
            git checkout -- .
        else
            git checkout -- "$2"
        fi
        ;;
    
    "stash-quick"|"sq")
        MESSAGE="${2:-WIP}"
        git stash save "$MESSAGE"
        echo "Stashed with message: $MESSAGE"
        ;;
    
    "pr-ready")
        echo "=== PR READINESS CHECK ==="
        BRANCH=$(git branch --show-current)
        echo "Current branch: $BRANCH"
        
        # Check if branch is up to date with remote
        git fetch origin >/dev/null 2>&1
        BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
        if [ "$BEHIND" -gt 0 ]; then
            echo "⚠️  Branch is $BEHIND commits behind origin/main"
        else
            echo "✓ Branch is up to date with origin/main"
        fi
        
        # Check for uncommitted changes
        if [ -n "$(git status --porcelain)" ]; then
            echo "⚠️  Uncommitted changes present"
        else
            echo "✓ No uncommitted changes"
        fi
        
        # Show diff summary
        echo ""
        echo "=== CHANGES SUMMARY ==="
        git diff origin/main...HEAD --stat
        ;;
    
    "pr-create")
        if ! command -v gh &> /dev/null; then
            echo "GitHub CLI (gh) not installed. Install it first."
            exit 1
        fi
        
        TITLE="$2"
        if [ -z "$TITLE" ]; then
            echo "Usage: $0 pr-create <title>"
            exit 1
        fi
        
        shift 2
        BODY="$*"
        
        # Push current branch
        BRANCH=$(git branch --show-current)
        git push -u origin "$BRANCH"
        
        # Create PR
        if [ -n "$BODY" ]; then
            gh pr create --title "$TITLE" --body "$BODY"
        else
            gh pr create --title "$TITLE" --body ""
        fi
        ;;
    
    "recent")
        N="${2:-10}"
        git log --pretty=format:"%h - %s (%cr) <%an>" -n "$N"
        ;;
    
    "diff"|"d")
        shift
        if command -v delta &> /dev/null; then
            # Enhanced diff with delta
            git diff "$@" | delta
        else
            echo "❌ delta is required for enhanced diffs"
            echo "Install with: brew install git-delta"
            echo ""
            echo "Falling back to standard git diff..."
            git diff "$@"
        fi
        ;;
    
    "diff-staged"|"ds")
        shift
        if command -v delta &> /dev/null; then
            git diff --staged "$@" | delta
        else
            git diff --staged "$@"
        fi
        ;;
    
    "diff-stat")
        if [ -z "$2" ]; then
            git diff --stat
        else
            git diff "$2" --stat
        fi
        ;;
    
    "contributors")
        echo "=== TOP CONTRIBUTORS ==="
        git shortlog -sn | head -10
        ;;
    
    "file-history")
        if [ -z "$2" ]; then
            echo "Usage: $0 file-history <file>"
            exit 1
        fi
        git log --oneline --follow -- "$2" | head -20
        ;;
    
    "undo-last")
        echo "Undoing last commit (keeping changes)..."
        git reset --soft HEAD~1
        echo "Last commit undone. Changes are staged."
        ;;
    
    "remote-sync")
        echo "=== SYNCING WITH REMOTE ==="
        git fetch --all
        echo ""
        echo "=== REMOTE STATUS ==="
        git remote -v
        echo ""
        git branch -r | head -5
        ;;
    
    *)
        echo "Git Operations Commands:"
        echo "  $0 status|st           - Quick status overview"
        echo "  $0 info                - Detailed git info"
        echo "  $0 branches|br         - List branches"
        echo "  $0 quick-commit|qc     - Stage all & commit"
        echo "  $0 amend               - Amend last commit"
        echo "  $0 unstage             - Unstage all files"
        echo "  $0 discard <file>      - Discard changes"
        echo "  $0 stash-quick|sq      - Quick stash"
        echo "  $0 pr-ready            - Check PR readiness"
        echo "  $0 pr-create <title>   - Create PR with gh"
        echo "  $0 recent [n]          - Show recent commits"
        echo "  $0 diff|d [ref]        - Show diff (enhanced with delta)"
        echo "  $0 diff-stat [ref]     - Show diff statistics"
        echo "  $0 contributors        - Show top contributors"
        echo "  $0 file-history <file> - Show file history"
        echo "  $0 undo-last           - Undo last commit"
        echo "  $0 remote-sync         - Sync with remote"
        echo ""
        echo "Optional tool status:"
        [[ "$GUM_AVAILABLE" == "true" ]] && echo "  ✓ gum (interactive prompts)"
        [[ "$DELTA_AVAILABLE" == "true" ]] && echo "  ✓ delta (enhanced diffs)"
        ;;
esac