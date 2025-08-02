FROM debian AS extract

RUN apt update
RUN apt install -y cpio 7zip curl

ARG PACKAGE="piCore64"
ARG VERSION="16.0.0"
ARG VERSION_ROOTFS="16.0"
ARG VERSION_FAMILY="16.x"
ARG ARCH="aarch64"
ARG _7Z="7zz"

ENV PACKAGE_VERSION="${PACKAGE}-${VERSION}"
RUN curl -sLo "/${PACKAGE_VERSION}.img.gz" "http://tinycorelinux.net/${VERSION_FAMILY}/${ARCH}/release/RPi/${PACKAGE_VERSION}.img.gz"

RUN $_7Z x "${PACKAGE_VERSION}.img.gz"
RUN $_7Z x "${PACKAGE_VERSION}.img"

RUN ( mkdir fat \
        && cd fat \
        && 7zz x ../0.fat )

RUN ( mkdir rootfs \
        && cd rootfs \
        && zcat ../fat/rootfs-${PACKAGE}-${VERSION_ROOTFS}.gz | cpio -idv )

RUN $_7Z x 1.img
RUN mv /tce rootfs/etc/sysconfig/tcedir

RUN ( cd rootfs \
        && tar xvzf etc/sysconfig/tcedir/mydata.tgz )


FROM scratch AS install

COPY --from=extract rootfs/ /

RUN chown -R tc /etc/sysconfig/tcedir

ARG KERNEL=6.12.25-piCore-v8

RUN rm /bin/uname && echo "echo $KERNEL" > /bin/uname && chmod +x /bin/uname

RUN for EXT in net-usb-KERNEL usb-serial-KERNEL; \
        do \
                su -l tc -c "tce-load -w $EXT" ; \
                echo "$EXT" >> /etc/sysconfig/tcedir/onboot.lst ; \
        done

#TODO filetool doesn't work because it looks for a mounted device
#RUN sudo filetool.sh -d

RUN ( mkdir /tmp/mydata \
        && cd /tmp/mydata \
        && tar xvzf /etc/sysconfig/tcedir/mydata.tgz \
        && sed -i -e 's|# \(/usr/sbin/startserialtty &\)|\1|' opt/bootlocal.sh \
        && tar cvzf /etc/sysconfig/tcedir/mydata.tgz . )


FROM scratch AS mydata

COPY --from=install /etc/sysconfig/tcedir/mydata.tgz /


FROM scratch AS tce

COPY --from=install /etc/sysconfig/tcedir /tce
