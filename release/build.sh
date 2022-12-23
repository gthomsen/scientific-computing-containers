#!/bin/sh

# simple script for building the ifort2021.6-intelmpi2021.6-2022.12 image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

# build the ifort2021.6-intelmpi2021.6-2022.12 base image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t ifort2021.6-intelmpi2021.6-2022.12 \
    ../ifort-classic+intel-mpi+oneAPI_base
