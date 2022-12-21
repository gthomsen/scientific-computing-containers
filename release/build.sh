#!/bin/sh

# simple script for building the ifort2021.4-intelmpi2021.4-2022.06-dev image.

# NOTE: this builds the ifort2021.4-intelmpi2021.4-2022.06 image as well, since
#       there was not a release for the intermediate image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

# build the ifort-intel-2021.4.0 base image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t ifort2021.4-intelmpi2021.4-2022.06 \
    ../ifort-classic+intel-mpi+oneAPI_base

# build the ifort-intel-2021.4.0-dev image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    --build-arg BASE_IMAGE=ifort2021.4-intelmpi2021.4-2022.06 \
    -t ifort2021.4-intelmpi2021.4-2022.06-dev \
    ../development
