#!/usr/bin/env bash

set -eux

SERVICE_DIR="$( cd "$(dirname $0)/.." && echo ${PWD} )"
: ${SERVICE:=$(basename $SERVICE_DIR)}
: ${IMAGE:=asssaf/${SERVICE}}
: ${TCZ:=${SERVICE}.tcz}

docker build --build-arg TCZ=${TCZ} -t ${IMAGE} -f docker/Dockerfile --output build . "$@"
