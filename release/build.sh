#!/bin/sh

# simple script for building the gfortran11.3-openmpi4.1-2022.12-dev image.
# this assumes that the gfortran11.3-openmpi4.1-2022.12 base image has already
# been built.

# base image to extend.
BASE_IMAGE_NAME=gfortran11.3-openmpi4.1-2022.12

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    --build-arg BASE_IMAGE=${BASE_IMAGE_NAME} \
    -t ${BASE_IMAGE_NAME}-dev \
    ../development
