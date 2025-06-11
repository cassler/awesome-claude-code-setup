# Performance Check

Please analyze this codebase for performance issues and optimization opportunities:

## 1. File Size Analysis
Check for files that might be too large:
```bash
# Find large files
chs large-files 500  # Files over 500 lines

# Check overall codebase size
ch ts size  # For Node projects
find . -name "*.js" -o -name "*.ts" | xargs wc -l | sort -n
```

## 2. Common Performance Anti-Patterns
Search for potential bottlenecks:
```bash
# Nested loops
chs find-code "for.*for\|while.*while"
chs find-code "\.forEach.*\.forEach\|\.map.*\.map"

# Synchronous operations
chs find-code "readFileSync\|execSync\|statSync"

# Inefficient array operations
chs find-code "\.shift()\|\.unshift()"

# Large data in memory
chs find-code "JSON\.parse.*readFile\|\.split.*readFile"
```

## 3. Bundle & Import Analysis
Check for heavy dependencies:
```bash
# Find large imports
chs search-imports "moment\|lodash"

# Check for whole package imports
chs find-code "import .* from ['\"]\w+['\"]"  # vs specific imports

# Find dynamic imports
chs find-code "import(\|require("
```

## 4. Async/Promise Issues
Look for async problems:
```bash
# Missing await
chs find-code "async.*{" | xargs grep -L "await"

# Promise chains that could be async/await
chs find-code "\.then.*\.then\|\.catch.*\.then"

# Potential race conditions
chs find-code "Promise\.all\|Promise\.race"
```

## 5. Memory Leak Risks
Identify potential memory issues:
```bash
# Event listeners without cleanup
chs find-code "addEventListener" | xargs grep -L "removeEventListener"

# Timers without cleanup
chs find-code "setInterval\|setTimeout" | xargs grep -L "clear"

# Global variables
chs find-code "^(var\|let\|const).*window\.\|global\."
```

## 6. Generate Optimization Report
Create a prioritized list of:
- **Critical**: Issues causing immediate performance problems
- **High**: Significant optimization opportunities
- **Medium**: Good practices that would help
- **Low**: Nice-to-have improvements

For each issue, provide:
- The problem and its impact
- Specific code locations
- Recommended solution
- Estimated effort

Focus on changes that will have measurable impact!