#!/usr/bin/env bash

set -euxo pipefail

PACKAGE_VERSION="${PACKAGE}-${VERSION}"
ROOTFS="rootfs-${PACKAGE}-${VERSION_ROOTFS}"
curl -sLo "${PACKAGE_VERSION}.img.gz" "http://tinycorelinux.net/${VERSION_FAMILY}/${ARCH}/release/RPi/${PACKAGE_VERSION}.img.gz"
$_7Z x "${PACKAGE_VERSION}.img.gz"
$_7Z x "${PACKAGE_VERSION}.img"
mkdir boot
cd boot
$_7Z x ../0.fat
cd ..
$_7Z x "boot/${ROOTFS}.gz"
mkdir rootfs
cd rootfs
sudo $_7Z x ../${ROOTFS} -snld '-x!var/tmp' '-x!etc/mtab' '-x!dev' '-x!var/spool/lpd/lp'

cat > install.sh <<EOF
set -euxo pipefail
mkdir home/tc
chown tc home/tc
su -l -c "tce-load -wi firmware-rpi-wifi" tc
EOF
chmod +x install.sh

sudo mkdir dev
sudo mount --bind /proc proc
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /tmp tmp 
sudo chroot . bin/sh -c ./install.sh
echo "Exited chroot"
