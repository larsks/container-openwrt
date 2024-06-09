#!/bin/bash

set -ex

default_iface=$(ip route | awk '$1 == "default" {print $5}')
default_gateway=$(ip route | awk '$1 == "default" {print $3}')

subnet_counter=0
for path in /sys/class/net/eth*; do
	subnet_tag="subnet$((subnet_counter++))"
	conf="/etc/dnsmasq.d/${subnet_tag}.conf"
	iface=${path##*/}
	addr=$(ip -4 addr show "$iface" | awk '$1 == "inet" {print $2}')
	[[ -z "$addr" ]] && continue

	. <(ipcalc -mn "$addr")

	netpart=${NETWORK%.*}
	hostpart=${NETWORK##*.}
	start_addr="${netpart}.$((hostpart + 10))"
	end_addr="${netpart}.$((hostpart + 40))"

	echo "dhcp-range=$subnet_tag,$start_addr,$end_addr,$NETMASK" >"$conf"

	if [[ $iface == $default_iface ]]; then
		echo "dhcp-option=$subnet_tag,option:router,$default_gateway" >>"$conf"
	fi
done

iptables -t nat -A POSTROUTING -o "$default_iface" -j MASQUERADE

exec "$@"
