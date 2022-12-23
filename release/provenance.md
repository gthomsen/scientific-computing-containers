# Description
This is an Intel MPI-based stack built with ifort 2021.6.0 on Ubuntu 20.04.  The
following packages are provided:

| Name | Version | Notes |
| --- | --- | --- |
| Emacs | 26.3 | |
| gcc | 9.4.0 | |
| GDB | 9.2 | |
| FFTW | 3.3.9 | C and Fortran support, no C++ |
| HDF5 | 1.8.10 | Parallel I/O build, static library |
| icc/ifort Classic | 2021.6.0 | |
| Intel MKL | 2022.1.0 | |
| Intel MPI | 2021.6.0 | |
| make | 4.3 | |
| mwm | 2.3.8 | |
| netCDF4 - C | 4.8.1 | Parallel I/O build, static library |
| netCDF4 - Fortran | 4.5.3 | Parallel I/O build, static library |
| OpenSSH (client) | 8.2p1 | |
| perf | N/A | No version since it is tied to the host |
| strace | 5.5 | |
| TightVNC Server | 1.3.10 | |
| Valgrind | 3.15 | |
| Vim | 8.1 | |
| xterm | 353 | |
| zlib | 1.2.11 | |

# Base Images
This image was built against
`docker.io/intel/oneapi-hpckit:2022.2-devel-ubuntu20.04`.

# Deficiencies
There are no known deficiencies in the provenance of this image.
