# ADR-001: Static Analysis Tooling Implementation

## Status
Proposed

## Context
We want to add static analysis capabilities to the Claude Helper Scripts to help developers quickly understand codebases with minimal token usage. The analysis should include:
- Code complexity metrics
- Security scanning
- Import/dependency analysis
- Documentation quality checks
- Code smell detection

We need to decide between Python (using stdlib only) and Rust for implementation.

## Decision
We will implement static analysis tools in **Python using only the standard library**, with an optional future migration path to Rust for performance-critical components.

## Rationale

### Why Python First:
1. **Zero additional dependencies** - Python 3 is already required for other helpers
2. **Rapid development** - Can implement and iterate quickly
3. **Built-in AST module** - Powerful code analysis for Python files
4. **Maintains instant install** - No compilation or binary distribution needed
5. **Cross-platform** - Works everywhere Python works
6. **Extensible** - Easy for contributors to add features

### Why Consider Rust Later:
1. **Performance** - 10-100x faster for large codebases
2. **Tree-sitter integration** - Proper parsing for all languages
3. **Single binary distribution** - Optional upgrade path
4. **Learning opportunity** - Showcase modern tooling

### Implementation Strategy:
1. Phase 1: Python implementation with core features
2. Phase 2: Identify performance bottlenecks through usage
3. Phase 3: Optional Rust port for specific hot paths
4. Phase 4: Potential hybrid approach (Python orchestration, Rust analysis)

## Consequences

### Positive:
- Immediate availability to all users
- No change to installation process
- Can leverage Python's rich standard library (ast, tokenize, dis)
- Easy to maintain and extend
- Follows project philosophy of minimal dependencies

### Negative:
- Slower than native implementation for large codebases
- Limited to regex-based parsing for non-Python languages
- May need optimization for very large projects

### Mitigation:
- Design with clean interfaces for easy porting
- Focus on token-efficient output formats
- Add progress indicators for long operations
- Document performance characteristics

## Example Usage Vision:
```bash
# Quick codebase analysis
ch analyze overview         # High-level metrics
ch analyze security        # Security scan
ch analyze complexity      # Complexity metrics
ch analyze imports         # Dependency analysis
ch analyze smells          # Code smell detection

# Specific file analysis
ch analyze file app.py --all
```

## References
- Python AST documentation: https://docs.python.org/3/library/ast.html
- Tree-sitter (future consideration): https://tree-sitter.github.io/
- Rust syn crate (future consideration): https://github.com/dtolnay/syn