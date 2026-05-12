# Galaxy Reduction Pipeline — Agent Context

This repository is part of the **`wwaldron/galred`** pipeline family for reducing *Hubble Space Telescope* (*HST*) galaxy imaging data using Jupyter notebooks and Python. It may be the template repo itself or a configured galaxy instance derived from it.

## What This Repo Is

- A **pipeline template**: fork/copy it per galaxy target (e.g., `wwaldron/ngc3568`).
- The pipeline covers: image download → catalog download → CRDS update → cosmic ray removal → drizzle reduction → NaN inpainting → photometry checking.
- All user-specific strings (galaxy name, author, institution) are injected by running `./configure "Galaxy Name" -a "Author" -i "Institution"` before use.

## Key Files and Directories

| Path | Purpose |
|---|---|
| `configure` / `configure.py` | Substitutes `[GALAXY]`, `[AUTHOR]`, `[INSTITUTION]` placeholders in notebooks |
| `astroba.yml` | Conda env for most notebooks (general astronomy) |
| `dcr.yml` | Conda env for DeepCR cosmic ray removal (GPU/PyTorch) |
| `Images/` | Raw and processed HST images (FITS files excluded from git) |
| `Data/NED/`, `Data/GAIA/` | Downloaded catalog data (excluded from git) |
| `Notebooks/` | Symlinks to all pipeline notebooks for convenience |

## Conda Environments

Three environments are required: `stenv` (STScI-managed, external), `astroba`, and `dcr`. Each notebook declares its required environment in a blue HTML alert box near the top.

## Code Style Targets

- **Python**: flake8-compliant, PEP 8, `snake_case`, 88-char line limit, full type annotations (mypy standard strictness), Python 3.10+ syntax.
- **Notebooks**: `snake_case` variables, `ALL_CAPS` constants, structured cell order (title → env alert → imports → setup → domain sections).
- **Git**: linear history on `main`, descriptive imperative commit messages, FITS and data files never committed.
