# Overview
Providing `Dockerfile`'s and tools to build images in different formats is not
sufficient for reproducible science as there is a gap between the images built
and downstream provenance.  This document aims to provide a preliminary workflow
for creating provenance that can bridge this gap with the following:

- Documentation on the image itself (why it was needed, important details, etc)
- Documentation on the images used during build
- Command line(s) for building the image
- Command line(s) for publishing the image

The above allow the chain of provenance to be tracked from the application level
all the way back to individual commits used:

1. Application references a uniquely tagged image
2. Uniquely tagged images map to Git branches that created them
3. Git repository branches map to the SHA1's that provided the build artifacts

# Workflow
The following outlines the steps for creating and publishing a new container
image.

1. Create a branch that has the same name of the target image
    A. Update the branch as necessary
2. Create the `release/` directory
3. Create a script to build (e.g. `release/build.sh`)
4. Create a script to publish (e.g. `release/publish.sh`)
5. Build, test, and push the image
6. Create after-the-fact documentation (e.g. `release/provenance.md`)

The above ensures that the branch's documentation reflects the image pushed, and
does not have any race conditions during generation.

The `release/` directory should be contain any artifacts needed to build and
publish the release.

# Templates
Below are templates for creating the [[build|#Build Script]] and [[publication
scripts|#Publication Scripts]], as well as the documentation summarizing the
process.

## Build Script
The build script should do everything needed to build the target container
image.  It should also be compatible with the associated [[publication
script|#Publication Script]].

The following `release/build.sh` builds the base image in a parallel manner:

```shell
#!/bin/sh

# simple script for building the <image> image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    -t gfortran-openmpi-YYYY.MM \
    ../gfortran+openmpi
```

## Publication Script
The publication script should do everything needed to publish the target
container image to an upstream registry.  It should also be compatible with the
associated [[build script|#Build Script]].

The following `release/publish.sh` publishes the base image to DockerHub:
```shell
#!/bin/sh

# simple wrapper for tagging and pushing the <image>:<tag> to <registry>.

UPSTREAM_REGISTRY="docker.io"
UPSTREAM_REPO="gthomsen/scientific-base"
IMAGE_NAME="gfortran-openmpi-2022.08"

echo "Logging into ${UPSTREAM_REGISTRY}"

# NOTE: modify the following to account for the registry and authentication required.
podman login ${UPSTREAM_REGISTRY}
podman tag \
    ${IMAGE_NAME} \
    ${UPSTREAM_REPO}/${UPSTREAM_REPO}:${IMAGE_NAME}
podman push \
    ${IMAGE_NAME} \
    docker://${UPSTREAM_REGISTRY}/${UPSTREAM_REPO}:${IMAGE_NAME}

if [ $? -eq 0 ]; then
    echo "Pushed ${UPSTREAM_REGISTRY}/${UPSTREAM_REPO}:${IMAGE_NAME} successfully!"
    exit 0
else
    echo "Failed to push ${UPSTREAM_REGISTRY}/${UPSTREAM_REPO}:${IMAGE_NAME}!"
    exit 1
fi
```

***NOTE:*** The `podman login` needs to authenticate to the registry.  If this
is not properly configured, it will prompt for credentials.

## Documentation
Provenance information should be included alongside the scripts used to build
and publish the image.  The following details should be included:

- Description of the image
- Base image(s) used (e.g. ubuntu:jammy-20220801)
- Known deficiencies (e.g. lack of provenance - where and why)

For consistency, use the following sections in the `release/provenance.md` file:

```markdown
# Description
# Base Images
# Deficiencies
```
