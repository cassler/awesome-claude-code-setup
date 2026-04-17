---
globs: "**/*.py"
---

# Python Rules

- Target Python 3.10+ — use `match`, `X | Y` union types, and `tomllib`
- Use type hints everywhere; run `mypy` or `pyright` before committing
- Prefer `pathlib.Path` over `os.path` for file operations
- Use `dataclasses` or `pydantic` for structured data — avoid raw dicts
- Context managers (`with`) for all file I/O and resource handling
- Use `ruff` for linting and formatting (replaces flake8/black/isort)
- Raise specific exceptions — never bare `except:` or `except Exception:`
- Keep functions under 40 lines; prefer composition over inheritance
- Use `__all__` to declare public API in modules
