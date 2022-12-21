#!/bin/sh

# simple script for building the gfortran7.5-openmpi4.1-2022.10 image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t gfortran7.5-openmpi4.1-2022.10 \
    ../gfortran+openmpi
