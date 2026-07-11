#!/usr/bin/env bash
set -euo pipefail

readonly project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly source_dir="${project_dir}/.cache/calamares-aur"
readonly package_dir="${project_dir}/.cache/packages"

if [[ ${EUID} -eq 0 ]]; then
    echo "Run this script as a regular user, not root." >&2
    exit 1
fi

for command in git makepkg; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        echo "Missing required command: ${command}" >&2
        echo "Install the build tools with: sudo pacman -S --needed base-devel git" >&2
        exit 1
    fi
done

mkdir -p "$(dirname -- "${source_dir}")" "${package_dir}"

if [[ -d "${source_dir}/.git" ]]; then
    git -C "${source_dir}" pull --ff-only
else
    git clone https://aur.archlinux.org/calamares.git "${source_dir}"
fi

echo "Reviewing ${source_dir}/PKGBUILD before build:" >&2
sed -n '1,240p' "${source_dir}/PKGBUILD"

(
    cd "${source_dir}"
    makepkg --syncdeps --cleanbuild --clean --noconfirm
)

find "${source_dir}" -maxdepth 1 -type f \
    -name 'calamares-[0-9]*-x86_64.pkg.tar.*' \
    ! -name '*.sig' \
    -exec cp -f -- {} "${package_dir}/" \;

if ! compgen -G "${package_dir}/calamares-[0-9]*-x86_64.pkg.tar.*" >/dev/null; then
    echo "The Calamares package was not produced." >&2
    exit 1
fi

echo "Calamares package cached in ${package_dir}"
