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
          image = var.image
          command = [
            "/bin/sh",
            "-c",
            "/usr/local/bin/statexec --sync-until-succeed -c iperf-server-statexec --log-file ${local.iperf_client_json_path} --file ${local.statexec_iperf_client_metrics_path} -l cni=${var.CNI_NAME} -mst ${var.metrics_reference_time} -- /usr/local/bin/iperf3 -c iperf-server-statexec --json"
          ]
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "metrics-volume"
            mount_path = var.volume_mount_path
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
