# Analyze Dependencies

Please perform a comprehensive dependency analysis of this codebase:

## 1. Dependency Overview
First, gather dependency information from your project:
- Check package files (package.json, requirements.txt, go.mod, pom.xml, etc.)
- List all direct and transitive dependencies
- Identify dependency management tools used

## 2. Security Audit
Run security checks on dependencies:
- Use your language's security audit tools
- Check for known vulnerabilities in dependencies
- Identify packages with security advisories

## 3. Usage Analysis
Find which dependencies are actually used:
- Use `chs search-imports` to find import statements
- Check for unused dependencies that can be removed
- Identify duplicate functionality across packages

## 4. Update Recommendations
Provide an organized report with:
- **Critical Security Updates** - Must update immediately
- **Major Version Updates** - Breaking changes to consider
- **Minor/Patch Updates** - Safe to update
- **Unused Dependencies** - Can be removed
- **Optimization Opportunities** - Alternative lighter packages

## 5. Implementation Plan
Create a step-by-step plan to:
1. Remove unused dependencies
2. Update critical security issues
3. Plan major version migrations
4. Document any breaking changes

Use the helper scripts throughout to verify changes and ensure nothing breaks.