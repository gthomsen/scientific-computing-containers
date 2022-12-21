#!/bin/sh

# simple script for building the gfortran11.2-openmpi4.1-2022.08 image.

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    -t gfortran11.2-openmpi4.1-2022.08 \
    ../gfortran+openmpi
