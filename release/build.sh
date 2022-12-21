#!/bin/sh

# simple script for building the ifort2021.6-intelmpi2021.6-2022.08-dev
# image.

# NOTE: this builds the ifort2021.6-intelmpi2021.6-2022.08 image as well,
#       since there was not a release for the intermediate image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

# build the ifort2021.6-intelmpi2021.6-2022.08 base image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t ifort2021.6-intelmpi2021.6-2022.08 \
    ../ifort-classic+intel-mpi+oneAPI_base

# build the ifort-intel-2022.2.0-dev image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    --build-arg BASE_IMAGE=ifort2021.6-intelmpi2021.6-2022.08 \
    -t ifort2021.6-intelmpi2021.6-2022.08-dev \
    ../development
