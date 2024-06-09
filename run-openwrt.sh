#!/bin/bash

: "${VIRT_IMAGE_PATH:=/virt}"
: "${VIRT_STATE_PATH:=/state}"

set -e

if [[ -n $OPENWRT_DEBUG ]]; then
	set -x
fi

if ! [[ -f $VIRT_STATE_PATH/rootfs.img ]]; then
	echo "creating copy-on-write rootfs image"
	qemu-img create -b "$VIRT_IMAGE_PATH/rootfs.img" -F raw -f qcow2 "$VIRT_STATE_PATH/rootfs.img" 512m
fi

exec qemu-system-mips -nographic -m 256 \
	-kernel "${VIRT_IMAGE_PATH}"/vmlinux \
	-append "root=/dev/sda" \
	-drive file="$VIRT_STATE_PATH/rootfs.img",format=qcow2 \
	-nic user,hostfwd=tcp::22-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443 \
	-netdev tap,ifname=wrtx,id=wrtx,script=no,downscript=no \
	-device pcnet,netdev=wrtx \
	-netdev tap,ifname=wrti,id=wrti,script=no,downscript=no \
	-device pcnet,netdev=wrti \
	"$@"
