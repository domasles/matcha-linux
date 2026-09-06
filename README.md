![Matcha Linux Logo](./MatchaLinuxLogo.svg)

# Matcha Linux

Fresh, fast and fluid.

## What is it?

Matcha Linux is a desktop operating system built on [Alpine Linux](https://alpinelinux.org).

It's designed to be lightweight and help people escape companies trying to squeeze more profit out of their systems. Matcha Linux is made to use as few resources as possible, making current hardware last a lifetime.

## Project Philosophy

It's like comparing matcha to tea. With a little bit of extra setup, you get a smooth-sailing, performant and modern experience.

## Features

Matcha Linux offers a unique blend of simplicity and modern functionality:

- **Lightweight & Fast** - Built on Alpine Linux for minimal resource usage and maximum performance
- **Modern Desktop Experience** - Full GNOME desktop environment
- **Out-of-the-Box Usability** - Pre-configured system settings for an immediate productive experience
- **EFI only** - Focused on modern hardware with UEFI support
- **Works with VMs** - Matcha Linux Virt is optimized for virtual environments
- **Audio Ready** - PipeWire stack for modern audio handling
- **Beautiful Theming** - Custom Matcha-themed backgrounds and GNOME defaults, as well as a custom Zsh configuration

Compared to other distributions and base Alpine, Matcha Linux provides a curated, opinionated desktop experience without bloat while maintaining the flexibility and security benefits of Alpine.

## Tips and Tricks for Users

- **Live Environment**: You can test Matcha Linux without installing by booting from the ISO
- **Installation**: Use the included Calamares installer for a straightforward installation process
- **Install a Distrobox Terminal**: Use Distrobox to install a container and run other distributions within Matcha Linux. This is especially useful for users who want to run software that isn't available in Alpine's repositories (common issue when trying to run Linux apps that won't launch natively)

## Minimum Requirements to Run Matcha Linux

- **Memory**: 3GB of RAM
- **Storage**: 5GB of free disk space for installation
- **UEFI Firmware**: Matcha Linux is designed for modern hardware with UEFI support, so legacy BIOS systems are not supported

## Requirements For a Build

- **act** - To run GitHub Actions workflows locally
- **Docker** - For containerized build environment, required for act

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
- Create a new VM with UEFI firmware and at least 4GB of RAM
- (Recommended) Enable 3D acceleration and at least 128MB of video memory for better performance
- Attach the Matcha Linux ISO as a bootable drive
- Create a new virtual hard disk (at least 10GB) and attach it to the VM
- Select the UEFI option in the VM settings
- Start the VM!

Hyper-V:
- Create a new Generation 2 (enables UEFI) VM with at least 4GB of RAM
- Attach the Matcha Linux ISO as a bootable drive
- Create a new virtual hard disk (at least 10GB) and attach it to the VM
- Disable Secure Boot in the VM settings
- Start the VM!

QEMU:
- Download the OVMF firmware for UEFI support (e.g., `OVMF.fd`) and place it in the same directory as the ISO
- Navigate to the directory containing the ISO and OVMF.fd files and create a new virtual hard disk (at least 10GB) for the VM:
  ```bash
  qemu-img create -f qcow2 matcha-linux.qcow2 10G
  ```
- Use the following command to start a VM with Matcha Linux:
  ```bash
  # For Linux/macOS:
  qemu-system-x86_64 -m 4G -accel kvm -device virtio-gpu-pci,3d=on -display sdl,gl=on -bios ./OVMF.fd -cdrom ./matcha-linux-virt-2026.09.06-x86_64.iso -drive file=matcha-linux.qcow2,format=qcow2 -boot d

  # For Windows:
  qemu-system-x86_64 -m 4G -accel whpx -bios .\OVMF.fd -cdrom .\matcha-linux-virt-2026.09.06-x86_64.iso -drive file=matcha-linux.qcow2,format=qcow2 -boot d
  ```

## Configuration

The system is configured through the ISO profile in `iso-profile/`. You can customize various aspects:

### Custom Packages

You can add or modify packages in `iso-profile/mkimg.matcha.sh`. The `apks` variable defines all packages installed in the ISO:

```bash
apks="alpine-base linux-lts ... your-custom-package-here"
# or
apks="alpine-base linux-lts ..."
apks="$apks your-custom-package-here"  # this doesn't alter the original list, just appends to it
```

**Important**: If you want these packages to be visible in the live environment (not just installed to the filesystem), you must also add them to `rootfs/etc/apk/world`. However, be cautious with `linux` and `grub` packages as they can break the live system if included in the `world` file.

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
