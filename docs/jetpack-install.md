# JetPack 6.2.2 Manual Installation

The Packer build prepares the VM but does not automatically install JetPack,
because NVIDIA SDK Manager requires interactive login with a developer account.

## Option A: Pre-seed the tarball (automated)

1. On your workstation, download JetPack 6.2.2 for Jetson Orin Nano via
   [SDK Manager](https://developer.nvidia.com/sdk-manager) or the
   [JetPack archive](https://developer.nvidia.com/embedded/jetpack-archive).

2. Copy the tarball into the Packer build as `/tmp/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS.tar.gz`
   before running `packer build`. The `02-jetpack.sh` provisioner will extract it.

## Option B: Manual install after first boot (interactive)

1. Boot the VM and SSH in: `ssh -p 2223 nvidia@127.0.0.1`
2. Download and install SDK Manager:
   ```bash
   wget https://developer.nvidia.com/downloads/sdkmanager-[version].deb
   sudo apt install ./sdkmanager-[version].deb
   ```
3. Run `sdkmanager` and follow the prompts:
   - Select JetPack 6.2.2
   - Target: Jetson Orin Nano Developer Kit
   - Install to `/home/nvidia/nvidia/nvidia_sdk/`
4. Verify:
   ```bash
   ls /home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra
   ```

## Verification

The orin-flash MCP expects:
```
[vm]
l4t = "/home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra"
```

Test with:
```bash
ls /home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra/l4t_initrd_flash.sh
```
