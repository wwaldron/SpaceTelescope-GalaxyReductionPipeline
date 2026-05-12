---
name: fix-notebook-violations
description: "Fix notebook convention violations after a Notebook Reviewer audit. Use when the Notebook Reviewer agent has reported violations and you want to systematically apply fixes: cell structure, import order, placeholder strings, variable naming, directory-check pattern, FITS I/O, or Python style. Edits notebooks in place."
argument-hint: "Path to the notebook to fix, or paste the Notebook Reviewer report"
---

# Fix Notebook Violations

## When to Use

After running the **Notebook Reviewer** agent and receiving a violation report, use this skill to apply the fixes systematically, category by category.

## Procedure

### Step 1 — Get the Violation Report

If you don't already have a report, run the reviewer first:
```
@notebook-reviewer review <path/to/Notebook.ipynb>
```

### Step 2 — Load the Notebook

Read the notebook file to understand its current state before making changes.

### Step 3 — Fix by Category (in order)

Work through each flagged category below. Apply all fixes in that category before moving to the next.

---

#### Category 1 — Mandatory Cell Structure

Required top-level order:
1. Title cell (markdown): `# [GALAXY] – <Notebook Name>`
2. Environment alert cell (markdown): blue `alert-block alert-info` div naming the conda env
3. `## Imports` markdown header
4. Single imports code cell
5. `## Notebook Setup` markdown header
6. Directory-check code cell
7. Domain sections (`##` headers)

**Fix patterns:**
- Missing title cell → insert at position 0 with `# [GALAXY] – <Notebook Name>`
- Missing env alert → insert after title with the template below
- Imports not grouped into a single cell → merge all import code into one cell
- Setup header/code cell out of order → move cells to correct positions

**Environment alert template:**
```html
<div class="alert alert-block alert-info">
<b>Environment:</b> Run this notebook in the <code>ENV_NAME</code> conda environment.
</div>
```

---

#### Category 2 — Import Organization

Required group order (each group separated by a blank line):
```python
# Python Imports

# Astropy Collaboration Imports

# Other Astronomy Imports

# 3rd Party Imports
```

**Fix patterns:**
- Wrong order → reorder groups within the imports cell
- Missing comment headers → add `# Python Imports`, etc.
- `import *` → replace with explicit imports
- Imports scattered across cells → consolidate into the single designated cell

---

#### Category 3 — Placeholder Strings

Placeholders that must appear verbatim (never hard-coded):
- `[GALAXY]`, `[GALAXY_SHORT]`, `[GALAXY_WILDCARD]`, `[AUTHOR]`, `[INSTITUTION]`

**Fix patterns:**
- Hard-coded galaxy name (e.g., `"NGC 3568"`) where a placeholder is expected → replace with `[GALAXY]` or `[GALAXY_SHORT]`
- Missing placeholder in title → change to `# [GALAXY] – <Name>`

> **Note:** If the notebook has already been `configure`d and the placeholders are intentionally replaced with real values, this is correct — do NOT re-introduce placeholders in a configured instance.

---

#### Category 4 — Variable Naming

| Pattern | Convention |
|---------|-----------|
| Local variables, function args | `snake_case` |
| Notebook-level constants (paths, globs, flags) | `ALL_CAPS` |

Standard abbreviations to use: `fn`, `hdr`, `filt`, `crd`/`crds`, `msk`, `pix`, `img`, `hdu_list`, `out_list`

**Fix patterns:**
- Constant defined with `snake_case` → rename to `ALL_CAPS`
- Non-standard abbreviation → replace with the canonical form

---

#### Category 5 — Directory-Check Setup Cell

Required pattern:
```python
if Path.cwd().name != "ExpectedDir":
    if Path.cwd().name == "Notebooks":
        os.chdir("../relative/path/to/ExpectedDir")
    else:
        raise RuntimeError("This notebook must be run from the ExpectedDir directory.")
print(f'Current Directory: {Path.cwd()}')
```

**Fix patterns:**
- `RuntimeError(...)` without `raise` → add `raise`
- No `Notebooks` symlink branch → add the inner `if/else`
- Uses `os.getcwd()` instead of `Path.cwd()` → replace

---

#### Category 6 — FITS I/O Pattern

Required patterns (when the notebook reads/writes FITS files):
```python
with fits.open(fn) as hdu_list:
    out_list = hdu_list.copy()
    # modify out_list
    out_list[0].header.add_history("...")
    out_list[0].header.add_comment("[AUTHOR], [INSTITUTION]")
    out_list.writeto(out_fn, overwrite=True)
```

**Fix patterns:**
- `fits.open()` without context manager → wrap in `with ... as hdu_list:`
- Modifying `hdu_list` directly → add `.copy()` assignment first
- Missing `add_history` / `add_comment` → add with `[AUTHOR]` / `[INSTITUTION]` placeholders

---

#### Category 7 — Python Style

Key rules (88-char limit, type annotations, f-strings, `pathlib`):

**Fix patterns:**
- Lines > 88 chars → wrap with parentheses or intermediate variables
- Functions missing type annotations → add parameter types and return type
- `Optional[X]` → replace with `X | None`
- `%`-formatting or `.format()` → convert to f-strings
- `os.path.join(...)` → replace with `Path(...) / "subpath"`
- `subprocess` calls → convert to `%%bash` magic cell where appropriate
- Single blank line between top-level definitions → change to two blank lines

---

#### Category 8 — Section Markdown Style

**Fix patterns:**
- `###` used for top-level sections → change to `##`
- Code cell without a preceding markdown cell → add a prose description markdown cell
- Section documented only in code comments (not markdown cells) → move prose to a markdown cell

---

### Step 4 — Verify

After applying all fixes, run the **Notebook Reviewer** again to confirm zero remaining violations:
```
@notebook-reviewer review <path/to/Notebook.ipynb>
```

## Tips

- Use `edit_notebook_file` to modify cell contents directly; use cell indices (0-based).
- When reordering cells, plan the final order first, then make moves.
- If fixing multiple notebooks, process one at a time and verify each before moving on.
