#!/usr/bin/env bash

set -euxo pipefail

: ${BASE:=./}
: ${KERNEL_VERSION:=6.18.28}
: ${PACKAGE:=piCore64}
: ${PICORE_VERSION_MAJOR:=17}
: ${PICORE_VERSION_MINOR=0}
: ${PICORE_VERSION_MICRO=0}
: ${ROOTFS_SUFFIX:=zst}
: ${CPU:=max}
: ${SMP:=4}
: ${MEM:=2G}

KERNEL="${BASE}/Image-${KERNEL_VERSION}"
INITRD="${BASE}/rootfs-${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.${ROOTFS_SUFFIX}"
IMAGE="${BASE}/firmware-with-tce-disk-${PACKAGE}.img"
CMDLINE="console=ttyAMA0,115200 console=ttyGS0,115200 text root=/dev/ram0 nortc rootwait loglevel=3 tce=LABEL=RECOVERY tz=PST+8PDT,M3.2.0/2,M11.1.0/2 debug=y nozswap"
qemu-system-aarch64 -machine virt -cpu ${CPU} -smp ${SMP} -m ${MEM} \
	-kernel "$KERNEL" -append "$CMDLINE" \
	-initrd "$INITRD" \
	-nographic \
	-drive "format=raw,file=$IMAGE,if=none,id=hd0,cache=writeback,media=disk" \
	-device virtio-blk,drive=hd0,bootindex=0 \
	-netdev user,id=mynet,hostfwd=tcp::2223-:22 \
	-device virtio-net-pci,netdev=mynet \
	-monitor telnet:127.0.0.1:5555,server,nowait
