build-debug:
	docker buildx build --platform=linux/amd64 -f Dockerfile.debug -t veta-r-notebook:debug .
	# Copy all logs from the R install process to the local filesystem
	rm -rf logs || true
	mkdir -p logs
	docker run --rm veta-r-notebook:debug sh -c "cd /tmp && tar -cf - *.log" | tar -C logs -xvf -
	# Search logs locally for errors
	@echo "#######   Checking for R package install errors..."
	grep -H "ERROR" logs/*.log || true
	@echo "#######   Last 50 successful installs..."
	grep "DONE" logs/*.log | tail -50

build-deploy:
	# Remove old logs to remove confusion; this run won't generate any.
	rm -rf logs || true
	docker buildx build --platform=linux/amd64 -f Dockerfile.deploy -t veta-r-notebook:deploy .