terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
  }
}

# Control Plane Machine Config
resource "talos_machine_configuration" "control_plane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  talos_version    = var.talos_version
  kubernetes_version = var.kubernetes_version

  machine_network = {
    interfaces = [
      {
        interface = "net0"
        addresses = ["${var.control_plane.ip_address}/24"]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = var.control_plane.gateway
          }
        ]
      }
    ]
    nameservers = ["192.168.1.201"] # Blocky DNS
  }

  machine_config = {
    install = {
      disk  = "/dev/sda"
      image = "factory.talos.dev/installer/siderolabs/installer:${var.schematic_id}"
    }

    features = {
      kubePrism = {
        enabled = true
      }
    }
  }

  machine_sysctls = {
    "net.ipv4.ip_forward" = "1"
  }

  cluster_endpoint = "https://${var.api_vip}:6443"
}

# Worker Machine Configs
resource "talos_machine_configuration" "workers" {
  for_each = { for w in var.workers : w.name => w }

  cluster_name       = var.cluster_name
  machine_type       = "worker"
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  machine_network = {
    interfaces = [
      {
        interface = "net0"
        addresses = ["${each.value.ip_address}/24"]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = each.value.gateway
          }
        ]
      }
    ]
    nameservers = ["192.168.1.201"] # Blocky DNS
  }

  machine_config = {
    install = {
      disk  = "/dev/sda"
      image = "factory.talos.dev/installer/siderolabs/installer:${var.schematic_id}"
    }

    features = {
      kubePrism = {
        enabled = true
      }
    }
  }

  machine_sysctls = {
    "net.ipv4.ip_forward" = "1"
  }

  cluster_endpoint = "https://${var.api_vip}:6443"
}

# Proxmox VMs — Control Plane
resource "proxmox_virtual_environment_vm" "control_plane" {
  node_name = var.control_plane.target_node
  vm_id     = var.control_plane.vm_id

  name = "${var.cluster_name}-cp"

  cpu {
    cores = var.control_plane.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.control_plane.memory_mb
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.control_plane.disk_gb
    file_format  = "raw"
    ssd          = true
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

  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }

  serial_device {}
}

# Proxmox VMs — Workers
resource "proxmox_virtual_environment_vm" "workers" {
  for_each = { for w in var.workers : w.name => w }

  node_name = each.value.target_node
  vm_id     = each.value.vm_id

  name = "${var.cluster_name}-${each.value.name}"

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk_gb
    file_format  = "raw"
    ssd          = each.value.disk_gb >= 100
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

  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }

  serial_device {}
}

# Bootstrap cluster after control plane is up
resource "talos_machine_configuration_apply" "bootstrap" {
  for_each = {
    "cp" = {
      client_configuration = talos_machine_configuration.control_plane.client_configuration
      node                 = var.control_plane.ip_address
      config_patches       = [local.link_alias_config, local.cilium_patch, local.blocky_dns_patch]
    }
  }

  client_configuration = each.value.client_configuration
  node                 = each.value.node
  config_patches       = each.value.config_patches
}

resource "talos_machine_configuration_apply" "worker_apply" {
  for_each = { for w in var.workers : w.name => w }

  client_configuration = talos_machine_configuration.workers[each.key].client_configuration
  node                 = each.value.ip_address
  config_patches = [
    local.link_alias_config,
    local.cilium_patch,
    local.blocky_dns_patch,
    local.worker_extra_mounts,
  ]
}

# Get kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_configuration.control_plane.client_configuration
  node                 = var.control_plane.ip_address
  endpoint             = var.api_vip

  depends_on = [talos_machine_configuration_apply.bootstrap]
}

locals {
  # LinkAliasConfig: alias NIC to net0 for stable interface name
  link_alias_config = <<EOF
machine:
  network:
    links:
      - name: net0
        match:
          hardwareAddress: ""
          driver: virtio_net
EOF

  # Cilium: disable kube-proxy, use CNI none
  cilium_patch = <<EOF
cluster:
  proxy:
    disabled: true
  network:
    cni:
      name: none
EOF

  # Blocky DNS as nameserver
  blocky_dns_patch = <<EOF
machine:
  network:
    nameservers:
      - 192.168.1.201
EOF

  # Worker extra mounts for Longhorn
  worker_extra_mounts = <<EOF
machine:
  disks:
    - device: /dev/nvme0n1
      partitions:
        - mountpoint: /var/lib/longhorn
EOF
}
