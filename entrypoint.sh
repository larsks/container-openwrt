#!/bin/bash

setup-network

if [[ $1 = "bash" ]]; then
	exec /bin/bash
else
	exec run-openwrt "$@"
fi
