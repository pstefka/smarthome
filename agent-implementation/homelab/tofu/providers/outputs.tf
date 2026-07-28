output "api_vip" {
  value = var.api_vip
}

output "talosconfig" {
  value     = talos_machine_configuration_apply.this.talosclient_configuration
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration
  sensitive = true
}
