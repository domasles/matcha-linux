#!/bin/sh
set -e

WORKSPACE=${WORKSPACE:-$(pwd)}
HOSTNAME="matcha"
TMP=$(mktemp -d)

trap "rm -rf $TMP" EXIT

rc_add() {
    mkdir -p "$TMP"/etc/runlevels/"$2"
    ln -sf /etc/init.d/"$1" "$TMP"/etc/runlevels/"$2"/"$1"
}

if [ -d "$WORKSPACE/rootfs/etc" ]; then
    cp -a "$WORKSPACE/rootfs/etc/." "$TMP/etc/"
fi

echo "$HOSTNAME" > "$TMP"/etc/hostname

rc_add hwdrivers sysinit
rc_add modloop sysinit
rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit

rc_add sysctl boot
rc_add syslog boot
rc_add hwclock boot
rc_add modules boot
rc_add bootmisc boot
rc_add hostname boot

rc_add networkmanager default
rc_add gdm default

tar -C "$TMP" -c . | gzip -9 > "$HOSTNAME.apkovl.tar.gz"
