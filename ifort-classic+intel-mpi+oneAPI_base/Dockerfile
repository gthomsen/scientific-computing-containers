# build against Intel's latest working base image.
FROM docker.io/intel/oneapi-hpckit:2022.2-devel-ubuntu20.04

# this Dockerfile builds an image on top of an 2022.2 Intel oneAPI HPCkit
# image (which is derived from Ubuntu 20.04).
#
# dependencies built from source using v2022.1.0 of the Intel compilers:
#
#     Name               Version      Notes
#     ----               -------      -----
#     OpenMPI            4.1.2        C and Fortran support, no C++
#     HDF5               1.8.10       Parallel I/O build, static library
#     netCDF4 - C        4.8.1        Parallel I/O build, static library
#     netCDF4 - Fortran  4.5.3        Parallel I/O build, static library
#     FFTW               3.3.9        C and Fortran support, no C++
#
# packages installed via apt:
#
#     Name               Version
#     ----               -------
#     gcc                9.4.0
#     GDB                9.2
#     OpenSSH (client)   8.2
#     perf               N/A (tied to the host)
#     Valgrind           3.15
#     zlib               1.2.11

# points of interest:
#
#    - we use Intel's oneAPI HPCKit base image to start from.  it is unclear
#      whether we could start from a base Ubuntu image and add a minimal set of
#      oneAPI dependencies.
#
#    - we do not install pkg-config since the base dependencies (OpenMPI, HDF5,
#      netCDF) do not use it.  as a result, we specify LDFLAGS and CFLAGS to
#      several packages to coax the build to look in the right locations.
#
#    - we support arbitrary INSTALL_ROOT since it does not increase the
#      maintenance burden, despite not using pkg-config.
#
#    - we disable shared library creation for HDF5 and netCDF to avoid linking
#      and LD_LIBRARY_PATH run-time headaches.  this results in larger
#      executables at run-time though is not a concern since this mechanism is
#      currently geared towards debugging and troubleshooting.
#
#      of note, this makes building the Fortran netCDF wrappers slightly more
#      complicated as we have to provide an explicit list of libraries to link
#      against, rather than relying upon the C netCDF library (possibly via
#      pkg-config).  be mindful that a change to any of the Fortran wrappers'
#      dependencies could silently impact its build.
#
#    - we explicitly set PATH and LD_LIBRARY_PATH via the "ENV" directives to
#      ensure that the dependencies are available no matter how the container
#      is launched (via ENTRYPOINT/CMD, interactive or not, etc).  we could
#      create a shell script that is available post-container launch that is
#      also run by default if consistent behavior between Podman and Singularity
#      can be found.

# location oneAPI components.
ENV I_COMPILER_ROOT=/opt/intel/oneapi/compiler/2022.1.0
ENV I_IPP_ROOT=/opt/intel/oneapi/ipp/2021.6.0
ENV I_MKL_ROOT=/opt/intel/oneapi/mkl/2022.1.0
ENV I_MPI_ROOT=/opt/intel/oneapi/mpi/2021.6.0

# installation tree.
ARG INSTALL_ROOT=/opt

# staging and build location.
ARG BUILD_ROOT=/tmp/build

# full paths to the compilers used.
ARG CC=${I_COMPILER_ROOT}/linux/bin/intel64/icc
ARG FC=${I_COMPILER_ROOT}/linux/bin/intel64/ifort

# full paths to the MPI compilers used.
ARG MPICC=${I_MPI_ROOT}/bin/mpiicc
ARG MPIF90=${I_MPI_ROOT}/bin/mpiifort

# the number of subordinate jobs to launch during the build.  by default we use
# a single core unless the build process overrides this.
ARG NUMBER_JOBS=1

# version of the base image's kernel.  we use this to link the kernel-specific
# perf binary in place of the /usr/bin/perf placeholder.
ARG BASE_IMAGE_KERNEL_VERSION=4.15.0-175-generic

# create the build and installation roots.
RUN \
    mkdir -p ${BUILD_ROOT} && \
    mkdir -p ${INSTALL_ROOT}

# work out of the build root so we have a single location for build artifacts.
WORKDIR ${BUILD_ROOT}

