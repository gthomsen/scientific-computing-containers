# Overview

The oneAPI HPC suite has a lot of useful tools for developers though requires a
large amount of disk space when everything is installed.  Unfortunately, due to
the complexity of the tools and the current state of packaging, simply
installing a minimal subset of packages and building an image on top of it
doesn't (usually) work.  As a result, derived images are built from the full
base image and weigh in somewhere in the 15-25 GiB range which makes certain
workflows very expensive

This document aims to capture the state of affairs to explain why the images
were built the way they are, and provide context for when it would be worthwhile
to revisit the build process in an attempt to create smaller derived images in
the svelte 5-10 GiB ballpark.

**NOTE:** Due to time constraints this is more of a transcription of nodes
rather than an edited-for-clarity document.

# Target Software

The derived-image base is designed to contain the following tools:

- Intel's MPI distribution
- Intel's classic C, C++, and Fortran compilers
- Parallel, static-only build of HDF5 with Fortran bindings
- Parallel, static-only build of netCDF4 with Fortran bindings
- Parallel FFTW with Fortran bindings

This provides accelerated linear algebra (c.f. MKL), Fourier transforms
(c.f. FFTW), common math operations (Intel Performance Primitives), as well as
MPI-parallel I/O libraries.  All necessary components for distributed scientific
computing applications.

# Expectations vs Reality

The derived images are intended to build, debug, and run scientific codes to
remove the dependency management aspect from non-DevOps-enabled scientists.
Below are the expectations held when initial approaching this problem:

- Able to use a recent version of Ubuntu for compatibility and security reasons
- Have a small container to reduce required resources (transferring a 20 GiB
  image is a non-starter on a 100 Mbps link)
- Be able to reliably build non-oneAPI dependencies from source

Nice to haves include:

- Having a quick container build. While this isn't strictly required, it makes
  development significantly less painful.

# Problems Encountered

There are three categories of experiences when building a derived image:

1. Non-Intel base image, offline installer
2. Non-Intel base image, Intel APT repository
3. Intel base image

Below are summaries of issues encountered, and the context that lead to them, so
future maintainers can identify existing failure modes and avoid rediscovering
existing knowledge.  At a high level the following were show stoppers:

1. Installation did not produce an working non-interactive environment (though
   interactive environments did appear to work)
2. The target application could not run due to bugs in the tools (e.g. the MPI
   distribution would crash during initialization)

## Offline Installer on Ubuntu Image

Using an offline installer on a base Ubuntu image is a simple approach that
works in air gapped environments and produces a minimal image by an additive
process.  While being slow due to the self-contained compressed .tar archive
(extraction is a single core operation) it did not produce a stack that could
build the dependencies in an non-interactive manner.

Since this was the first roadblock in the image development process, detailed
notes were not taken.  It is believed that the parallel HDF5 dependency could
not be built due to the compiler not providing the correct path to `for_main.o`
during linking with MPI (see [[Installing from Intel Repositories on Ubuntu Image]]).

**NOTE:** Exhaustive testing of older versions did not occur, and only 2022.0.2
version (the most recent versions at the time) was tested.

## Installing from Intel Repositories on Ubuntu Image

Installing `.deb` packages from Intel's official repositories trades network
bandwidth for CPU cycles to decompress the offline installer's archive.  Barring
the repositories having a corrupt manifest (which occurred more than once in
March 2022) and having a slow network connection/no package cache, this is a
faster build process.

This effort started with Ubuntu 21.04 images (Hirsute) but was moved back to
18.04 in an attempt to match the images Intel provides.  While the newest
versions of Ubuntu are not "officially" supported, it is believed this will work
once other bugs are addressed.

