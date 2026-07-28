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

variable "target_node" {
  type    = string
  default = "N100"
}

variable "vm_id" {
  type    = number
  default = 900
}

variable "cpu_cores" {
  type    = number
  default = 4
}

variable "memory_mb" {
  type    = number
  default = 8192
}

variable "disk_gb" {
  type    = number
  default = 64
}

variable "haos_version" {
  type    = string
  default = "15.2"
}

variable "ip_address" {
  type    = string
  default = "192.168.1.100"
}

variable "gateway" {
  type    = string
  default = "192.168.1.1"
}
