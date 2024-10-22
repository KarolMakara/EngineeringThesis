resource "docker_container" "nginx_container" {
  name  = "client"
  image = "nginx:alpine"

  networks_advanced {
    name = var.k3d_network_id
  }

  tty = true
}

resource "null_resource" "get_container_ip" {

  depends_on = [ docker_container.nginx_container ]

  provisioner "local-exec" {
    command = <<EOT
      docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${docker_container.nginx_container.name} > /tmp/container.ip
    EOT
  }

}

data "local_file" "container_ip" {
  filename = "/tmp/container.ip"
  depends_on = [ null_resource.get_container_ip ]
}

resource "kubernetes_pod" "iperf_client_pod" {

  depends_on = [ null_resource.get_container_ip ]

  metadata {
    name = "iperf-client"
    labels = {
      app = "iperf-client"
    }
    namespace = "iperf"
  }

  spec {
    container {
      image = "alpine:latest"
      name  = "iperf"

      command = ["/bin/sh", "-c"]
      args    = [
        "sleep 3600"
        # "apk add --no-cache curl && curl -I $(CONTAINER_IP)"
      ]

      env {
        name  = "CONTAINER_IP"
        value = data.local_file.container_ip.content
      }

    }
  }

}
