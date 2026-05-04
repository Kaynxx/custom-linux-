#!/bin/bash
set -e

# Initialize pacman keys
pacman-key --init
pacman-key --populate archlinux

# Add chaotic-aur key and install keyring (if not already installed by base)
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

# Set root password
echo "root:1111" | chpasswd

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Create kaynxx user
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh kaynxx
echo "kaynxx:1111" | chpasswd

# Fetch JaKooLit dotfiles
echo "Fetching JaKooLit dotfiles..."
git clone https://github.com/JaKooLit/Arch-Hyprland.git /tmp/jakoolit
mkdir -p /etc/skel/.config
cp -r /tmp/jakoolit/config/* /etc/skel/.config/

# Ensure kaynxx has the dotfiles as well
mkdir -p /home/kaynxx/.config
cp -r /tmp/jakoolit/config/* /home/kaynxx/.config/
chown -R kaynxx:kaynxx /home/kaynxx/.config

# Setup default sddm theme (JaKooLit often uses sddm-candy or similar, but default is ok for now)
# The user wants to login directly using SDDM
systemctl enable sddm.service
systemctl enable NetworkManager.service

# Setup autologin for Live USB
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=kaynxx
Session=hyprland
EOF

# Clean up
rm -rf /tmp/jakoolit
