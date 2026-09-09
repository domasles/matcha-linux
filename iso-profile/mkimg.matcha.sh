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

    apks="$(cat "$WORKSPACE/rootfs/etc/apk/matcha-pkgs" | tr '\n' ' ')"
}
