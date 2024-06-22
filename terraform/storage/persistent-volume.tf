resource "kubernetes_persistent_volume" "iperf_pv" {
  metadata {
    name = "iperf-pv"
  }

  spec {
    capacity {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]

    host_path {
      path = "/mnt/data"
    }
  }
}
