---
description: "Create a new pipeline notebook for the galaxy reduction pipeline with the correct mandatory cell structure, import organization, directory-check setup, and placeholder strings."
name: "New Pipeline Notebook"
argument-hint: "Notebook name, purpose, and optional pipeline position (e.g., 'StarCatalogBuilder – builds star catalog from GAIA data, runs in astroba, position 4')"
agent: "agent"
---

Create a new Jupyter notebook for the galaxy reduction pipeline following all conventions in [notebooks.instructions.md](../instructions/notebooks.instructions.md) and [python-style.instructions.md](../instructions/python-style.instructions.md).

## Required Notebook Structure

Build the notebook with cells in this exact order:

### Cell 1 — Title (markdown)
```markdown
# [GALAXY] – <Notebook Name>
```

### Cell 2 — Environment Alert (markdown)
```html
<div class="alert alert-block alert-info">
<b>Environment:</b> Run this notebook in the <code>ENV_NAME</code> conda environment.
</div>
```
Choose `ENV_NAME` from: `stenv` (drizzling/CRDS/HST pipeline), `astroba` (general astronomy), `dcr` (DeepCR cosmic ray removal).

### Cell 3 — Imports header (markdown)
```markdown
## Imports
```

### Cell 4 — Imports (python)
Group imports with comment headers in this exact order, each group separated by a blank line:
```python
# Python Imports
import os
from pathlib import Path

# Astropy Collaboration Imports
from astropy.io import fits

# Other Astronomy Imports
# (add as needed)

# 3rd Party Imports
import numpy as np
```
Never use `import *`.

### Cell 5 — Notebook Setup header (markdown)
```markdown
## Notebook Setup
```

### Cell 6 — Directory check (python)
```python
if Path.cwd().name != "ExpectedDir":
    if Path.cwd().name == "Notebooks":
        os.chdir("../relative/path/to/ExpectedDir")
    else:
        raise RuntimeError("This notebook must be run from the ExpectedDir directory.")
print(f'Current Directory: {Path.cwd()}')
```
Use `raise RuntimeError(...)` — not a bare `RuntimeError(...)`.

### Cell 7+ — Constants cell (python)
Define all notebook-level constants with `ALL_CAPS` names:
```python
DATA_DIR = Path("../Data")
```

### Remaining cells — Domain sections
Each domain section: `##` markdown header cell with a prose description, followed by code cell(s).

## Naming Rules

- Local variables and function arguments: `snake_case`
- Notebook-level constants (paths, globs, flags): `ALL_CAPS`
- Standard abbreviations: `fn` (filename), `hdr` (header), `filt` (filter), `crd`/`crds` (coordinate/s), `msk` (mask), `img` (image), `hdu_list` (HDU list), `out_list` (output HDU list)

## Placeholder Strings

Use these verbatim — do **not** replace with hard-coded values:
- `[GALAXY]` — notebook title, comments, query names
- `[GALAXY_SHORT]` — filenames, paths, short query identifiers
- `[GALAXY_WILDCARD]` — astroquery wildcard search patterns
- `[AUTHOR]` — FITS header `add_comment` lines
- `[INSTITUTION]` — FITS header `add_comment` lines

## FITS I/O Pattern (when applicable)

```python
for fn in file_list:
    out_name = fn.replace('_input', '_output')
    with fits.open(fn) as hdu_list:
        out_list = hdu_list.copy()
        out_list[0].header.add_history('Description of processing step')
        out_list[0].header.add_comment('Created by [AUTHOR], [INSTITUTION]')
        out_list[0].header.add_comment('Created with pipeline at https://github.com/wwaldron/galred')
        out_list['SCI'].data = processed_data
        out_list.writeto(out_name, overwrite=True)
```

## Python Style

- Max line length: 88 characters
- All function signatures must have type annotations for parameters and return values
- Use `X | None` union syntax (Python 3.10+) for nullable values; never `Optional[X]`
- Use f-strings over `%`-formatting or `.format()`
- Use `pathlib.Path` over `os.path` for filesystem operations
- Use `%%bash` magic cells (not `subprocess`) for file-system tasks

## Notebooks/ Symlink

After creating the notebook file, create a numbered symlink in the [`Notebooks/`](../../Notebooks/) directory. Symlinks use the pattern `NN-NotebookName.ipynb` (zero-padded two-digit prefix) and point to the notebook's actual path relative to `Notebooks/` (e.g., `../Images/MyNotebook.ipynb`).

### Determining the symlink number

An optional pipeline position argument may be provided (e.g., "position 5" or "after step 4"). If it is **not** provided, place the new symlink at the end: `N+1` where `N` is the current highest-numbered symlink.

If a position **is** provided:
1. List all existing symlinks in `Notebooks/` to find every link with a number ≥ the requested position.
2. Rename each of those symlinks by incrementing its number by 1 (e.g., `05-Foo.ipynb` → `06-Foo.ipynb`). Use `mv` commands in a `%%bash` cell or via terminal. Rename in **descending** order to avoid collisions.
3. Create the new symlink at the requested position number.

### Example terminal commands

```bash
# Rename existing links that shift up (descending order to avoid collisions)
mv Notebooks/08-PhotometryChecker.ipynb Notebooks/09-PhotometryChecker.ipynb
mv Notebooks/07-DrizzledInpainter.ipynb Notebooks/08-DrizzledInpainter.ipynb

# Create new symlink at the freed position
ln -s ../Images/MyNewNotebook.ipynb Notebooks/07-MyNewNotebook.ipynb
```

After creating the notebook and symlink, confirm:
- The notebook file path
- The symlink path and its target
- Any symlinks that were renumbered
