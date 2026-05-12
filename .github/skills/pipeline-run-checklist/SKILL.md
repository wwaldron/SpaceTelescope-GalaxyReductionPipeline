---
name: pipeline-run-checklist
description: "Step-by-step checklist for running the full 8-step HST galaxy reduction pipeline. Use when starting a pipeline run, resuming after an error, deciding whether to skip step 7 (DrizzledInpainter), or verifying outputs at each stage. Covers pre-flight checks, per-step validation, and common failure recovery."
argument-hint: "Starting step number, or 'full run' to start from step 1"
---

# Pipeline Run Checklist

## When to Use

- Starting a full or partial pipeline run for a configured galaxy instance
- Resuming after an error at a specific step
- Deciding whether step 7 (DrizzledInpainter) is needed
- Verifying outputs before proceeding to the next step

## Pre-Flight Checks (before step 1)

- [ ] `./configure` has been run — no `[GALAXY]` placeholders remain in notebooks
- [ ] All three conda environments exist: `conda env list | grep -E 'stenv|astroba|dcr'`
- [ ] CRDS environment variables are set: `echo $CRDS_PATH`
- [ ] JupyterLab is running with `nb_conda_kernels` so each notebook can select its own kernel

---

## Step 1 — Image Download

**Notebook:** `Images/ImageDownloader.ipynb`
**Environment:** `stenv`
**What it does:** Queries MAST for HST observations of `[GALAXY]` and downloads raw FLT/FLC files.

**Validation:**
- [ ] FLT or FLC FITS files appear in `Images/`
- [ ] File count is non-zero and matches expected observations

**Common failures:**
- MAST query returns 0 results → check `GALAXY_WILDCARD` constant matches the MAST target name
- Download incomplete → re-run the download cell; MAST supports resuming

---

## Step 2 — NED Info Download

**Notebook:** `Data/NED/NED_InfoDownloader.ipynb`
**Environment:** `stenv`
**What it does:** Downloads galaxy metadata (distance, morphology, redshift) from NED.

**Validation:**
- [ ] Output files appear in `Data/NED/`
- [ ] Distance and morphology values look reasonable for the target

---

## Step 3 — GAIA Catalog Download

**Notebook:** `Data/GAIA/GAIA_Downloader.ipynb`
**Environment:** `stenv`
**What it does:** Downloads GAIA star catalog for astrometric alignment.

**Validation:**
- [ ] FITS or CSV catalog file appears in `Data/GAIA/`
- [ ] Source count is non-zero

---

## Step 4 — Update CRDS References

**Script:** `Images/update_crds.sh`
**Environment:** shell
**What it does:** Downloads/updates HST reference files to `~/Data/CRDS`.

```bash
bash Images/update_crds.sh
```

**Validation:**
- [ ] Script completes without errors
- [ ] `$CRDS_PATH/references/hst/` directories (`iref/`, `jref/`, etc.) are populated

**Common failures:**
- `CRDS_SERVER_URL` not set → set in `~/.bashrc` and `source ~/.bashrc`
- Disk space low → CRDS mirrors can be several GB; free space before running

---

## Step 5 — Cosmic Ray Removal (DeepCR)

**Notebook:** `Images/DeepCR-Remover.ipynb`
**Environment:** `dcr`
**What it does:** Runs DeepCR neural network to identify and mask cosmic rays in each FLT/FLC.

**Validation:**
- [ ] Cosmic-ray-masked files (e.g., `*_crc.fits`) appear in `Images/`
- [ ] Mask fraction per image is plausible (< ~5% of pixels)

**Common failures:**
- CUDA/GPU not available → DeepCR falls back to CPU; much slower but works
- `deepCR` package not found → confirm the `dcr` environment is selected as the kernel

---

## Step 6 — Image Reduction (Drizzle)

**Notebook:** `Images/ImageReducer.ipynb`
**Environment:** `stenv`
**What it does:** Runs AstroDrizzle to align, combine, and drizzle all exposures into final science images.

**Validation:**
- [ ] Drizzled science mosaic (`*_drz_sci.fits`) appears in `Images/ProcessedImages/HST/`
- [ ] Weight map (`*_drz_wht.fits`) is present alongside the science mosaic
- [ ] No large NaN/blank regions in the science image (open in DS9 or matplotlib to check)

**Common failures:**
- `iref` / `jref` variables not set → CRDS reference lookup fails; check step 4 was run
- Poor alignment → tweak `ASTRODRIZZLE_PARAMS` or check GAIA catalog coverage from step 3

---

## Step 7 — NaN Inpainting (optional)

**Notebook:** `Images/ProcessedImages/HST/PythonNotebooks/DrizzledInpainter.ipynb`
**Environment:** `astroba`

**Decision — skip or run?**

Open `Images/ProcessedImages/HST/DS9/FOVs/` and inspect FOV region files in DS9:
- No blank/NaN regions within the science FOV → **skip step 7**
- Blank edges or chip gaps intersect the galaxy or science region → **run step 7**

**Validation (if run):**
- [ ] Inpainted mosaic is written to `Images/ProcessedImages/HST/`
- [ ] NaN regions are filled; pixel values at boundaries look smooth

---

## Step 8 — Photometry Check

**Notebook:** `Images/ProcessedImages/HST/PythonNotebooks/PhotometryChecker.ipynb`
**Environment:** `stenv`
**What it does:** Compares source photometry from the drizzled image against catalog values as a quality check.

**Validation:**
- [ ] Photometry comparison plot is generated
- [ ] Residuals / zero-point offset are within acceptable range for the instrument/filter

---

## Pipeline Complete

All 8 steps done. Final data products live in `Images/ProcessedImages/HST/`. Science analysis notebooks go in `Science/`.

## Resuming After a Failure

1. Identify the failing step from the error message.
2. Fix the root cause (see common failures above, or ask the **Pipeline Explorer** agent).
3. Re-run **only the failed step and all subsequent steps** — earlier outputs are still valid unless you changed input files or constants.
