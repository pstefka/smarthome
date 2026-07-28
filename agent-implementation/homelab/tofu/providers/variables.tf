variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  default     = "https://192.168.1.1:8006"
}

variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox"
  type        = bool
  default     = true
}

variable "api_vip" {
  description = "Kubernetes API virtual IP"
  type        = string
  default     = "192.168.1.200"
}

variable "cluster_name" {
  description = "Talos cluster name"
  type        = string
  default     = "budabuda-k8s"
}
