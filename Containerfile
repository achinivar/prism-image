# Prism OS - https://github.com/achinivar/prism-os

#ARG is the equivalent of ENV or defines passed to the build process
ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/silverblue:44

# Allow build scripts to be referenced without being copied into the final image
# The below "FROM" line creates a named build "stage" called "ctx" from an empty image (scratch), 
# then copies repo files into it so later stages can bind-mount them during the main RUN
FROM scratch AS ctx
# NOTE - Use the /ctx prefix to access the copied over files in the RUN command below
COPY build_files /build_files
COPY sys_files /sys_files
# TODO: packages.json should contain lists of RPM packages to install or remove
#COPY packages.json /packages.json

# Base Image
FROM ${BASE_IMAGE}

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

#The first mount command binds the "ctx" stage that we created earlier to the root of the image, 
# - This makes the copied over files visible to the RUN command from /ctx/
#The second mount command creates a persistent build cache across runs (not saved into the final image).
# - dnf downloads RPMs here. Reusing this cache makes rebuilds much faster.
#The third mount command creates a log directory
# - Package installs write logs here; caching avoids redoing that work and keeps the build step cleaner.
#The fourth mount command creates a temporary directory of type tmpfs, this is erased after the build is complete.
# - Scripts use /tmp for short-lived work. RAM is fast, and nothing leftover in /tmp gets baked into the image.
#The fifth mount command runs the build.sh script

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh && \
    /ctx/build_files/post_build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
