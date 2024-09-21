resource "kubernetes_persistent_volume_claim" "azure-iperf-pvc" {
  metadata {
    name = "azure-iperf-pvc"
    namespace = "iperf-namespace"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "azurefile-csi"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
