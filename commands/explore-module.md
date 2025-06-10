# Module Explorer

Please help me deeply understand this module: $MODULE_PATH

Exploration depth: ${DEPTH:-3}
Focus areas: ${FOCUS:-all aspects}

## Module Analysis

1. **Get module overview**:
   ```bash
   # Show module structure
   ch ctx focus "$MODULE_PATH" ${DEPTH:-3}
   
   # List all files
   find "$MODULE_PATH" -type f -name "*.${EXT:-js|ts|py}" | head -20
   ```

2. **Understand module boundaries**:
   ```bash
   # Find entry points
   chs find-file "index.*" "$MODULE_PATH"
   
   # Look for main exports
   chs find-code "export|module.exports" "$MODULE_PATH"
   ```

3. **Trace dependencies**:
   ```bash
   # What does this module import?
   ch cr imports-of "$MODULE_PATH/index.${EXT:-js}"
   
   # Generate dependency tree
   ch cr dependency-tree "$MODULE_PATH"
   
   # Check for circular dependencies
   ch cr circular "$MODULE_PATH"
   ```

4. **Find who uses this module**:
   ```bash
   # Who imports this module?
   ch cr imported-by "$MODULE_PATH"
   
   # Search for direct references
   MODULE_NAME=$(basename "$MODULE_PATH")
   chs find-code "from.*$MODULE_NAME|import.*$MODULE_NAME"
   ```

5. **Locate tests**:
   ```bash
   # Find test files
   chs find-file "*.test.*|*.spec.*" "$MODULE_PATH"
   
   # Find tests in other locations
   chs find-code "$MODULE_NAME" --include "*.test.*"
   ```

6. **Check documentation**:
   ```bash
   # Find docs
   chs find-file "*.md" "$MODULE_PATH"
   
   # Look for inline documentation
   chs find-code "^\\s*\\*|^\\s*/\\*\\*|@param|@returns" "$MODULE_PATH"
   ```

7. **Analyze code quality**:
   ```bash
   # Check complexity
   ch cq large-files 200 "$MODULE_PATH"
   
   # Find TODOs
   ch cq todos "$MODULE_PATH"
   ```

## Key Questions

1. **Architecture**:
   - What is the module's primary responsibility?
   - How does it fit into the overall architecture?
   - Are there clear boundaries and interfaces?

2. **Dependencies**:
   - What are the external dependencies?
   - Are there any concerning coupling issues?
   - Could this module be easily extracted/reused?

3. **Testing**:
   - What's the test coverage like?
   - Are edge cases handled?
   - Are the tests maintainable?

4. **Performance**:
   - Are there any obvious bottlenecks?
   - Is async/await used appropriately?
   - Are there any resource leaks?

Please provide a comprehensive analysis of $MODULE_PATH including its purpose, structure, dependencies, and any recommendations for improvements.