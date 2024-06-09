Run virtualized openwrt in a container.

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

## Bumps in the road

The stock openwrt image has a minimal amount of free space available:

```
root@(none):/dev# df -h /
Filesystem                Size      Used Available Use% Mounted on
/dev/root               102.3M     16.6M     83.6M  17% /
```

Typically, it would be trivial to resize this to the size of the underlying device by using `resize2fs`, but because openwrt (as of version 23.05.3) [uses the buggy `make_ext4fs`](https://github.com/openwrt/openwrt/issues/7729#issuecomment-1551950744) tool to generate the root filesystem, you need to perform some repair work first:

```
opkg install tune2fs resize2fs
mount -o remount,ro /
tune2fs -O^resize_inode /dev/vda
e2fsck -y -f /dev/vda
reboot
```

After the reboot completes, you will be able to resize the filesystem normally:

```
root@OpenWrt:/dev# resize2fs /dev/vda
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/vda is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/vda is now 131072 (4k) blocks long.
```
