#!/usr/bin/env bats

load ../test-helper

setup() {
    setup_test_dir
    # Create a mock git repo for testing
    cd "$TEST_DIR"
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "test content" > test.txt
    git add test.txt
    git commit -m "Initial commit" --quiet
    
    # Source the script (but don't exit on errors from it)
    set +e
    source "$SCRIPTS_DIR/git-ops.sh" 2>/dev/null
    set -e
}

teardown() {
    teardown_test_dir
}

@test "git-ops status shows current branch and recent commits" {
    run "$SCRIPTS_DIR/git-ops.sh" status
    assert_success
    assert_output_contains "=== GIT STATUS ==="
    assert_output_contains "Branch: main"
    assert_output_contains "=== RECENT COMMITS ==="
}

@test "git-ops info shows repository information" {
    # Add a remote for testing
    git remote add origin https://github.com/test/repo.git
    
    run "$SCRIPTS_DIR/git-ops.sh" info
    assert_success
    assert_output_contains "=== GIT INFO ==="
    assert_output_contains "Current branch: main"
    assert_output_contains "Remote: https://github.com/test/repo.git"
    assert_output_contains "Last commit:"
    assert_output_contains "Initial commit"
}

@test "git-ops branches lists local and remote branches" {
    # Create another branch
    git checkout -b test-branch --quiet
    git checkout main --quiet
    
    run "$SCRIPTS_DIR/git-ops.sh" branches
    assert_success
    assert_output_contains "=== LOCAL BRANCHES ==="
    assert_output_contains "main"
    assert_output_contains "test-branch"
}

@test "git-ops diff shows changes" {
    # Make a change
    echo "modified content" > test.txt
    
    run "$SCRIPTS_DIR/git-ops.sh" diff
    assert_success
    # Delta uses color codes, so just check for the filename
    assert_output_contains "test.txt"
}

@test "git-ops diff-stat without argument works correctly (BUG FIXED)" {
    # This test verified we fixed the unbound variable bug
    echo "modified content" > test.txt
    
    run "$SCRIPTS_DIR/git-ops.sh" diff-stat
    assert_success
    assert_output_contains "test.txt"
    assert_output_contains "1 file changed"
}

@test "git-ops stash-quick creates a quick stash" {
    # Make a change to stash
    echo "stashed content" > stash.txt
    git add stash.txt
    
    run "$SCRIPTS_DIR/git-ops.sh" stash-quick
    assert_success
    assert_output_contains "Stashed with message: WIP"
    
    # Verify the file is gone
    [[ ! -f stash.txt ]]
}

@test "git-ops quick-commit stages and commits all changes" {
    # Make changes
    echo "new content" > new.txt
    echo "modified" >> test.txt
    
    run "$SCRIPTS_DIR/git-ops.sh" quick-commit "Test commit"
    assert_success
    # Git commit output includes the message
    assert_output_contains "Test commit"
    assert_output_contains "2 files changed"
    
    # Verify changes were committed
    run git status --porcelain
    [[ -z "$output" ]]
}


@test "git-ops shows help for unknown commands" {
    run "$SCRIPTS_DIR/git-ops.sh" unknown-command
    assert_success
    assert_output_contains "Git Operations Commands:"
    assert_output_contains "status|st"
    assert_output_contains "diff|d"
}

@test "git-ops recent shows recent commits" {
    # Create more commits
    echo "second" > second.txt
    git add second.txt
    git commit -m "Second commit" --quiet
    
    echo "third" > third.txt
    git add third.txt
    git commit -m "Third commit" --quiet
    
    run "$SCRIPTS_DIR/git-ops.sh" recent 2
    assert_success
    assert_output_contains "Third commit"
    assert_output_contains "Second commit"
    # Should not show the first commit when limited to 2
    assert_output_not_contains "Initial commit"
}