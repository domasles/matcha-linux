#!/bin/sh
set -e

ALPINE_VERSION="3.23"
MATCHA_VERSION="26.06.08"

ARCH="x86_64"
HOSTNAME="matcha"

WORKSPACE=$(pwd)

APORTS="$HOME/aports"
CHROOT="$APORTS/chroot"

INSTALLER_REPO="domasles/matcha-calamares"
INSTALLER_TAG="latest"
LOCAL_REPO="/tmp/local-repo"

trap "sudo rm -rf '$CHROOT'" EXIT

USER_GROUPS="audio input video kvm netdev plugdev seat"

if [ "$(id -u)" -eq 0 ]; then
    apk update
    apk add --no-cache alpine-sdk xorriso squashfs-tools \
        grub-efi mtools mkinitfs git sudo dconf \
        alpine-conf nodejs unzip jq glib curl

    if ! id builduser >/dev/null 2>&1; then
        adduser -D builduser
        adduser builduser abuild

        echo "builduser ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/builduser
    fi

    chown -R builduser:abuild "$WORKSPACE"
    mkdir -p /out
    chown -R builduser:abuild /out

    exec su - builduser -c "cd '$WORKSPACE' && \
        WORKSPACE='$WORKSPACE' APORTS='$APORTS' \
        CHROOT='$CHROOT' HOSTNAME='$HOSTNAME' sh '$0'"
fi

if [ ! -f "$HOME"/.abuild/*.rsa ]; then
    abuild-keygen -a -n
    sudo cp "$HOME"/.abuild/*.rsa.pub /etc/apk/keys/
fi

# Download Matcha Calamares packages and set up a local repository
PRIVKEY=$(echo "$HOME"/.abuild/*.rsa)
API_URL="https://api.github.com/repos/$INSTALLER_REPO/releases/$INSTALLER_TAG"
RELEASE_JSON=$(curl -fsSL -H "Accept: application/vnd.github+json" "$API_URL")

mkdir -p "$LOCAL_REPO"/"$ARCH"

for url in $(echo "$RELEASE_JSON" | jq -r '.assets[].browser_download_url'); do
    name="${url##*/}"

    case "$name" in
        *.apk)
            curl -fsSL -o "$LOCAL_REPO"/"$ARCH"/"$name" "$url" ;;
        *.rsa.pub)
            sudo curl -fsSL -o /etc/apk/keys/"$name" "$url" ;;
    esac
done

apk index -o "$LOCAL_REPO"/"$ARCH"/APKINDEX.tar.gz "$LOCAL_REPO"/"$ARCH"/*.apk
abuild-sign -k "$PRIVKEY" "$LOCAL_REPO"/"$ARCH"/APKINDEX.tar.gz

if [ ! -d "$APORTS" ]; then
    git clone --depth 1 --branch "$ALPINE_VERSION"-stable https://gitlab.alpinelinux.org/alpine/aports.git "$APORTS"
fi

mkdir -p "$CHROOT/etc/apk/keys"

sudo cp /etc/apk/keys/* "$CHROOT"/etc/apk/keys/
sudo cp /etc/apk/repositories "$CHROOT"/etc/apk/repositories

sudo apk add --root "$CHROOT" --initdb --no-cache alpine-base

sudo chroot "$CHROOT" /bin/sh -c "adduser -D -h /home/matcha -s /bin/zsh -G wheel -g 'Live User' -u 1000 matcha || true"
sudo chroot "$CHROOT" /bin/sh -c "for g in $USER_GROUPS; do addgroup -S \$g 2>/dev/null || true; done"
sudo chroot "$CHROOT" /bin/sh -c "for g in $USER_GROUPS; do addgroup matcha \$g 2>/dev/null || true; done"
sudo chroot "$CHROOT" /bin/sh -c "passwd -d matcha 2>/dev/null || true"

cp -a "$WORKSPACE"/iso-profile/. "$APORTS"/scripts/
chmod +x "$APORTS"/scripts/*.sh

cd "$APORTS"/scripts

sh mkimage.sh \
    --outdir /out \
    --repository "$LOCAL_REPO" \
    --repository https://dl-cdn.alpinelinux.org/alpine/v"$ALPINE_VERSION"/main \
    --repository https://dl-cdn.alpinelinux.org/alpine/v"$ALPINE_VERSION"/community \
    --profile matcha \
    --tag "$MATCHA_VERSION" \
    --hostkeys

# Disable Legacy BIOS boot
ISO="/out/matcha-linux-$MATCHA_VERSION-$ARCH.iso"

xorriso -indev "$ISO" \
    -outdev "$ISO" \
    -boot_image grub grub2_mbr=/dev/zero \
    -boot_image any discard \
    -boot_image any next \
    -boot_image grub efi_path=boot/grub/efi.img \
    -boot_image any platform_id=0xef \
    -boot_image any emul_type=no_emulation \
    -changes_pending yes \
    -commit 2>/dev/null || true
