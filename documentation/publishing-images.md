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

# Naming Conventions
Care is needed to properly name things so we balance the following:

* Tags are descriptive and interpretable by users
* Provenance is traceable
* Maintenance is not unbearable

While the repository stores individual image `Dockerfile`'s
in [separate directories](#Repository_Directories), we also have to
consider [branch names](#Git_Branch_Names), [tag names](#Git_Tag_Names),
and [images published to registries](#Container_Image_Names), all while taking
into consideration what is required by the maintenance cycle.  As a result, we
name things based on the key components that distinguish releases:

1. Compiler version
2. MPI distribution version
3. Release date

The above components are prioritized since applications are typically most
sensitive to compiler version (due to improved warning/error checking and
optimizations), followed by MPI distributions (due to performance capabilities),
and finally the release date (giving an indication of how out of date its
security patches are).  Note that we do not include the base OS version in
the naming convention as the goal of the containers is to provide a stable
foundation of dependencies that are independent of the OS.

## Repository Directories
Given that compiler version and MPI distribution version are the top two most
important components, `Dockerfile`'s are organized in directories named
`<compiler>+<mpi_distribution>/`.

***NOTE:*** This currently does not include the versions of either the compiler
or the MPI distribution as these are implicit in the base image built from.
While this may change in the future, the repository branch and tag names, as
well as the container image names, already account for this making updating to a
more specific form straight forward should maintenance dictate it.

## Git Branch Names
Branches represent a specific SHA1 of the artifacts required to build a
particular container image and must capture the key components describing its
contents.  As such, Git branch names have the following form:

```
<compiler><compiler_version>-<mpi_distribution><mpi_version>-<YYYY>.<MM>[-dev]
```

This results in branch names like `gfortran10.3-openmpi4.1-2022.04` and
`ifort2022.2-intelmpi2021.6-2022.06-dev`.

Things to note:

- Lexicographic sorting groups components in order of their importance.  This
  makes it easier to find maintenance updates for a given compiler and MPI
  distribution.
- We only track major and minor version numbers (e.g. `<major>.<minor>`) as this
  is all that has been needed thus far.  More granular versions
  (e.g. `<major>.<minor>.<point>` or `<major>.<minor>-<sha>`) could be used in
  the future, though are not included to minimize verbosity.
- Branch names, and implicitly tag names and container image names, are not
  intended to be parsed so we simply concatenate the component with its version
  rather than separating it with a delimiter.  This improves readability for
  end users.

## Git Tag Names
Since Git complains when [branches](#Git_Branch_Names) and tags have the same
name, tag names should separate the `<compiler>` and `<mpi_distribution>`
components with a `+`.

This results in branch names like `gfortran10.3-openmpi4.1-2022.04` being tagged with
`gfortran10.3+openmpi4.1-2022.04`.

## Container Image Names
Published container images reside in a registry which typically includes a
[fixed host and repository component](https://docs.docker.com/engine/reference/commandline/tag/) that
does not change across images.  Said differently, a single repository may house
multiple images published by this workflow which requires enforcing naming
conventions on the container images' tags which results in image names of
the following form:

```
<host>/<repository>:<compiler><compiler_version>-<mpi_distribution><mpi_version>-<YYYY>.<MM>[-dev]
```

The above uses [branch names](#Git_Branch_Names) as the image's tag to make it
easy to trace provenance.

***NOTE:*** Tags have a 128-character limit, per the Docker specification linked
above.  The date component (`-<YYYY>.<MM>`) takes 8 characters, and the optional
development tag (`-dev`) takes four characters, leaving 116
characters for the compiler and MPI distribution.  Given that date-based
versions are similar to the date component, image tag names should be able to
mirror branch names so long as the software names are kept to no more than 50
characters.

# Workflow
The following outlines the steps for creating and publishing a new container
image.

1. [Create a branch](#Git_Branch_Names) that has the
    same [tag of the target image](#Container_Image_Names) (e.g. `gfortran11.2-openmpi4.1-2022.04`)
    A. Update the branch as necessary
2. Create the `release/` directory
3. Create a script to build (e.g. `release/build.sh`)
4. Create a script to publish (e.g. `release/publish.sh`)
5. Build, test, and push the image
6. Create after-the-fact documentation (e.g. `release/provenance.md`)
7. [Create a tag](#Git_Tag_Names) to generate a Github release (e.g. `gfortran11.2+openmpi4.1-2022.04`)

The above ensures that the branch's documentation reflects the image pushed, and
does not have any race conditions during generation.

The `release/` directory should be contain any artifacts needed to build and
publish the release.

## Branching
Branches represent and produce a single container image which, given that images
are named with a date component, means they typically have few commits on top of
their source branch.  Container images with a new combination of compiler and
MPI distribution versions will typically branch from `master`, while maintenance
updates to existing versions will typically branch from the predecessor branch.

### Development Images
Development images using a scientific base shall append a `-dev` suffix to their
branch name, resulting in names like `gfortran10.3-openmpi4.1-2022.04-dev` and
`ifort2022.2-intelmpi2021.6-2022.08-dev`.

## Release Directory
Within each release branch, all artifacts to build-, publish- and document the
container image will reside in a newly created `release/` subdirectory.
Consistent naming conventions will allow future automation to be applied to
container image generation.

## Build Script
The commands to build the container image will be contained in a
`release/build.sh` script.  For simple builds, minimal modifications to
the [build script template](#Build_Script_Template) should suffix.

The following requirements must be met by each build script:
1. Expects to run out of the `release/` subdirectory
2. Builds a container image in the local registry, using the
   correct [tag name](#Container_Image_Names), for the publication
   script to tag and publish

Only one image is available per branch, though the build script may generate
multiple images if intermediates are required.

## Publication Script
The commands to publish the container image will be contained in a
`release/publish.sh` script.  It should be assumed that the [build
script](#Build_Script) has run successfully prior to executing the publication
script.  For most every container image, simple modifications to
the [publication script template](#Publication_Script_Template) should suffix.

The following requirements must be met by each publication script:
1. References an already built image in the local registry
2. [Tags the local image](#Container_Image_Names) with the name:tag combo `<registry>/<repo>:<image_name>`
3. Authenticates and pushes to the remote registry

While not strictly necessary, tagging the local image makes it easier to see
which image was pushed after the process completes.

## Build, Test, and Push
The [build](#Build_Script) and [publication](#Publication_Script) scripts shall
be run and the pushed image should be tested to ensure correct behavior.  Any
changes made shall be committed to the branch as necessary.

## Provenance Documentation
Provenance of the container image will be contained in the
`release/provenance.md` file which follows
the [provenance documentation template](#Provenance_Documentation_Template).
Versions of key software packages will be enumerated and information regarding
the images used and any provenance deficiencies will be noted.

The "Deficiencies" section should be empty for the majority of newly created
images, as the goal of this release workflow is to have a reproducible image.
This section exists to capture known deficiencies in images created prior to the
workflow or to capture exceptional circumstances that prevent reproducibility.

## Tag the Release
For easy reference, and integration with Github's release framework, the branch
should be tagged once the build and publication scripts, and the provenance
documentation have been committed to the release branch.
[Tag names](#Git_Tag_Names) should separate the `<compiler>` and
`<mpi_distribution>` components with a `+`.

This results in branch names like `gfortran10.3-openmpi4.1-2022.04` being tagged with
`gfortran10.3+openmpi4.1-2022.04`.

# Templates
Below are templates for creating the [build](#Build_Script) and [publication
scripts](#Publication_Scripts), as well as the documentation summarizing the
process.

## Build Script Template
The build script should do everything needed to build the target container
image.  It should also be compatible with the associated [publication
script](#Publication_Script).

The following `release/build.sh` builds the base image in a parallel manner:

```shell
#!/bin/sh

# simple script for building the <image> image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    -t gfortran11.2-openmpi4.1-2022.08 \
    ../gfortran+openmpi
```

## Publication Script Template
The publication script should do everything needed to publish the target
container image to an upstream registry.  It should also be compatible with the
associated [build script](#Build_Script).

The following `release/publish.sh` publishes the base image to DockerHub:
```shell
#!/bin/sh

# simple wrapper for tagging and pushing the <image>:<tag> to <registry>.

UPSTREAM_REGISTRY="docker.io"
UPSTREAM_REPO="gthomsen/scientific-base"
IMAGE_NAME="gfortran11.2-openmpi4.1-2022.08"

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
- Base image(s) used (e.g. `ubuntu:jammy-20220801`)
- Known deficiencies (e.g. lack of provenance - where and why)

For consistency, use the following sections in the `release/provenance.md` file:

```markdown
# Description
# Base Images
# Deficiencies
```
