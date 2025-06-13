# Claude Helpers Test Suite

This directory contains the test suite for the Claude Helpers shell scripts.

## Setup

Run the setup script to install BATS (Bash Automated Testing System):

```bash
./tests/setup-tests.sh
```

## Running Tests

Run all tests:
```bash
bats tests/unit/*.bats
```

Run a specific test file:
```bash
bats tests/unit/common-functions.bats
```

Run tests with verbose output:
```bash
bats -v tests/unit/*.bats
```

## Test Structure

```
tests/
├── setup-tests.sh      # Install BATS and set up test environment
├── test-helper.bash    # Common test utilities and assertions
├── unit/               # Unit tests for individual scripts
│   └── common-functions.bats
├── integration/        # Integration tests (future)
└── fixtures/           # Test data and mock files
```

## Writing Tests

Tests are written using BATS syntax. Example test:

```bash
#!/usr/bin/env bats

load ../test-helper

setup() {
    setup_test_dir
    source "$SCRIPTS_DIR/common-functions.sh"
}

teardown() {
    teardown_test_dir
}

@test "function_name does something" {
    run function_name "argument"
    assert_success
    [[ "$output" == "expected output" ]]
}
```

## Test Helpers

The `test-helper.bash` file provides:
- `setup_test_dir` / `teardown_test_dir` - Temporary test directories
- `assert_success` / `assert_failure` - Check command exit status
- `assert_output_contains` - Check output contains string
- `skip_if_missing` - Skip test if command not available
- `setup_git_repo` - Create a mock git repository

## Best Practices

1. Each script should have a corresponding test file
2. Test both success and failure cases
3. Use descriptive test names
4. Clean up any created files in teardown
5. Skip tests that require optional dependencies

## Coverage Goals

- [ ] common-functions.sh ✅
- [ ] project-info.sh
- [ ] git-ops.sh
- [ ] search-tools.sh
- [ ] interactive-helper.sh
- [ ] test-helper.sh (meta!)
- [ ] Additional scripts...