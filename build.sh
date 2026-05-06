#!/bin/sh
set -e

ALPINE_VERSION="3.23"
MATCHA_VERSION="26.05.06"

WORKSPACE=$(pwd)
APORTS="$HOME/aports"

if [ "$(id -u)" -eq 0 ]; then
    apk update
    apk add --no-cache alpine-sdk xorriso squashfs-tools \
        syslinux grub-efi mtools mkinitfs git doas dconf \
        alpine-conf nodejs unzip jq glib

    if ! id builduser >/dev/null 2>&1; then
        adduser -D builduser
        adduser builduser abuild

        echo "permit nopass builduser" > /etc/doas.conf
    fi

    chown -R builduser:abuild "$WORKSPACE"
    mkdir -p /out
    chown -R builduser:abuild /out

    exec su - builduser -c "cd '$WORKSPACE' && WORKSPACE='$WORKSPACE' sh '$0'"
fi

if [ ! -f "$HOME/.abuild/"*.rsa ]; then
    abuild-keygen -a -n
    doas cp "$HOME"/.abuild/*.rsa.pub /etc/apk/keys/
fi

if [ ! -d "$APORTS" ]; then
    git clone --depth 1 --branch "$ALPINE_VERSION-stable" https://gitlab.alpinelinux.org/alpine/aports.git "$APORTS"
fi

cp -a "$WORKSPACE"/iso-profile/. "$APORTS"/scripts/
chmod +x "$APORTS"/scripts/*.sh

cd "$APORTS"/scripts
source ./mkimg.matcha.sh

sh mkimage.sh \
    --outdir /out \
    --repository https://dl-cdn.alpinelinux.org/alpine/v"$ALPINE_VERSION"/main \
    --repository https://dl-cdn.alpinelinux.org/alpine/v"$ALPINE_VERSION"/community \
    --profile matcha \
    --tag "$MATCHA_VERSION"