# add a subset of the environment produced by oneAPI's setvars.sh script.  these
# are the only environment variables required for functionality.
ENV PATH=${I_MPI_ROOT}/libfabric/bin:${I_MPI_ROOT}/bin:${I_MKL_ROOT}/bin/intel64:${I_COMPILER_ROOT}/linux/bin/intel64:${I_COMPILER_ROOT}/linux/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=${I_MPI_ROOT}/libfabric/lib:${I_MPI_ROOT}/lib/release:${I_MPI_ROOT}/lib:${I_MKL_ROOT}/lib/intel64:${I_IPP_ROOT}/lib/intel64:${I_COMPILER_ROOT}/linux/lib:${I_COMPILER_ROOT}/linux/lib/x64:${I_COMPILER_ROOT}/linux/compiler/lib/intel64_lin

# install tools for an improved quality of life when working with the container.
#
# at a high-level here are the motivations for each of the packages:
#
#   file:                    "what is this thing" tool
#   less:                    a pager that can scroll backward
#
RUN \
    apt update && \
    apt-get install -y --no-install-recommends \
                       file \
                       less \
                        && \
    rm -rf /var/lib/apt/lists/*

# install a base set of tools so we can download, build, and install our tools.
# we prevent additional "recommended" packages since we want a minimal baseline.
#
# at a high-level here are the motivations for each of the packages:
#
#   curl, ca-certificates:   TLS-enabled package downloads
#   make:                    build system for compiling from source
#   m4, zlib1g, zlib1g-dev:  netCDF dependencies
#
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
                    ca-certificates \
                    curl \
                    make \
                    m4 \
                    zlib1g \
                    zlib1g-dev \
                    && \
    rm -rf /var/lib/apt/lists/*

# HDF5 1.10.8
RUN \
    # download and unpack.
    curl -O https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.8/src/hdf5-1.10.8.tar.gz && \
    tar zxf hdf5-1.10.8.tar.gz && \

    # configure HDF5.
    #
    # we build a parallel-only installation (by supplying MPI-wrapper compilers)
    # and enable both Fortran support, as well as the high-level HDF interface.
    # we explicitly disable shared library support to force static linking in
    # user applications.
    cd hdf5-1.10.8 && \
    ./configure \
       --prefix=${INSTALL_ROOT} \
       --enable-parallel \
       --enable-fortran \
       --enable-hl \
       --disable-shared \
       CC=${MPICC} \
       FC=${MPIF90} && \

    # build and install.
    make -j${NUMBER_CORES} && \
    make install && \

    # rename the poorly named benchmark program so that it doesn't hide the
    # "real" perf.
    #
    # NOTE: we break from HDF5 convention and use "hdf5" as the prefix, rather
    #       than "h5" since there already is a h5perf executable.  a better
    #       name should be used once this tool's purpose is learned.
    #
    mv ${INSTALL_ROOT}/bin/perf ${INSTALL_ROOT}/bin/hdf5perf && \

    # cleanup after ourselves.
    cd ${BUILD_ROOT} && \
    rm -rf hdf5-1.10.8*

# netCDF4 4.8.1
RUN \
    # download and unpack.
    curl -L -o netcdf-c-4.8.1.tar.gz https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz && \
    tar zxf netcdf-c-4.8.1.tar.gz && \

    # configure the netCDF C interface.
    #
    # we explicitly disable shared library support to force static linking in
    # user applications.
    #
    # NOTE: LDFLAGS/CFLAGS are required since we support arbitrary installation
    #       locations, and this specifies where HDF5 can be found.
    #
    cd netcdf-c-4.8.1 && \
    ./configure \
       --prefix=${INSTALL_ROOT} \
       --disable-shared \
       CC=${MPICC} \
       FC=${MPIF90} \
       LDFLAGS="-L${INSTALL_ROOT}/lib" \
       CFLAGS="-I${INSTALL_ROOT}/include" && \

    # build and install.
    make -j${NUMBER_JOBS} && \
    make install && \

    # cleanup after ourselves.
    cd ${BUILD_ROOT} && \
    rm -rf netcdf-c-4.8.1*

# netCDF4 Fortran wrappers 4.5.3
RUN \
    # download and unpack.
    curl -L -o netcdf-fortran-4.5.3.tar.gz https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.5.3.tar.gz && \
    tar zxf netcdf-fortran-4.5.3.tar.gz && \

    # configure the Fortran netCDF wrappers.
    #
    # NOTE: LDFLAGS/CFLAGS are required since we support arbitrary installation
    #       locations, and this specifies where both HDF5 and netCDF can be
    #       found.
    #
    # NOTE: we have to specify each of the libraries required to link against
    #       libnetcdf via LIBS=.  this is required since we built it as a static
    #       library and shared libraries capture the dependencies, along with
    #       their locations, while static libraries do not.  the values supplied
    #       were derived from 'nc-config --libs netcdf' in a fully-built
    #       container.
    #
    cd netcdf-fortran-4.5.3 && \
    ./configure \
       --prefix=${INSTALL_ROOT} \
       --disable-shared \
       --without-curl \
       CC=${MPICC} \
       FC=${MPIF90} \
       LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lm -ldl -lz" \
       LDFLAGS="-L${INSTALL_ROOT}/lib" \
       CFLAGS="-I${INSTALL_ROOT}/include" && \

    # build and install.
    make -j${NUMBER_JOBS} && \
    make install && \

    # cleanup after ourselves.
    cd ${BUILD_ROOT} && \
    rm -rf netcdf-fortran-4.5.3*

# FFTW 3.3.9
RUN \
    # download and unpack.
    curl -O http://www.fftw.org/fftw-3.3.9.tar.gz && \
    tar zxf fftw-3.3.9.tar.gz && \

    # configure FFTW.
    #
    # enable parallel processing with both MPI and threads.  exploit modern
    # Intel ISAs by using fused multiply-adds and AVX-2.
    #
    # NOTE: specifying AVX-2 makes this x86-64 specific!
    #
    cd fftw-3.3.9 && \
    ./configure \
        --prefix=${INSTALL_ROOT} \
        --enable-mpi \
        --enable-openmp \
        --enable-threads \
        --enable-avx2 \
        --enable-fma \
        CC=${CC} \
        F77=${FC} \
        MPICC=${MPICC} && \

    # build and install.
    make -j${NUMBER_JOBS} && \
    make install && \

    # cleanup after ourselves.
    cd ${BUILD_ROOT} && \
    rm -rf fftw-3.3.9*

# install GDB and Valgrind to debug issues in the tools.
#
# NOTE: we use DEBIAN_FRONTEND=noninteractive to prevent the tzdata dependency
#       installation from hanging the build.
RUN \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gdb \
        valgrind && \
    rm -rf /var/lib/apt/lists/*

# install the base linux-tools packages so we can access perf.
#
# NOTE: we force the creation of a symbolic link to the base container's
#       perf installation since we cannot be guaranteed that we can
#       install the kernel-specific linux-tools-XYZ package (i.e. the
#       host is a different distro than the container, or the host is
#       a newer release than the container).
#
RUN \
    apt update && \
    apt install -y --no-install-recommends \
                linux-tools-generic \
                linux-tools-common \
               && \
    ln -sf /usr/lib/linux-tools/${BASE_IMAGE_KERNEL_VERSION}/perf /usr/bin/perf && \
    rm -rf /var/lib/apt/lists/*

# run from the user's home directory.  this doesn't really matter for run-times
# that are isolated, but is a creature comfort for those that do
# (e.g. Singularity).
WORKDIR ${HOME}

# update the paths to prefer everything we just installed.
#
# NOTE: we do this very last so we don't hide implicit path problems where the
#       build works due to the order of installation.  keeping the environment
#       pristine build forces us to explicitly configure the packages built.
#
ENV PATH=${INSTALL_ROOT}/bin:${PATH}
ENV LD_LIBRARY_PATH=${INSTALL_ROOT}/lib:${LD_LIBRARY_PATH}

# configure Intel MPI to use the shared memory transport for inter-process
# communication.
#
# NOTE: this is required for newer versions of the Intel oneAPI stack (2022.1.0)
#       to work within a container, otherwise the MPI run-time crashes before
#       launching the application.  it does not appear to negatively impact
#       older version of the stack (2021.4.0) though has not been thoroughly
#       tested.
#
ENV I_MPI_FABRICS=shm
