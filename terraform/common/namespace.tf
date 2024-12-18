resource "kubernetes_namespace" "iperf" {
  metadata {
    name = "iperf"
  }
}
