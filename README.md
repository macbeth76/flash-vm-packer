# Flash VM (QEMU) — Packer Build

Builds the Ubuntu 22.04 QEMU image used as the Flash VM for Jetson Orin Nano
flashing via the `orin-flash` MCP.

## Prerequisites

- [Packer](https://www.packer.io/) >= 1.9
- QEMU with `hvf` acceleration (macOS) or `kvm` (Linux)
- ~60GB free disk space
- NVIDIA Developer account (for JetPack SDK Manager)

## Quick Start

```bash
cd packer
packer init .
packer build flash-vm.pkr.hcl
```

The output QCOW2 image will be in `output-flash-vm/`.

## Running the VM

```bash
qemu-system-x86_64 \
  -m 8192 \
  -smp 4 \
  -drive file=output-flash-vm/flash-vm,format=qcow2 \
  -netdev user,id=net0,hostfwd=tcp::2223-:22 \
  -device virtio-net-pci,netdev=net0 \
  -accel hvf
```

Then SSH: `ssh -p 2223 nvidia@127.0.0.1` (password: `nvidia`)

## JetPack Installation

See [docs/jetpack-install.md](docs/jetpack-install.md) for the SDK Manager procedure.
The expected L4T path is:
```
/home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra
```

This must match `manifest.toml` in the orin-flash MCP.

## Replaces

This replaces the old VirtualBox/Vagrant-based Flash VM
(`jetson-imaging/ubuntu22-sdkmanager` box, now retired).
