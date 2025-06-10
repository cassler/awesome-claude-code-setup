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
   if ! git diff --name-only origin/main...HEAD 2>/dev/null | while IFS= read -r f; do
     echo "Checking tests for: $f"
     chs find-file "*.test.*" | xargs grep -l "$(basename "$f" .js)" 2>/dev/null || echo "  No tests found for $f"
   done; then
     echo "Note: Could not compare with origin/main"
   fi
   
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
   git diff --stat origin/main...HEAD
   ```

2. **Check commit history**:
   ```bash
   # Review commits
   git log --oneline origin/main..HEAD
   
   # Consider squashing if needed
   ```

3. **Update PR if exists**:
   ```bash
   # Check if PR exists
   PR_NUMBER=$(gh pr list --head "$(git branch --show-current)" --json number -q ".[0].number")
   
   if [ -n "$PR_NUMBER" ]; then
     # Update PR description with context
     gh pr edit "$PR_NUMBER" --body "$(gh pr view "$PR_NUMBER" --json body -q .body)\n\n## Review Context\n\n$(cat PR_CONTEXT.md)"
     
     # Mark as ready if it's a draft
     gh pr ready "$PR_NUMBER" 2>/dev/null || echo "PR already ready for review"
     
     # Add review request if needed
     gh pr edit "$PR_NUMBER" --add-reviewer "${REVIEWER:-@me}"
   else
     echo "No PR found. Create one with: gh pr create"
   fi
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