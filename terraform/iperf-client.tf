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
          image = "${var.image}"
          # command = ["/bin/sh", "-c", "/usr/local/bin/statexec --sync-until-succeed -c iperf-server -- iperf3 -c iperf-server -t ${var.test_duraction} > ${local.iperf_client_log_path} 2>&1 && cp statexec_metrics.prom ${local.statexec_iperf_client_metrics_path}"]
          command = ["sh", "-c", "ping -c 333 iperf-server-service"]
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "metrics-volume"
            mount_path = "${var.volume_mount_path}"
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
