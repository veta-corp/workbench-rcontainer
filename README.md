# R Data Analysis Container for Vertex AI Workbench

This repository contains a Dockerfile and associated configuration files to create a custom R data analysis container for use with Google Cloud's Vertex AI Workbench. The container is designed to provide a robust environment for data scientists and analysts working with R in the cloud.

Google's official containers are often highly inconsistent in terms of R updates and functionality; they offer outdated versions of R and lack major data science packages. This custom container aims to provide a more reliable and up-to-date environment.

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

5. Push the deployment image to Google Artifact Registry:
   ```
   make push-deploy
   ```
    Ensure you have set up `gcloud` and created an Artifact Registry repository first. You will be prompted to confirm before the push proceeds.
    This will push the image to `:latest` as well as a versioned tag based on the current date (e.g., `:250915` for 2025/09/15).
6. In Vertex AI Workbench, create a new notebook instance and select "Custom Container". Provide the URL of your pushed image in Artifact Registry.


## Notes:
- This image is based on Google's `slim` base image, and installs only the libraries and tools required for R data analysis and integration with Workbench.
- A set of Dockerfiles marked as `.old` are included for reference; these are versions of the container based on Google's full-size containers. These are much larger in size and contain a lot of Python-specific tooling that is not required for R workflows.
- The images built with this repository are intended for use with Vertex AI Workbench; we may create more generalised versions at a later date which can be executed on local machines or other cloud service platforms to provide a pre-rolled R data science environment.

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