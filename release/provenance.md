# Description
This is an OpenMPI-based stack built with gfortran 10.3 on Ubuntu 21.04.  The
following packages are provided:

| Name | Version | Notes |
| --- | --- | --- |
| gcc/gfortran | 10.3.0 | |
| GDB | 10.1 | |
| FFTW | 3.3.9 | C and Fortran support, no C++ |
| HDF5 | 1.8.10 | Parallel I/O build, static library |
| make | 4.3 | |
| netCDF4 - C | 4.8.1 | Parallel I/O build, static library |
| netCDF4 - Fortran | 4.5.3 | Parallel I/O build, static library |
| OpenMPI | 4.1.2 | C and Fortran support, no C++ |
| OpenSSH (client) | 8.4 | |
| perf | N/A | No version since it is tied to the host |
| Valgrind | 3.17 | |
| zlib | 1.2.11 | |

# Base Images
This image was built against `ubuntu:hirsute`.  See [the
deficiencies](#Deficiencies) for additional details.

# Deficiencies
This image was originally created on 2022-06-01T20:27:20.124231745Z though was
built against `ubuntu:hirsute` instead of a versioned base image.  Based on the
timestamp embedded in the original image, it is assumed that
`ubuntu:hirsute-20220113` was used.

***NOTE:*** Due to this image being built on a non-LTS base image, it is no
longer possible to build this image without modification.  Changing
`/etc/apt/sources.list` so that it references `https://old-releases.ubuntu.com`
instead of `https://ubuntu.com` *should* allow the image to be built.
