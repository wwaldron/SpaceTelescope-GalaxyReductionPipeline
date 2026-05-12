---
description: "Use when writing, editing, or reviewing Python files. Enforces flake8 and mypy compliance: PEP 8 formatting, type annotations, and static type safety."
applyTo: "**/*.{py,ipynb}"
---

# Python Style – flake8 & mypy Compliance

## flake8 Rules (PEP 8)

- Max line length: **88 characters** (E501).
- Use **4 spaces** per indent level; never tabs (W191, E101).
- Do **not** align assignment operators or values with extra spaces — one space on each side only (E221, E222).
  ```python
  # Bad
  galTitle  = value
  shrtTitle = value

  # Good
  gal_title = value
  shrt_title = value
  ```
- Two blank lines between top-level definitions; one blank line between methods (E302, E303, E301).
- No trailing whitespace (W291, W293); files must end with a single newline (W292).
- Imports must be grouped in this order, separated by a blank line (E401, I-series):
  1. Standard library
  2. Third-party packages
  3. Local/project imports
- One import per line; no `from module import *` (F401, F403).
- Use spaces around binary operators and after commas; no spaces before `:`, `,`, `)` (E225, E231, E203).

## mypy Rules (Static Typing)

- All function signatures must have **type annotations** for parameters and return values.
  ```python
  # Bad
  def process(name, count):
      ...

  # Good
  def process(name: str, count: int) -> list[str]:
      ...
  ```
- Module-level variables that are not obvious from a literal assignment should be annotated.
- Do **not** use bare `# type: ignore` — if suppression is needed, include an explanatory comment: `# type: ignore[attr-defined]  # reason`.
- Use `X | None` union syntax (Python 3.10+) for nullable values; never annotate as just the base type. Do not use `Optional[X]`.
- Prefer concrete types over `Any`; use `Any` only when interfacing with untyped third-party code.
- Target **standard mypy strictness**: enable `disallow_untyped_defs`, `disallow_incomplete_defs`, `warn_return_any`, and `warn_unused_ignores`. Full `--strict` mode is not required.
- `from __future__ import annotations` is not needed — use native 3.10+ syntax directly.

## Naming Conventions

- Variables and functions: `snake_case`.
- Classes: `PascalCase`.
- Constants: `UPPER_SNAKE_CASE`.
- Avoid single-character names except for loop counters (`i`, `j`) and well-established conventions (`fn` for filename is acceptable).

## General

- Prefer f-strings over `%`-formatting or `.format()` for new code.
- Use `pathlib.Path` over `os.path` for file system operations in new code.
- Avoid mutable default arguments (e.g., `def f(x: list = [])`) — use `None` and assign inside the body.
