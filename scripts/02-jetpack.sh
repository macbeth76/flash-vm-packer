#!/bin/bash
# 02-jetpack.sh — NVIDIA JetPack 6.2.2 SDK installation
#
# IMPORTANT: JetPack installation via SDK Manager is interactive and requires
# an NVIDIA developer account. This script prepares the system; the actual
# SDK install may need manual steps. See docs/jetpack-install.md.
#
# Expected final path (must match orin-flash manifest.toml):
#   /home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra
set -euo pipefail

L4T_TARGET="/home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra"

# Dependencies for SDK Manager and flashing
apt-get update
apt-get install -y \
  lbzip2 \
  python3-pyelftools \
  device-tree-compiler \
  abootimg

# Create the expected directory structure
mkdir -p "$(dirname "$L4T_TARGET")"
chown -R nvidia:nvidia /home/nvidia/nvidia

# If a pre-downloaded JetPack tarball is provided, extract it here.
# Otherwise, SDK Manager must be run manually after first boot.
# See docs/jetpack-install.md for the manual procedure.

if [ -f "/tmp/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS.tar.gz" ]; then
  echo "Extracting pre-seeded JetPack..."
  tar -xzf "/tmp/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS.tar.gz" \
    -C /home/nvidia/nvidia/nvidia_sdk/
  chown -R nvidia:nvidia /home/nvidia/nvidia
  echo "JetPack extracted to $L4T_TARGET"
else
  echo "WARNING: No JetPack tarball found. Run SDK Manager manually."
  echo "See docs/jetpack-install.md"
fi

echo "JetPack preparation complete."
