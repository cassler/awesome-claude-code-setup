# Start New Feature

Please help me start working on a new feature: $FEATURE_NAME

## Workflow

1. **Generate focused context** for the feature:
   ```bash
   ch ctx for-task "$FEATURE_NAME"
   ```

2. **Understand current project state**:
   ```bash
   chp  # Project overview
   chg status  # Git status
   ```

3. **Create feature branch**:
   ```bash
   # Branch name: feature/${BRANCH_NAME:-$FEATURE_NAME_SLUGIFIED}
   chg checkout -b "feature/${BRANCH_NAME:-$FEATURE_NAME_SLUGIFIED}"
   ```

4. **Identify affected areas**:
   - Search for related code: `chs find-code "$SEARCH_TERMS"`
   - Find related files: `chs find-file "*$RELATED_PATTERN*"`
   - Check imports: `ch cr imports-of "$MAIN_FILE"` (if applicable)

5. **Set up initial structure**:
   - Identify where the feature should live
   - Check existing patterns in similar features
   - Create necessary directories

6. **Create implementation plan**:
   - Break down the feature into tasks
   - Identify dependencies
   - Note potential challenges
   - Create TODO list

## Questions to Consider

- What existing code will this feature interact with?
- Are there similar features I can reference?
- What tests will be needed?
- Are there any security or performance considerations?
- How will this integrate with existing workflows?

Please analyze the codebase and create a structured plan for implementing $FEATURE_NAME.