![Matcha Linux Logo](./MatchaLinuxLogo.svg)

# Matcha Linux

Fresh, fast and fluid.

## What is it?

Matcha Linux is a desktop operating system built on [Alpine Linux](https://alpinelinux.org).

It's designed to be lightweight and help people escape companies trying to squeeze more profit out of their systems. Matcha Linux is made to use as few system resources as possible, making current hardware last a lifetime.

## Project Philosophy

It's like comparing matcha to tea. With a little bit of extra setup, you get a performant and modern experience.

## Features

- **Built on Alpine Linux** for minimal resource usage
- **Full** GNOME desktop environment
- **UEFI-only**
- **Matcha Linux Virt** is optimized for VMs
- **Custom** look and feel through extensions

Compared to other distributions, Matcha Linux provides a bloat-free desktop experience.

## Tips and Tricks

- **Install a Distrobox Terminal**: Use Distrobox to install a container and run other distributions within Matcha Linux. Useful if you want to run software that isn't available withinin Alpine's repositories

## Minimum Requirements to Run Matcha Linux

- **Memory**: 3GB of RAM
- **Storage**: 5GB of free disk space for installation
- **UEFI Firmware**: Matcha Linux is designed for modern hardware with UEFI support, and BIOS systems are not supported

## Requirements For a Build

- **act** - To run GitHub Actions workflows locally
- **Docker** - Required for act (you can also use Podman, but setting up a mock Docker socket requires more work)

## Build Instructions

1. **Clone the repository**:
```bash
git clone https://github.com/domasles/matcha-linux.git
cd matcha-linux
```

2. **Run the build**:
```bash
act  # You can control what to build by appending --matrix:[virt, lts], by default both are built
```

3. **Find your builds**:
Builds will be zipped in the `build/` directory after completion.

## How To Run In a VM

VirtualBox:
- Create a new VM with UEFI firmware and at least 3GB of RAM
- (Recommended) Enable 3D acceleration and at least 128MB of video memory for better performance
- Attach the Matcha Linux ISO as a bootable drive
- Create a new virtual hard disk (at least 5GB) and attach it to the VM
- Select the UEFI option in the VM settings
- Start the VM!

Hyper-V:
- Create a new Generation 2 (enables UEFI) VM with at least 3GB of RAM
- Attach the Matcha Linux ISO as a bootable drive
- Create a new virtual hard disk (at least 5GB) and attach it to the VM
- Disable Secure Boot in the VM settings
- Start the VM!

QEMU:
- Download the OVMF firmware for UEFI support (e.g., `OVMF.fd`) and place it in the same directory as the ISO
- Navigate to the directory containing the ISO and OVMF.fd files and create a new virtual hard disk (at least 5GB) for the VM:
  ```bash
  qemu-img create -f qcow2 matcha-linux.qcow2 5G
  ```
- Use the following command to start a VM with Matcha Linux:
  ```bash
  # For Linux/macOS:
  qemu-system-x86_64 -m 3G -enable-kvm -display sdl,gl=on -bios ./OVMF.fd -cdrom ./matcha-linux-virt-2026.09.10-x86_64.iso -drive file=matcha-linux.qcow2,format=qcow2 -boot d

  # For Windows:
  qemu-system-x86_64 -m 3G -accel whpx -bios .\OVMF.fd -cdrom .\matcha-linux-virt-2026.09.10-x86_64.iso -drive file=matcha-linux.qcow2,format=qcow2 -boot d
  ```

## Configuration

The system is configured through the ISO profile in `iso-profile/`. You can customize various aspects:

### Custom Packages

You can add or modify packages in `rootfs/etc/apk/matcha-pkgs`. The package `linux-{flavor}` (for example `linux-virt`) is appended at build time to provide utils for installing and more, so you shouldn't declare it separately.

**Important**: If you want these packages to be visible in the live environment (not just installed to the filesystem), you must also add them to `rootfs/etc/apk/world`.

### GNOME Configuration

- **GNOME backgrounds** - Matcha-themed wallpapers in `rootfs/usr/share/backgrounds/matcha/`
- **GNOME extensions** - Included in the `iso-profile/config/extensions.json` file, with settings in the dconf defaults
- **GNOME and extension settings** - Pre-defined settings in `rootfs/etc/dconf/db/local.d/desktop-defaults`
- **OS information** - Defined in `rootfs/etc/os-release` and `rootfs/etc/issue`

### Configuration Files

- **iso-profile/mkimg.matcha.sh** - Main build profile with kernel, packages and image settings
- **iso-profile/config/** - Extension and permission configurations
- **iso-profile/genapkovl.sh** - A portable overlay generation script

## Support

For issues, feature requests, or questions open an issue or pull request on GitHub.
