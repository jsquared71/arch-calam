#!/usr/bin/env bash
iso_name="arch-calam"
iso_label="ARCH-CALAM"
iso_publisher="Arch Calam <https://example.org>"
iso_application="Arch Calam Live ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi-x64.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '19')
file_permissions=(
    ["/etc/sudoers.d/99_liveuser"]="0:0:0440"
)
