#!/bin/bash

# Script to help modernize bash syntax from [ to [[
# Usage: ./modernize-bash.sh [file]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

modernize_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error_exit "File not found: $file"
    fi
    
    echo "🔍 Checking $file for old-style test syntax..."
    
    # Count occurrences
    local count=$(grep -c '\[ ' "$file" || echo "0")
    
    if [[ "$count" -eq 0 ]]; then
        success "No old-style syntax found in $file"
        return
    fi
    
    echo "Found $count instances of old-style [ syntax"
    echo ""
    
    # Show instances with line numbers
    grep -n '\[ ' "$file" | head -10
    
    if [[ "$count" -gt 10 ]]; then
        echo "... and $(($count - 10)) more"
    fi
    
    echo ""
    echo "Common replacements:"
    echo "  [ -z \"\$var\" ]     → [[ -z \"\$var\" ]]"
    echo "  [ -n \"\$var\" ]     → [[ -n \"\$var\" ]]"
    echo "  [ -f \"\$file\" ]    → [[ -f \"\$file\" ]]"
    echo "  [ -d \"\$dir\" ]     → [[ -d \"\$dir\" ]]"
    echo "  [ \"\$a\" = \"\$b\" ]   → [[ \"\$a\" == \"\$b\" ]]"
    echo "  [ \$? -eq 0 ]      → [[ \$? -eq 0 ]]"
    echo ""
    echo "Note: Some [ commands in scripts might be intentional (e.g., for POSIX compatibility)"
}

if [[ -z "$1" ]]; then
    echo "Modernize Bash Syntax Helper"
    echo ""
    echo "Usage: $0 <file>"
    echo ""
    echo "This script helps identify old-style [ test syntax that can be"
    echo "modernized to [[ for better bash scripting."
    echo ""
    echo "To check all scripts:"
    echo "  for f in scripts/*.sh; do $0 \"\$f\"; done"
    exit 0
fi

modernize_file "$1"