resource "kubernetes_deployment" "iperf_server" {
  metadata {
    name      = "iperf-server"
    namespace = "iperf-namespace"
    labels = {
      app = "iperf-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "iperf-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "iperf-server"
        }
      }

      spec {
        container {
          name  = "iperf-server"
          image = var.image
          command = [
            "/bin/sh",
            "-c",
            "/usr/local/bin/statexec -s --log-file ${local.iperf_server_json_path} --file ${local.statexec_iperf_server_metrics_path} -l cni=${var.CNI_NAME} -- /usr/local/bin/iperf3 -s --json"
          ]

          port {
            container_port = 8080
          }
          port {
            container_port = 5201
          }

          volume_mount {
            name       = "metrics-volume"
            mount_path = var.volume_mount_path
          }
        }

        volume {
          name = "metrics-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.iperf-pvc.metadata[0].name
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "iperf_server_service_statexec" {
  metadata {
    name      = "iperf-server-statexec"
    namespace = "iperf-namespace"
  }

  spec {
    selector = {
      app = "iperf-server"
    }

    port {
      name        = "statexec"
      port        = 8080
      target_port = 8080
    }

    port {
      name        = "iperf"
      port        = 5201
      target_port = 5201
    }

    type = "ClusterIP"
  }
}
