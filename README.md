# Arch Calamares ISO

This project builds a plain Arch Linux live ISO that:

- boots to KDE Plasma with SDDM;
- includes a desktop launcher for the Calamares installer;
- supports guided or manual partitioning with ext4 and Btrfs;
- creates standard Btrfs subvolumes (`@`, `@home`, `@cache`, `@log`);
- installs GRUB on BIOS and UEFI systems; and
- installs an offline KDE Plasma system from the ISO itself.

It does not use EndeavourOS packages, repositories, themes, or installer helpers.

> [!WARNING]
> Calamares can erase disks and modify partition tables. Test the ISO in a virtual
> machine before using it on real hardware, and keep backups of important data.

## Build requirements

The ISO must be built on an up-to-date x86_64 Arch Linux installation or Arch
Linux virtual machine. `mkarchiso` is not supported on macOS, Debian, Ubuntu, or
other non-Arch hosts.

Install the build tools:

```bash
sudo pacman -Syu --needed archiso base-devel git
```

Calamares is currently an AUR package, not an official Arch repository package.
Build it as your regular user first:

```bash
./scripts/prepare-calamares.sh
```

Review the AUR `PKGBUILD` before approving dependency installation. Then build
the ISO (this step needs root because `mkarchiso` creates chroots and mounts):

```bash
sudo ./scripts/build-iso.sh
```

The completed image is written to `out/`. A successful build removes its
temporary ArchISO work directory. If a build is interrupted, inspect mounts and
then pass `--clean` to `build-iso.sh` before retrying.

## Test in a virtual machine

Install QEMU and UEFI firmware:

```bash
sudo pacman -S --needed qemu-desktop edk2-ovmf
```

Test legacy BIOS boot:

```bash
run_archiso -i out/arch-calam-*.iso
```

Test UEFI boot:

```bash
run_archiso -u -i out/arch-calam-*.iso
```

Use a blank virtual disk of at least 32 GiB. Exercise both **Erase disk** and
**Manual partitioning**, once with ext4 and once with Btrfs. After installation,
detach the ISO and confirm the installed system reaches SDDM, networking works,
and `findmnt --real` shows the expected layout.

## Write to a USB drive

Identify the whole USB device carefully, unmount its partitions, and write the
ISO. Replace `/dev/sdX` with the actual device (not a partition such as
`/dev/sdX1`):

```bash
sudo dd if=out/arch-calam-YYYY.MM.DD-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## How the project is organized

- `profile/packages.x86_64` adds KDE, Calamares, filesystem, networking, and
  bootloader packages to ArchISO's current `releng` profile.
- `profile/airootfs/` is overlaid onto that profile. It contains the live-user,
  SDDM, desktop-launcher, and Calamares configuration.
- `scripts/prepare-calamares.sh` builds the upstream AUR package into `.cache/`.
- `scripts/build-iso.sh` makes a temporary local pacman repository and calls
  `mkarchiso`.
- `scripts/validate.sh` performs non-destructive structural and YAML checks.

The build intentionally starts from the version of `releng` installed on the
host rather than storing a stale copy of Arch's boot files in this repository.
Review changes to ArchISO and Calamares before rebuilding an old checkout.

## Installation model and limitations

The installation is offline: Calamares unpacks the live root filesystem rather
than downloading a new package set. The target therefore contains the package
versions present when the ISO was built. Run `sudo pacman -Syu` after the first
boot.

Secure Boot is not configured. The image boots with Secure Boot disabled unless
you add and sign your own shim, bootloader, kernel, and unified images.

Disk encryption is available through Calamares. As with any custom installer,
test encrypted BIOS and UEFI paths before depending on them. RAID, LVM-specific
layouts, dual-boot resizing, and unusual firmware are outside the default test
matrix and should be validated separately.
