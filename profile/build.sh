#!/usr/bin/env bash
set -euo pipefail
PROFILE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ISO_LABEL=${ISO_LABEL:-ARCH-CALAM}
ISO_VERSION=${ISO_VERSION:-$(date +%Y.%m.%d)}

mkarchiso -v -w "$PROFILE_DIR/work" -o "$PROFILE_DIR/out" "$PROFILE_DIR"

cat <<INFO
ISO build complete.
Label: $ISO_LABEL
Version: $ISO_VERSION
Artifacts: $PROFILE_DIR/out
INFO
