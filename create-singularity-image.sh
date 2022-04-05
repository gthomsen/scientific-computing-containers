#!/bin/sh

# exports a Podman image to disk and then creates a Singularity SIF file from it.
#
# NOTE: this has no error checking or convenience functionality.  just a wrapper
#       to avoid fat finger mistakes.
#

PODMAN_TAG=$1
ARCHIVE_PATH=$2
SIF_PATH=$3

if [ $# -lt 3 ]; then
    echo "Usage: <tag> <podman_path> <singularity_path>" >&2
    exit 1
fi

if [ -f ${ARCHIVE_PATH} ]; then
    rm -f ${ARCHIVE_PATH}
fi

podman save -o ${ARCHIVE_PATH} ${PODMAN_TAG}

singularity build -F ${SIF_PATH} docker-archive://${ARCHIVE_PATH}
