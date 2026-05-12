---
description: "Use when creating, editing, or reviewing Jupyter notebooks in this galaxy reduction pipeline. Covers cell structure, import organization, placeholder strings, variable naming, FITS I/O patterns, and conda environment notes."
applyTo: "**/*.ipynb"
---

# Notebook Conventions – Galaxy Reduction Pipeline

## Mandatory Cell Structure

Every notebook must follow this top-level order:

1. **Title cell** (markdown): `# [GALAXY] – <Notebook Name>`
2. **Environment alert cell** (markdown): HTML blue alert box specifying the required conda environment (see template below).
3. **`## Imports`** (markdown header) followed immediately by a code cell containing all imports.
4. **`## Notebook Setup`** (markdown header) followed by a directory-check code cell.
5. Domain-specific sections using `##` headers; subsections with `###`.

### Environment Alert Template

```html
<div class="alert alert-block alert-info">
<b>Environment:</b> Run this notebook in the <code>ENV_NAME</code> conda environment.
</div>
```

Replace `ENV_NAME` with the correct environment: `stenv`, `astroba`, or `dcr` (see workflow instructions for the mapping).

## Import Organization

Group imports with comment headers in this order, each group separated by a blank line:

```python
# Python Imports
import os
from pathlib import Path

# Astropy Collaboration Imports
from astropy.io import fits
from astroquery.mast import Observations

# Other Astronomy Imports
from deepCR import deepCR

# 3rd Party Imports
import numpy as np
```

Never use bare `import *`.

## Notebook Setup Cell (Directory Check)

Every notebook must include a directory check immediately after the imports code cell:

```python
if Path.cwd().name != "ExpectedDir":
    if Path.cwd().name == "Notebooks":
        os.chdir("../relative/path/to/ExpectedDir")
    else:
        raise RuntimeError("This notebook must be run from the ExpectedDir directory.")
print(f'Current Directory: {Path.cwd()}')
```

Note: use `raise RuntimeError(...)`, not a bare `RuntimeError(...)` (which silently does nothing).

## Placeholder Strings

The following bracket-enclosed placeholders are injected by the `configure` script and must **never** be replaced with hard-coded values:

| Placeholder | Usage |
|---|---|
| `[GALAXY]` | Notebook title, comments, query names |
| `[GALAXY_SHORT]` | Filenames, paths, short query identifiers |
| `[GALAXY_WILDCARD]` | astroquery wildcard search patterns |
| `[AUTHOR]` | FITS header `add_comment` lines |
| `[INSTITUTION]` | FITS header `add_comment` lines |

Do not introduce new bracket-style placeholders without also adding them to `configure.py`.

## Variable Naming Conventions

Target PEP 8 / flake8 compliance even though existing notebooks may not yet conform:

- **`snake_case`** for all local variables and function arguments.
  - Examples: `file_name_dict`, `obs_table`, `gal_crd`, `hdu_list`, `out_list`, `fov_msk`, `rep_pix_msk`
- **`ALL_CAPS`** for notebook-level constants (paths, globs, DQ bit flags).
  - Examples: `DATA_DIR`, `FLC_GLOB_PAT`, `DQ_FILLED`, `INP_DIR`, `R_IN`, `R_OUT`
- **Standard abbreviations** to use consistently:
  - `fn` – filename, `hdr` – header, `filt` – filter, `crd`/`crds` – coordinate(s)
  - `msk` – mask, `pix` – pixel, `img` – image, `instr` – instrument, `aper` – aperture
  - `drc`/`drz` – drizzled calibrated / drizzled, `flc`/`flt` – flat-fielded calibrated / flat-fielded
  - `hdu_list` – HDU list object, `out_list` – output copy of HDU list

## FITS I/O Pattern

Use this pattern for reading, processing, and writing FITS files:

```python
for fn in file_list:
    out_name = fn.replace('_input', '_output')  # derive output name
    with fits.open(fn) as hdu_list:
        out_list = hdu_list.copy()
        out_list[0].header.add_history('Description of processing step')
        out_list[0].header.add_comment('Created by [AUTHOR], [INSTITUTION]')
        out_list[0].header.add_comment('Created with pipeline at https://github.com/wwaldron/galred')
        out_list['SCI'].data = processed_data
        out_list.writeto(out_name, overwrite=True)
```

Always add `add_history` and `add_comment` entries to FITS output headers.

## HST Filter Extraction Pattern

Use this standard loop when building a dict of files grouped by filter:

```python
file_name_dict = {}
for fn in glob_pattern:
    with fits.open(fn) as hdu_list:
        hdr = hdu_list[0].header
        if 'FILTER' in hdr:
            filt = hdr['FILTER']
        elif 'CLEAR' not in hdr['FILTER1']:
            filt = hdr['FILTER1']
        else:
            filt = hdr['FILTER2']
    if filt not in file_name_dict:
        file_name_dict[filt] = []
    file_name_dict[filt].append(fn)
```

## Bash Cells

Use `%%bash` magic cells (not `subprocess`) for file organization tasks such as moving, renaming, or deleting intermediate products:

```bash
%%bash
mkdir -p output_dir
mv *_intermediate.fits output_dir/
rm -f temp_*
```

## Section Markdown Style

- Top-level sections: `## Section Name`
- Subsections: `### Subsection Name`
- Include a brief prose description in each markdown header cell explaining the purpose of the following code cell(s).
- Do not merge documentation into code comments when a markdown cell is more appropriate.
