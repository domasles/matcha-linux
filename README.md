![Matcha Linux Logo](./MatchaLinuxLogo.svg)

# Matcha Linux

Fresh. Fast. Fluid. Always.

## What is it?

Matcha Linux is a desktop operating system built on Alpine Linux.

It's designed to provide a lightweight yet modern computing experience that helps users escape the trend of companies trying to squeeze more profit out of their systems and combat the push for locking down devices, as well as increasing hardware prices.

## Project Philosophy

It's like comparing matcha to tea. With a little bit of extra setup, you get a smooth-sailing, performant experience that just works.

This repository is for tech enthusiasts who are looking to try out a new flavor of Linux, this time coated in matcha. Whether you're a software maintainer or a regular user, you'll benefit from this project.

## Features

Matcha Linux offers a unique blend of simplicity and modern functionality:

- **Lightweight & Fast** - Built on Alpine Linux for minimal resource usage and maximum performance
- **Modern Desktop Experience** - Full GNOME desktop environment with carefully curated extensions
- **Out-of-the-Box Usability** - Pre-configured system settings for an immediate productive experience
- **EFI only** - Focused on modern hardware with UEFI support, saying goodbye to legacy BIOS
- **Developer-Friendly** - Includes tools like git and development utilities
- **Audio Ready** - PipeWire stack for modern audio handling
- **Network Management** - NetworkManager with WiFi support included
- **Terminal Productivity** - Zsh with VCS support pre-installed
- **Beautiful Theming** - Custom Matcha-themed backgrounds and GNOME defaults, as well as a custom Zsh configuration
- **Polkit Integration** - Proper privilege management for desktop operations
- **Open Source** - Fully transparent, community-driven development

Compared to other distributions and base Alpine, Matcha Linux provides a curated, opinionated desktop experience without bloat while maintaining the flexibility and security benefits of Alpine.

## Tips and Tricks for Users

- **Live Environment**: You can test Matcha Linux without installing by booting from the ISO
- **Installation**: Use the included Calamares installer for a straightforward installation process
- **Install a Distrobox Terminal**: Use Distrobox to install a container and run other distributions within Matcha Linux. This is especially useful for users who want to run software that isn't available in Alpine's repositories (common issue when trying to run Linux apps that won't launch natively)

## Requirements to run Matcha Linux

- **Memory**: 4GB RAM (live environment uses around 3.5GB, installed system idles somewhere at 1.5GB)
- **Storage**: 10GB of free disk space for installation
- **UEFI Firmware**: Matcha Linux is designed for modern hardware with UEFI support, so legacy BIOS systems are not supported

## Requirements for a Build

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
act workflow_dispatch
```

> NOTE: `workflow_dispatch` is required here, because `act` can't automatically detect the event to choose. Running act without an event specified will result in an error.

3. **Find your builds**:
Builds will be zipped in the `build/` directory after completion.

## How to run in a VM

VirtualBox:
- Create a new VM with UEFI firmware and at least 4GB of RAM
- (Recommended) Enable 3D acceleration and at least 128MB of video memory for better performance
- Attach the Matcha Linux ISO as a bootable drive
- Select the UEFI option in the VM settings
- Start the VM!

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

### Customization Notes

Modifying everything that wasn't covered is highly discouraged unless you know what you're doing - incorrect changes can prevent the system from booting or installing properly.

## Architecture

The project follows a modular Alpine ISO build structure:

```
build.sh              # Build script to automate the build process

.iso-profile/
├── config/
│   ├── extensions.json
│   └── permissions.json
├── genapkovl.sh     # A portable overlay generation script
└── mkimg.matcha.sh  # Main image profile configuration

rootfs/
├── etc/
│   ├── apk/
│   │   └── world                     # Packages visible in live environment
│   ├── dconf/
│   │   └── db/
│   │       └── local.d/
│   │           └── desktop-defaults  # GNOME default settings
│   ├── issue
│   ├── motd
│   ├── os-release
│   ├── rc.conf
│   ├── gdm/
│   ├── polkit-1/
│   ├── skel/
│   └── sudoers.d/
│       └── matcha
└── usr/
    └── share/
        ├── backgrounds/
        │   └── matcha/
        └── gnome-background-properties/
            └── matcha.xml
```

## Support

For issues, feature requests, or questions open an issue or pull request on GitHub.

---

Built with love for the Linux community. _Open source, as intended._
