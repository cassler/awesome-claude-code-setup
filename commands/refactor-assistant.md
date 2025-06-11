# Refactor Assistant

Please help me refactor code systematically using a structured approach:

## 1. Define the Refactoring
First, clearly identify:
- **What**: The specific code/pattern to refactor
- **Why**: The reason for refactoring (maintainability, performance, etc.)
- **Scope**: Which parts of the codebase are affected

## 2. Discovery Phase
Use search tools to find all occurrences:
```bash
# Find direct usage
chs find-code "ExactPatternName"

# Find imports/requires
chs search-imports "module-name"

# Find similar patterns
chs search-function "functionName"
chs search-class "ClassName"

# Find test files
chs find-file "*.test.*" | xargs grep -l "PatternName"
```

## 3. Impact Analysis
- List all files that need changes
- Identify potential breaking changes
- Check for external dependencies

## 4. Migration Plan
Create a step-by-step plan:
1. Update core implementation
2. Update imports/exports
3. Update all usages
4. Update tests
5. Update documentation

## 5. Execute Changes
For each file:
- Make the change
- Verify with your project's linter/type checker
- Run related tests
- Commit changes with meaningful messages

## 6. Verification
After all changes:
- Run full test suite
- Check for type/lint errors
- Verify no broken imports
- Review all changes

## 7. Documentation
Update any affected:
- README files
- API documentation
- Code comments
- Migration guides for breaking changes

Track progress and ensure nothing is missed!