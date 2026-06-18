#!/usr/bin/env bash

set -eux

: ${PACKAGE:=piCore64}
: ${PICORE_VERSION_MAJOR:=17}
: ${PICORE_VERSION_MINOR:=0}
: ${PICORE_VERSION_MICRO:=0}
: ${PICORE_VERSION_RC:=-beta1}
: ${PICORE_SUFFIX:=zip}
: ${ROOTFS_SUFFIX:=zst}
: ${PLATFORM:=linux/arm64/v8}
: ${TARGET:=install}
: ${IMAGE:=asssaf/picore}
: ${TCEMIRROR:=}
: ${KERNEL=6.18.28-piCore-v8}

if [ "$(uname -m)" = "x86_64" ]
then
    #docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    # need "flags: F" in /proc/sys/fs/binfmt_misc/qemu-${arch} so the image can run without copying qemu into the guest image
    if [ "$PACKAGE" = "piCore64" ]
    then
        BINFMT_PATH="/proc/sys/fs/binfmt_misc/qemu-aarch64"
    else
        BINFMT_PATH="/proc/sys/fs/binfmt_misc/qemu-arm"
    fi

    grep -q "flags: F" "$BINFMT_PATH" || { echo "need 'flags: F' in $BINFMT_PATH" >& 2; exit 1; }
fi

docker build --platform=${PLATFORM} --target=${TARGET} \
    --build-arg PACKAGE=${PACKAGE} \
    --build-arg PICORE_VERSION_MAJOR=${PICORE_VERSION_MAJOR} \
    --build-arg PICORE_VERSION_MINOR=${PICORE_VERSION_MINOR} \
    --build-arg PICORE_VERSION_MICRO=${PICORE_VERSION_MICRO} \
    --build-arg PICORE_VERSION_RC=${PICORE_VERSION_RC} \
    --build-arg PICORE_SUFFIX=${PICORE_SUFFIX} \
    --build-arg ROOTFS_SUFFIX=${ROOTFS_SUFFIX} \
    --build-arg TCEMIRROR=${TCEMIRROR} \
    --build-arg KERNEL=${KERNEL} \
    --network host \
    -t ${IMAGE} \
    -f docker/Dockerfile "$@" .
