#!/usr/bin/env bash
set -euo pipefail

readonly project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly source_profile="/usr/share/archiso/configs/releng"
readonly build_profile="${project_dir}/build/profile"
readonly work_dir="${project_dir}/work"
readonly out_dir="${project_dir}/out"
readonly package_cache="${project_dir}/.cache/packages"
readonly local_repo="/tmp/arch-calam-repo"

clean=false
clean_only=false
case "${1:-}" in
    "") ;;
    --clean) clean=true ;;
    --clean-only) clean=true; clean_only=true ;;
    *) echo "Usage: $0 [--clean|--clean-only]" >&2; exit 2 ;;
esac

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this script through sudo: sudo ./scripts/build-iso.sh" >&2
    exit 1
fi

if [[ ${clean} == true ]]; then
    for path in "${work_dir}" "${build_profile}"; do
        while IFS= read -r mountpoint; do
            if [[ ${mountpoint} == "${path}" || ${mountpoint} == "${path}/"* ]]; then
                echo "Refusing to remove mounted ArchISO work path: ${path}" >&2
                exit 1
            fi
        done < <(findmnt --raw --noheadings --output TARGET)
        rm -rf -- "${path}"
    done
fi

if [[ ${clean_only} == true ]]; then
    exit 0
fi

if [[ -e "${work_dir}" ]]; then
    echo "An earlier ArchISO work directory exists: ${work_dir}" >&2
    echo "Re-run with --clean after checking that no build is still running." >&2
    exit 1
fi

for command in mkarchiso repo-add awk sed; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        echo "Missing required command: ${command}" >&2
        echo "Install requirements with: sudo pacman -S --needed archiso" >&2
        exit 1
    fi
done

if [[ ! -d "${source_profile}" ]]; then
    echo "ArchISO releng profile not found at ${source_profile}" >&2
    exit 1
fi

mapfile -t calamares_packages < <(
    find "${package_cache}" -maxdepth 1 -type f \
        -name 'calamares-[0-9]*-x86_64.pkg.tar.*' \
        ! -name '*.sig' \
        ! -name '*-debug-*' \
        -print | sort
)
if (( ${#calamares_packages[@]} == 0 )); then
    echo "No cached Calamares package found. Run ./scripts/prepare-calamares.sh first." >&2
    exit 1
fi

rm -rf -- "${local_repo}"
install -d -m 0755 "${local_repo}" "$(dirname -- "${build_profile}")" "${out_dir}"
cp -f -- "${calamares_packages[@]}" "${local_repo}/"
repo-add "${local_repo}/arch-calam.db.tar.zst" "${local_repo}"/*.pkg.tar.*

rm -rf -- "${build_profile}"
cp -a -- "${source_profile}" "${build_profile}"
cp -a -- "${project_dir}/profile/." "${build_profile}/"

awk '!seen[$0]++' \
    "${source_profile}/packages.x86_64" \
    "${project_dir}/profile/packages.x86_64" \
    > "${build_profile}/packages.x86_64.tmp"
mv "${build_profile}/packages.x86_64.tmp" "${build_profile}/packages.x86_64"

{
    printf '%s\n' '[arch-calam]'
    printf '%s\n' 'SigLevel = Optional TrustAll'
    printf 'Server = file://%s\n\n' "${local_repo}"
    cat "${source_profile}/pacman.conf"
} > "${build_profile}/pacman.conf"

sed -i \
    -e 's/^iso_name=.*/iso_name="arch-calam"/' \
    -e 's/^iso_label=.*/iso_label="ARCH_CALAM_$(date +%Y%m)"/' \
    -e 's/^iso_publisher=.*/iso_publisher="Arch Calamares Project"/' \
    -e 's|^iso_application=.*|iso_application="Arch Linux KDE Calamares Live/Install ISO"|' \
    "${build_profile}/profiledef.sh"

"${project_dir}/scripts/validate.sh" "${build_profile}"

mkarchiso -v -r -w "${work_dir}" -o "${out_dir}" "${build_profile}"

echo "ISO build complete. Output: ${out_dir}"
