#!/usr/bin/env bats

load ../test-helper

setup() {
    setup_test_dir
    # Source common-functions.sh in test mode
    set +euo pipefail  # Temporarily disable strict mode
    source "$SCRIPTS_DIR/common-functions.sh" 2>/dev/null || true
    set -euo pipefail  # Re-enable strict mode
}

teardown() {
    teardown_test_dir
}

@test "check_command detects existing commands" {
    run check_command "ls"
    assert_success
}

@test "check_command fails for non-existent commands" {
    run check_command "this-command-does-not-exist-12345"
    assert_failure
}

@test "error_exit outputs error message and exits" {
    run bash -c "source '$SCRIPTS_DIR/common-functions.sh' && error_exit 'Test error' 99"
    assert_failure
    [[ "$status" -eq 99 ]]
    assert_output_contains "ERROR: Test error"
}

@test "warn outputs warning message" {
    run warn "Test warning"
    assert_success
    assert_output_contains "WARNING: Test warning"
}

@test "success outputs success message" {
    run success "Test success"
    assert_success
    assert_output_contains "✓ Test success"
}

@test "slugify converts strings correctly" {
    run slugify "Hello World!"
    assert_success
    [[ "$output" == "hello-world" ]]
}

@test "slugify handles special characters" {
    run slugify "Test@#$%^&*()_+=123"
    assert_success
    [[ "$output" == "test123" ]]
}

@test "is_stop_word identifies common stop words" {
    # Test with bash -c to ensure array is available
    run bash -c "source '$SCRIPTS_DIR/common-functions.sh' 2>/dev/null; is_stop_word 'the'"
    assert_success
    
    run bash -c "source '$SCRIPTS_DIR/common-functions.sh' 2>/dev/null; is_stop_word 'and'"
    assert_success
    
    run bash -c "source '$SCRIPTS_DIR/common-functions.sh' 2>/dev/null; is_stop_word 'notastopword'"
    assert_failure
}

@test "quote_path handles paths with spaces" {
    run quote_path "/path/with spaces/file.txt"
    assert_success
    [[ "$output" == "/path/with\\ spaces/file.txt" ]]
}

@test "quote_path leaves simple paths unchanged" {
    run quote_path "/simple/path/file.txt"
    assert_success
    [[ "$output" == "/simple/path/file.txt" ]]
}

@test "check_file succeeds for existing file" {
    touch "$TEST_DIR/test.txt"
    run check_file "$TEST_DIR/test.txt"
    assert_success
}

@test "check_file fails for non-existent file" {
    run check_file "$TEST_DIR/nonexistent.txt"
    assert_failure
    assert_output_contains "File not found"
}

@test "ensure_dir creates directory if it doesn't exist" {
    local new_dir="$TEST_DIR/new/nested/dir"
    run ensure_dir "$new_dir"
    assert_success
    [[ -d "$new_dir" ]]
}

@test "ensure_dir succeeds if directory already exists" {
    mkdir -p "$TEST_DIR/existing"
    run ensure_dir "$TEST_DIR/existing"
    assert_success
}

@test "detect_package_manager detects brew on macOS" {
    # This test will only pass on macOS with brew installed
    if [[ "$OSTYPE" != "darwin"* ]]; then
        skip "Not on macOS"
    fi
    
    run detect_package_manager
    assert_success
    if command -v brew &> /dev/null; then
        [[ "$output" == "brew" ]]
    else
        [[ "$output" == "none" ]]
    fi
}

@test "detect_package_manager returns known package managers" {
    run detect_package_manager
    assert_success
    # Should return one of the known package managers
    [[ "$output" =~ ^(brew|apt|dnf|yum|pacman|none|unknown)$ ]]
}