resource "kubernetes_job" "iperf_client" {
  metadata {
    name      = "iperf-client"
    namespace = "iperf-namespace"
  }

  spec {
    template {
      metadata {
        labels = {
          app = "iperf-client"
        }
      }

      spec {
        container {
          name  = "iperf-client"
          image = "karolmakara/iperf-statexec:latest"
          command = ["sh", "-c", "statexec iperf3 -c iperf-server -t ${var.test_duraction} && cp statexec_metrics.prom ${var.volume_mount_path}/statexec_metrics_client.prom"]

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "metrics-volume"
            mount_path = "/mnt/k3s/metrics"
          }
        }

        restart_policy = "Never"

        volume {
          name = "metrics-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.iperf-pvc.metadata[0].name
          }
        }
      }
    }

    backoff_limit = 4
  }
}
