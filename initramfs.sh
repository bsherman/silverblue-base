#!/usr/bin/bash

set -oue pipefail

# Remove nvidia specific files
if [[ "${IMAGE_FLAVOR}" =~ "nvidia" || ${COREOS_TYPE} =~ "nvidia" ]]; then
  rm -f /usr/lib/modprobe.d/nvk.conf
  rm -f /usr/lib/modprobe.d/amd-legacy.conf
else
  rm -f /usr/lib/dracut/dracut.conf.d/*nvidia.conf
  rm -f /usr/lib/modprobe.d/nvidia*.conf
fi

if [[ "${AKMODS_FLAVOR}" == "surface" ]]; then
    KERNEL_SUFFIX="surface"
else
    KERNEL_SUFFIX=""
fi

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"