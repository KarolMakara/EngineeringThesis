resource "kubernetes_service" "echo_1" {
  metadata {
    name = "echo-1"
    labels = {
      app = "echo-1"
    }
  }

  spec {
    selector = {
      app = "echo-1"
    }
    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_deployment" "echo_1" {
  metadata {
    name      = "echo-1"
    namespace = "default"
    labels = {
      app = "echo-1"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "echo-1"
      }
    }
    template {
      metadata {
        labels = {
          app = "echo-1"
        }
      }
      spec {
        container {
          name = "echo-1"
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
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
        }
      }
    }
  }
}