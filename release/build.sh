#!/bin/sh

# simple script for building the gfortran-openmpi-2022.04 image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t gfortran-openmpi-2022.04 \
    ../gfortran+openmpi
