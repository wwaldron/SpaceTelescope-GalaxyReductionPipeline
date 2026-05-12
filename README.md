# [GALAXY] - Galaxy Reduction

This template repository is meant to provide some guidance in reducing space telescope galaxy data
using Python Jupyter Notebooks. The repository is not meant to be a one-size-fits-all set of
notebooks as each galaxy and dataset is unique. Rather, the goal of this project is to provide a
set of useful defaults for image reduction as well as pointers to documentation of oft-changed
parameters.

To date, this repository only supports the *Hubble Space Telescope* (*HST*), but the hope is to add
support for the *James Webb Space Telescope* (*JWST*) in the future.

## Pipeline

### Python Research Environment

Although you may utilize any Python package/environment manager, this pipeline assumes the utility
of the [conda](https://conda.io/) manager. If you are not familiar with this tool, you will want
to begin by downloading and installing either
[Anaconda](https://docs.anaconda.com/free/anaconda/install/index.html) or
[Miniconda](https://docs.conda.io/en/latest/miniconda.html).

Similarly, one can utilize any preferred Jupyter environment manager, but the YML files listed below
are designed to work using
[nb_conda_kernels](https://github.com/Anaconda-Platform/nb_conda_kernels). If you desire to adopt
this method then run the following command in your base environment

```bash
$ conda install jupyterlab nb_conda_kernels
```

which will ensure the environments below are visible in Jupyter.

### Prerequisites

Begin by copying this template to your local GitHub account. I recommend making the new repository
name descriptive of the galaxy data you hope to reduce (*e.g.*,
[ngc3568](https://github.com/wwaldron/ngc3568)). Then, clone this newly created repository to your
research environment.

Next (if you have never done so before), you will need to create the following conda environments.

* [stenv](https://stenv.readthedocs.io/en/latest/index.html)
* [astroba](astroba.yml)
* [dcr](dcr.yml)

To install the `stenv`, follow the directions under the
[Getting Started](https://stenv.readthedocs.io/en/latest/getting_started.html) page. To install the
latter two environments run the following two commands in the top-level repository directory.

```bash
$ conda env create -f astroba.yml
$ conda env create -f dcr.yml
```

Finally, the drizzling process assumes that you have a local
[CRDS](https://hst-crds.stsci.edu/static/users_guide/overview.html) mirror. If you have never set
this up on your machine, you will need to create a `CRDS` cache directory.

```bash
$ mkdir -p ~/Data/CRDS
```

Afterwards, you will need to setup the appropriate
[environment variables](https://hst-crds.stsci.edu/static/users_guide/environment.html). Assuming
the `bash` shell environment, you could add the following lines to your `.bashrc`.

```bash
# CRDS
export CRDS_SERVER_URL="https://hst-crds.stsci.edu"
export CRDS_PATH=$HOME/Data/CRDS
export iref="${CRDS_PATH}/references/hst/iref/"
export jref="${CRDS_PATH}/references/hst/jref/"
export oref="${CRDS_PATH}/references/hst/oref/"
export lref="${CRDS_PATH}/references/hst/lref/"
export nref="${CRDS_PATH}/references/hst/nref/"
export uref="${CRDS_PATH}/references/hst/uref/"
```

### Configure Notebooks

Each of the notebooks in this repository have a number of variables that will be programmatically
replaced using the [configuration script](configure.py). Failing to run this script before utilizing
the workflow below will likely break the workflow.

To see a list of parameters that can be changed, you can display the help text by running the
following command in the top-level directory.

```bash
$ ./configure -h
```

As an example, if I wanted to setup this template to process data on
[ESO 137-001](https://en.wikipedia.org/wiki/ESO_137-001), I could run the following in the top-level
directory.

```bash
$ ./configure "ESO 137-001" -a "Will Waldron" -i "UAH"
```

Please note the use of quotation marks in the previous command as is necessary if there is
whitespace you want preserved.

### Workflow Steps

Now, you may work through the following files using their hyperlinks or by
navigating to the [Notebooks](Notebooks) directory (which just contains a list
of symlinks to the files listed below). Remember that some
parameters may need to be updated.

1. [Image Downloader](Images/ImageDownloader.ipynb)
1. [NED Downloader](Data/NED/NED_InfoDownloader.ipynb)
1. [GAIA Downloader](Data/GAIA/GAIA_Downloader.ipynb)
1. [CRDS Updater](Images/update_crds.sh)
1. [Cosmic Ray (CR) Remover](Images/DeepCR-Remover.ipynb)
1. [Image Reducer](Images/ImageReducer.ipynb)
1. [NaN Pixel Inpainter](Images/ProcessedImages/HST/PythonNotebooks/DrizzledInpainter.ipynb) (May be skipped if no `NaN` regions in FOVs)
1. [Photometry Checker](Images/ProcessedImages/HST/PythonNotebooks/PhotometryChecker.ipynb)

## External Documentation

> **Note:** The conda environments in this pipeline may not use the most up-to-date versions of
> the packages listed below. Always check the installed version against the documentation for any
> parameters or APIs that have changed.

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
