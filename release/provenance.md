# Description
This is an OpenMPI-based stack built with gfortran 11.3 on Ubuntu 22.04.  The
following packages are provided:

| Name | Version | Notes |
| --- | --- | --- |
| gcc/gfortran | 11.3.0 | |
| GDB | 12.1 | |
| FFTW | 3.3.9 | C and Fortran support, no C++ |
| HDF5 | 1.8.10 | Parallel I/O build, static library |
| make | 4.3 | |
| netCDF4 - C | 4.8.1 | Parallel I/O build, static library |
| netCDF4 - Fortran | 4.5.3 | Parallel I/O build, static library |
| OpenMPI | 4.1.2 | C and Fortran support, no C++ |
| OpenSSH (client) | 8.9 | |
| GNU Parallel | 20210822 | |
| perf | N/A | No version since it is tied to the host |
| Valgrind | 3.18.1 | |
| zlib | 1.2.11 | |

# Base Images
This image was built against `ubuntu:jammy-20221130`.

# Deficiencies
There are no known deficiencies in the provenance of this image.
