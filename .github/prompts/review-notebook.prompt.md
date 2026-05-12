---
description: "Audit the active pipeline notebook against all galaxy reduction pipeline conventions: cell structure, import organization, placeholder strings, variable naming, FITS I/O patterns, and Python style."
name: "Review Pipeline Notebook"
agent: "agent"
tools: [copilot_getNotebookSummary, read_file]
---

Review the currently open Jupyter notebook against the galaxy reduction pipeline conventions defined in [notebooks.instructions.md](../instructions/notebooks.instructions.md) and [python-style.instructions.md](../instructions/python-style.instructions.md).

Produce a **violation checklist** grouped by category. For each violation, state:
- The cell number where it occurs
- What the violation is
- How to fix it

If a category has no violations, mark it ✅.

## Categories to Check

### 1. Mandatory Cell Structure
Cells must appear in this top-level order:
1. Title cell (markdown): `# [GALAXY] – <Notebook Name>`
2. Environment alert cell (markdown): HTML `<div class="alert alert-block alert-info">` block naming the correct conda environment (`stenv`, `astroba`, or `dcr`)
3. `## Imports` markdown header followed immediately by a code cell with all imports
4. `## Notebook Setup` markdown header followed immediately by a directory-check code cell
5. Domain sections using `##` headers; subsections with `###`

### 2. Import Organization
Imports must be grouped with comment headers in this exact order, each group separated by a blank line:
1. `# Python Imports`
2. `# Astropy Collaboration Imports`
3. `# Other Astronomy Imports`
4. `# 3rd Party Imports`

No `import *`. All imports in the single imports code cell (not scattered through the notebook).

### 3. Placeholder Strings
Check that these placeholders are used verbatim and never replaced with hard-coded values:
- `[GALAXY]` — notebook title, comments, query names
- `[GALAXY_SHORT]` — filenames, paths
- `[GALAXY_WILDCARD]` — astroquery wildcard search patterns
- `[AUTHOR]` — FITS header comments
- `[INSTITUTION]` — FITS header comments

### 4. Variable Naming
- Local variables and function arguments: `snake_case`
- Notebook-level constants (paths, globs, DQ flags): `ALL_CAPS`
- Standard abbreviations used consistently: `fn`, `hdr`, `filt`, `crd`/`crds`, `msk`, `pix`, `img`, `hdu_list`, `out_list`

### 5. Directory-Check Setup Cell
Must use:
- `raise RuntimeError(...)` — **not** a bare `RuntimeError(...)` (which silently does nothing)
- Handles both a direct run directory and a `Notebooks/` symlink launch path

### 6. FITS I/O Pattern (if FITS files are read/written)
- Uses `with fits.open(fn) as hdu_list:` context manager
- Copies HDU list before writing: `out_list = hdu_list.copy()`
- Adds `add_history` and `add_comment` entries to output headers
- Comments include `[AUTHOR]`, `[INSTITUTION]`, and the pipeline URL

### 7. Python Style (flake8 / mypy)
- Max line length 88 characters
- Functions have full type annotations (parameters and return values)
- Uses `X | None` for nullable types (not `Optional[X]`)
- Uses f-strings, not `%`-formatting or `.format()`
- Uses `pathlib.Path` not `os.path` for filesystem operations
- Uses `%%bash` magic cells instead of `subprocess` for shell tasks
- No trailing whitespace; two blank lines between top-level definitions

### 8. Section Markdown Style
- Top-level sections: `## Section Name`
- Subsections: `### Subsection Name`
- Each markdown header cell includes brief prose describing the following code cell(s)
- Documentation goes in markdown cells, not purely in code comments

## Output Format

```
## Review: <Notebook Name>

### 1. Mandatory Cell Structure
✅ No violations.

### 2. Import Organization
- Cell 3: Missing `# Other Astronomy Imports` group header.
- Cell 3: `import matplotlib.pyplot as plt` should be under `# 3rd Party Imports`, not after astropy imports without a header.

...
```

End with a **summary count** of total violations found.
