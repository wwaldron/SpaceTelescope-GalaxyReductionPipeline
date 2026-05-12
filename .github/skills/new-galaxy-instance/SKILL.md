---
name: new-galaxy-instance
description: "Set up a new galaxy reduction instance from the galred template. Use when creating a new galaxy target repo, configuring placeholder strings, installing conda environments, verifying CRDS setup, and validating notebooks are ready to run. Covers fork, clone, configure, env create, CRDS check, and pre-flight validation."
argument-hint: "Galaxy name, author, and institution (e.g., 'NGC 3568 by Will Waldron at UT Austin')"
---

# New Galaxy Instance Setup

## When to Use

- Starting a fresh galaxy reduction for a new HST target
- Verifying an existing instance is correctly configured before running the pipeline
- Onboarding a collaborator to an already-configured instance

## Procedure

### Step 1 — Fork / Clone the Template

1. Fork `wwaldron/galred` on GitHub, naming it after the target (e.g., `wwaldron/ngc3568`).
2. Clone locally:
   ```bash
   git clone https://github.com/<user>/<galaxy-slug>.git
   cd <galaxy-slug>
   ```

### Step 2 — Run the Configure Script

Run `configure` **before** opening any notebook:

```bash
./configure "Galaxy Name" -a "Author Name" -i "Institution"
```

- Use `./configure -h` to see optional flags (`-s` for short name, `-w` for wildcard pattern).
- Verify substitution succeeded — check that `[GALAXY]` no longer appears anywhere:
  ```bash
  grep -r '\[GALAXY\]' Notebooks/
  ```
  If any matches remain, re-run `configure` or fix them manually.
- Commit the configured notebooks:
  ```bash
  git add Notebooks/ Images/ Data/
  git commit -m "Configure pipeline for <Galaxy Name>"
  ```

### Step 3 — Create Conda Environments

Install the two repo-managed environments:

```bash
conda env create -f astroba.yml
conda env create -f dcr.yml
```

Install `stenv` separately via the [STScI stenv docs](https://stenv.readthedocs.io/en/latest/getting_started.html).

Verify all three are available:
```bash
conda env list | grep -E 'stenv|astroba|dcr'
```

### Step 4 — Verify CRDS Setup

Confirm the local CRDS mirror and required environment variables exist:

```bash
# Check mirror directory
ls ~/Data/CRDS

# Check environment variables
echo $CRDS_SERVER_URL
echo $CRDS_PATH
echo $iref
```

If any variable is missing, add to `~/.bashrc` (see [workflow.instructions.md](../../instructions/workflow.instructions.md) for the full block), then `source ~/.bashrc`.

Update reference files before first drizzle run:

```bash
bash Images/update_crds.sh
```

### Step 5 — Pre-Flight Notebook Validation

Before running step 1 of the pipeline, confirm notebooks are ready:

1. Open `Notebooks/01-ImageDownloader.ipynb` in JupyterLab.
2. Verify the title cell reads `# <Galaxy Name> – Image Downloader` (not `[GALAXY]`).
3. Confirm the environment alert names `stenv`.
4. Check that constants like `GALAXY_NAME`, `MAST_DIR` are set to non-placeholder values.

Repeat spot-checks for each notebook or use the **Notebook Reviewer** agent:
```
@notebook-reviewer review Notebooks/01-ImageDownloader.ipynb
```

### Step 6 — Confirm Directory Structure

Ensure expected output directories exist (the notebooks create them, but confirming avoids surprises):

```
Images/
Images/ProcessedImages/HST/
Images/ProcessedImages/HST/DS9/FOVs/
Images/ProcessedImages/HST/PythonNotebooks/
Data/NED/
Data/GAIA/
Science/
```

### Ready to Run

Once all six steps pass, proceed with the pipeline in order — see [workflow.instructions.md](../../instructions/workflow.instructions.md) for the full step-by-step sequence.

## Common Pitfalls

- **Skipping `configure`**: Notebooks will fail with literal `[GALAXY]` in queries and filenames.
- **Missing `stenv`**: Steps 1–3 and 6–8 require it; it must be installed separately from STScI.
- **`CRDS_PATH` not set**: `ImageReducer` will fail silently or use wrong reference files.
- **Running notebooks from the wrong directory**: Each notebook checks `Path.cwd()` and raises `RuntimeError` if run from the wrong location. Use the `Notebooks/` symlinks or `cd` to the correct directory first.
