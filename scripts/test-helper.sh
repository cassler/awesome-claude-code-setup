#!/bin/bash

# Test Helper - Smart test operations for any project
# Usage: ./test-helper.sh [command] [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# Common test file patterns
TEST_PATTERNS=(
    "*.test.*"
    "*.spec.*"
    "*_test.*"
    "test_*.*"
    "*Test.*"
    "*Spec.*"
)

# Test directories
TEST_DIRS=(
    "test"
    "tests"
    "spec"
    "specs"
    "__tests__"
    "test_*"
)

# Function to find test files for a given source file
find_tests_for_file() {
    local file="$1"
    local basename=$(basename "$file" | sed 's/\.[^.]*$//')
    local dirname=$(dirname "$file")
    local temp_results=$(mktemp -t ch_test_results.XXXXXX || mktemp)
    
    # Look for test files with similar names
    for pattern in "${TEST_PATTERNS[@]}"; do
        local test_pattern=$(echo "$pattern" | sed "s/\*/$basename/g")
        
        # Check in same directory
        if [[ -f "$dirname/$test_pattern" ]]; then
            echo "$dirname/$test_pattern" >> "$temp_results"
        fi
        
        # Check in test directories
        for test_dir in "${TEST_DIRS[@]}"; do
            if [[ -d "$test_dir" ]]; then
                find "$test_dir" -name "$test_pattern" -type f 2>/dev/null >> "$temp_results"
            fi
            
            # Check for exact name match in test directories (e.g., common-functions.bats)
            if [[ -f "$test_dir/$basename.bats" ]]; then
                echo "$test_dir/$basename.bats" >> "$temp_results"
            fi
            
            # Check in subdirectories (e.g., tests/unit/common-functions.bats)
            if [[ -d "$test_dir" ]]; then
                find "$test_dir" -name "$basename.bats" -type f 2>/dev/null >> "$temp_results"
            fi
            
            # Check in parallel test structure
            local parallel_test="$test_dir/$file"
            if [[ -f "$parallel_test" ]]; then
                echo "$parallel_test" >> "$temp_results"
            fi
        done
    done
    
    # Remove duplicates and return
    if [[ -s "$temp_results" ]]; then
        sort -u "$temp_results" | grep -v '^$'
    fi
    rm -f "$temp_results"
}

# Function to find source files without tests
find_untested_files() {
    local dir="${1:-.}"
    local untested=()
    
    # Find all source files (excluding test files and common non-source files)
    find "$dir" -type f \( \
        -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \
        -o -name "*.py" -o -name "*.go" -o -name "*.rb" -o -name "*.java" \
        -o -name "*.cpp" -o -name "*.c" -o -name "*.sh" \
    \) ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
       ! -path "*/build/*" ! -path "*/dist/*" | while read -r file; do
        
        # Skip if it's a test file
        local is_test=false
        for pattern in "${TEST_PATTERNS[@]}"; do
            if [[ "$(basename "$file")" == $pattern ]]; then
                is_test=true
                break
            fi
        done
        
        if [[ "$is_test" == "false" ]]; then
            # Check if tests exist for this file
            local tests=$(find_tests_for_file "$file")
            if [[ -z "$tests" ]]; then
                echo "$file"
            fi
        fi
    done
}

# Function to detect test runner
detect_test_runner() {
    # Shell scripts with BATS (check first for shell projects)
    if command -v bats &> /dev/null; then
        # Check if we have .bats files in tests directory
        if [[ -d "tests" ]] && find tests -name "*.bats" -type f 2>/dev/null | head -1 | grep -q .; then
            echo "bats"
            return
        fi
        # Check test directory separately
        if [[ -d "test" ]] && find test -name "*.bats" -type f 2>/dev/null | head -1 | grep -q .; then
            echo "bats"
            return
        fi
    fi
    
    # Node.js test runners
    if [[ -f "package.json" ]]; then
        if grep -q '"test"' package.json; then
            local test_cmd=$(jq -r '.scripts.test // ""' package.json 2>/dev/null || \
                            grep '"test"' package.json | head -1 | cut -d'"' -f4)
            if [[ -n "$test_cmd" ]]; then
                echo "$test_cmd"
                return
            fi
        fi
    fi
    
    # Python test runners
    if command -v pytest &> /dev/null && [[ -f "pytest.ini" || -f "setup.cfg" || -f "pyproject.toml" ]]; then
        echo "pytest"
        return
    elif command -v python &> /dev/null && [[ -d "tests" || -d "test" ]]; then
        echo "python -m unittest"
        return
    fi
    
    # Go test
    if [[ -f "go.mod" ]] && command -v go &> /dev/null; then
        echo "go test"
        return
    fi
    
    # Ruby/RSpec
    if [[ -f "Gemfile" ]] && command -v rspec &> /dev/null; then
        echo "rspec"
        return
    elif [[ -f "Rakefile" ]] && command -v rake &> /dev/null; then
        echo "rake test"
        return
    fi
    
    echo ""
}

