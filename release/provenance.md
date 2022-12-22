# Description
This is an Intel MPI-based stack built with ifort 2021.4.0 on Ubuntu 18.04.  The
following packages are provided:

| Name | Version | Notes |
| --- | --- | --- |
| gcc/gfortran | 7.5.0 | |
| GDB | 8.1.1 | |
| FFTW | 3.3.9 | C and Fortran support, no C++ |
| HDF5 | 1.8.10 | Parallel I/O build, static library |
| icc/ifort Classic | 2021.4.0 | |
| Intel MKL | 2021.4.0 | |
| Intel MPI | 2021.4.0 | |
| make | 4.3 | |
| netCDF4 - C | 4.8.1 | Parallel I/O build, static library |
| netCDF4 - Fortran | 4.5.3 | Parallel I/O build, static library |
| GNU Parallel | 20210822 | |
| perf | N/A | No version since it is tied to the host |
| Valgrind | 3.13 | |
| zlib | 1.2.11 | |

# Base Images
This image was built against `intel/oneapi-hpckit:2021.4-devel-ubuntu18.04`.

# Deficiencies
There are no known deficiencies in the provenance of this image.
