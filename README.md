# R Data Analysis Container for Vertex AI Workbench

This repository contains a Dockerfile and associated configuration files to create a custom R data analysis container for use with Google Cloud's Vertex AI Workbench. The container is designed to provide a robust environment for data scientists and analysts working with R in the cloud.

Google's official R containers are often highly inconsistent in terms of updates and functionality; they offer very old versions of R and some major data science packages are no longer supported on those versions. This custom container aims to provide a more reliable and up-to-date environment.

## Features
- Latest stable version of R (installed from CRAN).
- Commonly used R packages for data analysis pre-installed, along with their dependencies.
- Google Cloud / Vertex AI specific packages and integrations are included.
- Optimised Docker image: deployment images compress the layers of the build process to reduce the final image size and complexity.
- Optional testing / debugging tools: a separate Docker build process to help figure out missing dependencies if you add new packages.

## Usage
1. Clone this repository to your local machine.
2. Edit the packages.txt file to add any additional R packages you need pre-installed.
3. Edit system-libs.txt to add any additional system libraries required by your R packages.
4. Build the Docker image using the provided `make` commands:
    - Test / debug the build process:
      ```
      make build-debug
      ```
      This will create a larger image and will output detailed logs on the installation process of every R package to the `logs` directory, as well as showing a brief summary output to identify any installation errors.

    - For the final deployment image:
      ```
      make build-deploy
      ```
      This will not output any logs and will create a more compact image suitable for use on Vertex AI Workbench.

## Notes:
- This image is based on a plain ubuntu:22.04 base image, and installs only the libraries and tools required for R data analysis and integration with Workbench.
- A set of Dockerfiles marked as `.old` are included for reference; these are versions of the container based on Google's official data analysis containers. However, these are not really suitable for R-focused workflows (they are highly Python-centric, include gigabytes of Python data science tools, and have very old versions of R and R packages).
- While the images built with this repository are intended for use with Vertex AI Workbench, they can also be used in other environments - you could run them locally with Docker and connect to them to get a ready-rolled R data science notebook environment, if you like. This could be useful if you're struggling with the mess of dependencies that R packages often have.

## Package Manifest

Here is the current list of R packages included in the container:

### Core data processing packages
- tidyverse
- data.table
- lubridate

### Visualisation / graphing
- ggplot2
- patchwork
- ggthemes
- ggrepel

### Causal inference / econometrics
- estimatr
- fixest
- Synth
- tidysynth
- gsynth
- grf
- rdrobust
- MatchIt

### Modeling / machine learning
- glmnet
- randomForest
- ranger
- bayesplot
- rstan
- mediation

### Simulation / parallel processing
- furrr
- future
- doParallel
- AlgDesign

### Google Cloud Platform integration
- bigrquery
- googleCloudStorageR
- googleAuthR
- gargle
- DBI