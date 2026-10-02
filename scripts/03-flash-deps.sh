#!/bin/bash
# 03-flash-deps.sh — Flash tooling prerequisites
#
# Installs dependencies needed by the orin-flash MCP's VM-side scripts:
#   - usbip (for USB/IP device sharing from Dragon)
#   - QEMU guest tools for USB passthrough
#   - Python dependencies for the flash scripts
set -euo pipefail

apt-get update
apt-get install -y \
  linux-tools-generic \
  linux-modules-extra-$(uname -r) \
  usbip \
  python3-usb

# Load vhci-hcd for USB/IP client (required for usbip attach)
modprobe vhci-hcd || true
echo "vhci-hcd" >> /etc/modules

# Python packages used by orin-flash vm_scripts
pip3 install pyusb 2>/dev/null || true

echo "Flash dependencies complete."