# Function to run tests for changed files
run_tests_for_changes() {
    local base_ref="${1:-HEAD~1}"
    local test_runner=$(detect_test_runner)
    
    if [[ -z "$test_runner" ]]; then
        warn "No test runner detected"
        return 1
    fi
    
    echo "🧪 Test runner: $test_runner"
    echo ""
    
    # Get changed files
    local changed_files=$(git diff --name-only "$base_ref" 2>/dev/null || git diff --name-only --cached)
    
    if [[ -z "$changed_files" ]]; then
        echo "No changes detected"
        return 0
    fi
    
    local test_files=""
    
    # Find tests for each changed file
    echo "📝 Changed files and their tests:"
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            echo "  $file"
            local tests=$(find_tests_for_file "$file")
            if [[ -n "$tests" ]]; then
                while IFS= read -r test; do
                    echo "    → $test"
                    test_files+="$test "
                done <<< "$tests"
            else
                echo "    → No tests found"
            fi
        fi
    done <<< "$changed_files"
    
    if [[ -z "$test_files" ]]; then
        echo ""
        echo "⚠️  No tests found for changed files"
        return 0
    fi
    
    echo ""
    echo "🏃 Running tests..."
    echo ""
    
    # Run tests based on the test runner
    case "$test_runner" in
        *jest*|*mocha*|*vitest*)
            # Node.js test runners
            eval "$test_runner $test_files"
            ;;
        pytest)
            pytest $test_files
            ;;
        "python -m unittest")
            python -m unittest $test_files
            ;;
        "go test")
            go test $test_files
            ;;
        rspec)
            rspec $test_files
            ;;
        bats)
            bats $test_files
            ;;
        *)
            # Generic - just run the test command with files
            eval "$test_runner $test_files"
            ;;
    esac
}

# Function to create test skeleton
create_test_skeleton() {
    local source_file="$1"
    
    if [[ ! -f "$source_file" ]]; then
        error_exit "Source file not found: $source_file"
    fi
    
    local ext="${source_file##*.}"
    local basename=$(basename "$source_file" | sed 's/\.[^.]*$//')
    local test_file=""
    
    # Determine test file location and name
    case "$ext" in
        js|jsx|ts|tsx)
            test_file="${source_file%.*}.test.$ext"
            ;;
        py)
            test_file="test_$basename.py"
            if [[ -d "tests" ]]; then
                test_file="tests/$test_file"
            fi
            ;;
        go)
            test_file="${source_file%.go}_test.go"
            ;;
        rb)
            test_file="${basename}_spec.rb"
            if [[ -d "spec" ]]; then
                test_file="spec/$test_file"
            fi
            ;;
        sh)
            test_file="${basename}.bats"
            if [[ -d "tests" ]]; then
                test_file="tests/$test_file"
            fi
            ;;
        *)
            error_exit "Unsupported file type: $ext"
            ;;
    esac
    
    if [[ -f "$test_file" ]]; then
        warn "Test file already exists: $test_file"
        return 1
    fi
    
    echo "📝 Creating test skeleton: $test_file"
    
    # Create test skeleton based on file type
    case "$ext" in
        js|jsx)
            cat > "$test_file" << EOF
const { describe, it, expect } = require('@jest/globals');
const { /* functions to test */ } = require('./$basename');

describe('$basename', () => {
    describe('functionName', () => {
        it('should do something', () => {
            // Arrange
            const input = 'test';
            
            // Act
            const result = functionName(input);
            
            // Assert
            expect(result).toBe('expected');
        });
    });
});
EOF
            ;;
            
        ts|tsx)
            cat > "$test_file" << EOF
import { describe, it, expect } from '@jest/globals';
import { /* functions to test */ } from './$basename';

