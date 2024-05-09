terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

// Namespaces
resource "kubernetes_namespace" "stars" {
  metadata {
    name = "stars"
  }
}

resource "kubernetes_namespace" "management_ui" {
  metadata {
    name = "management-ui"
    labels = {
      role = "management-ui"
    }
  }
}

resource "kubernetes_namespace" "client" {
  metadata {
    name = "client"
    labels = {
      role = "client"
    }
  }
}

// Services
resource "kubernetes_service" "management_ui" {
  metadata {
    name = "management-ui"
    namespace = kubernetes_namespace.management_ui.metadata.0.name
  }

  spec {
    type = "NodePort"

    selector = {
      role = "management-ui"
    }

    port {
      port = 9001
      target_port = 9001
      node_port = 30002
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
    namespace = kubernetes_namespace.stars.metadata.0.name
  }

  spec {
    port {
      port = 6379
      target_port = 6379
    }

    selector = {
      role = "backend"
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    namespace = kubernetes_namespace.stars.metadata.0.name
  }

  spec {
    port {
      port = 80
      target_port = 80
    }

    selector = {
      role = "frontend"
    }
  }
}

resource "kubernetes_service" "client" {
  metadata {
    name = "client"
    namespace = kubernetes_namespace.client.metadata.0.name
  }

  spec {
    port {
      port = 9000
      target_port = 9000
    }

    selector = {
      role = "client"
    }
  }
}

// Deployments
resource "kubernetes_deployment" "management_ui" {
  metadata {
    name = "management-ui"
    namespace = kubernetes_namespace.management_ui.metadata.0.name
    labels = {
      role = "management-ui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        role = "management-ui"
      }
    }

    template {
      metadata {
        labels = {
          role = "management-ui"
        }
      }

      spec {
        container {
          name = "management-ui"
          image = "calico/star-collect:multiarch"
          image_pull_policy = "Always"

          port {
            container_port = 9001
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
    namespace = kubernetes_namespace.stars.metadata.0.name
    labels = {
      role = "backend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        role = "backend"
      }
    }

    template {
      metadata {
        labels = {
          role = "backend"
        }
      }

      spec {
        container {
          name = "backend"
          image = "calico/star-probe:multiarch"
          image_pull_policy = "Always"
          command = ["probe", "--http-port=6379", "--urls=http://frontend.stars:80/status,http://backend.stars:6379/status,http://client.client:9000/status"]

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    namespace = kubernetes_namespace.stars.metadata.0.name
    labels = {
      role = "frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        role = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          role = "frontend"
        }
      }

      spec {
        container {
          name = "frontend"
          image = "calico/star-probe:multiarch"
          image_pull_policy = "Always"
          command = ["probe", "--http-port=80", "--urls=http://frontend.stars:80/status,http://backend.stars:6379/status,http://client.client:9000/status"]

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "client" {
  metadata {
    name = "client"
    namespace = kubernetes_namespace.client.metadata.0.name
    labels = {
      role = "client"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        role = "client"
      }
    }

    template {
      metadata {
        labels = {
          role = "client"
        }
        annotations = {
          "kubernetes.io/ingress-bandwidth" = "1M"
          "kubernetes.io/egress-bandwidth"  = "1M"
        }
      }

      spec {
        container {
          name = "client"
          image = "calico/star-probe:multiarch"
          image_pull_policy = "Always"
          command = ["probe", "--urls=http://frontend.stars:80/status,http://backend.stars:6379/status"]

          port {
            container_port = 9000
          }
        }

      }
    }
  }
}

resource "kubernetes_network_policy" "allow_ui_client" {
  metadata {
    name      = "allow-ui"
    namespace = kubernetes_namespace.client.metadata.0.name
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            role = "management-ui"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_ui_stars" {
  metadata {
    name      = "allow-ui"
    namespace = kubernetes_namespace.stars.metadata.0.name
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            role = "management-ui"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "backend_policy" {
  metadata {
    name      = "backend-policy"
    namespace = kubernetes_namespace.stars.metadata.0.name
  }

  spec {
    pod_selector {
      match_labels = {
        role = "backend"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            role = "frontend"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 6379
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name = "default-deny"
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "frontend_policy" {
  metadata {
    name      = "frontend-policy"
    namespace = kubernetes_namespace.stars.metadata.0.name
  }

  spec {
    pod_selector {
      match_labels = {
        role = "frontend"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            role = "client"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 80
      }
    }

    policy_types = ["Ingress"]
  }
}


