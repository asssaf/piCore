#!/usr/bin/env bash

set -euxo pipefail

: ${BASE:=./}
: ${KERNEL_VERSION:=6.12.25}
: ${PACKAGE:=piCore64}
: ${PICORE_VERSION_MAJOR:=16}
: ${PICORE_VERSION_MINOR=0}
: ${PICORE_VERSION_MICRO=0}

KERNEL="${BASE}/Image-${KERNEL_VERSION}"
INITRD="${BASE}/rootfs-${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.gz"
IMAGE="${BASE}/firmware-with-tce-disk.img"
CMDLINE="console=ttyAMA0,115200 text root=/dev/ram0 nortc rootwait loglevel=3 tce=vda1 debug=y getty=ttyAMA0 nozswap"
qemu-system-aarch64 -machine virt -cpu cortex-a72 -smp 2 -m 1G \
	-kernel "$KERNEL" -append "$CMDLINE" \
	-initrd "$INITRD" \
	-nographic \
	-drive "format=raw,file=$IMAGE,if=none,id=hd0,cache=writeback,media=disk" \
	-device virtio-blk,drive=hd0,bootindex=0 \
	-netdev user,id=mynet,hostfwd=tcp::2223-:22 \
	-device virtio-net-pci,netdev=mynet \
	-monitor telnet:127.0.0.1:5555,server,nowait
