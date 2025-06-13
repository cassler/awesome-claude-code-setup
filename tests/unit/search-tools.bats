#!/usr/bin/env bats

load ../test-helper

# Minimal tests that focus on actual bugs and edge cases
# Not testing ripgrep functionality itself

@test "search-tools handles missing arguments gracefully" {
    run "$SCRIPTS_DIR/search-tools.sh" find-code
    assert_failure
    assert_output_contains "Usage:"
    
    run "$SCRIPTS_DIR/search-tools.sh" find-file
    assert_failure
    assert_output_contains "Usage:"
}

@test "search-tools large-files handles numeric size parameter" {
    # Create a file larger than 100KB
    dd if=/dev/zero of=large.txt bs=1024 count=150 2>/dev/null
    
    # Test that numeric parameter gets 'k' suffix
    run "$SCRIPTS_DIR/search-tools.sh" large-files 100
    assert_success
    assert_output_contains "=== FILES LARGER THAN 100k ==="
    
    rm -f large.txt
}

@test "search-tools help command works" {
    run "$SCRIPTS_DIR/search-tools.sh" help
    assert_success
    assert_output_contains "Search Tools Commands:"
    assert_output_contains "Optional tool status:"
}