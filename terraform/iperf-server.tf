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
          image = "${var.image}"
          # command = ["/bin/sh", "-c", "/usr/local/bin/statexec -s --command-timeout ${var.test_duraction} -- /usr/local/bin/iperf3 -s > ${local.iperf_server_log_path} 2>&1 && cp statexec_metrics.prom ${local.statexec_iperf_client_metrics_path}"]
          command = ["ping", "localhost", "-c", "100"]

          port {
            container_port = 5201
          }

          volume_mount {
            name       = "metrics-volume"
            mount_path = "${var.volume_mount_path}"
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

resource "kubernetes_service" "iperf_server_service" {
  metadata {
    name = "iperf-server-service"
    namespace = "iperf-namespace"
  }

  spec {
    selector = {
      app = "iperf-server"
    }

    port {
      port        = 80
      target_port = 5201
    }

    type = "ClusterIP"
  }
}
