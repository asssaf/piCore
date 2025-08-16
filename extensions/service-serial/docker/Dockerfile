# syntax=docker/dockerfile-upstream:master
FROM debian:stable AS build

RUN apt-get update \
        && apt-get install -y squashfs-tools \
        && apt-get clean

ARG TCZ
COPY extension /extension
RUN mksquashfs extension /${TCZ} -all-root -noappend

WORKDIR /
RUN unsquashfs -lc ${TCZ} | sed 's|^squashfs-root/||' > ${TCZ}.list
RUN md5sum ${TCZ} > ${TCZ}.md5.txt


FROM scratch AS export

ARG TCZ

COPY --from=build /${TCZ} /
COPY --from=build /${TCZ}.list /
COPY --from=build /${TCZ}.md5.txt /