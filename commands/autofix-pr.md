# Auto-Fix PR

Automatically identify and fix CI failures or review feedback on the current PR,
then push the fixes.

PR: ${PR_NUMBER:-$(gh pr view --json number -q .number 2>/dev/null)}

## Step 1: Get Current PR Status

```bash
# Get PR details and CI status
gh pr view --json title,body,state,statusCheckRollup,reviewDecision

# List any failing checks
gh pr checks 2>/dev/null | grep -E "fail|error" || echo "No failures found"
```

## Step 2: Collect Feedback

```bash
# Get review comments
gh pr view --json reviews -q '.reviews[] | select(.state=="CHANGES_REQUESTED") | .body'

# Get inline comments  
gh api repos/{owner}/{repo}/pulls/${PR_NUMBER}/comments \
  --jq '.[] | {path: .path, line: .line, body: .body}'
```

## Step 3: Analyze Failures

For each failing CI check:
1. Identify the root cause (lint error, test failure, type error, build failure)
2. Locate the affected file(s) using:
   ```bash
   ch nlp security $(git diff --name-only origin/main...HEAD | tr '\n' ' ')
   ch nlp complexity $(git diff --name-only origin/main...HEAD | tr '\n' ' ')
   ```
3. Fix the issue — be surgical, change only what is needed to resolve the failure

For each review comment requesting changes:
1. Read the comment and understand what is being asked
2. Find the file and line referenced
3. Apply the requested change if it is unambiguous and safe
4. Skip changes that would require architectural decisions — flag those instead

## Step 4: Verify Fixes

```bash
# Run the same checks that CI runs
# TypeScript
ch ts check && ch ts test

# Python
ch py lint && ch py test

# Go
ch go build && ch go test
```

## Step 5: Push

```bash
git add -p  # Review each change before staging
git commit -m "fix: address CI failures and review feedback"
git push
```

## Step 6: Report

Summarize what was fixed, what was skipped and why, and any remaining issues
that require human judgment.
