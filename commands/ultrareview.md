# Ultra Review

Run a comprehensive multi-agent code review on the current branch's changes.

Branch: ${BRANCH:-$(git branch --show-current)}
Base: ${BASE:-main}

## Review Scope

```bash
# Show what will be reviewed
git diff --stat ${BASE:-main}...HEAD
git log --oneline ${BASE:-main}..HEAD
```

## Deep Analysis

Perform a thorough review covering all of the following areas. For each area,
analyze every changed file in the diff above.

### 1. Correctness & Logic
- Are there off-by-one errors, null dereferences, or incorrect conditionals?
- Do edge cases produce correct behavior?
- Are async operations handled properly (race conditions, unhandled rejections)?

### 2. Security
```bash
ch cq secrets-scan
ch nlp security $(git diff --name-only ${BASE:-main}...HEAD | tr '\n' ' ')
```
- Injection vulnerabilities (SQL, command, XSS)
- Authentication / authorization gaps
- Sensitive data in logs or error messages

### 3. Performance
```bash
ch nlp complexity $(git diff --name-only ${BASE:-main}...HEAD | tr '\n' ' ')
```
- N+1 queries or unnecessary loops
- Missing indexes or expensive operations in hot paths
- Memory leaks or unbounded data structures

### 4. Test Coverage
```bash
# Find changed files with no corresponding test
git diff --name-only ${BASE:-main}...HEAD | grep -v test | while read f; do
  base=$(basename "$f" | sed 's/\.[^.]*$//')
  chs find-file "*${base}*test*" || echo "No tests found for: $f"
done
```

### 5. Code Quality
```bash
ch nlp smells $(git diff --name-only ${BASE:-main}...HEAD | tr '\n' ' ')
ch cq large-files 300
```
- Functions over 50 lines
- Deep nesting (>3 levels)
- Duplicate logic that should be extracted

### 6. Documentation
- Are public APIs documented?
- Are non-obvious decisions explained with comments?
- Is the CHANGELOG or README updated if needed?

## Review Report

After completing all analyses above, produce a structured report:

**Summary:** One paragraph describing the overall quality and risk level of these changes.

**Must Fix (blocking):** Issues that must be resolved before merge.

**Should Fix (non-blocking):** Improvements worth addressing but not merge-blocking.

**Nice to Have:** Minor style or optimization suggestions.

**Approved?** Yes / No / Yes with conditions — and what those conditions are.
