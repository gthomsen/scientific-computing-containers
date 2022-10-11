#!/bin/sh

# simple script for building the ifort-intel-2022.2.0-dev image.

# NOTE: this builds the ifort-intel-2022.2.0 image as well, since there was not
#       a release for the intermediate image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

# build the ifort-intel-2022.2.0 base image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t ifort-intel-2022.2.0 \
    ../ifort-classic+intel-mpi+oneAPI_base

# build the ifort-intel-2022.2.0-dev image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    --build-arg BASE_IMAGE=ifort-intel-2022.2.0 \
    -t ifort-intel-2022.2.0-dev \
    ../development
