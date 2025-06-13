#!/usr/bin/env bats

# Test code-relationships.sh functionality

setup() {
    load ../test-helper
    SCRIPTS_DIR="$PROJECT_ROOT/scripts"
    
    # Create test directory structure
    TEST_DIR="$BATS_TEST_TMPDIR/test-code"
    mkdir -p "$TEST_DIR/src"
    
    # Create test files
    cat > "$TEST_DIR/src/index.js" << 'EOF'
import { utils } from './utils';
import React from 'react';
const config = require('./config');

console.log('Hello');
EOF

    cat > "$TEST_DIR/src/utils.js" << 'EOF'
export const utils = {
    log: console.log
};
EOF

    cat > "$TEST_DIR/src/app.py" << 'EOF'
import os
from utils import helper
import sys

def main():
    pass
EOF
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "code-relationships help shows correct output" {
    run "$SCRIPTS_DIR/code-relationships.sh" help
    assert_success
    assert_output_contains "Code Relationships"
    assert_output_contains "imports-of"
    assert_output_contains "imported-by"
    assert_output_contains "dependency-tree"
}

@test "code-relationships show-deps command exists" {
    run "$SCRIPTS_DIR/code-relationships.sh" show-deps "$TEST_DIR"
    assert_success
    assert_output_contains "DEPENDENCY TREE"
}

@test "code-relationships imports-of shows JS imports" {
    run "$SCRIPTS_DIR/code-relationships.sh" imports-of "$TEST_DIR/src/index.js"
    assert_success
    assert_output_contains "ES6 imports:"
    assert_output_contains "import { utils }"
    assert_output_contains "import React"
    assert_output_contains "CommonJS requires:"
    assert_output_contains "require('./config')"
}

@test "code-relationships imports-of shows Python imports" {
    run "$SCRIPTS_DIR/code-relationships.sh" imports-of "$TEST_DIR/src/app.py"
    assert_success
    assert_output_contains "Python imports:"
    assert_output_contains "import os"
    assert_output_contains "from utils import helper"
}

@test "code-relationships imports-of requires file argument" {
    run "$SCRIPTS_DIR/code-relationships.sh" imports-of
    assert_failure
    assert_output_contains "Usage:"
}

@test "code-relationships imported-by requires module argument" {
    run "$SCRIPTS_DIR/code-relationships.sh" imported-by
    assert_failure
    assert_output_contains "Usage:"
}

@test "code-relationships dependency-tree shows structure" {
    run "$SCRIPTS_DIR/code-relationships.sh" dependency-tree "$TEST_DIR"
    assert_success
    assert_output_contains "DEPENDENCY TREE"
}

@test "code-relationships handles non-existent directory" {
    run "$SCRIPTS_DIR/code-relationships.sh" dependency-tree "/non/existent/path"
    assert_failure
    assert_output_contains "Directory not found"
}

@test "code-relationships circular check runs" {
    run "$SCRIPTS_DIR/code-relationships.sh" circular "$TEST_DIR"
    assert_success
    assert_output_contains "CHECKING FOR CIRCULAR DEPENDENCIES"
}