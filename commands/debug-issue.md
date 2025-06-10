# Debug Issue

Please help me debug this issue: $ISSUE_DESCRIPTION

Error/symptom: $ERROR_MESSAGE
Component/area (if known): ${COMPONENT:-unknown}
When it started: ${TIMEFRAME:-recently}

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

7. **Generate debugging report**:
   - Summarize findings
   - Identify root cause
   - Propose fix
   - Note any side effects

## Debug Checklist

- [ ] Error reproduced locally
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] Tests added/updated
- [ ] No new issues introduced
- [ ] Documentation updated if needed

Please analyze the codebase and help me resolve this issue systematically.