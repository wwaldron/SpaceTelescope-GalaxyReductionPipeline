---
description: "Use when editing, creating, or troubleshooting conda environment YML files (astroba.yml, dcr.yml). Covers channel ordering, version pinning, adding packages, and compatibility with the STScI stack."
applyTo: "**/*.yml"
---

# Conda Environment Conventions

## The Three Environments

| Name | File | Purpose |
|---|---|---|
| `stenv` | installed from STScI (not in this repo) | Drizzling, CRDS, HST pipeline tasks |
| `astroba` | [`astroba.yml`](../astroba.yml) | General astronomy/data analysis; most notebooks |
| `dcr` | [`dcr.yml`](../dcr.yml) | DeepCR cosmic ray removal; GPU/PyTorch stack |

Do not modify `stenv` — it is managed externally by STScI. Only `astroba.yml` and `dcr.yml` are in this repo.

## Channel Ordering Rules

- **`astroba.yml`**: uses `conda-forge` and `astropy` as top-level channels. Add new packages from `conda-forge` first; use the `astropy` channel for packages exclusive to it. Do not add `defaults` as a channel — it conflicts with the `conda-forge` stack.
- **`dcr.yml`**: uses `conda-forge` and `pytorch` as top-level channels because the PyTorch stack requires them. Add new packages from `conda-forge` where possible; use `conda-forge::package` prefix only when a package is unavailable in the listed channels.
- Never add `defaults` as a channel to `astroba.yml` — it will conflict with `conda-forge`-pinned packages.

## Version Pinning Philosophy

- **Pin only when necessary** — unversioned entries (`astropy`, `numpy`) let conda find compatible versions automatically.
- **Pin tightly for GPU/driver-sensitive packages** in `dcr.yml`: PyTorch, CUDA toolkit, and related packages must be pinned together (e.g., `pytorch::pytorch==2.0.1` with `pytorch::pytorch-cuda=11.8`).
- **Pin `mkl`** in `dcr.yml` to avoid MKL/OpenBLAS conflicts with the PyTorch stack (currently `mkl=2023`).
- Do not pin `numpy` or `scipy` unless a specific version is required for a known compatibility issue.

## Adding Packages

- **New analysis/astronomy packages** → add to `astroba.yml` unless they require GPU or are DCR-specific.
- **GPU, deep learning, or CR-removal packages** → add to `dcr.yml`.
- If a package is only available on `pip`, add it under the `pip:` subsection at the bottom of the `dependencies` list.
- Prefer conda packages over pip when both are available, to keep the solver aware of the dependency.
- For packages installed from a git repo (e.g., `deepCR`), use the `pip: git+https://...` pattern and pin to a specific commit or tag if reproducibility matters.

## `ipykernel` Requirement

Every environment must include `ipykernel` so it is visible as a kernel in JupyterLab via `nb_conda_kernels`. Do not remove it.

## Updating Environments

To rebuild an environment from scratch after editing a YML file:

```bash
conda env remove -n ENV_NAME
conda env create -f ENV_NAME.yml
```

To update an existing environment in-place (faster, but may leave stale packages):

```bash
conda env update -f ENV_NAME.yml --prune
```

Prefer the remove-and-recreate approach when changing channels or pinned versions.
