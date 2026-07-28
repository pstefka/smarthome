variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "cluster_name" {
  type    = string
  default = "budabuda-k8s"
}

variable "talos_version" {
  type    = string
  default = "1.13.3"
}

variable "kubernetes_version" {
  type    = string
  default = "1.36.3"
}

variable "api_vip" {
  type    = string
  default = "192.168.1.200"
}

variable "control_plane" {
  type = object({
    vm_id       = number
    cpu_cores   = number
    memory_mb   = number
    disk_gb     = number
    target_node = string
    ip_address  = string
    gateway     = string
  })
}

variable "workers" {
  type = list(object({
    vm_id       = number
    cpu_cores   = number
    memory_mb   = number
    disk_gb     = number
    target_node = string
    ip_address  = string
    gateway     = string
    name        = string
  }))
}

variable "schematic_id" {
  type = string
}
