terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}

# Download HAOS qcow2 image
resource "proxmox_virtual_environment_download_file" "haos" {
  node_name   = var.target_node
  content_type = "iso"
  datastore_id = "local"

  url = "https://github.com/home-assistant/operating-system/releases/download/${var.haos_version}/haos_ova-${var.haos_version}.qcow2.xz"

  file_name = "haos_ova-${var.haos_version}.qcow2"
}

# HAOS VM
resource "proxmox_virtual_environment_vm" "haos" {
  node_name = var.target_node
  vm_id     = var.vm_id

  name = "home-assistant"

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_gb
    file_format  = "raw"
    ssd          = true
    import_from  = proxmox_virtual_environment_download_file.haos.id
  }

  network_devices {
    model   = "virtio"
    bridge  = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  bios = "ovmf"

  serial_device {}
}
