Run virtualized openwrt (for the [malta] platform) in a container.

To start things up:

```
docker compose up -d
```

The initial network configuration is useless; to reach the openwrt console:

```
docker compose attach openwrt
```

When you're done, `^P^Q` to detach from the console.

[malta]: https://openwrt.org/docs/techref/targets/malta
