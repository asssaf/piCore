#!/usr/bin/env bash

set -eux

: ${PACKAGE:=piCore64}
: ${PICORE_VERSION_MAJOR:=16}
: ${PICORE_VERSION_MINOR:=0}
: ${PICORE_VERSION_MICRO:=0}
: ${PLATFORM:=linux/arm64/v8}
: ${TARGET:=install}
: ${IMAGE:=asssaf/picore}

#docker run --privileged --rm tonistiigi/binfmt --install arm64

docker build --platform=${PLATFORM} --target=${TARGET} \
    --build-arg PACKAGE=${PACKAGE} \
    --build-arg PICORE_VERSION_MAJOR=${PICORE_VERSION_MAJOR} \
    --build-arg PICORE_VERSION_MINOR=${PICORE_VERSION_MINOR} \
    --build-arg PICORE_VERSION_MICRO=${PICORE_VERSION_MICRO} \
    -t ${IMAGE} \
    -f docker/Dockerfile "$@" .
