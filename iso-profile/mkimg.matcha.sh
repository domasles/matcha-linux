profile_matcha() {
    profile_standard
    kernel_cmdline="unionfs_size=512M console=tty0"
    syslinux_serial="0 115200"
    apkovl="genapkovl.sh"
    image_name="matcha-linux"
    title="Matcha Linux"
    apks="$apks alpine-base git sudo networkmanager
        elogind polkit eudev udev-init-scripts
        udev-init-scripts-openrc dbus gnome gnome-apps-core
        gnome-shell-extensions zsh zsh-vcs distrobox pipewire
        pipewire-pulse wireplumber networkmanager-wifi
        icu-data-full font-noto font-noto-extra font-noto-emoji
        font-noto-cjk font-noto-symbols apk-polkit-rs"
}
