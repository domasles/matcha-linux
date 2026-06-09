#!/bin/sh
set -e

TMP=$(mktemp -d)

EXT_DIR="$TMP/usr/share/gnome-shell/extensions"
EXT_LIST="$WORKSPACE/iso-profile/config/extensions.json"
PERM_LIST="$WORKSPACE/iso-profile/config/permissions.json"

trap "rm -rf '$TMP'" EXIT
try() { "$@" 2>/dev/null || true; }

rc_add() {
    mkdir -p "$TMP/etc/runlevels/$2"
    ln -sf "/etc/init.d/$1" "$TMP/etc/runlevels/$2/$1"
}

apply_perms() {
    _path="$1" _mode="$2" _owner="$3" _group="$4" _recursive="$5"

    if [ "$_recursive" = "true" ]; then
        try find "$TMP$_path"
    else
        try find "$TMP$_path" -maxdepth 0
    fi | while IFS= read -r _abs; do
        [ -e "$_abs" ] || continue
        try chmod "$_mode" "$_abs"

        [ -d "$_abs" ] && try chmod +X "$_abs"
        try chown "$_owner:$_group" "$_abs"
    done
}

# Overlay rootfs
if [ -d "$WORKSPACE/rootfs" ]; then
    cp -a "$WORKSPACE/rootfs"/. "$TMP/"
fi

sudo cp "$CHROOT/etc/passwd" "$TMP/etc/passwd"
sudo cp "$CHROOT/etc/group" "$TMP/etc/group"
sudo cp "$CHROOT/etc/shadow" "$TMP/etc/shadow"

sudo chown builduser "$TMP/etc/passwd" "$TMP/etc/group" "$TMP/etc/shadow"

echo "$HOSTNAME" > "$TMP/etc/hostname"

# Compile dconf databases if present
if command -v dconf >/dev/null 2>&1; then
    for dir in "$TMP/etc/dconf/db/"*.d; do
        [ -d "$dir" ] || continue
        dbname="$(dirname "$dir")/$(basename "$dir" .d)"
        try dconf compile "$dbname" "$dir"
    done
fi

if command -v git >/dev/null 2>&1; then
    try git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$TMP/etc/skel/.oh-my-zsh"
fi

# GNOME Shell extensions
mkdir -p "$EXT_DIR"

if [ -f "$EXT_LIST" ]; then
    jq -r '.[] | "\(.uuid) \(.url)"' "$EXT_LIST" | while IFS=' ' read -r uuid url; do
        tmpdir=$(mktemp -d /tmp/ext-XXXXXX)

        if ! wget -q -O "$tmpdir/ext.zip" "$url"; then
            rm -rf "$tmpdir"
            continue
        fi

        if ! unzip -q "$tmpdir/ext.zip" -d "$tmpdir/extracted"; then
            rm -rf "$tmpdir"
            continue
        fi

        metadata_path=$(find "$tmpdir/extracted" -name "metadata.json" | head -n1)

        if [ -n "$metadata_path" ]; then
            mkdir -p "$EXT_DIR/$uuid"
            cp -r "$(dirname "$metadata_path")/." "$EXT_DIR/$uuid/"
        fi

        [ -d "$EXT_DIR/$uuid/schemas" ] && glib-compile-schemas "$EXT_DIR/$uuid/schemas"

        rm -rf "$tmpdir"
    done
fi

mkdir -p "$TMP/home/matcha"
try cp -a "$TMP/etc/skel/." "$TMP/home/matcha/"

# Apply permissions from permissions.json
if [ -f "$PERM_LIST" ]; then
    jq -r '.[] | "\(.path) \(.mode) \(.owner) \(.group) \(.recursive // false)"' "$PERM_LIST" | while IFS=' ' read -r path mode owner group recursive; do
        apply_perms "$path" "$mode" "$owner" "$group" "$recursive"
    done
fi

# OpenRC runlevels
# sysinit
rc_add devfs        sysinit
rc_add dmesg        sysinit
rc_add udev         sysinit
rc_add udev-trigger sysinit
rc_add udev-settle  sysinit
rc_add hwdrivers    sysinit
rc_add modloop      sysinit

# boot
rc_add dbus     boot
rc_add swap     boot
rc_add sysctl   boot
rc_add syslog   boot
rc_add cgroups  boot
rc_add hwclock  boot
rc_add modules  boot
rc_add bootmisc boot
rc_add hostname boot

# default
rc_add apk-polkit-server default
rc_add networkmanager    default
rc_add udev-postmount    default
rc_add elogind           default
rc_add gdm               default

tar -C "$TMP" -c . | gzip -9 > "$HOSTNAME.apkovl.tar.gz"
