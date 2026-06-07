# Prism OS - https://github.com/achinivar/prism-os

#ARG is the equivalent of ENV or defines passed to the build process
ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/silverblue:44

# Allow build scripts to be referenced without being copied into the final imagei
# The below "FROM" line creates a named build stage called ctx from an empty image (scratch), 
# then copies repo files into it so later stages can bind-mount them during the main RUN
FROM scratch AS ctx
# NOTE - Use the /ctx prefix to access the copied over files in the RUN command below
COPY build_files /ctx/build_files
COPY sys_files /sys_files
# TODO: packages.json should contain lists of RPM packages to install or remove
#COPY packages.json /packages.json

# Base Image
FROM ${BASE_IMAGE}

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
