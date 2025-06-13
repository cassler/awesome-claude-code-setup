# Testing Guide

## Quick Start

```bash
# Install test framework
make setup-test

# Run all tests
make test

# Run specific test
make test-git-ops

# Check test coverage
make coverage
```

## Available Commands

| Command | Description |
|---------|-------------|
| `make test` | Run all tests |
| `make test-verbose` | Run tests with detailed output |
| `make test-<script>` | Run tests for specific script (e.g., `make test-git-ops`) |
| `make coverage` | Show which scripts have tests |
| `make check-tools` | Check if required tools are installed |
| `make setup-test` | Install BATS testing framework |

## Writing Tests

Tests are written in BATS (Bash Automated Testing System) format. Each script should have a corresponding test file in `tests/unit/`.

Example test:
```bash
@test "my-script handles missing arguments" {
    run ./scripts/my-script.sh
    assert_failure
    assert_output_contains "Usage:"
}
```

## Test Helpers

Available assertions in `tests/test-helper.bash`:
- `assert_success` - Command exits with 0
- `assert_failure` - Command exits with non-zero
- `assert_output_contains "text"` - Output contains text
- `assert_output_not_contains "text"` - Output doesn't contain text

## Current Test Coverage

Run `make coverage` to see which scripts have tests.

As of now:
- ✅ common-functions.sh (16 tests)
- ✅ git-ops.sh (10 tests)
- ✅ search-tools.sh (12 tests)
- ❌ 19 scripts still need tests

## Running Tests in CI

For GitHub Actions or other CI systems:
```bash
make ci-test
```

This outputs in TAP format for better CI integration.