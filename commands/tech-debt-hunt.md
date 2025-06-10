# Technical Debt Assessment

Please help me identify and prioritize technical debt in ${FOCUS_AREA:-the entire codebase}.

Thresholds:
- File size: ${MAX_FILE_SIZE:-500} lines
- Complexity: ${MAX_COMPLEXITY:-15}
- TODO age: ${TODO_AGE_DAYS:-30} days

## Debt Discovery

1. **Find TODOs and FIXMEs**:
   ```bash
   # Get all TODOs with context
   ch cq todos --with-context
   
   # Find old TODOs (using git blame)
   chs find-code "TODO|FIXME|HACK|XXX" 2>/dev/null | while IFS= read -r file; do
     if [ -f "$file" ]; then
       echo "=== $file ==="
       git blame "$file" 2>/dev/null | grep -E "TODO|FIXME|HACK|XXX" || true
     fi
   done
   ```

2. **Identify large files**:
   ```bash
   # Find files exceeding threshold
   ch cq large-files ${MAX_FILE_SIZE:-500}
   
   # Show largest files first
   find . -name "*.${FILE_EXT:-js|ts|py}" -exec wc -l {} + | sort -rn | head -20
   ```

3. **Find complex code**:
   ```bash
   # High cyclomatic complexity
   ch cq complexity ${MAX_COMPLEXITY:-15}
   
   # Deeply nested code
   chs find-code "^\\s{16,}" --files-with-matches
   
   # Long functions (multiple patterns)
   chs find-code "function.*\\{[^}]{500,}" 
   ```

4. **Check for outdated patterns**:
   ```bash
   # Find deprecated usage
   chs find-code "@deprecated|DEPRECATED"
   
   # Old library usage
   chs find-code "${OLD_PATTERNS:-callback\\(err\\)|var\\s+\\w+\\s*=\\s*require}"
   ```

5. **Dependency debt**:
   ```bash
   # Check for outdated packages
   ch ts deps --outdated
   
   # Find security vulnerabilities
   ch ts audit
   
   # Look for multiple versions
   ch ts deps --duplicates
   ```

6. **Code duplication**:
   ```bash
   # Find similar patterns
   for pattern in "${DUPLICATE_PATTERNS[@]:-"function.*{" "class.*{" "interface.*{"}"; do
     echo "=== Checking pattern: $pattern ==="
     chs find-code "$pattern" --count | sort -rn | head -10
   done
   ```

7. **Missing tests**:
   ```bash
   # Find untested files
   comm -23 \
     <(find . -name "*.${FILE_EXT:-js}" | grep -v test | sort) \
     <(chs find-file "*.test.*" | xargs grep -l "import\|require" | sort -u)
   ```

## Debt Analysis

Please analyze the findings and provide:

1. **Priority Matrix**:
   - 🔴 Critical: Security issues, broken functionality
   - 🟡 High: Performance issues, maintainability blockers
   - 🟢 Medium: Code quality, outdated patterns
   - ⚪ Low: Nice-to-have improvements

2. **Effort Estimation**:
   - Quick wins (< 1 hour)
   - Small tasks (1-4 hours)
   - Medium tasks (1-2 days)
   - Large refactors (> 2 days)

3. **Risk Assessment**:
   - What could break?
   - What needs careful testing?
   - What has wide impact?

4. **Recommendations**:
   - What to tackle first
   - What can be batched together
   - What needs planning

## Output Format

Please organize findings into:
```
## Technical Debt Report

### Critical Issues
1. [Issue] - [Location] - [Impact] - [Effort]

### Quick Wins
1. [Issue] - [Location] - [Benefit] - [Time]

### Long-term Improvements
1. [Area] - [Current State] - [Desired State] - [Plan]
```