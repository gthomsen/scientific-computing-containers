# Overview

While the containers provided could be used with (most) any run-time, we focus
on supporting rootless Podman and Singularity run-times.  This ensures that none
of the configurations require elevated privileges for normal use and, thereby,
avoiding any security-related problems Docker may bring, as well as being
maximally compatible/portable to large HPC installations.

At a high level there really are only two steps in the build process:

1. Build the OCI image via Podman
2. Optionally, convert the OCI image into a Singularity SIF image

# Podman Build

Building rootless containers with Podman is as simple as:

```shell
$ podman build directory/ -t image_name:tag
```

For example, to build the gfortran + OpenMPI image:

```shell
$ podman build gfortran+openmpi/ -t gfortran-openmpi:latest
```

## Debugging Broken Builds

Add `|| echo "Broken"` to command lines to cause a failed build's `RUN` command
to succeed so it can be triaged.  Then run the untagged image and debug:

```shell
$ podman run --rm -t `podman images | head -n2 | tail -n2 | awk '{ print $3 }'`
```

Searching for keywords via `more` and `less` allows efficient location of
problems.  The following identifies the error that stopped the HDF5
configuration process:

```shell
# NOTE: use 'more' when 'less' isn't available.
$ more +/'configure:.*: error:.*' hdf5-1.10.8/config.log

$ less -p 'configure:.*: error:.*' hdf5-1.10.8/config.log
```

# Podman Test

Interactively kick the tires with packages and the base image.
```shell
$ podman run --rm -it image:tag
```

Full test with target application by mapping host volumes into the container
for access.  Note that all modifications are done as the user despite the
containers being built as `root`:

```shell
$ podman run --rm -it -v /path/on/host:/home/user image:tag
```

# Using Podman Images for Profiling and Debugging

Attaching a debugger to a process requires privileges that aren't normally
granted to containers by default.  Add `--cap-add=SYS_PTRACE,SYS_ADMIN` to
the container launch command to let `gdb`, `strace`, and friends work as
expected:

```shell
$ podman run -p 5902:5902 \
             --cap-add=SYS_PTRACE,SYS_ADMIN \
             --rm -it \
             -v ${HOME}/code:/code \
             gfortran-openmpi:2022.08
```

# Creating Singularity Images

Since advanced features of Singularity images are not needed, we build them from
existing OCI images build via Podman.  Once created, the single file `.sif`
artifact can be moved to remote systems or used (possibly via MPI).

**NOTE:** This requires a lot of extra space, at least twice what `image:tag`
occupies, once for the tar archive and once more for the intermediate
Singularity SIF file.  Note that it may be less because SIF files compress
layers.

```shell
$ podman save -o image-tag.tar image:tag
$ singularity build -F singularity-image-tag.sif docker-archive://image-tag.tar
```

Or, use the `create-singularity-image.sh` wrapper script:

```shell
$ ./create-singularity-image image:tag image-tag.tar singularity-image-tag.sif
```
