#!/bin/sh
set -e

WORKSPACE=${WORKSPACE:-$(pwd)}
HOSTNAME="matcha"
TMP=$(mktemp -d)

EXT_DIR="$TMP"/usr/share/gnome-shell/extensions
EXT_LIST="$WORKSPACE"/iso-profile/config/extensions.json
PERM_LIST="$WORKSPACE"/iso-profile/config/permissions.json

trap "rm -rf '$TMP'" EXIT

rc_add() {
    mkdir -p "$TMP"/etc/runlevels/"$2"
    ln -sf /etc/init.d/"$1" "$TMP"/etc/runlevels/"$2"/"$1"
}

if [ -d "$WORKSPACE"/rootfs ]; then
    cp -a "$WORKSPACE"/rootfs/. "$TMP"/
fi

if command -v dconf >/dev/null 2>&1; then
    for dir in "$TMP"/etc/dconf/db/*.d/; do
        [ -d "$dir" ] || continue
        dbname="${dir%.d/}"
        dconf compile "$dbname" "$dir" 2>/dev/null || true
    done
fi

if command -v git >/dev/null 2>&1; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$TMP"/etc/skel/.oh-my-zsh 2>/dev/null || true
    chmod -R 755 "$TMP"/etc/skel/.oh-my-zsh 2>/dev/null || true
fi

mkdir -p "$EXT_DIR"

if [ -f "$EXT_LIST" ]; then
    jq -r '.[] | "\(.uuid) \(.url)"' "$EXT_LIST" | while IFS=' ' read -r uuid url; do
        tmpzip=$(mktemp /tmp/ext-XXXXXX)

        wget -q -O "$tmpzip" "$url"
        unzip -q "$tmpzip" -d "$EXT_DIR"/"$uuid"

        if [ -d "$EXT_DIR"/"$uuid"/schemas ]; then
            glib-compile-schemas "$EXT_DIR"/"$uuid"/schemas
        fi

        rm "$tmpzip"
    done
fi

mkdir -p "$TMP"/home/matcha
cp -a "$TMP"/etc/skel/. "$TMP"/home/matcha/ 2>/dev/null || true

chown -R 1000:1000 "$TMP"/home/matcha 2>/dev/null || true

if [ -f "$PERM_LIST" ]; then
    jq -r '.[] | "\(.path) \(.mode) \(.owner) \(.group)"' "$PERM_LIST" | while IFS=' ' read -r path mode owner group; do
        for target in $(find "$TMP" -path "$TMP$path" 2>/dev/null | sed "s|^$TMP||"); do
            [ -e "$TMP$target" ] || continue
            chmod "$mode" "$TMP$target" 2>/dev/null || true
            chown "$owner":"$group" "$TMP$target" 2>/dev/null || true
        done
    done
fi

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

rc_add apk-polkit-server default
rc_add networkmanager default
rc_add udev-postmount default
rc_add elogind default
rc_add gdm default

tar -C "$TMP" -c . | gzip -9 > "$HOSTNAME".apkovl.tar.gz
