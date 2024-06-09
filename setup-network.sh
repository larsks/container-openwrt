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

default_gw=$(ip route show | awk '$1 == "default" {print $3}')

if ! ip -d link show eth0 | grep -q bridge_slave; then
	move_address_to_bridge eth0 br-eth0
fi

if ! ip -d link show eth1 | grep -q bridge_slave; then
	move_address_to_bridge eth1 br-eth1
fi

if [ -n "$default_gw" ] && ! ip route | grep -q '^default'; then
	ip route add default via "$default_gw"
fi

gw_bridge=$(ip route show | awk '$1 == "default" {print $5}')

case $gw_bridge in
br-eth0) cluster_bridge=br-eth1 ;;
br-eth1) cluster_bridge=br-eth0 ;;
esac

if ! ip link show wrtx >/dev/null 2>&1; then
	ip tuntap add mode tap name wrtx
	ip link set master "$gw_bridge" wrtx
	ip link set wrtx up
fi

if ! ip link show wrti >/dev/null 2>&1; then
	ip tuntap add mode tap name wrti
	ip link set master "$cluster_bridge" wrti
	ip link set wrti up
fi
