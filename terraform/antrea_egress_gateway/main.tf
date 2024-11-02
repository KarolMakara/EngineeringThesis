resource "kubernetes_config_map" "antrea_config" {
  metadata {
    name      = "antrea-config"
    namespace = "kube-system"
  }

  data = {
    "antrea-agent.conf"     = <<-EOT
      featureGates:
        Egress: true
      EOT
    "antrea-controller.conf" = <<-EOT
      featureGates:
        Egress: true
      EOT
  }
}
