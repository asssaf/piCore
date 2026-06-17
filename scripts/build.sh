#!/usr/bin/env bash

set -eux

: ${PACKAGE:=piCore64}
: ${PICORE_VERSION_MAJOR:=16}
: ${PICORE_VERSION_MINOR:=0}
: ${PICORE_VERSION_MICRO:=0}
: ${PLATFORM:=linux/arm64/v8}
: ${TARGET:=install}
: ${IMAGE:=asssaf/picore}
: ${TCEMIRROR:=}

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
    --build-arg TCEMIRROR=${TCEMIRROR} \
    -t ${IMAGE} \
    -f docker/Dockerfile "$@" .
