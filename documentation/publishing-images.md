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

1. Create a branch that has the same name of the target image (e.g. `gfortran-openmpi-2022.04`)
    A. Update the branch as necessary
2. Create the `release/` directory
3. Create a script to build (e.g. `release/build.sh`)
4. Create a script to publish (e.g. `release/publish.sh`)
5. Build, test, and push the image
6. Create after-the-fact documentation (e.g. `release/provenance.md`)
7. Create a tag to generate a Github release (e.g. `gfortran+openmpi-2022.04`)

The above ensures that the branch's documentation reflects the image pushed, and
does not have any race conditions during generation.

The `release/` directory should be contain any artifacts needed to build and
publish the release.

## Branching
Changes made for a particular container image release are done in a separate
branch.  Since container registries organize container images by individual
repositories, the name of the branch and container image's tag should match, and
be based on the software stack used in the image.

The convention used depends on the software stack in question.  For GNU-based
stacks, the convention is date-based date-based like the following:

```
<compiler>-<mpi_distribution>-<YYYY>.<MM>
```

The above results in branch names like `gfortran-openmpi-2018.12` and
`gfortran-openmpi-2022.04`.

For Intel-based stacks, the convention is base-image-based like the following:

```
ifort-<mpi_distribution>-<version>
```

The above results in branch names like `ifort-intel-2021.4.0` and `ifort-intel-2022.2.0`.

### Development Images
Development images using a scientific base shall append a `-dev` suffix to their
branch name, resulting in names like `gfortran-openmpi-2022.04-dev` and
`ifort-intel-2022.2.0-dev`.

## Release Directory
Within each release branch, all artifacts to build-, publish- and document the
container image will reside in a newly created `release/` subdirectory.
Consistent naming conventions will allow future automation to be applied to
container image generation.

## Build Script
The commands to build the container image will be contained in a
`release/build.sh` script.  For simple builds, simple modifications to
the [build script template](#Build Script Template) should suffix.

The following requirements must be met by each build script:
1. Expects to run out of the `release/` subdirectory
2. Builds a container image in the local registry for the publication
   script to tag and publish

Only one image is available per branch, though the build script may generate
multiple images if intermediates are required.

## Publication Script
The commands to publish the container image will be contained in a
`release/publish.sh` script.  It should be assumed that the [build
script](#Build Script) has run successfully prior to executing the publication
script.  For most every container image, simple modifications to
the [publication script template](#Publication Script Template) should suffix.

The following requirements must be met by each publication script:
1. References an already built image in the local registry
2. Tags the local image with the name:tag combo `<registry>/<repo>:<image_name>`
3. Authenticates and pushes to the remote registry

While not strictly necessary, tagging the local image makes it easier to see
which image was pushed after the process completes.

## Build, Test, and Push
The [build](#Build Script) and [publication](#Publication Script) scripts shall
be run and the pushed image should be tested to ensure correct behavior.  Any
changes made shall be committed to the branch as necessary.

## Provenance Documentation
Provenance of the container image will be contained in the
`release/provenance.md` file which follows
the [provenance documentation template](#Provenance Documentation Template).
Versions of key software packages will be enumerated and information regarding
the images used and any provenance deficiencies will be noted.

The "Deficiencies" section should be empty for the majority of newly created
images, as the goal of this release workflow is to have a reproducible image.
This section exists to capture known deficiencies in images created prior to the
workflow or to capture exceptional circumstances that prevent reproducibility.

## Tag the Release
For easy reference, and integration with Github's release framework, the branch
should be tagged once the build and publication scripts, and the provenance
documentation have been committed to the release branch.  Since Git complains
when branches and tags have the same name, tag names should separate the `<compiler>`
and `<mpi_distribution>` components with a `+`.

This results in branch names like `gfortran-openmpi-2022.04` being tagged with
`gfortran+openmpi-2022.04`.

# Templates
Below are templates for creating the [[build|#Build Script]] and [[publication
scripts|#Publication Scripts]], as well as the documentation summarizing the
process.

## Build Script Template
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

## Publication Script Template
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

## Provenance Documentation Template
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
