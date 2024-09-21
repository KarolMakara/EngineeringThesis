output "resource_group_name" {
  value = nonsensitive(azurerm_resource_group.rg.name)
}

output "kubernetes_cluster_name" {
  value = nonsensitive(azurerm_kubernetes_cluster.k8s.name)
}

output "client_certificate" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  sensitive = true
}

output "client_key" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  sensitive = true
}

output "key_data" {
  value = nonsensitive(azapi_resource_action.ssh_public_key_gen.output.publicKey)
}

output "cluster_ca_certificate" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  sensitive = true
}

output "cluster_password" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config[0].password)
  sensitive = true
}

output "cluster_username" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config[0].username)
  sensitive = true
}

output "host" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config[0].host)
  sensitive = true
}

output "kube_config" {
  value     = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config_raw)
  sensitive = true
}