#!/usr/bin/env bash

set -euxo pipefail

: ${BASE:=./}
: ${KERNEL_VERSION:=6.18.28}
: ${KERNEL:="${BASE}/Image-${KERNEL_VERSION}"}
: ${INITRD:=""}
: ${CMDLINE:=""}
: ${CPU:=max}
: ${SMP:=4}
: ${MEM:=2G}
: ${SSH_PORT:=2223}
: ${TELNET_PORT:=5555}

case ${INITRD} in
	*" "*)
		IFS=' ' read -r -a SPLIT_INITRD <<< "$INITRD"
		TMP_INITRD="$(mktemp foo.XXXXXX)"
		cat "${SPLIT_INITRD[@]}" > "$TMP_INITRD"
		INITRD="${TMP_INITRD}"
	;;
esac


qemu-system-aarch64 -machine virt -cpu ${CPU} -smp ${SMP} -m ${MEM} \
	-kernel "$KERNEL" -append "$CMDLINE" \
	${INITRD:+-initrd ${INITRD}} \
	-nographic \
	-drive "format=raw,file=$IMAGE,if=none,id=hd0,cache=writeback,media=disk" \
	-device virtio-blk,drive=hd0,bootindex=0 \
	-netdev user,id=mynet,hostfwd=tcp::${SSH_PORT}-:22 \
	-device virtio-net-pci,netdev=mynet \
	-monitor telnet:127.0.0.1:${TELNET_PORT},server,nowait


if [ -n "${TMP_INITRD}" ]
then
	rm "${TMP_INITRD}"
fi
