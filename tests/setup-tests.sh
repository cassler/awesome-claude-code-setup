#!/bin/bash

# Setup script for running tests on claude-helpers
# This is for developers/contributors only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🧪 Setting up test environment for claude-helpers"
echo ""

# Check if BATS is installed
if ! command -v bats &> /dev/null; then
    echo "📦 Installing BATS (Bash Automated Testing System)..."
    
    # Try different installation methods
    if command -v brew &> /dev/null; then
        echo "  Using Homebrew..."
        brew install bats-core
    elif command -v npm &> /dev/null; then
        echo "  Using npm..."
        npm install -g bats
    elif command -v apt-get &> /dev/null; then
        echo "  Using apt-get..."
        sudo apt-get update && sudo apt-get install -y bats
    else
        echo "❌ No supported package manager found"
        echo "Please install BATS manually:"
        echo "  https://github.com/bats-core/bats-core#installation"
        exit 1
    fi
else
    echo "✅ BATS is already installed: $(command -v bats)"
fi

# Create test directories if they don't exist
mkdir -p "$SCRIPT_DIR"/{unit,integration,fixtures}

echo ""
echo "✅ Test environment ready!"
echo ""
echo "To run tests:"
echo "  cd $PROJECT_ROOT"
echo "  bats tests/unit/*.bats"
echo ""
echo "To run a specific test file:"
echo "  bats tests/unit/common-functions.bats"