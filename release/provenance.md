# Description
This is an OpenMPI-based stack built with gfortran 7.5 on Ubuntu 18.04.  The
following packages are provided:

| Name | Version | Notes |
| --- | --- | --- |
| gcc/gfortran | 7.5 | |
| GDB | 8.1.1 | |
| FFTW | 3.3.9 | C and Fortran support, no C++ |
| HDF5 | 1.8.10 | Parallel I/O build, static library |
| make | 4.1 | |
| netCDF4 - C | 4.8.1 | Parallel I/O build, static library |
| netCDF4 - Fortran | 4.5.3 | Parallel I/O build, static library |
| OpenBLAS | 0.2.20 | |
| OpenMPI | 4.1.2 | C and Fortran support, no C++ |
| OpenSSH (client) | 7.6p1 | |
| perf | N/A | No version since it is tied to the host |
| Valgrind | 3.13 | |
| zlib | 1.2.11 | |

# Base Images
This image was built against `ubuntu:bionic-20221130`.

# Deficiencies
There are no known deficiencies in the provenance of this image.
