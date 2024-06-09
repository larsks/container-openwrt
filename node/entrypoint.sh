#!/bin/sh

ssh-keygen -A

if [ -n "$DEFAULT_GATEWAY" ]; then
	ip route replace default via "$DEFAULT_GATEWAY"
fi

exec "$@"
