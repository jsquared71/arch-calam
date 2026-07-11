#!/usr/bin/env bash
set -euo pipefail

readonly project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly profile_dir="${1:-${project_dir}/profile}"

for script in "${project_dir}/scripts/"*.sh; do
    bash -n "${script}"
done

required=(
    "packages.x86_64"
    "airootfs/etc/calamares/settings.conf"
    "airootfs/etc/calamares/modules/partition.conf"
    "airootfs/etc/calamares/modules/unpackfs.conf"
    "airootfs/etc/calamares/modules/mount.conf"
    "airootfs/etc/calamares/modules/bootloader.conf"
    "airootfs/etc/calamares/modules/preparetarget.conf"
    "airootfs/etc/calamares/modules/cleanup.conf"
    "airootfs/etc/calamares/branding/arch/branding.desc"
    "airootfs/etc/pacman.d/hooks/90-arch-calam-live.hook"
    "airootfs/usr/local/lib/arch-calam/linux.preset"
)

for file in "${required[@]}"; do
    if [[ ! -s "${profile_dir}/${file}" ]]; then
        echo "Missing required profile file: ${profile_dir}/${file}" >&2
        exit 1
    fi
done

if command -v ruby >/dev/null 2>&1; then
    while IFS= read -r file; do
        ruby -e 'require "yaml"; YAML.safe_load(File.read(ARGV.fetch(0)), permitted_classes: [], aliases: true)' "${file}"
    done < <(find "${profile_dir}/airootfs/etc/calamares" -type f \
        \( -name '*.conf' -o -name '*.desc' \) -print | sort)
else
    echo "ruby not found; skipped YAML syntax validation" >&2
fi

grep -qx 'btrfs-progs' "${profile_dir}/packages.x86_64"
grep -qx 'e2fsprogs' "${profile_dir}/packages.x86_64"
grep -q 'availableFileSystemTypes:.*ext4.*btrfs' \
    "${profile_dir}/airootfs/etc/calamares/modules/partition.conf"

echo "Profile validation passed: ${profile_dir}"
