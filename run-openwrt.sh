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

exec qemu-system-x86_64 -M microvm -enable-kvm -nographic -m 1g \
	-kernel "${VIRT_IMAGE_PATH}"/vmlinux \
	-append "root=/dev/vda console=/dev/ttyS0,115200" \
	-drive file="$VIRT_STATE_PATH/rootfs.img",format=qcow2,id=vda \
	-device virtio-blk-device,drive=vda \
	-drive file="$VIRT_IMAGE_PATH/config.iso",format=raw,id=vdb,media=cdrom \
	-device virtio-blk-device,drive=vdb \
	-netdev user,id=admin,hostfwd=tcp::22-:22,hostfwd=tcp::80-:80,hostfwd=tcp::443-:443 \
	-device virtio-net-device,netdev=admin \
	-netdev tap,ifname=wrtx,id=wrtx,script=no,downscript=no \
	-device virtio-net-device,netdev=wrtx \
	-netdev tap,ifname=wrti,id=wrti,script=no,downscript=no \
	-device virtio-net-device,netdev=wrti \
	"$@"
