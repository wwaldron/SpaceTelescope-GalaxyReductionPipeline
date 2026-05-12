---
description: "Use when working on galaxy reduction pipeline tasks: downloading images, running notebooks, setting up conda environments, configuring CRDS, reducing HST data, removing cosmic rays, drizzling, inpainting, or checking photometry."
---

# Galaxy Reduction Pipeline – Workflow Instructions

## Project Overview

This repository provides a Jupyter Notebook–based pipeline for reducing *Hubble Space Telescope* (*HST*) galaxy observations. Each galaxy dataset is unique, so parameters in notebooks will need to be adjusted per-target. Future support for *JWST* is planned but not yet implemented.

## Environment Setup

- Three conda environments are required:
  - **`stenv`**: STScI's environment for drizzling and CRDS; install via [stenv docs](https://stenv.readthedocs.io/en/latest/getting_started.html).
  - **`astroba`**: installed from [`astroba.yml`](../astroba.yml) — `conda env create -f astroba.yml`
  - **`dcr`**: installed from [`dcr.yml`](../dcr.yml) — `conda env create -f dcr.yml`
- Notebooks are intended to be run with [nb_conda_kernels](https://github.com/Anaconda-Platform/nb_conda_kernels) so each notebook selects its own environment.
- When suggesting package installs or environment changes, target the correct environment (`stenv`, `astroba`, or `dcr`) based on the notebook/task at hand.

## CRDS Setup

- A local CRDS mirror at `~/Data/CRDS` is required for drizzling.
- The following environment variables must be set (e.g., in `.bashrc`):
  ```bash
  export CRDS_SERVER_URL="https://hst-crds.stsci.edu"
  export CRDS_PATH=$HOME/Data/CRDS
  export iref="${CRDS_PATH}/references/hst/iref/"
  export jref="${CRDS_PATH}/references/hst/jref/"
  export oref="${CRDS_PATH}/references/hst/oref/"
  export lref="${CRDS_PATH}/references/hst/lref/"
  export nref="${CRDS_PATH}/references/hst/nref/"
  export uref="${CRDS_PATH}/references/hst/uref/"
  ```
- Reference files are updated by running [`Images/update_crds.sh`](../Images/update_crds.sh) (pipeline step 4).

## Configure Script

- Before running any notebooks, configure them with the [`configure`](../configure) script:
  ```bash
  ./configure "Galaxy Name" -a "Author Name" -i "Institution"
  ```
- Use `./configure -h` to see all available parameters.
- The script programmatically substitutes variables in notebooks; skipping it will likely break the workflow.

## Pipeline Workflow Order

Always follow this sequence when working through the pipeline:

| Step | Notebook / Script | Environment |
|------|-------------------|-------------|
| 1 | [`Images/ImageDownloader.ipynb`](../Images/ImageDownloader.ipynb) | `stenv` |
| 2 | [`Data/NED/NED_InfoDownloader.ipynb`](../Data/NED/NED_InfoDownloader.ipynb) | `stenv` |
| 3 | [`Data/GAIA/GAIA_Downloader.ipynb`](../Data/GAIA/GAIA_Downloader.ipynb) | `stenv` |
| 4 | [`Images/update_crds.sh`](../Images/update_crds.sh) | shell |
| 5 | [`Images/DeepCR-Remover.ipynb`](../Images/DeepCR-Remover.ipynb) | `dcr` |
| 6 | [`Images/ImageReducer.ipynb`](../Images/ImageReducer.ipynb) | `stenv` |
| 7 | [`Images/ProcessedImages/HST/PythonNotebooks/DrizzledInpainter.ipynb`](../Images/ProcessedImages/HST/PythonNotebooks/DrizzledInpainter.ipynb) | `astroba` *(optional — skip if no NaN regions in FOVs)* |
| 8 | [`Images/ProcessedImages/HST/PythonNotebooks/PhotometryChecker.ipynb`](../Images/ProcessedImages/HST/PythonNotebooks/PhotometryChecker.ipynb) | `stenv` |

The [`Notebooks/`](../Notebooks/) directory contains symlinks to all of the above for convenience.

## Notebook Conventions

- Each notebook has configurable variables at the top that are set by `configure.py`; do not hard-code galaxy names, author names, or institution strings directly.
- When modifying a notebook, preserve the cell structure and variable naming conventions established by the configure script.
- Do not add cells that change the conda kernel or environment inline — kernel selection is managed at the notebook level via nb_conda_kernels.

## Data Directories

- Raw downloaded images: `Images/`
- Processed/drizzled images: `Images/ProcessedImages/HST/`
- NED catalog data: `Data/NED/`
- GAIA catalog data: `Data/GAIA/`
- DS9 region files and FOV overlays: `Images/ProcessedImages/HST/DS9/`

## External Documentation

The conda environments may not use the most up-to-date package versions. Always cross-reference the installed version against these references when looking up parameters or APIs.

### HST Notebooks & General Reference

- [STScI HST Notebooks](https://spacetelescope.github.io/hst_notebooks/)
- [HST Documentation Hub](https://www.stsci.edu/hst/documentation)
- [MAST Archive](https://mast.stsci.edu/) — HST data download portal

### Instrument Handbooks

- [ACS Instrument Handbook](https://hst-docs.stsci.edu/display/ACSIHB/)
- [WFC3 Instrument Handbook](https://hst-docs.stsci.edu/display/WFC3IHB)

### Data Reduction Handbooks

- [HST Data Handbook](https://hst-docs.stsci.edu/display/HSTDHB)
- [ACS Data Handbook](https://hst-docs.stsci.edu/display/ACSDHB)
- [WFC3 Data Handbook](https://hst-docs.stsci.edu/display/WFC3DHB)
- [DrizzlePac Handbook](https://hst-docs.stsci.edu/drizzpac)

### Software Documentation

- [Astropy](https://docs.astropy.org/en/stable/index_user_docs.html)
- [Astroquery](https://astroquery.readthedocs.io/en/stable/) — used for MAST and NED queries
- [NED](https://ned.ipac.caltech.edu/) — NASA/IPAC Extragalactic Database
- [photutils](https://photutils.readthedocs.io/en/stable/index.html)
- [DrizzlePac](https://drizzlepac.readthedocs.io/en/latest/)
- [DeepCR](https://deepcr.readthedocs.io/) — cosmic ray removal
