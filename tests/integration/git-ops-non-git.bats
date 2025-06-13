#!/usr/bin/env bats

load ../test-helper

setup() {
    setup_test_dir
    # Don't create a git repo - we want to test non-git behavior
}

teardown() {
    teardown_test_dir
}

@test "git-ops handles non-git directory gracefully" {
    # We're in a temp directory with no git repo
    run "$SCRIPTS_DIR/git-ops.sh" status
    assert_failure
    assert_output_contains "Not in a git repository"
    assert_output_contains "Please run this command from within a git repository"
}

@test "git-ops help works in non-git directory" {
    # Help should work even outside a git repo
    run "$SCRIPTS_DIR/git-ops.sh" help
    assert_success
    assert_output_contains "Git Operations Commands:"
}