resource "kubernetes_persistent_volume_claim" "iperf_pvc" {
  metadata {
    name      = "iperf-pvc"
    namespace = "iperf-namespace"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "1Gi"
      }
    }
  }
}
