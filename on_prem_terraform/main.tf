provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "iperf" {
  metadata {
    name = "iperf-namespace"
  }
}


