# Start New Feature

Please help me start working on a new feature: $FEATURE_NAME

Related issue: ${ISSUE_NUMBER:-create new}
Feature type: ${FEATURE_TYPE:-enhancement}

## Workflow

1. **Create or link GitHub issue** (if not provided):
   ```bash
   # If no issue number provided, create one
   if [ -z "$ISSUE_NUMBER" ]; then
     gh issue create \
       --title "$FEATURE_NAME" \
       --body "Feature implementation for: $FEATURE_NAME\n\n## Description\n$FEATURE_DESCRIPTION\n\n## Acceptance Criteria\n- [ ] TBD\n\n## Technical Notes\n- TBD" \
       --label "${FEATURE_TYPE:-enhancement}"
   fi
   
   # List recent issues to verify
   gh issue list --limit 5
   ```

2. **Generate focused context** for the feature:
   ```bash
   ch ctx for-task "$FEATURE_NAME"
   ```

3. **Understand current project state**:
   ```bash
   chp  # Project overview
   chg status  # Git status
   ```

4. **Create feature branch** (linked to issue):
   ```bash
   # Slugify feature name using common function
   source ~/.claude/scripts/common-functions.sh
   FEATURE_NAME_SLUGIFIED=$(slugify "$FEATURE_NAME")
   
   # Branch name includes issue number for automatic linking
   BRANCH_NAME="feature/${ISSUE_NUMBER}-${FEATURE_NAME_SLUGIFIED}"
   git checkout -b "$BRANCH_NAME"
   
   # Push to remote to establish tracking
   git push -u origin "$BRANCH_NAME"
   ```

5. **Identify affected areas**:
   - Search for related code: `chs find-code "$SEARCH_TERMS"`
   - Find related files: `chs find-file "*$RELATED_PATTERN*"`
   - Check imports: `ch cr imports-of "$MAIN_FILE"` (if applicable)

6. **Set up initial structure**:
   - Identify where the feature should live
   - Check existing patterns in similar features
   - Create necessary directories

7. **Create initial commit and draft PR**:
   ```bash
   # Create initial commit
   echo "# $FEATURE_NAME\n\nImplementation for #$ISSUE_NUMBER\n\n## TODO\n- [ ] Implementation\n- [ ] Tests\n- [ ] Documentation" > FEATURE_PLAN.md
   git add FEATURE_PLAN.md
   git commit -m "feat: Initial setup for $FEATURE_NAME (#$ISSUE_NUMBER)"
   git push
   
   # Create draft PR linked to issue
   gh pr create --draft \
     --title "feat: $FEATURE_NAME" \
     --body "## Description\n\nImplements $FEATURE_NAME\n\nCloses #$ISSUE_NUMBER\n\n## Changes\n- TBD\n\n## Testing\n- [ ] Unit tests\n- [ ] Integration tests\n- [ ] Manual testing\n\n## Checklist\n- [ ] Implementation complete\n- [ ] Tests added\n- [ ] Documentation updated" \
     --base main
   ```

8. **Create implementation plan**:
   - Break down the feature into tasks
   - Identify dependencies
   - Note potential challenges
   - Update the draft PR with task list

## GitHub Integration

This workflow will:
- ✅ Create a GitHub issue for tracking (if not provided)
- ✅ Use issue number in branch name for automatic linking
- ✅ Create a draft PR early for visibility
- ✅ Link PR to issue with "Closes #X"
- ✅ Set up proper tracking from the start

## Questions to Consider

- What existing code will this feature interact with?
- Are there similar features I can reference?
- What tests will be needed?
- Are there any security or performance considerations?
- How will this integrate with existing workflows?

Please analyze the codebase and create a structured plan for implementing $FEATURE_NAME.