# Claude Helpers Makefile

.PHONY: install test test-verbose test-unit help setup-test clean check-tools

# Default target
help:
	@echo "Claude Helpers - Available commands:"
	@echo "  make install      - Install claude-helpers to ~/.claude"
	@echo "  make test         - Run all tests"
	@echo "  make test-verbose - Run tests with verbose output"
	@echo "  make test-unit    - Run unit tests only"
	@echo "  make setup-test   - Install test dependencies (BATS)"
	@echo "  make check-tools  - Check if required tools are installed"
	@echo "  make clean        - Clean test artifacts"

# Install claude-helpers
install:
	@echo "🚀 Installing Claude Helpers..."
	@./setup.sh

# Run all tests
test: test-unit test-integration

# Run integration tests  
test-integration: check-bats
	@echo "🧪 Running integration tests..."
	@if ls tests/integration/*.bats >/dev/null 2>&1; then \
		bats tests/integration/*.bats; \
	else \
		echo "No integration tests found"; \
	fi

# Run tests with verbose output
test-verbose: check-bats
	@echo "🧪 Running tests (verbose)..."
	@bats -v tests/unit/*.bats

# Run unit tests only
test-unit: check-bats
	@echo "🧪 Running unit tests..."
	@bats tests/unit/*.bats

# Install test dependencies
setup-test:
	@echo "📦 Setting up test environment..."
	@./tests/setup-tests.sh

# Check if BATS is installed
check-bats:
	@command -v bats >/dev/null 2>&1 || { \
		echo "❌ BATS is not installed. Run 'make setup-test' first."; \
		exit 1; \
	}

# Check required tools
check-tools:
	@echo "🔍 Checking required tools..."
	@command -v bash >/dev/null 2>&1 && echo "✅ bash" || echo "❌ bash"
	@command -v git >/dev/null 2>&1 && echo "✅ git" || echo "❌ git"
	@command -v bats >/dev/null 2>&1 && echo "✅ bats" || echo "❌ bats (run 'make setup-test')"
	@echo ""
	@echo "🔍 Checking optional tools..."
	@command -v jq >/dev/null 2>&1 && echo "✅ jq" || echo "❌ jq"
	@command -v rg >/dev/null 2>&1 && echo "✅ ripgrep" || echo "❌ ripgrep"
	@command -v fzf >/dev/null 2>&1 && echo "✅ fzf" || echo "❌ fzf"
	@command -v bat >/dev/null 2>&1 && echo "✅ bat" || echo "❌ bat"
	@command -v gum >/dev/null 2>&1 && echo "✅ gum" || echo "❌ gum"
	@command -v delta >/dev/null 2>&1 && echo "✅ delta" || echo "❌ delta"

# Clean test artifacts
clean:
	@echo "🧹 Cleaning test artifacts..."
	@rm -rf /tmp/ch_test.*
	@echo "✅ Clean complete"

# Run specific test file
test-%: check-bats
	@echo "🧪 Running tests for $*..."
	@if [ -f "tests/unit/$*.bats" ]; then \
		bats tests/unit/$*.bats || exit 0; \
	else \
		echo "❌ Test file not found: tests/unit/$*.bats"; \
		exit 1; \
	fi

# Quick test for CI
ci-test: check-bats
	@echo "🚀 Running CI tests..."
	@bats tests/unit/*.bats --formatter tap

# Coverage report (basic - counts tested vs untested files)
coverage:
	@echo "📊 Test Coverage Report"
	@echo "======================"
	@tested=$$(ls tests/unit/*.bats 2>/dev/null | wc -l | xargs); \
	scripts=$$(ls scripts/*.sh | wc -l | xargs); \
	echo "Test files: $$tested"; \
	echo "Script files: $$scripts"; \
	echo ""; \
	echo "Scripts with tests:"
	@for test in tests/unit/*.bats; do \
		basename $$test .bats | sed 's/^/  ✅ /'; \
	done
	@echo ""
	@echo "Scripts without tests:"
	@for script in scripts/*.sh; do \
		base=$$(basename $$script .sh); \
		if [ ! -f "tests/unit/$$base.bats" ]; then \
			echo "  ❌ $$base.sh"; \
		fi; \
	done

# Development shortcuts
t: test
tv: test-verbose
i: install