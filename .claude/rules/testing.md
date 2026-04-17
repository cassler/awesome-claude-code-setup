---
globs: "**/*.test.ts,**/*.test.tsx,**/*.test.js,**/*.spec.ts,**/*.spec.js,**/test_*.py,**/*_test.py,**/*_test.go"
---

# Testing Rules

- Every new function or module needs at least one test
- Tests must be deterministic — no random data, no time-dependent assertions
- Prefer `describe`/`it` naming that reads as a sentence: "UserService > login > fails with wrong password"
- Avoid testing implementation details — test observable behavior only
- One assertion concept per test; splitting helps pinpoint failures
- Mock only what you own — don't mock third-party libraries directly
- Use `beforeEach` for setup, `afterEach` for teardown; never share mutable state between tests
- Snapshot tests are fragile — prefer explicit assertions
- Aim for tests that run in under 1 second each; slow tests hide in CI
