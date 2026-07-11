#!/usr/bin/env bash
set -euo pipefail

if ! id liveuser >/dev/null 2>&1; then
    useradd --create-home --groups wheel,audio,video,storage --shell /bin/bash liveuser
fi

passwd --delete liveuser
install -d -m 0750 /etc/sudoers.d
printf '%s\n' 'liveuser ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-liveuser
chmod 0440 /etc/sudoers.d/10-liveuser

install -d -m 0755 /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-live-autologin.conf <<'EOF'
[Autologin]
User=liveuser
Session=plasma.desktop
Relogin=true
EOF

install -d -m 0755 /home/liveuser/Desktop
if [[ -f /etc/skel/Desktop/install-arch.desktop ]]; then
    install -m 0755 /etc/skel/Desktop/install-arch.desktop /home/liveuser/Desktop/install-arch.desktop
fi
chown -R liveuser:liveuser /home/liveuser

systemctl enable NetworkManager.service sddm.service bluetooth.service
