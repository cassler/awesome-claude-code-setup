#!/bin/bash

# Common functions for Claude Helper Scripts
# Source this file in other scripts: source "$(dirname "${BASH_SOURCE[0]}")/common-functions.sh"

# Colors for output
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# Error handling
set -euo pipefail

# Function to display errors and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit "${2:-1}"
}

# Function to display warnings
warn() {
    echo -e "${YELLOW}WARNING: $1${NC}" >&2
}

# Function to display success messages
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        return 1
    fi
    return 0
}

# Function to check required dependencies
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! check_command "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing optional dependencies: ${missing[*]}"
        warn "Some features may not work. Install with your package manager."
    fi
}

# Function to slugify a string (for branch names, etc.)
slugify() {
    local input="$1"
    local max_length="${2:-50}"
    
    # Convert to lowercase, replace spaces with hyphens, remove special chars
    echo "$input" | \
        tr '[:upper:]' '[:lower:]' | \
        tr ' ' '-' | \
        tr -cd '[:alnum:]-' | \
        cut -c1-"$max_length"
}

# Function to validate input (alphanumeric + spaces + basic punctuation)
validate_input() {
    local input="$1"
    local pattern="${2:-^[a-zA-Z0-9 \-_.,!?]+$}"
    
    if [[ ! "$input" =~ $pattern ]]; then
        return 1
    fi
    return 0
}

# Function to safely handle file paths with spaces
quote_path() {
    printf '%q' "$1"
}

# Function to run command with error checking
run_command() {
    local cmd="$1"
    local error_msg="${2:-Command failed: $cmd}"
    
    if ! eval "$cmd"; then
        error_exit "$error_msg"
    fi
}

# Function to run command with optional failure
run_optional() {
    local cmd="$1"
    local warn_msg="${2:-Optional command failed: $cmd}"
    
    if ! eval "$cmd" 2>/dev/null; then
        warn "$warn_msg"
        return 1
    fi
    return 0
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error_exit "Not in a git repository"
    fi
}

# Function to get current git branch
get_current_branch() {
    git branch --show-current 2>/dev/null || echo "main"
}

# Function to check if file exists and is readable
check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        error_exit "File not found: $file"
    fi
    if [ ! -r "$file" ]; then
        error_exit "File not readable: $file"
    fi
}

# Function to create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || error_exit "Failed to create directory: $dir"
    fi
}

# Export functions so they're available to sourcing scripts
export -f error_exit warn success check_command check_dependencies
export -f slugify validate_input quote_path run_command run_optional
export -f check_git_repo get_current_branch check_file ensure_dir