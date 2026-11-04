# Builds the monero.com Android APKs in Docker. See BUILD.md.

# The image Cake's own builds use, as pinned by the native library stages.
IMAGE := $(shell sed -n 's/^FROM --platform=[^ ]* //p' scripts/android/docker/Dockerfile.base)

# Optional: a docker network for builds, e.g. host when the bridge has no DNS.
CW_DOCKER_NETWORK ?=
export CW_DOCKER_NETWORK

.PHONY: apk native

apk: native
	docker run --rm $(if $(CW_DOCKER_NETWORK),--network $(CW_DOCKER_NETWORK)) \
	  -v "$(CURDIR):$(CURDIR)" -w "$(CURDIR)" \
	  -v cake-pub-cache:/root/.pub-cache -v cake-gradle:/root/.gradle \
	  -e HOST_UID=$$(id -u) -e HOST_GID=$$(id -g) \
	  $(IMAGE) bash scripts/android/build_apk_in_docker.sh
	@ls -1 build/app/outputs/flutter-apk/*.apk

# Builds the native libraries, or reuses the stage images if they're cached,
# and copies them into the tree.
native:
	scripts/android/docker/build.sh
