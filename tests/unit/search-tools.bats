#!/usr/bin/env bats

load ../test-helper

setup() {
    setup_test_dir
    
    # Create test files with content
    mkdir -p src/components
    echo "function testFunction() { return true; }" > src/test.js
    echo "export const helper = () => console.log('test');" > src/helper.js
    echo "import { helper } from './helper';" > src/components/App.js
    echo "# Test README" > README.md
    echo "TODO: Fix this bug" > src/components/Todo.jsx
    echo "FIXME: Memory leak here" > src/components/Bug.jsx
    
    # Create a large file
    for i in {1..1000}; do echo "Line $i" >> large.txt; done
}

teardown() {
    teardown_test_dir
}

@test "search-tools requires ripgrep" {
    # Test that script checks for ripgrep
    grep -q "ripgrep.*is required" "$SCRIPTS_DIR/search-tools.sh"
}

@test "search-tools find-code searches for pattern in files (non-interactive)" {
    # Force non-interactive mode
    run "$SCRIPTS_DIR/search-tools.sh" find-code "testFunction" --non-interactive
    assert_success
    assert_output_contains "=== SEARCHING FOR: testFunction ==="
    assert_output_contains "src/test.js"
    assert_output_contains "function testFunction"
}

@test "search-tools find-code shows usage when pattern missing (BUG FIXED)" {
    # Verify the unbound variable bug is fixed
    run "$SCRIPTS_DIR/search-tools.sh" find-code
    assert_failure
    assert_output_contains "Usage:"
    assert_output_contains "find-code <pattern>"
}

@test "search-tools find-file finds files by name pattern" {
    run "$SCRIPTS_DIR/search-tools.sh" find-file "*.js" --non-interactive
    assert_success
    assert_output_contains "=== FILES MATCHING: *.js ==="
    assert_output_contains "src/test.js"
    assert_output_contains "src/helper.js"
}

@test "search-tools search-imports finds import statements" {
    run "$SCRIPTS_DIR/search-tools.sh" search-imports "helper"
    assert_success
    assert_output_contains "=== IMPORTS OF: helper ==="
    assert_output_contains "src/components/App.js"
    assert_output_contains "import { helper }"
}

@test "search-tools todo-comments finds TODO and FIXME comments" {
    run "$SCRIPTS_DIR/search-tools.sh" todo-comments
    assert_success
    assert_output_contains "=== TODO/FIXME SEARCH ==="
    assert_output_contains "src/components/Todo.jsx"
    assert_output_contains "TODO: Fix this bug"
    assert_output_contains "src/components/Bug.jsx"
    assert_output_contains "FIXME: Memory leak"
}

@test "search-tools search-function finds function definitions" {
    run "$SCRIPTS_DIR/search-tools.sh" search-function "testFunction"
    assert_success
    assert_output_contains "=== FUNCTION DEFINITIONS: testFunction ==="
    assert_output_contains "src/test.js"
    assert_output_contains "function testFunction"
}

@test "search-tools find-type lists files with given extension" {
    run "$SCRIPTS_DIR/search-tools.sh" find-type "jsx"
    assert_success
    assert_output_contains "=== FILES WITH EXTENSION: jsx ==="
    assert_output_contains "src/components/Todo.jsx"
    assert_output_contains "src/components/Bug.jsx"
    assert_output_not_contains "test.js"
}

@test "search-tools large-files finds files over threshold" {
    run "$SCRIPTS_DIR/search-tools.sh" large-files 100
    assert_success
    assert_output_contains "=== LARGE FILES"
    assert_output_contains "large.txt"
}

@test "search-tools recent-files finds recently modified files" {
    # Touch a file to make it recent
    touch -t "$(date +%Y%m%d%H%M.%S)" src/helper.js
    
    run "$SCRIPTS_DIR/search-tools.sh" recent-files 1
    assert_success
    assert_output_contains "=== RECENTLY MODIFIED"
    # Should find files modified in last day
}

@test "search-tools shows help correctly (FZF_AVAILABLE BUG FIXED)" {
    # Verify the FZF_AVAILABLE unbound variable bug is fixed
    run "$SCRIPTS_DIR/search-tools.sh" unknown-command
    assert_success
    assert_output_contains "Search Tools Commands:"
    assert_output_contains "Optional tool status:"
}

@test "search-tools count-lines counts lines by file type" {
    run "$SCRIPTS_DIR/search-tools.sh" count-lines
    assert_success
    assert_output_contains "=== LINE COUNT BY FILE TYPE ==="
    # Should show counts for different file types
}