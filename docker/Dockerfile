FROM debian:bookworm AS extract

RUN apt update
RUN apt install -y cpio 7zip curl

ARG PACKAGE
ARG PICORE_VERSION_MAJOR
ARG PICORE_VERSION_MINOR
ARG PICORE_VERSION_MICRO
ARG _7Z="7zz"

ENV ARCH="${PACKAGE/*piCore64*/aarch64}"
ENV ARCH="${ARCH/*piCore*/armhf}"
ENV PACKAGE_VERSION="${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.${PICORE_VERSION_MICRO}"

RUN curl -sLo "/${PACKAGE_VERSION}.img.gz" "http://tinycorelinux.net/${PICORE_VERSION_MAJOR}.x/${ARCH}/release/RPi/${PACKAGE_VERSION}.img.gz"

RUN $_7Z x "${PACKAGE_VERSION}.img.gz"
RUN $_7Z x "${PACKAGE_VERSION}.img"

RUN ( mkdir fat \
        && cd fat \
        && 7zz x ../0.fat )

RUN ( mkdir rootfs \
        && cd rootfs \
        && zcat ../fat/rootfs-${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.gz | cpio -idv )

RUN $_7Z x 1.img
RUN mv /tce rootfs/etc/sysconfig/tcedir

RUN ( cd rootfs \
        && tar xvzf etc/sysconfig/tcedir/mydata.tgz )

RUN ( cd rootfs \
        && $_7Z x etc/sysconfig/tcedir/optional/openssl.tcz \
        && $_7Z x etc/sysconfig/tcedir/optional/ca-certificates.tcz )


FROM debian:bookworm AS extensions

RUN apt-get update \
        && apt-get install -y squashfs-tools make \
        && apt-get clean

COPY extensions /extensions
RUN make -C /extensions OUTPUT_DIR=/tcz


FROM scratch AS install

COPY --from=extract rootfs/ /

RUN ldconfig

RUN chown -R tc /etc/sysconfig/tcedir
RUN chmod u+s /usr/bin/sudo

RUN usr/local/tce.installed/ca-certificates

ARG KERNEL=6.12.25-piCore-v8

RUN rm /bin/uname && echo -e "#!/bin/sh\necho $KERNEL" > /bin/uname && chmod +x /bin/uname

RUN for EXT in net-usb-KERNEL usb-serial-KERNEL; \
        do \
                su -l tc -c "tce-load -w $EXT" \
                && echo "${EXT}.tcz" >> /etc/sysconfig/tcedir/onboot.lst ; \
        done

# install external extensions
RUN ( \
        TCEMIRROR="$(cat /opt/tcemirror)"; \
        for EXT in tryboot busybox-system; \
        do \
                echo "https://github.com/asssaf/picore-${EXT}/raw/refs/heads/tcz-v0.0.1" > /opt/tcemirror \
                && su -l tc -c "tce-load -w $EXT" \
                && echo "${EXT}.tcz" >> /etc/sysconfig/tcedir/onboot.lst ; \
        done \
        && echo "$TCEMIRROR" > /opt/tcemirror \
)

COPY --from=extensions /tcz/service-serial.tcz /etc/sysconfig/tcedir/optional/
RUN echo "service-serial.tcz" >> /etc/sysconfig/tcedir/onboot.lst


RUN ln -s /etc/sysconfig/tcedir/ /mnt/nfs
RUN filetool.sh -b nfs || cat /tmp/backup_status


FROM scratch AS mydata

COPY --from=install /etc/sysconfig/tcedir/mydata.tgz /


FROM scratch AS tce

COPY --from=install /etc/sysconfig/tcedir /tce


FROM scratch AS firmware

COPY --from=extract /fat /
COPY --from=tce /tce /tce


FROM scratch AS rootfs

ARG PACKAGE
ARG PICORE_VERSION_MAJOR
ARG PICORE_VERSION_MINOR

COPY --from=extract /fat/rootfs-${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.gz /
