# Pre-Review Checklist

Please help me ensure my code is ready for review.

PR/Branch: ${PR_BRANCH:-current branch}
Focus areas: ${FOCUS_AREAS:-all changes}

## Quality Checks

1. **Find and fix debug code**:
   ```bash
   # Find TODOs that need addressing
   ch cq todos --with-context
   
   # Remove debug logs
   ch cq console-logs
   
   # Check for commented code
   chs find-code "^\\s*//.*\\b(console|debug|test)" 
   ```

2. **Check code quality metrics**:
   ```bash
   # Find overly large files
   ch cq large-files ${MAX_LINES:-500}
   
   # Check complexity
   ch cq complexity ${MAX_COMPLEXITY:-10}
   
   # Look for duplicated code patterns
   chs find-code "$PATTERN" --count
   ```

3. **Security scan**:
   ```bash
   # Scan for hardcoded secrets
   ch cq secrets-scan
   
   # Check for sensitive data in logs
   chs find-code "password|token|secret|key" --exclude .env
   ```

4. **Verify test coverage**:
   ```bash
   # Find untested files
   chg diff --name-only | while read f; do
     echo "Checking tests for: $f"
     chs find-file "*.test.*" | xargs grep -l "$(basename $f .js)"
   done
   
   # Run tests
   ch ts test
   ```

5. **Check dependencies**:
   ```bash
   # Audit for vulnerabilities
   ch ts audit
   
   # Check for unused dependencies
   ch ts deps --check-unused
   ```

6. **Documentation check**:
   - Are new functions documented?
   - Is the README updated if needed?
   - Are breaking changes noted?

## PR Preparation

1. **Generate context for reviewers**:
   ```bash
   # Create summary
   ch ctx summarize > PR_CONTEXT.md
   
   # Show what changed
   chg diff --stat
   ```

2. **Check commit history**:
   ```bash
   # Review commits
   chg log --oneline origin/main..HEAD
   
   # Consider squashing if needed
   ```

## Final Checklist

- [ ] All debug code removed
- [ ] No hardcoded secrets
- [ ] Tests pass locally
- [ ] New code has tests
- [ ] Documentation updated
- [ ] No generated files committed
- [ ] Commit messages are clear
- [ ] PR description is complete

Please review my changes and confirm they meet quality standards.