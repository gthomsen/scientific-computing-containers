#!/bin/sh

# simple wrapper for tagging and pushing the
# gthomsen/scientific-base:gfortran11.3-openmpi4.1-2022.12 image to DockerHub.

UPSTREAM_HUB="docker.io"
UPSTREAM_REPO="gthomsen/scientific-base"
IMAGE_NAME="gfortran11.3-openmpi4.1-2022.12"

echo "Logging into ${UPSTREAM_HUB}"

# NOTE: modify the following to account for the registry and authentication required.
podman login ${UPSTREAM_HUB}
podman tag \
    ${IMAGE_NAME} \
    ${UPSTREAM_REPO}/${UPSTREAM_REPO}:${IMAGE_NAME}
podman push \
    ${IMAGE_NAME} \
    docker://${UPSTREAM_HUB}/${UPSTREAM_REPO}:${IMAGE_NAME}

if [ $? -eq 0 ]; then
    echo "Pushed ${UPSTREAM_HUB}/${UPSTREAM_REPO}:${IMAGE_NAME} successfully!"
    exit 0
else
    echo "Failed to push ${UPSTREAM_HUB}/${UPSTREAM_REPO}:${IMAGE_NAME}!"
    exit 1
fi
