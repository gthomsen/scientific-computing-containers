# base image to build against.  note that we do not supply a default to
# force the builder to make a choice.
ARG BASE_IMAGE

# build against the supplied base image.
FROM ${BASE_IMAGE}

# this Dockerfile builds an image on top of the supplied BASE_IMAGE base with
# the intent to provide additional development capabilities.  currently this
# includes tools needed for visualization and debugging distributed processing
# applications (via one X11 terminal running GDB for each process).
#
# it is intended that the base image be one of the scientific base images,
# though does not strictly require that.
#
# NOTE: we do not specify versions here since we do not know which image we're
#       building on!
#
# packages installed via apt:
#
#     Name               Purpose
#     ----               -------
#     emacs-nox          Terminal-based Emacs
#     mwm                Minimal window manager
#     strace             Trace system calls in applications
#     tightvncserver     VNC server
#     vim                Terminal-based Vim
#     xterm              Simple X11 terminal application
#     xfonts-*           Font dependencies required for VNC server


# installation tree.
ARG INSTALL_ROOT=/opt

# staging and build location.
ARG BUILD_ROOT=/tmp/build

# the number of subordinate jobs to launch during the build.  by default we use
# a single core unless the build process overrides this.
ARG NUMBER_JOBS=1

# password for accessing the VNC server.
#
# NOTE: this should be replaced with something secure if the VNC server is
#       is exposed outside of the container.  see vncpasswd(1) for details on
#       how.
#
ARG VNC_SERVER_PASSWORD="123456"

# create the build and installation roots.
RUN \
    mkdir -p ${BUILD_ROOT} && \
    mkdir -p ${INSTALL_ROOT}

# work out of the build root so we have a single location for build artifacts.
WORKDIR ${BUILD_ROOT}

# install tools for an improved quality of life when working with the container.
#
# at a high-level here are the motivations for each of the packages:
#
#   emacs-nox:               Terminal-based Emacs for editing files.  Also
#                            provides etags.
#   mwm:                     Motif Window Manager.  Simple windowing system
#                            to host graphical applications.
#   strace:                  trace system calls made by an application.
#   tightvncserver:          VNC server.
#   vim:                     Terminal-based Vim for editing files.  Also
#                            provides ctags.
#   xfonts-*:                X11 fonts for 75 and 100 DPI.  required for the VNC
#                            server to run since they're not installed by
#                            default with "--no-install-recommends".
#   xterm                    Simple X11 terminal.
#
RUN \
    apt update && \
    apt-get install -y --no-install-recommends \
                       emacs-nox \
                       mwm \
                       strace \
                       tightvncserver \
                       vim \
                       xterm \
                       xfonts-base xfonts-75dpi xfonts-100dpi \
                       && \
    rm -rf /var/lib/apt/lists/*

# configure the VNC server with a minimal setup as well as setting the default
# server password (see VNC_SERVER_PASSWORD above).  this runs the Motif window
# manager (mwm) and a single xterm on server start.
RUN \
    mkdir -p ${HOME}/.vnc && \
    /bin/echo -e '#!/bin/sh\nmwm &\nxterm &\n' > ${HOME}/.vnc/xstartup && \
    chmod +x ${HOME}/.vnc/xstartup && \
    echo "${VNC_SERVER_PASSWORD}" | vncpasswd -f > ${HOME}/.vnc/passwd && \
    chmod 600 ${HOME}/.vnc/passwd

# set the USER environment variable since TightVNC's server refuses to run
# when it does not exist.  it doesn't actually matter what we set it to,
# though we set it to the build user to be consistent with normal systems
# so as to not confuse applications that actually respect its value.
ENV USER=root

# provide a minimal Python3 environment for scientific applications.  this is
# enough to install upstream packages from PyPi for simple dependencies, though
# is not intended to be used for larger applications as Conda is the preferred
# approach (to be added in the future...).
RUN \
    apt update && \
    apt-get install -y --no-install-recommends \
                       python3-numpy \
                       python3-pip \
                       && \
    rm -rf /var/lib/apt/lists/*

# run from the user's home directory.  this doesn't really matter for run-times
# that are isolated, but is a creature comfort for those that do
# (e.g. Singularity).
WORKDIR ${HOME}
