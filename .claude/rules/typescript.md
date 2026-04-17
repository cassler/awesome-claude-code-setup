---
globs: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.mjs,**/*.cjs"
---

# TypeScript / JavaScript Rules

- Prefer `const` over `let`; avoid `var`
- Use strict equality (`===`) — never `==`
- Async functions must handle errors: use `try/catch` or `.catch()`
- Avoid `any` — prefer `unknown` and narrow with type guards
- Export types separately from values (`export type { Foo }`)
- Use `satisfies` operator for type-safe object literals
- Prefer `structuredClone` over spread for deep copies
- No `console.log` in committed code — use a proper logger
- Keep functions under 40 lines; extract helpers rather than nest logic
