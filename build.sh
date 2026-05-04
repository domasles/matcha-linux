#!/bin/sh
set -e

ALPINE_VERSION="3.23"
MATCHA_VERSION="v26.05.04"

WORKSPACE=$(pwd)
APORTS="$HOME/aports"

if [ "$(id -u)" -eq 0 ]; then
    apk update
    apk add --no-cache alpine-sdk xorriso squashfs-tools syslinux grub-efi mtools mkinitfs git sudo alpine-conf nodejs

    if ! id builduser >/dev/null 2>&1; then
        adduser -D builduser
        adduser builduser abuild

        echo "builduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builduser
    fi

    chown -R builduser:abuild "$WORKSPACE"
    mkdir -p /out
    chown -R builduser:abuild /out

    exec su - builduser -c "cd $WORKSPACE && WORKSPACE=$WORKSPACE sh $0"
fi

if [ ! -f "$HOME/.abuild/"*.rsa ]; then
    abuild-keygen -a -n
    sudo cp "$HOME"/.abuild/*.rsa.pub /etc/apk/keys/
fi

if [ ! -d "$APORTS" ]; then
    git clone --depth 1 --branch $ALPINE_VERSION-stable https://gitlab.alpinelinux.org/alpine/aports.git "$APORTS"
fi

cp "$WORKSPACE/iso-profile/mkimg.matcha.sh" "$APORTS/scripts/"
cp "$WORKSPACE/iso-profile/genapkovl.sh" "$APORTS/scripts/"

chmod +x "$APORTS/scripts/mkimg.matcha.sh"
chmod +x "$APORTS/scripts/genapkovl.sh"

cd "$APORTS/scripts"
. mkimg.matcha.sh

sh mkimage.sh \
    --outdir /out \
    --repository https://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/main \
    --repository https://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/community \
    --profile matcha \
    --tag $MATCHA_VERSION
