FROM --platform=linux/arm64 debian:latest AS deps

RUN apt update
RUN apt install -y curl 7zip git

ENV PACKAGE=$PACKAGE
ENV VERSION=$VERSION
ENV VERSION_ROOTFS=$VERSION_ROOTFS
ENV VERSION_FAMILY=$VERSION_FAMILY
ENV ARCH=$ARCH
ENV _7Z="7zz"

ADD scripts/install.sh /install.sh
RUN /install.sh
