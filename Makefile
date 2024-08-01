#
# Makefile for Docker Dister
#
# Note that this is for development and container image builds.
#


# How to invoke Docker

ifneq ($(shell id -u),0)
  SUDO=sudo
  DOCKER=$(SUDO) docker
else
  SUDO=
  DOCKER=docker
endif


default: run


# Protoype data directory for testing
DATA := $(shell pwd)/sample-data


# Where the build happens.

IMAGE := docker-dister
CONTAINER_NAME := docker-dister

BUILT := .built
$(BUILT): Dockerfile Makefile
	$(DOCKER) build \
		--tag $(IMAGE) \
		.
	touch $@
TO_CLEAN += $(BUILT)


build image: $(BUILT)


# Temporary container /data directory
TMP_DATA=/tmp/docker-dister-data
$(TMP_DATA):
	$(SUDO) rm -rf "$@"
	$(SUDO) mkdir -p "$@"
	(cd $(DATA) && tar cf - .) | (cd "$@" && $(SUDO) tar xf -)
	$(SUDO) chown -R root:root "$@"
TO_CLEAN_ROOT += $(TMP_DATA)

# Run the container and exit
run: $(BUILT) $(REPO) $(LOG) $(TMP_DATA)
	$(DOCKER) run \
		--rm \
		--volume $(TMP_DATA):/data:Z \
		--name "$(CONTAINER_NAME)" \
		"$(IMAGE)"

# Log into the persisted container
shell:
	$(DOCKER) exec -it "$(CONTAINER_NAME)" /bin/sh


# Stop the persisted container
halt:
	$(DOCKER) exec -it "$(CONTAINER_NAME)" kill 1


# Remove the container
rm:
	$(DOCKER) rm -f "$(CONTAINER_NAME)"
	$(DOCKER) image rm -f "$(IMAGE)"


clean: rm
	rm -rf $(TO_CLEAN)
	$(SUDO) rm -rf $(TO_CLEAN_ROOT)
	find . -name '*~' | xargs rm -f
