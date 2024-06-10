#!/bin/bash

set -eu

cat >/etc/dnsmasq.d/wan.conf <<EOF
dhcp-range=wan,$DHCP_RANGE_START,$DHCP_RANGE_END,$DHCP_NETMASK
dhcp-option=wan,option:router,$DEFAULT_GATEWAY
EOF

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

exec "$@"
