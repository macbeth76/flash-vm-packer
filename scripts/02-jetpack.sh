#!/bin/bash
# 02-jetpack.sh — NVIDIA L4T R36.5.0 (JetPack 6.2.2) BSP installation
#
# Downloads the L4T Driver Package (BSP) and Sample Root Filesystem directly
# from NVIDIA's CDN — no SDK Manager login required.
#
# Expected final path (must match orin-flash manifest.toml):
#   /home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra
set -euo pipefail

L4T_VERSION="36.5.0"
L4T_BASE="https://developer.download.nvidia.com/embedded/L4T/r36_Release_v36.5.0/release"
BSP_TARBALL="Jetson_Linux_R36.5.0_aarch64.tbz2"
ROOTFS_TARBALL="Tegra_Linux_Sample-Root-Filesystem_R36.5.0_aarch64.tbz2"

INSTALL_DIR="/home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS"
L4T_TARGET="$INSTALL_DIR/Linux_for_Tegra"

# Dependencies for flashing
apt-get update
apt-get install -y \
  lbzip2 \
  python3-pyelftools \
  device-tree-compiler \
  abootimg \
  wget

# Create the expected directory structure
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download BSP (~700MB) if not already present
if [ ! -f "$BSP_TARBALL" ]; then
  echo "Downloading L4T BSP..."
  wget -q --show-progress "$L4T_BASE/$BSP_TARBALL"
fi

# Download Root Filesystem (~1.7GB) if not already present
if [ ! -f "$ROOTFS_TARBALL" ]; then
  echo "Downloading L4T Root Filesystem..."
  wget -q --show-progress "$L4T_BASE/$ROOTFS_TARBALL"
fi

# Extract BSP (creates Linux_for_Tegra/)
if [ ! -d "$L4T_TARGET" ]; then
  echo "Extracting BSP..."
  tar -xf "$BSP_TARBALL"
fi

# Extract rootfs into Linux_for_Tegra/rootfs/
if [ ! -f "$L4T_TARGET/rootfs/etc/os-release" ]; then
  echo "Extracting root filesystem..."
  tar -xpf "$ROOTFS_TARBALL" -C "$L4T_TARGET/rootfs/"
fi

# Apply NVIDIA binaries to rootfs
if [ ! -f "$L4T_TARGET/rootfs/etc/nv_tegra_release" ]; then
  echo "Applying NVIDIA binaries..."
  cd "$L4T_TARGET"
  ./apply_binaries.sh
fi

# Install host-side flash prerequisites
echo "Installing flash prerequisites..."
cd "$L4T_TARGET"
./tools/l4t_flash_prerequisites.sh || true

# Fix ownership
chown -R nvidia:nvidia /home/nvidia/nvidia

# Cleanup tarballs to save space (optional, comment out to keep)
# rm -f "$INSTALL_DIR/$BSP_TARBALL" "$INSTALL_DIR/$ROOTFS_TARBALL"

echo "L4T R36.5.0 installed at $L4T_TARGET"
ls -lh "$L4T_TARGET/l4t_initrd_flash.sh"
