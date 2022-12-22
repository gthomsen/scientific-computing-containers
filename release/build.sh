#!/bin/sh

# simple script for building the ifort2021.4-intelmpi2021.4-2022.12-dev image.
# this assumes that the ifort2021.4-intelmpi2021.4-2022.12 base image has
# already been built.

# base image to extend.
BASE_IMAGE_NAME=ifort2021.4-intelmpi2021.4-2022.12

# parallelize the build as much as possible.
NUMBER_CORES=`grep MHz /proc/cpuinfo  | wc -l`

# build the ifort2021.4-intelmpi2021.4-2022.12-dev image.
podman build \
    --build-arg NUMBER_JOBS=${NUMBER_CORES} \
    --build-arg BASE_IMAGE=${BASE_IMAGE_NAME} \
    -t ${BASE_IMAGE_NAME}-dev \
    ../development
