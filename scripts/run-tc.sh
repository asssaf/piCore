#!/usr/bin/env bash

set -euxo pipefail

: ${BASE:=./}
: ${KERNEL_VERSION:=6.18.28}
: ${PACKAGE:=piCore64}
: ${PICORE_VERSION_MAJOR:=17}
: ${PICORE_VERSION_MINOR=0}
: ${PICORE_VERSION_MICRO=0}
: ${ROOTFS_SUFFIX:=zst}

: ${KERNEL:="${BASE}/Image-${KERNEL_VERSION}"}
: ${INITRD:="${BASE}/rootfs-${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.${ROOTFS_SUFFIX}"}
: ${IMAGE:="${BASE}/firmware-with-tce-disk-${PACKAGE}.img"}
: ${CMDLINE:="console=ttyAMA0,115200 console=ttyGS0,115200 text root=/dev/ram0 nortc rootwait loglevel=3 tce=LABEL=RECOVERY tz=PST+8PDT,M3.2.0/2,M11.1.0/2 debug=y nozswap"}

export KERNEL INITRD IMAGE CMDLINE

$(dirname $0)/run.sh
