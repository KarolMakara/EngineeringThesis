resource "kubernetes_job" "iperf_server" {
  metadata {
    name      = "iperf-server"
    namespace = "iperf-namespace"
    labels = {
      app = "iperf-server"
    }
  }

  spec {
    template {
      metadata {
        labels = {
          app = "iperf-server"
        }
      }

      spec {
        container {
          name  = "iperf-server"
          image = "karolmakara/iperf-statexec:latest"
          command = ["sh", "-c", "statexec iperf3 -c iperf-server -t ${var.test_duraction} && cp statexec_metrics.prom ${var.volume_mount_path}/statexec_metrics_client.prom"]

          port {
            container_port = 5201
          }

          volume_mount {
            name       = "metrics-volume"
            mount_path = "/mnt/k3s/metrics"
          }
        }

        volume {
          name = "metrics-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.iperf-pvc.metadata[0].name
          }
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 4
  }
}
