#!/bin/bash

set -ouex pipefail

curl https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

# Nvidia for gts/stable - nvidia
if [[ "${NVIDIA_TYPE}" == "nvidia" ]]; then
    curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/hwe/main/nvidia-install.sh && \
    chmod +x /tmp/nvidia-install.sh && \
    IMAGE_NAME="${BASE_IMAGE_NAME}" RPMFUSION_MIRROR="" /tmp/nvidia-install.sh
    rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
fi

# Everyone
rpm-ostree install \
    /tmp/akmods/kmods/*xone*.rpm \
    /tmp/akmods/kmods/*xpadneo*.rpm \
    /tmp/akmods/kmods/*openrazer*.rpm
#    /tmp/akmods/kmods/*v4l2loopback*.rpm

# ZFS for gts/stable
if [[ ${AKMODS_FLAVOR} =~ "coreos" ]]; then
    rpm-ostree install pv /tmp/akmods-zfs/kmods/zfs/*.rpm
    depmod -a -v "${KERNEL}"
    echo "zfs" > /usr/lib/modules-load.d/zfs.conf
fi
