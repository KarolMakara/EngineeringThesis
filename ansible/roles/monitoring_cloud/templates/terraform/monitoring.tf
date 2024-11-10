resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_config_map" "grafana_dashboards" {

  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
  }

  data = {
    "cilium-dashboard.json" = file("${path.module}/../dashboards/cilium-dashboard.json")
    "cilium-operator-dashboard.json" = file("${path.module}/../dashboards/cilium-operator-dashboard.json")
    "hubble-dashboard.json" = file("${path.module}/../dashboards/hubble-dashboard.json")
    "hubble-l7-http-metrics-by-workload.json" = file("${path.module}/../dashboards/hubble-l7-http-metrics-by-workload.json")
    "node-exporter-dashboard-cmap.json" = file("${path.module}/../dashboards/node-exporter-dashboard-cmap.json")
    "statexec-dashboard.json" = file("${path.module}/../dashboards/statexec-dashboard.json")
  }

}

resource "kubernetes_deployment" "victoriametrics" {
  metadata {
    name = "victoriametrics"
    namespace = "monitoring"
  }

  spec {
    selector {
      match_labels = {
        app = "victoriametrics"
      }
    }
    template {
      metadata {
        labels = {
          app = "victoriametrics"
        }
      }
      spec {
        container {
          name  = "victoriametrics"
          image = "victoriametrics/victoria-metrics:v1.93.10"
          command = ["/victoria-metrics-prod"]
          args = [
            "-search.disableCache",
            "-retentionPeriod=30y",
            "-dedup.minScrapeInterval=1s"
          ]

          port {
            container_port = 8428
          }

          volume_mount {
            name = "victoriametrics-data-volume"
            mount_path = "/victoria-metrics-data"
          }
        }

        volume {
          name = "victoriametrics-data-volume"
          host_path {
            path = "/host_shared_data/monitoring/victoriametrics_db"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "victoriametrics_public_service" {
  metadata {
    name = "victoriametrics-public-service"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "victoriametrics"
    }

    port {
      port = 8428
      target_port = 8428
      node_port = 30842
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "victoriametrics_service" {
  metadata {
    name      = "victoriametrics-service"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "victoriametrics"
    }

    port {
      port = 8428
      target_port = 8428
    }

    type = "ClusterIP"
  }
}
