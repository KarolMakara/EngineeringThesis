resource "kubernetes_manifest" "gateway" {

  depends_on = [ kubernetes_deployment.echo_1, kubernetes_deployment.echo_2 ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "Gateway"
    metadata = {
      name = "cilium-gw"
      namespace = "default"
    }
    spec = {
      gatewayClassName = "cilium"
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

  depends_on = [ kubernetes_deployment.echo_1, kubernetes_deployment.echo_2 ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "HTTPRoute"
    metadata = {
      name = "example-route-1"
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