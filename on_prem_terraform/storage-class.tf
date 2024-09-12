resource "kubernetes_storage_class" "local_path" {
  metadata {
    name = "local-path"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"

  volume_binding_mode = "Immediate"

  reclaim_policy = "Delete"
}
