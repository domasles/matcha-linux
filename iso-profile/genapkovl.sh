#!/bin/sh
set -e

WORKSPACE=${WORKSPACE:-$(pwd)}
HOSTNAME="matcha"
TMP=$(mktemp -d)

trap "rm -rf $TMP" EXIT

mkdir -p "$TMP"/etc
mkdir -p "$TMP"/etc/runlevels/default
mkdir -p "$TMP"/etc/runlevels/sysinit
mkdir -p "$TMP"/etc/runlevels/boot

if [ -d "$WORKSPACE/rootfs/etc" ]; then
    cp -a "$WORKSPACE/rootfs/etc/." "$TMP/etc/"
fi

echo "$HOSTNAME" > "$TMP"/etc/hostname

ln -sf /etc/init.d/hwdrivers "$TMP"/etc/runlevels/sysinit/hwdrivers
ln -sf /etc/init.d/modloop "$TMP"/etc/runlevels/sysinit/modloop
ln -sf /etc/init.d/devfs "$TMP"/etc/runlevels/sysinit/devfs
ln -sf /etc/init.d/dmesg "$TMP"/etc/runlevels/sysinit/dmesg
ln -sf /etc/init.d/mdev "$TMP"/etc/runlevels/sysinit/mdev

ln -sf /etc/init.d/sysctl "$TMP"/etc/runlevels/boot/sysctl
ln -sf /etc/init.d/syslog "$TMP"/etc/runlevels/boot/syslog
ln -sf /etc/init.d/hwclock "$TMP"/etc/runlevels/boot/hwclock
ln -sf /etc/init.d/modules "$TMP"/etc/runlevels/boot/modules
ln -sf /etc/init.d/bootmisc "$TMP"/etc/runlevels/boot/bootmisc
ln -sf /etc/init.d/hostname "$TMP"/etc/runlevels/boot/hostname

tar -C "$TMP" -c . | gzip -9 > "$HOSTNAME.apkovl.tar.gz"
