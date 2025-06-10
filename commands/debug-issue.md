# Debug Issue

Please help me debug this issue: $ISSUE_DESCRIPTION

Error/symptom: $ERROR_MESSAGE
Component/area (if known): ${COMPONENT:-unknown}
When it started: ${TIMEFRAME:-recently}
GitHub issue: ${ISSUE_NUMBER:-none}
PR causing issue: ${PR_NUMBER:-unknown}

## Systematic Debugging Workflow

1. **Search for error patterns**:
   ```bash
   # Search for the exact error
   chs find-code "$ERROR_MESSAGE"
   
   # Search for related terms
   chs find-code "${RELATED_TERMS:-error exception fail}"
   ```

2. **Check recent changes**:
   ```bash
   # Get recent commit context
   ch ctx prepare-migration "debug $ISSUE_DESCRIPTION"
   
   # Show recent modifications
   chg log --oneline -20
   ```

3. **Trace the problem area**:
   ```bash
   # Focus on suspected area
   ch ctx focus "${COMPONENT:-src}" 3
   
   # Find related files
   chs find-file "*${COMPONENT}*"
   ```

4. **Analyze code flow**:
   - Trace imports: `ch cr imports-of "$SUSPECTED_FILE"`
   - Find dependencies: `ch cr imported-by "$SUSPECTED_FILE"`
   - Check for circular dependencies: `ch cr circular`

5. **Check test coverage**:
   ```bash
   # Find related tests
   chs find-file "*.test.*" | xargs grep -l "$COMPONENT"
   
   # Look for test failures
   ch ts test | grep -i "fail"
   ```

6. **Look for code quality issues**:
   ```bash
   # Check for TODOs and debug code
   ch cq todos --with-context | grep -C3 "$COMPONENT"
   ch cq console-logs
   ```

7. **Check related GitHub items**:
   ```bash
   # If issue number provided, get details
   if [ -n "$ISSUE_NUMBER" ]; then
     gh issue view "$ISSUE_NUMBER"
   fi
   
   # If PR number provided, check changes
   if [ -n "$PR_NUMBER" ]; then
     gh pr diff "$PR_NUMBER" | grep -C5 "$COMPONENT"
   fi
   
   # Search for related issues
   gh issue list --search "$ERROR_MESSAGE" --limit 5
   ```

8. **Generate debugging report**:
   - Summarize findings
   - Identify root cause
   - Propose fix
   - Note any side effects
   - Link to issue/PR if applicable

## Fix Workflow

Once root cause is identified:

```bash
# Slugify issue description using common function
source ~/.claude/scripts/common-functions.sh
ISSUE_SLUGIFIED=$(slugify "$ISSUE_DESCRIPTION" 50)

# Create fix branch from issue
git checkout -b "fix/${ISSUE_NUMBER:-bug}-${ISSUE_SLUGIFIED}"

# After implementing fix
git add -A
git commit -m "fix: $ISSUE_DESCRIPTION (#$ISSUE_NUMBER)"
git push -u origin HEAD

# Create PR linked to issue
gh pr create \
  --title "fix: $ISSUE_DESCRIPTION" \
  --body "## Description\n\nFixes $ERROR_MESSAGE\n\nCloses #$ISSUE_NUMBER\n\n## Root Cause\n\n[Explanation]\n\n## Solution\n\n[What was changed]\n\n## Testing\n\n- [ ] Error no longer occurs\n- [ ] No regressions\n- [ ] Tests added"
```

## Debug Checklist

- [ ] Error reproduced locally
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] Tests added/updated
- [ ] No new issues introduced
- [ ] Documentation updated if needed
- [ ] Issue/PR updated with findings

Please analyze the codebase and help me resolve this issue systematically.