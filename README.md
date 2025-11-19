# Arch-Calam

Arch-Calam provides an Arch Linux live ISO with a graphical XFCE session, the Calamares installer, and a toolbox of repair utilities. The Calamares workflow mirrors the EndeavourOS experience without the branding while exposing ext4 and Btrfs partitioning choices.

## Features
- Live graphical environment using XFCE with LightDM autologin to the `liveuser` account.
- Calamares installer preconfigured for guided or manual partitioning with ext4 or Btrfs.
- Boot repair and recovery tools: GParted, TestDisk/PhotoRec, SMART utilities, Timeshift, rsync, and more.
- System services enabled out of the box: NetworkManager, SSH, and Bluetooth.

## Building the ISO
1. Install build dependencies on an Arch-based host:
   ```bash
   sudo pacman -Syu --needed archiso mkinitcpio-archiso
   ```
2. Build from the included profile:
   ```bash
   cd profile
   sudo ./build.sh
   ```
3. The generated ISO is placed under `profile/out/` with working files in `profile/work/`.

## Calamares configuration
- Branding lives in `profile/airootfs/etc/calamares/branding/arch-calam/`.
- Module settings (partitioning, users, services, packages) are stored in `profile/airootfs/etc/calamares/modules/`.
- Package lists for target installs reside in `profile/airootfs/etc/calamares/packages/`.

## Live session defaults
- User: `liveuser` (passwordless sudo)
- Display manager: LightDM with XFCE session autostarting the Calamares installer.

## Notes
- The profile targets BIOS (Syslinux) and UEFI (systemd-boot) boots.
- `packages.x86_64` includes common repair utilities; adjust as desired before rebuilding.

## Testing
- Build verification is performed by running `./build.sh` from the `profile` directory on an Arch-based host with `archiso` and
  `mkinitcpio-archiso` installed.
- The script will fail if `mkarchiso` is unavailable; install the dependencies first when testing in fresh environments.

## Uploading to your own repository
1. Create an empty Git repository on your hosting platform (for example, a new GitHub project).
2. Add the new remote inside this workspace:
   ```bash
   git remote add origin git@github.com:<your-username>/<your-repo>.git
   ```
3. Push the existing branch and history:
   ```bash
   git push -u origin work
   ```
   Replace `work` with another branch name if you prefer; the upstream tracking reference is set automatically by `-u`.
4. Open a pull request or set the branch as default in your hosting platform as desired.
