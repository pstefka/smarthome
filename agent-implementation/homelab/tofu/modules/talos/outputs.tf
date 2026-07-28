output "cluster_name" {
  value = var.cluster_name
}

output "control_plane_ip" {
  value = var.control_plane.ip_address
}

output "worker_ips" {
  value = { for w in var.workers : w.name => w.ip_address }
}
