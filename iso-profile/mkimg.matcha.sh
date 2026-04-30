VERSION="v26.04"

profile_matcha() {
    profile_standard
    kernel_cmdline="unionfs_size=512M console=tty0"
    syslinux_serial="0 115200"
    apkovl="genapkovl.sh"
    image_name="matcha-linux"
    title="Matcha Linux"
    apks="$apks alpine-base"
}
