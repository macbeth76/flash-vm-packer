# Packer template for the Orin Nano Flash VM (QEMU)
#
# Builds an Ubuntu 22.04 QEMU image with NVIDIA JetPack 6.2.2 SDK
# for flashing the Jetson Orin Nano via the orin-flash MCP.
#
# Expected VM config (matches orin-flash manifest.toml):
#   - SSH: 127.0.0.1:2223, user `nvidia`
#   - L4T: /home/nvidia/nvidia/nvidia_sdk/JetPack_6.2.2_Linux_JETSON_ORIN_NANO_TARGETS/Linux_for_Tegra

packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "none"
  # TODO: Add real SHA256 for ubuntu-22.04.5-live-server-amd64.iso
  # Get from https://releases.ubuntu.com/22.04/SHA256SUMS
}

variable "ssh_username" {
  type    = string
  default = "nvidia"
}

variable "ssh_password" {
  type      = string
  default   = "nvidia"
  sensitive = true
}

variable "output_dir" {
  type    = string
  default = "output-flash-vm"
}

source "qemu" "flash-vm" {
  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  output_directory = var.output_dir
  vm_name          = "flash-vm"

  # QEMU settings
  accelerator = "hvf"  # macOS Hypervisor.framework; use "kvm" on Linux
  cpus        = 4
  memory      = 8192
  disk_size   = "60000"
  disk_image  = false
  format      = "qcow2"
  headless    = true  # No display (required for headless builds)

  # Network: user-mode with SSH forwarded to host port 2223
  net_device     = "virtio-net"
  host_port_min  = 2223
  host_port_max  = 2223

  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "90m"
  ssh_handshake_attempts = 100

  # Boot from ISO with autoinstall via config-drive (cidata)
  # cd_files creates a CIDATA ISO with nocloud user-data/meta-data
  # More reliable than HTTP server for QEMU user-mode networking
  cd_files = [
    "http/user-data",
    "http/meta-data"
  ]
  cd_label = "cidata"

  boot_wait = "10s"
  boot_command = [
    "<wait><wait><wait>e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud;label=cidata",
    "<f10>"
  ]

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
}

build {
  name = "flash-vm"

  sources = [
    "source.qemu.flash-vm"
  ]

  # Ansible provisioning: base setup, L4T R36.5.0, flash tools
  provisioner "ansible" {
    playbook_file = "../ansible/flash-vm.yml"
    user          = var.ssh_username
    extra_arguments = [
      "--extra-vars", "ansible_ssh_pass=${var.ssh_password}",
      "--extra-vars", "ansible_become_pass=${var.ssh_password}"
    ]
  }
}
