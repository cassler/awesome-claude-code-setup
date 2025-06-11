# Pre-Deployment Checklist

Please help me ensure we're ready to deploy to ${ENVIRONMENT:-production}.

Deployment type: ${DEPLOY_TYPE:-standard}
Target branch: ${TARGET_BRANCH:-main}
Skip checks: ${SKIP_CHECKS:-none}

## Critical Checks

1. **Remove debug code**:
   ```bash
   # Check for console logs
   ch cq console-logs
   
   # Find debug flags
   chs find-code "DEBUG|debug.*=.*true|__DEV__"
   
   # Check for development URLs
   chs find-code "localhost|127\\.0\\.0\\.1|192\\.168\\."
   ```

2. **Environment configuration**:
   ```bash
   # Find environment variables
   chs find-code "process\\.env\\.|ENV\\[|getenv\\("
   
   # Check for missing defaults
   chs find-code "process\\.env\\.\\w+" 2>/dev/null | while IFS= read -r match; do
     echo "$match" | grep -q "||" || echo "Missing default: $match"
   done
   
   # Verify .env.example is updated
   diff .env .env.example 2>/dev/null || echo "Check .env files"
   ```

3. **Security scan**:
   ```bash
   # Final secrets check
   ch cq secrets-scan
   
   # Check file permissions
   find . -type f -name "*.${SCRIPT_EXT:-sh|py}" -exec ls -la {} \; | grep -v "r--"
   
   # Verify no sensitive files
   chs find-file "*.pem|*.key|*.env|*.secret"
   ```

4. **Build verification**:
   ```bash
   # Clean build
   # Remove any build artifacts (adjust paths for your project)
   # Examples: dist/, build/, target/, out/, _site/
   
   # Run your project's build command
   # Examples: npm run build, make build, gradle build, etc.
   
   # Verify no source maps or debug files in production
   # Check your build output directory for .map files or debug symbols
   ```

5. **Test suite**:
   ```bash
   # Run your project's test suite
   # Examples: npm test, pytest, go test, mvn test, etc.
   
   # Run E2E/integration tests if available
   
   # Check test coverage if configured
   ```

6. **Database checks**:
   ```bash
   # Find migration files
   chs find-file "*migration*|*migrate*" --sort-date | tail -5
   
   # Check for migration conflicts
   git diff "${TARGET_BRANCH:-main}" --name-only | grep -i migration
   
   # Look for schema changes
   chs find-code "CREATE TABLE|ALTER TABLE|DROP TABLE"
   ```

7. **Performance checks**:
   ```bash
   # Check build size (if applicable)
   # Look for unexpectedly large files in your build output
   
   # Find large assets in your build directory
   # Adjust the path to match your build output location
   
   # Check for unoptimized images
   find . -name "*.png" -o -name "*.jpg" -size "+${IMG_SIZE:-500k}"
   ```

8. **Documentation**:
   ```bash
   # Check if README is updated
   git diff ${TARGET_BRANCH:-main} README.md
   
   # Verify API docs if applicable
   chs find-file "*api*.md|*API*.md"
   
   # Check changelog
   git log --oneline ${TARGET_BRANCH:-main}..HEAD > PENDING_CHANGES.txt
   ```

## Deployment Readiness

### Version checks:
- [ ] Version bumped appropriately
- [ ] Changelog updated
- [ ] Tags created if needed

### Infrastructure:
- [ ] Database migrations ready
- [ ] Environment variables set
- [ ] CDN cache cleared if needed
- [ ] Monitoring alerts configured

### Rollback plan:
- [ ] Previous version tagged
- [ ] Rollback script tested
- [ ] Database rollback plan
- [ ] Feature flags ready

## Final Verification

```bash
# Generate deployment summary
echo "=== Deployment Summary ==="
echo "Environment: ${ENVIRONMENT:-production}"
echo "Branch: $(git branch --show-current)"
echo "Commit: $(git rev-parse --short HEAD)"
echo "Changes: $(git rev-list --count ${TARGET_BRANCH:-main}..HEAD) commits"
echo ""
echo "Files changed:"
git diff --stat ${TARGET_BRANCH:-main}
```

## Post-Deploy Checklist

- [ ] Smoke tests pass
- [ ] Monitoring shows normal metrics
- [ ] No error spike in logs
- [ ] Key features verified
- [ ] Performance metrics normal

Please verify all checks pass and provide a deployment recommendation.