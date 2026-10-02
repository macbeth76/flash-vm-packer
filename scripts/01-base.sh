#!/bin/bash
# 01-base.sh — Base system setup for the Flash VM
# Creates the nvidia user, configures SSH, installs base dependencies.
set -euo pipefail

# Create nvidia user if not exists (autoinstall should handle this, belt-and-suspenders)
if ! id nvidia &>/dev/null; then
  useradd -m -s /bin/bash -G sudo nvidia
  echo "nvidia:nvidia" | chpasswd
fi

# Passwordless sudo for nvidia (required by orin-flash MCP automation)
echo "nvidia ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nvidia
chmod 440 /etc/sudoers.d/nvidia

# Base packages
apt-get update
apt-get install -y \
  openssh-server \
  python3 \
  python3-pip \
  curl \
  wget \
  git \
  qemu-guest-agent \
  usbutils \
  libusb-1.0-0

# Enable SSH and guest agent
systemctl enable ssh
systemctl enable qemu-guest-agent

echo "Base setup complete."
