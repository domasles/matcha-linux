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
    kernel_cmdline="unionfs_size=2G console=tty0"
    apkovl="genapkovl.sh"
    image_name="matcha-linux-$KERNEL_FLAVOR"
    title="Matcha Linux"
    hostname="$HOSTNAME"

    apks="alpine-base linux-firmware-none mesa bolt iio-sensor-proxy
        grub-efi gvfs dosfstools udisks2
        zsh git sudo openssl
        elogind polkit polkit-elogind apk-polkit-rs pinentry-gnome
        eudev dbus localsearch
        gdm gnome-keyring gnome-shell gsettings-desktop-schemas
        xdg-desktop-portal-gnome xdg-user-dirs
        gnome-control-center gnome-tour gnome-console gnome-browser-connector
        gnome-extensions-app gnome-text-editor gnome-calculator gnome-disk-utility
        snapshot nautilus loupe decibels firefox resources
        pipewire pipewire-pulse fastfetch chafa imagemagick
        networkmanager
        adwaita-fonts font-noto font-noto-cjk font-noto-emoji
        matcha-calamares"

    local _k

    for _k in $kernel_flavors; do
        apks="$apks linux-$_k"
    done
}
