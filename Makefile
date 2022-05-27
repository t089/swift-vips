.PHONY: test
test:
	docker run -it --rm \
		-v $(shell pwd):/app \
		-w /app \
		$(shell docker build -q docker -f docker/Dockerfile) \
		swift test