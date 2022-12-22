# Description
This is an OpenMPI-based stack built with gfortran 7.5 on Ubuntu 18.04.  The
following packages are provided:

| Name | Version | Notes |
| --- | --- | --- |
| Emacs | 25.2.2 | |
| gcc/gfortran | 7.5 | |
| GDB | 8.1.1 | |
| FFTW | 3.3.9 | C and Fortran support, no C++ |
| HDF5 | 1.8.10 | Parallel I/O build, static library |
| make | 4.1 | |
| mwm | 2.3.8 | |
| netCDF4 - C | 4.8.1 | Parallel I/O build, static library |
| netCDF4 - Fortran | 4.5.3 | Parallel I/O build, static library |
| OpenBLAS | 0.2.20 | |
| OpenMPI | 4.1.2 | C and Fortran support, no C++ |
| OpenSSH (client) | 7.6p1 | |
| GNU Parallel | 20210822 | |
| perf | N/A | No version since it is tied to the host |
| strace | 4.21 | |
| TightVNC Server | 1.3.10 | |
| Valgrind | 3.13 | |
| Vim | 8.0 | |
| xterm | 330 | |
| zlib | 1.2.11 | |

# Base Images
This image was built against `gfortran7.5-openmpi4.1-2022.12`.

# Deficiencies
There are no known deficiencies in the provenance of this image.
