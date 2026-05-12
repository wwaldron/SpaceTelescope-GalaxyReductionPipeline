---
description: "Add a package to the correct conda environment YML file (astroba.yml or dcr.yml) following channel ordering, version pinning, and compatibility rules for the galaxy reduction pipeline."
name: "Add Conda Package"
argument-hint: "Package name and target environment (e.g., 'scipy to astroba' or 'torchvision to dcr')"
agent: "agent"
---

Add a package to the appropriate conda environment YML file following the conventions in [conda-envs.instructions.md](../instructions/conda-envs.instructions.md).

## Step 1 — Determine the Target Environment

If not specified in the argument, decide based on:

| Environment | File | Use for |
|---|---|---|
| `astroba` | [`astroba.yml`](../../astroba.yml) | General astronomy, data analysis, most notebooks |
| `dcr` | [`dcr.yml`](../../dcr.yml) | DeepCR, GPU/PyTorch, cosmic ray removal |

Never modify `stenv` — it is managed externally by STScI.

## Step 2 — Read the Target YML File

Read the current contents of the appropriate YML file to understand the existing channel order, package list, and pip section.

## Step 3 — Apply Channel and Placement Rules

Follow the channel ordering, version pinning, and placement rules in [conda-envs.instructions.md](../instructions/conda-envs.instructions.md).

Key reminders:
- For `astroba.yml`: do **not** add `defaults` as a channel.
- For `dcr.yml`: GPU/driver-sensitive packages (PyTorch, CUDA) must be pinned together.

### pip packages
- If the package is only available on pip (or must be installed from a git repo), add it under the `pip:` subsection at the bottom of `dependencies:`
- For git-sourced packages: `- git+https://github.com/org/repo@tag`
- Prefer conda packages over pip when both are available

## Step 4 — Make the Edit

Edit the YML file to add the package in the correct location. Do not reformat or reorder existing lines unnecessarily.

## Step 5 — Report

Confirm:
- Which file was modified
- Where the package was added (conda `dependencies` list or `pip` subsection)
- Whether any version pinning was applied and why
- The rebuild command to apply the change:

```bash
# Remove and recreate (preferred for channel/pin changes):
conda env remove -n ENV_NAME
conda env create -f ENV_NAME.yml

# In-place update (faster, may leave stale packages):
conda env update -f ENV_NAME.yml --prune
```
