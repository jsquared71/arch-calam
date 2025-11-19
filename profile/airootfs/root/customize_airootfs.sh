#!/usr/bin/env bash
set -euo pipefail

# Create live user
useradd -m -s /bin/bash liveuser
passwd -d liveuser
usermod -aG wheel liveuser

# Passwordless sudo for live user
cat > /etc/sudoers.d/99_liveuser <<'SUDO'
liveuser ALL=(ALL) NOPASSWD: ALL
SUDO
chmod 0440 /etc/sudoers.d/99_liveuser

# Enable services for the live session
systemctl enable NetworkManager
systemctl enable lightdm
systemctl enable sshd

touch /etc/motd
