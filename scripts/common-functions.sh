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

# Function to check if we're in an interactive TTY environment
is_interactive() {
    # Check if both stdin and stdout are connected to a terminal
    [ -t 0 ] && [ -t 1 ]
}

# Function to check if we should use interactive mode
# Takes into account TTY status and optional --non-interactive flag
should_use_interactive() {
    # Check for --non-interactive flag
    for arg in "$@"; do
        if [ "$arg" = "--non-interactive" ] || [ "$arg" = "-n" ]; then
            return 1
        fi
    done
    
    # Check if we're in a TTY
    if is_interactive; then
        return 0
    else
        return 1
    fi
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

# Common stop words for filtering
export STOP_WORDS=(the and or in on at to for of with a an is are was were be been being have has had do does did will would could should may might must can)

# Function to check if a word is a stop word
is_stop_word() {
    local word="$1"
    local stop_word
    for stop_word in "${STOP_WORDS[@]}"; do
        if [[ "$word" == "$stop_word" ]]; then
            return 0
        fi
    done
    return 1
}

# Optional tools configuration
export OPTIONAL_TOOLS=(fzf jq bat gum delta rg fd-find httpie tldr)

# Function to detect system package manager
detect_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if check_command brew; then
            echo "brew"
        else
            echo "none"
        fi
    elif [[ -f /etc/debian_version ]]; then
        echo "apt"
    elif [[ -f /etc/redhat-release ]]; then
        if check_command dnf; then
            echo "dnf"
        else
            echo "yum"
        fi
    elif [[ -f /etc/arch-release ]]; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Function to suggest tool installation
suggest_install_tool() {
    local tool="$1"
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        brew)
            echo "Install with: brew install $tool"
            ;;
        apt)
            echo "Install with: sudo apt install $tool"
            ;;
        dnf|yum)
            echo "Install with: sudo $pkg_manager install $tool"
            ;;
        pacman)
            echo "Install with: sudo pacman -S $tool"
            ;;
        none)
            echo "Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            ;;
        *)
            echo "Please install $tool using your system's package manager"
            ;;
    esac
}

# Function to check and optionally install a tool
check_optional_tool() {
    local tool="$1"
    local prompt="${2:-true}"
    
    if check_command "$tool"; then
        return 0
    fi
    
    if [[ "$prompt" == "true" ]] && [[ -t 0 ]]; then
        echo -e "${YELLOW}Optional tool '$tool' not found.${NC}"
        suggest_install_tool "$tool"
        read -p "Would you like to install it now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_optional_tool "$tool"
            return $?
        fi
    fi
    
    return 1
}

# Function to install an optional tool
install_optional_tool() {
    local tool="$1"
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        brew)
            brew install "$tool"
            ;;
        apt)
            sudo apt update && sudo apt install -y "$tool"
            ;;
        dnf|yum)
            sudo "$pkg_manager" install -y "$tool"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$tool"
            ;;
        *)
            warn "Cannot automatically install $tool on this system"
            return 1
            ;;
    esac
}

# Function to use optional tool with fallback
use_optional_tool() {
    local tool="$1"
    local fallback_cmd="$2"
    shift 2
    local args=("$@")
    
    if check_command "$tool"; then
        "$tool" "${args[@]}"
    else
        eval "$fallback_cmd"
    fi
}

# Export functions so they're available to sourcing scripts
export -f error_exit warn success check_command check_dependencies
export -f slugify validate_input quote_path run_command run_optional
export -f check_git_repo get_current_branch check_file ensure_dir is_stop_word
export -f detect_package_manager suggest_install_tool check_optional_tool
export -f install_optional_tool use_optional_tool