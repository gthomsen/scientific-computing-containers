#!/bin/sh

# simple script for building the gfortran10.3-openmpi4.1-2022.06 image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t gfortran10.3-openmpi4.1-2022.06 \
    ../gfortran+openmpi
