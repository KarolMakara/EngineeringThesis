resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "Gateway"
    metadata = {
      name = "nginx-gw"
      namespace = "default"
    }
    spec = {
      gatewayClassName = "nginx"
      listeners = [
        {
          protocol = "HTTP"
          port = "80"
          name = "web-gw-echo"
          allowedRoutes = {
            namespaces = {
              from = "Same"
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "splitting_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "HTTPRoute"
    metadata = {
      name = "echo-route"
      namespace = "default"
    }
    spec = {
      parentRefs = [
        {
          name = "cilium-gw"
        }
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type = "PathPrefix"
                value = "/echo"
              }
            }
          ]
          backendRefs = [
            {
              kind = "Service"
              name = "echo-1"
              port = "8080"
              weight = "40"
            },
            {
              kind = "Service"
              name = "echo-2"
              port = "8090"
              weight = "60"
            }
          ]
        }
      ]
    }
  }
}