profile_matcha() {
    kernel_flavors="$KERNEL_FLAVOR"
    initfs_cmdline="modules=loop,squashfs,sd-mod,usb-storage quiet"
    initfs_features="ata base bootchart cdrom dhcp ext4 mmc nvme raid scsi squashfs usb virtio nfit"
    modloop_sign=yes
    grub_mod="all_video disk part_gpt linux normal configfile search search_label efi_gop fat iso9660 cat echo ls test true help gzio efi_uga"

    profile_abbrev="matcha"
    image_ext="iso"
    output_format="iso"
    arch="$ARCH"
    kernel_cmdline="unionfs_size=512M console=tty0"
    apkovl="genapkovl.sh"
    image_name="matcha-linux-$KERNEL_FLAVOR"
    title="Matcha Linux"
    hostname="$HOSTNAME"

    apks="alpine-base linux-firmware-none mesa-dri-gallium mesa-gl
        mesa-gles mesa-egl grub grub-efi git sudo networkmanager
        elogind polkit eudev openssl fastfetch chafa imagemagick
        udev-init-scripts udev-init-scripts-openrc dbus gnome
        gnome-apps-core gnome-shell-extensions zsh zsh-vcs pipewire
        pipewire-pulse wireplumber networkmanager-wifi icu-data-full
        font-noto font-noto-extra font-noto-emoji font-noto-cjk
        font-noto-symbols apk-polkit-rs matcha-calamares"

    local _k _a

    for _k in $kernel_flavors; do
        apks="$apks linux-$_k"
    done
}
