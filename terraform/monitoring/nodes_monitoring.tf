resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_daemonset" "node_monitoring" {
  metadata {
    name      = "node-monitoring"
    namespace = "monitoring"
  }
  spec {
    selector {
      match_labels = {
        app = "node-monitoring"
      }
    }

    template {
      metadata {
        labels = {
          app = "node-monitoring"
        }
      }
      spec {

        host_pid     = "true"
        host_network = "true"

        container {
          name = "node-monitoring"
          image = "quay.io/prometheus/node-exporter:v1.8.2"
          command = [ "/bin/node_exporter" ]
          args = [
            "--path.procfs=/host/proc",
            "--path.sysfs=/host/sys",
            "--path.rootfs=/host/root",
            "--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)"
          ]

          port {
            container_port = 9100
          }

          volume_mount {
            name = "root-volume"
            mount_propagation = "HostToContainer"
            mount_path = "/host"
            read_only = "true"
          }

          volume_mount {
            name = "proc-volume"
            mount_propagation = "HostToContainer"
            mount_path = "/host/proc"
            read_only = "true"
          }

          volume_mount {
            name = "sys-volume"
            mount_propagation = "HostToContainer"
            mount_path = "/host/sys"
            read_only = "true"
          }
        }

        volume {
          name = "root-volume"
          host_path {
            path = "/"
          }
        }

        volume {
          name = "proc-volume"
          host_path {
            path = "/proc"
          }
        }

        volume {
          name = "sys-volume"
          host_path {
            path = "/sys"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "node_monitoring_service" {
  metadata {
    name      = "node-monitoring-service"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "node-monitoring"
    }

    port {
      port = 9100
      target_port = 9100
      node_port = 30910
    }

    type = "NodePort"
    external_traffic_policy = "Local"
  }

}

resource "kubernetes_config_map" "prometheus_config" {

  metadata {
    name      = "prometheus-config"
    namespace = "monitoring"
  }

  data = {
    "prometheus.yml" = file("${path.module}/prometheus/prometheus.yml")
  }

}

resource "kubernetes_deployment" "prometheus" {

  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prom-monitoring"
      }
    }

    template {
      metadata {
        labels = {
          app = "prom-monitoring"
        }
      }
      spec {

        security_context {
          fs_group = 2000
          run_as_non_root = "true"
          run_as_user = 1000
        }

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.55.0-rc.1"
          command = [ "/bin/prometheus" ]
          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus",
            "--web.console.libraries=/usr/share/prometheus/console_libraries",
            "--web.console.templates=/usr/share/prometheus/consoles"
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name = "prometheus-config-volume"
            mount_path = "/etc/prometheus/prometheus.yml"
            sub_path = "prometheus.yml"
          }

          volume_mount {
            name = "monitoring-data"
            mount_path = "/prometheus"
          }
        }



        volume {
          name = "prometheus-config-volume"
          config_map {
            name = "prometheus-config"
          }

        }

        volume {
          name = "monitoring-data"
          persistent_volume_claim {
            claim_name = "monitoring-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prom_monitoring_service" {
  metadata {
    name      = "prom-monitoring-service"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "prom-monitoring"
    }

    port {
      port = 9090
      target_port = 9090
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"

  volume_binding_mode = "Immediate"

  reclaim_policy = "Delete"
}


resource "kubernetes_persistent_volume_claim" "monitoring_data" {

  depends_on = [ kubernetes_storage_class.local_storage ]

  metadata {
    name = "monitoring-pvc"
    namespace = "monitoring"
  }

  spec {
    access_modes = [ "ReadWriteOnce" ]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "monitoring_data" {

  metadata {
    name = "monitoring-pv"
  }

  spec {
    capacity = {
      storage = "20Gi"
    }

    access_modes = [ "ReadWriteOnce" ]

    persistent_volume_source {
      host_path {
        path = "/host_shared_data/monitoring/prometheus_db"
      }
    }
  }
}

resource "kubernetes_deployment" "grafana" {

  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana-monitoring"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana-monitoring"
        }
      }
      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:11.2.2-security-01"

          port {
            container_port = 3000
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ORG_ROLE"
            value = "Admin"
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ENABLED"
            value = "true"
          }

          env {
            name  = "GF_AUTH_BASIC_ENABLED"
            value = "false"
          }

          env {
            name  = "GF_PATHS_PROVISIONING"
            value = "/etc/grafana/provisioning"
          }

          volume_mount {
            name = "grafana-provisioning-volume"
            mount_path = "/etc/grafana/provisioning/datasources/datasource.yml"
            sub_path = "datasource.yml"
          }

          volume_mount {
            name = "grafana-provisioning-volume"
            mount_path = "/etc/grafana/provisioning/dashboards/default.yml"
            sub_path = "default.yml"
          }

          volume_mount {
            name = "grafana-dashboards-volume"
            mount_path = "/var/lib/grafana/dashboards/node-exporter-dashboard.json"
            sub_path = "node-exporter-dashboard.json"
          }

          volume_mount {
            name = "grafana-dashboards-volume"
            mount_path = "/var/lib/grafana/dashboards/statexec-dashboard.json"
            sub_path = "statexec-dashboard.json"
          }
        }

        volume {
          name = "grafana-provisioning-volume"
          config_map {
            name = "grafana-provisioning"
          }
        }

        volume {
          name = "grafana-dashboards-volume"
          config_map {
            name = "grafana-dashboards"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana_service" {
  metadata {
    name      = "grafana-monitoring-service"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "grafana-monitoring"
    }

    port {
      port = 3000
      target_port = 3000
      node_port = 30300
    }

    type = "NodePort"
  }
}

resource "kubernetes_config_map" "grafana_provisioning" {

  metadata {
    name      = "grafana-provisioning"
    namespace = "monitoring"
  }

  data = {
    "default.yml"    = file("${path.module}/grafana/provisioning/dashboards/default.yml")
    "datasource.yml" = file("${path.module}/grafana/provisioning/datasources/datasource.yml")
  }

}

resource "kubernetes_config_map" "grafana_dashboards" {

  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
  }

  data = {
    "node-exporter-dashboard.json" = file("${path.module}/grafana/dashboards/node-exporter-dashboard.json")
    "statexec-dashboard.json" = file("${path.module}/grafana/dashboards/statexec-dashboard.json")
  }

}