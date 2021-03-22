EXECUTABLE=Hello
SWIFT_DOCKER_IMAGE=stevapple/swift-scf:5.3.3

cloud_function:
	docker run \
			--rm \
			--volume "$(shell pwd)/../..:/src" \
			--workdir "/src/examples/$(EXECUTABLE)/" \
			$(SWIFT_DOCKER_IMAGE) \
			swift build --product $(EXECUTABLE) -c release \
			&& scripts/build.sh $(EXECUTABLE)