Building a base derived-image works in an interactive state (`podman run -it
...`) as it could build the requisite [[#Target Software]] and pass their
internal test suites.  However, something was wrong which prevented
non-interactive builds of the non-Intel dependencies.  It is not believed to be
a missing environment variable (these were painstakingly extracted from official
images and replicated, and an official build with a pared down environment could
build the stack) but something differs between Intel's provided images and those
generated from their [Dockerfiles](https://github.com/intel/oneapi-containers/blob/master/images/docker/hpckit/Dockerfile.ubuntu-18.04).

Since HDF5 is the first dependency built when using the Intel MPI distribution,
it is unclear whether it is the only tool that cannot be built (FFTW was never
built first).  In particular, the `./configure` output will complain about the
compiler not supporting `SIZEOF()` or `STORAGE_SIZE()` as part of Fortran 2003.
The compiler path is correct, though tricking the configuration process to print
the link commands used (add `LDFLAGS=-v` to `./configure`'s command line) will
lead to the curious fact that the compiler does not provide the correct path to
`for_main.o`.  Since this provides Fortran program's main entry point (`_MAIN`),
linking fails and `./configure` reports a broken compiler, and rightfully so.

As of April 2022, I do not know how to influence where `ifort` looks for
`for_main.o`.  Instead it uses a non-existent path beneath the compiler
installation location that appears to be architecture based.  Strangely,
entering into the partially built derived image and rerunning the same
configuration command will succeed and allow compiling HDF5.

This behavior was seen with versions 2022.x and 2021.y, possibly with offline
installer version 2021.y (older version chosen to match working bare metal
configuration).

This "environment" problem occurs even if one attempts to recreate the official
images and then iteratively remove packages from the build to back into a
minimal base image.  None of the versions available appeared to work, though for
different reasons:

- 2022.0.2 and 2021.4.0 have the `for_main.o` issue
- Pre-2021.4.0 did not provide a non-interactive image (it did not include a
  wall of `ENV VAR=VAL` and assumed users would source `setvars.sh` when running
  the container)

## Building on Official Images

Despite being gigantic (oneAPI HPC toolkit 2022.0.2 is ~22 GiB), building from
it appears to be the only way forward - either as is or or by removing unused
components and benefiting from Singularity's layer flattening when creating a
`.sif` file.

The [latest 2022.1.2 images](https://hub.docker.com/r/intel/oneapi-hpckit/tags)
allowed both the dependencies and target application to build, but would crash
during MPI initialization prior to application code running.  Intel MPI 2021.5
(part of the 2022.1.2 image) seems to be the culprit as earlier versions
(2021.4.0) work.

The 2021.4.0 image does work when setting the `PATH` and `LD_LIBRARY_PATH`
environment via `ENV` directives in the `Dockerfile`.

# Lessons Learned

Below are lessons that should never be forgotten.

## Environment Variables

Unfortunately, Intel's process to configure the environment via sourcing
`setvars.sh` does not work when building derived images.

Firstly, because non-Docker run-times do not consistently execute `ENTRYPOINT`
scripts which prevents starting a shell that sources it (both Podman and
Singularity have different issues here).  Additionally, albeit a corner case,
this doesn't allow frictionless execution of non-`ENTRYPOINT` commands as these
would require a complicated shell execution launching a custom commandline.

Secondly, the vast majority of the environment variables set are not actually
required for basic compiler and profiler use.  Simply setting `PATH` and
`LD_LIBRARY_PATH` is sufficient.  Building these by hand, or extracting them
from a working installation, is sufficient.  Horribly brittle and a pain to
maintain, but sadly the best course of action.

# Future Efforts

Below are several avenues to explore when new versions of the oneAPI components
come out.

## Extract Offline Installer

Should the offline installer be used to install the system, effort to extract
its packages once and test the installation process should be made.  This was
a significant hindrance to the develop/test loop.

## Replicate Intel Build Process

It is unclear why official builds cannot be replicated.  While one is not paid
as an Intel developer to fix this, it would be the starting point for a minimal
build.

## Examine New Versions

Versions of oneAPI newer than 2022.1.2 *should* be what we want:

- Installed from Intel's repositories
- Working compiler to allow non-interactive dependency builds
- Working MPI distribution to run target applications

Care must be taken as the oneAPI version number does not say anything useful
about the components provided.  It is believed that the following constraints
are worth trying:

1. Intel MPI newer than 2021.5
2. Intel Classic Fortran Compiler newer than 2022.0.2 (older work, though have
   internal compiler errors under some settings with 2021.4 and 2021.5)

## Move to a Newer OS Version

Once a method aside from building on the official image is identified, the base
image needs to be walked forward as far as possible to have as many security
fixes applied as possible.  While Ubuntu 18.04 still receives maintenance
updates (as of April 2022), it will transition to Extended Security Maintenance
(ESM) in 2023.

## Extract a "Working" Environment via Multi-Stage Build Process

It may be possible to use the official image as part of a multi-stage build
process and crudely copy portions of the official image into the derived image.
