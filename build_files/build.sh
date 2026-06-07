#!/bin/bash

#The set command below turns on strict bash mode for the script:
#-o u - error on unset variables
#-e - exit as soon as any command fails
#-x - print each command as it runs (useful in build logs)
#pipefail - a pipeline fails if any command in it fails, not just the last one
set -ouex pipefail

### Copy custom system files
# -r - copy directories recursively
# -v - verbose output
# -K - treat symlinked directories as real directories (safer when merging onto /)
rsync -rvK /ctx/sys_files/ /

# make root's home
# The custom root was used in the Universal Blue build script, so I've kept it here for now.
# The reason for this custom root is unknown, so commenting it out for now.
#mkdir -p /var/roothome

# Install dnf5 if not installed
if ! rpm -q dnf5 >/dev/null; then
    rpm-ostree install dnf5 dnf5-plugins
fi

# mitigate upstream packaging bug: https://bugzilla.redhat.com/show_bug.cgi?id=2332429
# swap the incorrectly installed OpenCL-ICD-Loader for ocl-icd, the expected package
# NOTE - Cursor's research tells me this issue should be fixed in Fedora 44, so commenting it out for now.
#dnf5 -y swap --repo='fedora' \
#    OpenCL-ICD-Loader ocl-icd

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# H.264 decode for Videos (GStreamer) and Firefox — patent licensing via Cisco OpenH264 (official Fedora repo)
dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 install -y \
    gstreamer1-plugin-openh264 \
    mozilla-openh264

# Repo definitions stay on disk from fedora-repos; only flip enable so future installs don't pull from Cisco by default.
dnf5 config-manager setopt fedora-cisco-openh264.enabled=0

# RPM Fusion: broad host-side codecs for Totem/VLC/ffmpeg-cli (HEVC/H.265, VC-1, AAC, MP3, MPEG variants,
# WMA-like stacks where packaged, etc.). OpenH264 above still helps browsers/GStreamer baseline H.264.
FEDORA_VER="$(rpm -E %fedora)"
dnf5 install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

# Fedora usually ships ffmpeg-free; swap to full FFmpeg from RPM Fusion Free. If names differ by release,
# installing ffmpeg with Fusion repos enabled still upgrades/replaces the Fedora build.
if rpm -q ffmpeg-free &>/dev/null; then
    dnf5 -y swap ffmpeg-free ffmpeg --allowerasing
else
    dnf5 -y install ffmpeg --allowerasing
fi

dnf5 install -y --skip-unavailable \
    libavcodec-freeworld \
    gstreamer1-libav \
    gstreamer1-plugins-ugly \
    lame-libs \
    libdvdcss

# Drop RPM Fusion release packages so repo definitions disappear; installed codec RPMs stay on the image.
# Users who want Fusion later can: dnf5 install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm …
dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Set up Flathub as the only Flatpak remote

# Remove Fedora's Flathub package — we set up Flathub manually (optional on some bases; don't fail the build)
dnf5 remove -y fedora-flathub-remote || true

# Download Flathub repo file directly
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Rename the service so nothing triggers Fedora's original flatpak setup on first boot.
# The custom service (already copied by rsync above) is now safely renamed.
mv -f /usr/lib/systemd/system/flatpak-add-flathub-repos.service /usr/lib/systemd/system/flatpak-add-fedora-repos.service

### Example for enabling a System Unit File
