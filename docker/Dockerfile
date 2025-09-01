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
RUN touch /tce/copy2fs.flg
RUN mv /tce rootfs/etc/sysconfig/tcedir

RUN ( cd rootfs \
        && tar xvzf etc/sysconfig/tcedir/mydata.tgz )

RUN ( cd rootfs \
        && $_7Z x etc/sysconfig/tcedir/optional/openssl.tcz \
        && $_7Z x etc/sysconfig/tcedir/optional/ca-certificates.tcz )

# customize config.txt and cmdline.txt
COPY config.txt.extra /
RUN cat config.txt.extra >> /fat/config.txt
RUN sed -i /fat/cmdline.txt \
	-e 's| console=tty1 | console=ttyAMA0,115200 console=ttyGS0,115200 |' \
	-e 's| quiet | |' \
	-e 's|$| tce=LABEL=RECOVERY|'


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

RUN for EXT in net-usb-KERNEL usb-serial-KERNEL usb-gadget-KERNEL wpa_supplicant wireless_tools wireless-KERNEL firmware-rpi-wifi iw hostapd iptables; \
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

COPY --from=extensions /tcz/* /etc/sysconfig/tcedir/optional/
RUN ( \
	for EXT in service-serial service-wifi service-dhcp service-dhcpd service-hostapd recovery service-gadget firewall; \
	do \
		echo "${EXT}.tcz" >> /etc/sysconfig/tcedir/onboot.lst ; \
	done \
)

RUN ln -s /etc/sysconfig/tcedir/ /mnt/nfs
RUN filetool.sh -b nfs || cat /tmp/backup_status


FROM scratch AS mydata

COPY --from=install /etc/sysconfig/tcedir/mydata.tgz /


FROM scratch AS tce

COPY --from=install /etc/sysconfig/tcedir /tce


FROM scratch AS firmware-with-tce

COPY --from=extract /fat /
COPY --from=tce /tce /tce


FROM scratch AS rootfs

ARG PACKAGE
ARG PICORE_VERSION_MAJOR
ARG PICORE_VERSION_MINOR

COPY --from=extract /fat/rootfs-${PACKAGE}-${PICORE_VERSION_MAJOR}.${PICORE_VERSION_MINOR}.gz /


FROM debian:bookworm AS build-images


RUN apt update
RUN apt install -y mtools parted
RUN apt install -y 7zip

COPY --from=extract 0.fat firmware-with-tce.img
COPY --from=install /etc/sysconfig/tcedir /tce

RUN mcopy -spQnmvi firmware-with-tce.img tce ::/tce
RUN mlabel -ni firmware-with-tce.img ::RECOVERY

RUN truncate -s 100M firmware-with-tce-disk.img
RUN parted -s firmware-with-tce-disk.img mklabel msdos mkpart primary fat16 2048s 100%
RUN dd if="firmware-with-tce.img" of=firmware-with-tce-disk.img bs=512 seek=2048


FROM scratch AS firmware-with-tce-image

COPY --from=build-images /firmware-with-tce.img /


FROM scratch AS firmware-with-tce-disk-image

COPY --from=build-images /firmware-with-tce-disk.img /
