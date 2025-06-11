# Test-Driven Development (TDD) Workflow

I'll help you implement changes using Test-Driven Development. This is an Anthropic-favorite workflow that ensures high-quality, well-tested code.

## TDD Process Overview

I'll follow these steps strictly:
1. **Write failing tests first** - Based on your requirements
2. **Verify tests fail** - Confirm we're testing the right thing
3. **Implement minimal code** - Just enough to make tests pass
4. **Refactor if needed** - Improve code while keeping tests green

## Your Requirements

Please provide:
1. **What feature/change do you want?**
   - Describe the expected behavior
   - Include any edge cases to handle

2. **Test examples (optional but helpful):**
   - Input/output pairs
   - Error scenarios
   - Performance requirements

3. **Test framework preferences:**
   - Which testing framework does your project use?
   - Any specific test patterns to follow?

## Important Notes

- I will **NOT** write any implementation code until tests are written and failing
- I will **NOT** modify tests once we start implementation (unless there's a bug in the test itself)
- I will use your project's test commands to run tests efficiently
- I'll identify the appropriate test command from your project setup

## Process I'll Follow

### Phase 1: Test Creation
```bash
# 1. Analyze existing test structure
chs find-file "*.test.*"
chs find-file "*.spec.*"

# 2. Write comprehensive tests
# 3. Run tests and confirm they fail
```

### Phase 2: Implementation
```bash
# 1. Write minimal implementation
# 2. Run tests repeatedly until all pass
# 3. Avoid overfitting to specific test cases
```

### Phase 3: Verification
```bash
# 1. Run full test suite
# 2. Check test coverage if available
# 3. Commit when all tests pass
```

Let's begin! What would you like to implement using TDD?