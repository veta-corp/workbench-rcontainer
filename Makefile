TAG ?= debug
PROJECT ?= veta-bunseki
REPO ?= veta-workbench-images
ARTIFACT_REGISTRY_LOCATION ?= asia-northeast1

# Colours
BOLD  := $(shell tput bold)
DIM   := $(shell tput dim)
RESET := $(shell tput sgr0)

build-debug:
	@echo "$(BOLD)#######   Building DEBUG image...$(RESET)"
	docker buildx build --platform=linux/amd64 -f Dockerfile.debug -t veta-r-notebook:debug .
# Copy all logs from the R install process to the local filesystem
	rm -rf logs || true
	mkdir -p logs
	docker run --rm veta-r-notebook:debug sh -c "cd /tmp && tar -cf - *.log" | tar -C logs -xvf -
# Search logs locally for errors
	@echo "$(BOLD)#######   Checking for R package install errors...$(RESET)"
	grep -H "ERROR" logs/*.log || true
	@echo "$(BOLD)#######   Last 50 successful installs...$(RESET)"
	grep "DONE" logs/*.log | tail -50
	@echo "$(BOLD)#######   Debug build complete. You can test it with $(DIM)make test TAG=debug$(RESET)"

build-deploy:
	@echo "$(BOLD)#######   Building DEPLOY image...$(RESET)"
# Remove old logs to remove confusion; this run won't generate any.
	rm -rf logs || true
	docker buildx build --platform=linux/amd64 -f Dockerfile.deploy -t veta-r-notebook:deploy .
	@echo "$(BOLD)#######   Deploy build complete. You can test it with $(DIM)make test TAG=deploy$(RESET)"

test:
	@echo "$(BOLD)#######   Running tests on veta-r-notebook:$(TAG) :: Specify TAG=debug, TAG=deploy etc. to test other builds.$(RESET)"
	@echo "$(BOLD)   ####   Testing R version. You should see an up-to-date version of R below:$(RESET)"
	@docker run --rm veta-r-notebook:$(TAG) R --version | grep "R version"
	@echo "$(BOLD)   ####   Testing R imports... You should see no errors below:$(RESET)"
	@docker run --rm veta-r-notebook:$(TAG) R -q -e "library(tidyverse, warn.conflicts=FALSE); library(data.table, warn.conflicts=FALSE); library(lubridate, warn.conflicts=FALSE); library(rstan, warn.conflicts=FALSE)"
	@echo "$(BOLD)   ####   Testing Jupyter connectivity... You should see the IRkernel \"ir\" on the following list:$(RESET)"
	@docker run --rm veta-r-notebook:$(TAG) jupyter kernelspec list
	@echo "$(BOLD)   ####   Testing Jupyter Lab launch... You should see Jupyter version output below:$(RESET)"
	@docker run --rm veta-r-notebook:$(TAG) jupyter lab --version
	@echo "$(BOLD)   ####   Testing R capabilities. Ensure all required functionality is present:$(RESET)"
	@docker run --rm veta-r-notebook:$(TAG) R -q -e "capabilities()"
	@echo "$(BOLD)#######   Tests complete.$(RESET)"

push-deploy:
	@echo "$(BOLD)#######   Preparing to push deploy image to Google Cloud Platform...$(RESET)"
	@echo "$(BOLD)   ####   Ensure you have set up $(DIM)gcloud$(RESET) and created an Artifact Registry repo first.$(RESET)"
	@echo "$(BOLD)   ####   Deployment details:$(RESET)"
	@echo "$(BOLD)   ####     PROJECT=$(DIM)$(PROJECT)$(RESET)"
	@echo "$(BOLD)   ####     REPO=$(DIM)$(REPO)$(RESET)"
	@echo "$(BOLD)   ####     ARTIFACT_REGISTRY_LOCATION=$(DIM)$(ARTIFACT_REGISTRY_LOCATION)$(RESET)"
	@echo "$(BOLD)   ####   You may be prompted to authenticate with GCP.$(RESET)"
	@read -p "$(BOLD)   ####   Do you wish to proceed? (y/n) $(RESET) " ans; \
	if [ "$$ans" != "y" ]; then \
		echo "Aborted."; exit 1; \
	fi
# Actually do the push. Note that this is all one long command (; \ on each line) so DATE doesn't fall out of scope.
	@DATE=$$(date +%y%m%d); \
	docker tag veta-r-notebook:deploy $(ARTIFACT_REGISTRY_LOCATION)-docker.pkg.dev/$(PROJECT)/$(REPO)/veta-r-notebook:latest; \
	docker tag veta-r-notebook:deploy $(ARTIFACT_REGISTRY_LOCATION)-docker.pkg.dev/$(PROJECT)/$(REPO)/veta-r-notebook:$$DATE; \
	docker push $(ARTIFACT_REGISTRY_LOCATION)-docker.pkg.dev/$(PROJECT)/$(REPO)/veta-r-notebook:latest; \
	docker push $(ARTIFACT_REGISTRY_LOCATION)-docker.pkg.dev/$(PROJECT)/$(REPO)/veta-r-notebook:$$DATE
	@echo "$(BOLD)#######   Push complete.$(RESET)"