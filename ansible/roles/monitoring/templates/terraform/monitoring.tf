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
  }

}