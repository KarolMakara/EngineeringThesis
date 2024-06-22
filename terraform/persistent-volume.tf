resource "kubernetes_persistent_volume" "iperf-pv" {
  metadata {
    name = "iperf-pv"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/mnt/k3s/metrics"
      }
    }
  }
}
