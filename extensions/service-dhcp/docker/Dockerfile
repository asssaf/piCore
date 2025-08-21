# syntax=docker/dockerfile-upstream:master
FROM debian:stable AS build

RUN apt-get update \
        && apt-get install -y squashfs-tools make \
        && apt-get clean

ARG TCZ
WORKDIR /${TCZ}
COPY Makefile .
COPY extension extension

RUN make OUTPUT_DIR=/tcz


FROM scratch AS export

ARG TCZ

COPY --from=build /tcz/* /
