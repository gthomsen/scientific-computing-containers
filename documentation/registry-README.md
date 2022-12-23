# Quick Reference
The `Dockerfile`'s and associated documentation are maintained on Github at
[gthomsen/scientific-computing-containers](https://github.com/gthomsen/scientific-computing-containers/).

Feature requests and bugs can be filed [here](https://github.com/gthomsen/scientific-computing-containers/issues).

# Images
Currently maintained images are listed below.

| Image Name | Pull Commands | Compiler | MPI | Container OS | Dependencies | `Dockerfile`s |
| --- | --- | --- | --- | --- | --- | --- |
| `scientific-base:gfortran7.5-openmpi4.1-2022.12` <br/> `scientific-base:gfortran7.5-openmpi4.1-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:gfortran7.5-openmpi4.1-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:gfortran7.5-openmpi4.1-2022.12-dev` | `gcc`/`gfortran` 7.5 | OpenMPI 4.1.2 | Ubuntu 18.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran7.5-openmpi4.1-2022.12/gfortran%2Bopenmpi/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran7.5-openmpi4.1-2022.12-dev/gfortran%2Bopenmpi/Dockerfile) |
| `scientific-base:gfortran11.3-openmpi4.1-2022.12` <br/> `scientific-base:gfortran11.3-openmpi4.1-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:gfortran11.3-openmpi4.1-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:gfortran11.3-openmpi4.1-2022.12-dev` | `gcc`/`gfortran` 11.3 | OpenMPI 4.1.2 | Ubuntu 22.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran11.3-openmpi4.1-2022.12/gfortran%2Bopenmpi/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/gfortran11.3-openmpi4.1-2022.12-dev/gfortran%2Bopenmpi/Dockerfile) |
| `scientific-base:ifort2021.4-intelmpi2021.4-2022.12` <br/> `scientific-base:ifort2021.4-intelmpi2021.4-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:ifort2021.4-intelmpi2021.4-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:ifort2021.4-intelmpi2021.4-2022.12-dev` | `icc`/`ifort` 2021.4 | Intel MPI 2021.4 | Ubuntu 18.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.4-intelmpi2021.4-2022.12/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.4-intelmpi2021.4-2022.12-dev/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile) |
| `scientific-base:ifort2021.6-intelmpi2021.6-2022.12` <br/> `scientific-base:ifort2021.6-intelmpi2021.6-2022.12-dev` | `docker pull docker.io/gthomsen/scientific-base:ifort2021.6-intelmpi2021.6-2022.12` <br/> `docker pull docker.io/gthomsen/scientific-base:ifort2021.6-intelmpi2021.6-2022.12-dev` | `icc`/`ifort` 2021.6 | Intel MPI 2021.6 | Ubuntu 20.04 | HDF5 1.8.10, netCDF4 4.8.1 (4.5.3), FFTW 3.3.9 | [`base`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.6-intelmpi2021.6-2022.12/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile), [`development`](https://github.com/gthomsen/scientific-computing-containers/blob/ifort2021.6-intelmpi2021.6-2022.12-dev/ifort-classic%2Bintel-mpi%2BoneAPI_base/Dockerfile) |

Currently only `x86-64`-based images are available, though the non-Intel images
support building `aarch64` images.  Multi-architecture images are planned for
the future.

# What is a Scientific Computing Container?

These containers provide a foundation for development and execution of
scientific applications in high performance computing (HPC) environments.  The
intent is to provide stable foundations with a diverse collection of compiler
and MPI distributions suitable for application development, data analysis and,
ultimately, support research.  Providing multiple software stacks lowers the bar
for building and testing while generally improving application's portability,
ultimately making it easier to deploy and run said application on larger
supercomputer resources.

See the
[repository's README](https://github.com/gthomsen/scientific-computing-containers/blob/master/README.md) for
more information.

# License
The `Dockerfile`'s generating these images are
[licensed under Apache 2.0](https://github.com/gthomsen/scientific-computing-containers/blob/master/LICENSE).

As with all Docker images, these likely also contain software which are under
other licenses.  As a starting point, please see the license information for the
base images currently used:

* [Ubuntu](https://hub.docker.com/_/ubuntu)
* [Intel's oneAPI HPCKit](https://hub.docker.com/r/intel/oneapi-hpckit)