describe('$basename', () => {
    describe('functionName', () => {
        it('should do something', () => {
            // Arrange
            const input = 'test';
            
            // Act
            const result = functionName(input);
            
            // Assert
            expect(result).toBe('expected');
        });
    });
});
EOF
            ;;
            
        py)
            cat > "$test_file" << EOF
import unittest
from ${basename} import *  # Import functions to test

class Test${basename^}(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures"""
        pass
    
    def tearDown(self):
        """Clean up after tests"""
        pass
    
    def test_function_name(self):
        """Test function_name behavior"""
        # Arrange
        input_data = "test"
        expected = "expected"
        
        # Act
        result = function_name(input_data)
        
        # Assert
        self.assertEqual(result, expected)

if __name__ == '__main__':
    unittest.main()
EOF
            ;;
            
        go)
            local package=$(head -1 "$source_file" | awk '{print $2}')
            cat > "$test_file" << EOF
package $package

import (
    "testing"
)

func TestFunctionName(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {
            name:     "basic test",
            input:    "test",
            expected: "expected",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := FunctionName(tt.input)
            if result != tt.expected {
                t.Errorf("FunctionName(%s) = %s; want %s", tt.input, result, tt.expected)
            }
        })
    }
}
EOF
            ;;
            
        sh)
            cat > "$test_file" << EOF
#!/usr/bin/env bats

# Test for $basename

setup() {
    # Source the script
    source "\${BATS_TEST_DIRNAME}/../$source_file"
}

@test "function_name does something" {
    run function_name "test"
    [ "\$status" -eq 0 ]
    [ "\$output" = "expected" ]
}

@test "function_name handles errors" {
    run function_name ""
    [ "\$status" -eq 1 ]
}
EOF
            chmod +x "$test_file"
            ;;
    esac
    
    success "Test skeleton created: $test_file"
}

# Main command handling
case "$1" in
    "find-for"|"ff")
        # Find tests for a specific file
        FILE="${2:-}"
        if [[ -z "$FILE" ]]; then
            error_exit "Usage: $0 find-for <file>"
        fi
        
        echo "🔍 Finding tests for: $FILE"
        tests=$(find_tests_for_file "$FILE")
        if [[ -n "$tests" ]]; then
            echo "$tests"
        else
            echo "No tests found"
        fi
        ;;
        
    "coverage-gaps"|"gaps")
        # Find files without tests
        DIR="${2:-.}"
        echo "🔍 Finding untested files in: $DIR"
        echo ""
        untested=$(find_untested_files "$DIR")
        if [[ -n "$untested" ]]; then
            echo "$untested" | while read -r file; do
                echo "❌ $file"
            done
            echo ""
            echo "Total: $(echo "$untested" | wc -l | xargs) files without tests"
        else
            success "All files have tests!"
        fi
        ;;
        
    "related-to-changes"|"changes")
        # Run tests for changed files
        BASE="${2:-HEAD~1}"
        run_tests_for_changes "$BASE"
        ;;
        
    "create-skeleton"|"create")
        # Create test skeleton for a file
        FILE="${2:-}"
        if [[ -z "$FILE" ]]; then
            error_exit "Usage: $0 create-skeleton <file>"
        fi
        create_test_skeleton "$FILE"
        ;;
        
    "detect-runner"|"runner")
        # Detect test runner
        runner=$(detect_test_runner)
        if [[ -n "$runner" ]]; then
            echo "Test runner: $runner"
        else
            echo "No test runner detected"
        fi
        ;;
        
    "help"|"-h"|"--help"|"")
        echo "Test Helper - Smart test operations"
        echo ""
        echo "Usage: $0 [command] [args]"
        echo ""
        echo "Commands:"
        echo "  find-for <file>         Find tests for a specific file"
        echo "  coverage-gaps [dir]     Find files without tests"
        echo "  related-to-changes      Run tests for changed files"
        echo "  create-skeleton <file>  Generate test template"
        echo "  detect-runner           Show detected test runner"
        echo ""
        echo "Aliases:"
        echo "  ff    = find-for"
        echo "  gaps  = coverage-gaps"
        echo "  changes = related-to-changes"
        echo "  create = create-skeleton"
        echo "  runner = detect-runner"
        echo ""
        echo "Examples:"
        echo "  $0 find-for src/user.js"
        echo "  $0 coverage-gaps src/"
        echo "  $0 related-to-changes HEAD~3"
        echo "  $0 create-skeleton src/utils.js"
        ;;
        
    *)
        error_exit "Unknown command: $1\nRun '$0 help' for usage"
        ;;
esac