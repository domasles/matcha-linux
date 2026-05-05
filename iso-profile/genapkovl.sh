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

if [ -d "$WORKSPACE/rootfs" ]; then
    cp -a "$WORKSPACE/rootfs/." "$TMP/"
fi

if command -v dconf >/dev/null 2>&1; then
    mkdir -p "$TMP/etc/dconf/db"
    dconf compile "$TMP/etc/dconf/db/local" "$TMP/etc/dconf/db/local.d/" 2>/dev/null || true
fi

if command -v git >/dev/null 2>&1; then
    mkdir -p "$TMP/etc/skel"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$TMP/etc/skel/.oh-my-zsh" 2>/dev/null || true
    chmod -R 755 "$TMP/etc/skel/.oh-my-zsh" 2>/dev/null || true
fi

mkdir -p "$TMP/home/matcha"
cp -a "$TMP/etc/skel/." "$TMP/home/matcha/" 2>/dev/null || true

chown -R 1000:1000 "$TMP/home/matcha" 2>/dev/null || true
chmod 0440 "$TMP/etc/doas.conf" 2>/dev/null || true

echo "$HOSTNAME" > "$TMP"/etc/hostname

rc_add udev-trigger sysinit
rc_add udev-settle sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit
rc_add devfs sysinit
rc_add dmesg sysinit
rc_add udev sysinit

rc_add dbus boot
rc_add sysctl boot
rc_add syslog boot
rc_add cgroups boot
rc_add hwclock boot
rc_add modules boot
rc_add bootmisc boot
rc_add hostname boot

rc_add udev-postmount default
rc_add networkmanager default
rc_add elogind default
rc_add gdm default

tar -C "$TMP" -c . | gzip -9 > "$HOSTNAME.apkovl.tar.gz"
