#!/bin/bash

: "${VIRT_IMAGE_PATH:=/virt}"

move_address_to_bridge() {
	iface=$1
	bridge=$2

	ip link add "$bridge" type bridge
	addr=$(ip -4 addr show "$iface" | awk '$1 == "inet" {print $2}')
	ip addr flush "$iface"
	ip link set "$iface" down
	ip link set "$iface" master "$bridge"
	ip addr add "$addr" dev "$bridge"
	ip link set "$iface" up
	ip link set "$bridge" up
}

set -eu

for path in /sys/class/net/eth*; do
	link=${path##*/}
	bridge="br-$link"
	echo "Attach link $link to $bridge"
	if ! ip -d link show "$link" | grep -q bridge_slave; then
		move_address_to_bridge "$link" "$bridge"
	fi
done

ip route replace default via "$DEFAULT_GATEWAY"

for path in /sys/class/net/br-eth*; do
	bridge=${path##*/}
	link=${bridge#br-}
	tap="wrt-$link"

	echo "Create tap device $tap attached to $bridge"
	if ! ip link show "$tap" >/dev/null 2>&1; then
		ip tuntap add mode tap name "$tap"
		ip link set master "$bridge" "$tap"
		ip link set "$tap" up
	fi
done
