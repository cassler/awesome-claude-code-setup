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
   chs find-code "process\\.env\\.\\w+" | while read match; do
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
   rm -rf ${BUILD_DIR:-dist build} node_modules/.cache
   ch ts build
   
   # Check build output
   ls -la ${BUILD_DIR:-dist}
   
   # Verify no source maps in production
   find ${BUILD_DIR:-dist} -name "*.map" | grep . && echo "WARNING: Source maps found!"
   ```

5. **Test suite**:
   ```bash
   # Run all tests
   ch ts test
   
   # Run E2E tests if available
   ch ts test:e2e || echo "No E2E tests found"
   
   # Check test coverage
   ch ts test:coverage || echo "No coverage reports"
   ```

6. **Database checks**:
   ```bash
   # Find migration files
   chs find-file "*migration*|*migrate*" --sort-date | tail -5
   
   # Check for migration conflicts
   git diff ${TARGET_BRANCH:-main} --name-only | grep -i migration
   
   # Look for schema changes
   chs find-code "CREATE TABLE|ALTER TABLE|DROP TABLE"
   ```

7. **Performance checks**:
   ```bash
   # Check bundle size
   ch ts size
   
   # Find large assets
   find ${BUILD_DIR:-dist} -type f -size +${MAX_SIZE:-1M} -exec ls -lh {} \;
   
   # Check for unoptimized images
   find . -name "*.png" -o -name "*.jpg" -size +${IMG_SIZE:-500k}
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