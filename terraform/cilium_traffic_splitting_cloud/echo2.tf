resource "kubernetes_service" "echo_2" {
  metadata {
    name = "echo-2"
    namespace = "default"
    labels = {
      app = "echo-2"
    }
  }

  spec {
    selector = {
      app = "echo-2"
    }
    port {
      port        = 8090
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_deployment" "echo_2" {
  metadata {
    name      = "echo-2"
    namespace = "default"
    labels = {
      app = "echo-2"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "echo-2"
      }
    }
    template {
      metadata {
        labels = {
          app = "echo-2"
        }
      }
      spec {
        container {
          name = "echo-2"
          image = "gcr.io/kubernetes-e2e-test-images/echoserver:2.2"

          port {
            container_port = 8080
          }

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/hostname"
                  operator = "In"
                  values   = ["aks-agentpool-33881195-vmss000001"]
                }
              }
            }
          }
        }
      }
    }
  }
}