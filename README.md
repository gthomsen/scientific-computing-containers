# Overview

Collection of `Dockerfile`'s suitable as the foundation for development and
execution of scientific applications in high performance computing (HPC)
environments.  This is intended to provide stable foundations that provide a
diverse collection of compiler and MPI distributions suitable for application
development, data analysis and, ultimately, support research.  Multiple software
stack foundations lowers the bar for building and testing while generally
improving application's portability, ultimately making it easier to deploy and
run said application on larger supercomputer resources.

Currently the following software stacks are supported:

- GNU gfortran with OpenMPI
- Intel ifort with Intel MPI

A supplemental "development" layer is available and intended to augment the base
GNU- and Intel-based images by providing additional tools suitable for
interactive development, debugging and profiling.  This provides things like a
VNC server, terminal-based editors, GDB, run-time analysis tools
(e.g. Valgrind), Linux `perf`, `strace`, and friends.

This repository is maintained with Podman in mind as privilege-less containers
are required in most HPC installations.  While Podman isn't typically allowed in
larger supercomputing centers, Singularity is and the conversion from a Podman
container image to a Singularity image is provided by a helper shell script.
Docker isn't regularly tested, though all images should work just fine.

***NOTE:*** GNU Parallel is installed in each software stack and has its
citation request acknowledged.  If you do not agree to terms outlined in
`parallel --citation` (or in
[the FAQ](https://git.savannah.gnu.org/cgit/parallel.git/tree/doc/citation-notice-faq.txt)),
then do not use the installed version of Parallel.

# Quick Start

Below are commands for building images using the GNU gfortran and OpenMPI stack.
Alternate stacks can be used by substituting the directory on the base image's
build (e.g. `ifort-classic+intel-mpi+oneAPI_base/` for Intel ifort and MPI).

***NOTE:*** It is recommended that images be tagged using a date-based format of
`YYYY.MM`.  Update the commands below with a year and month.

Building a base image:

``` shell
$ podman build \
               --build-arg NUMBER_JOBS=16 \
               -t gfortran-openmpi:YYYY.MM \
               gfortran+openmpi/
```

Building a development image:

``` shell
$ podman build \
               --build-arg NUMBER_JOBS=16 \
               --build-arg BASE_IMAGE=gfortran-openmpi:latest \
               -t gfortran-openmpi:YYYY.MM-dev \
               development
```

Running the development image with the host's `${HOME}/code/` directory mapped
into the container:

``` shell
$ podman run \
             --rm -it \
             -v ${HOME}/code:/code \
             gfortran-openmpi:YYYY.MM-dev
```

Exporting the development image to Singularity's native image format:

``` shell
$ podman save -o gfortran-openmpi-YYYY.MM-dev.tar gfortran-openmpi:YYYY.MM-dev
$ singularity build -F gfortran-openmpi-YYYY.MM-dev.sif \
                      docker-archive://gfortran-openmpi-YYYY.MM-dev.tar
```

# Published Images

Select images are published
to
[DockerHub at gthomsen/scientific-base](https://hub.docker.com/repository/docker/gthomsen/scientific-base).
The following images are currently available:

| Image Name | Pull Commands | Compiler | MPI | Container OS | Dependencies | `Dockerfile`s |
| --- | --- | --- | --- | --- | --- | --- |
| `scientific-base:gfortran7.5-openmpi4.1-2022.12` <br/> `scientific-base:gfortran7.5-openmpi4.1-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:gfortran7.5-openmpi4.1-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:gfortran7.5-openmpi4.1-2022.12-dev` | `gcc`/`gfortran` 7.5 | OpenMPI 4.1.2 | Ubuntu 18.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran7.5-openmpi4.1-2022.12/gfortran%2Bopenmpi/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran7.5-openmpi4.1-2022.12-dev/gfortran%2Bopenmpi/Dockerfile) |
| `scientific-base:gfortran11.3-openmpi4.1-2022.12` <br/> `scientific-base:gfortran11.3-openmpi4.1-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:gfortran11.3-openmpi4.1-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:gfortran11.3-openmpi4.1-2022.12-dev` | `gcc`/`gfortran` 11.3 | OpenMPI 4.1.2 | Ubuntu 22.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran11.3-openmpi4.1-2022.12/gfortran%2Bopenmpi/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran11.3-openmpi4.1-2022.12-dev/gfortran%2Bopenmpi/Dockerfile) |
| `scientific-base:ifort2021.4-intelmpi2021.4-2022.12` <br/> `scientific-base:ifort2021.4-intelmpi2021.4-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:ifort2021.4-intelmpi2021.4-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:ifort2021.4-intelmpi2021.4-2022.12-dev` | `icc`/`ifort` 2021.4 | Intel MPI 2021.4 | Ubuntu 18.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.4-intelmpi2021.4-2022.12/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.4-intelmpi2021.4-2022.12-dev/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile) |
| `scientific-base:ifort2021.6-intelmpi2021.6-2022.12` <br/> `scientific-base:ifort2021.6-intelmpi2021.6-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:ifort2021.6-intelmpi2021.6-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:ifort2021.6-intelmpi2021.6-2022.12-dev` | `icc`/`ifort` 2021.6 | Intel MPI 2021.6 | Ubuntu 20.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.6-intelmpi2021.6-2022.12/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.6-intelmpi2021.6-2022.12-dev/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile) |

***NOTE:*** The Intel images are large downloads (6 GB) and *huge* once expanded
in the local registry (20-24 GB).

# Documentation

Proper documentation is currently lacking, though is slowly being added as
releases are made (and important details are rediscovered after being
forgotten).

- [Workflow](documentation/workflow.md): How-to for using containers for
  development of scientific applications
- [Publishing images](documentation/publishing-images.md): Explanation of
  the image release process
- [Notes for Intel oneAPI's images](documentation/oneAPI-development-context.md):
  Details for reference when revisiting how images are built on top of oneAPI
  images so they aren't gigantic
