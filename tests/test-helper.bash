#!/bin/bash

# Common test helpers for BATS tests
# Source this in your test files: load test-helper

# Get the project root directory
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Create a temporary directory for test files
setup_test_dir() {
    export TEST_DIR="$(mktemp -d -t ch_test.XXXXXX)"
    cd "$TEST_DIR" || exit 1
}

# Clean up test directory
teardown_test_dir() {
    if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Source a script without executing its main code
# Usage: source_script "script-name.sh"
source_script() {
    local script="$1"
    # Many scripts have case statements that auto-execute
    # We'll source with a dummy command to avoid execution
    SOURCING_FOR_TESTS=1 source "$SCRIPTS_DIR/$script" "test-mode" 2>/dev/null || true
}

# Create a mock git repository
setup_git_repo() {
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add test.txt
    git commit -m "Initial commit" --quiet
}

# Assert that a command succeeds
assert_success() {
    if [[ "$status" -ne 0 ]]; then
        echo "Command failed with status $status"
        echo "Output: $output"
        return 1
    fi
}

# Assert that a command fails
assert_failure() {
    if [[ "$status" -eq 0 ]]; then
        echo "Command succeeded but should have failed"
        echo "Output: $output"
        return 1
    fi
}

# Assert output contains a string
assert_output_contains() {
    local expected="$1"
    if [[ ! "$output" =~ $expected ]]; then
        echo "Output does not contain expected string"
        echo "Expected: $expected"
        echo "Actual: $output"
        return 1
    fi
}

# Assert output does not contain a string
assert_output_not_contains() {
    local unexpected="$1"
    if [[ "$output" =~ $unexpected ]]; then
        echo "Output contains unexpected string"
        echo "Unexpected: $unexpected"
        echo "Actual: $output"
        return 1
    fi
}

# Skip test if command not available
skip_if_missing() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        skip "$cmd is not installed"
    fi
}