---
description: "Use when writing commit messages, managing branches, reviewing git history, creating .gitignore entries, or advising on git workflow for the galaxy reduction template or galaxy instance repositories."
---

# Git & GitHub Conventions

## Repository Model

This project follows a **template → instance** pattern:

- **Template repo** ([`wwaldron/galred`](https://github.com/wwaldron/galred)): contains the pipeline notebooks, conda YML files, configure script, and instruction files. Changes here affect all future galaxy instances.
- **Galaxy instance repo** (e.g., [`wwaldron/ngc3568`](https://github.com/wwaldron/ngc3568)): copied from the template via GitHub's "Use this template" feature, then configured with `./configure`. Changes here are galaxy-specific.

When suggesting git operations, clarify which repo is in scope if it is ambiguous.

## Branching Strategy

- Use a **linear history on `main`** — no long-lived feature branches.
- Commit directly to `main` for routine processing work in instance repos.
- In the template repo, short-lived branches are acceptable for significant structural changes before merging back to `main`.

## Commit Messages

- **Free-form but descriptive**: write one sentence that explains *what* changed and *why*, not just *what files* changed.
- Prefer present tense, imperative mood: "Add drizzle step to ImageReducer" not "Added drizzle step".
- Reference the pipeline step number when relevant: "Step 6: update TweakReg parameters for WFC3/IR".
- Keep the subject line under ~72 characters; use a blank line + body for additional context.

**Good examples:**
```
Configure notebooks for ESO 137-001

Fix filter extraction loop to handle FILTER1/FILTER2 fallback

Step 5: switch DeepCR model to ACS-WFC-2048 for better CR detection
```

**Avoid:**
```
updates
fixed stuff
changed notebook
```

## What to Track vs. Exclude

The `.gitignore` already excludes raw and processed data. Follow these rules when considering new entries:

| Track (commit) | Exclude (gitignore) |
|---|---|
| Notebooks (`.ipynb`) | `*.fits`, `*.fits.gz` — all FITS files |
| `configure.py`, `configure` | `.ipynb_checkpoints/` |
| `astroba.yml`, `dcr.yml` | `*.ecsv`, `*.reg`, `*.txt` (catalog outputs) |
| `.github/` instructions | `mastDownload/` |
| `update_crds.sh` | Any directory containing only downloaded/processed data |

- Never commit FITS images, drizzled products, or MAST download directories.
- Data products live outside the repository, as defined by the `DATA_DIR` paths in each notebook.
- If a new output type is introduced (e.g., `.csv` catalogs, `.png` plots), explicitly decide whether it belongs in the repo before committing.

## `.gitignore` Maintenance

- Add new exclusion rules to the **root `.gitignore`** unless the rule is specific to a single subdirectory (e.g., `Data/NED/.gitignore` for NED outputs).
- When adding a new pipeline step that produces output files, add the relevant glob patterns to `.gitignore` at the same time.

## Template vs. Instance Changes

- Bug fixes and structural improvements to notebooks → commit to the **template repo**, then pull into instance repos as needed.
- Galaxy-specific parameter tuning, processed outputs, and science notes → commit only to the **instance repo**.
- Do not commit placeholder strings (`[GALAXY]`, `[AUTHOR]`, etc.) in an instance repo — run `./configure` before the first commit.
