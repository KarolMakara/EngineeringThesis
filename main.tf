# Provider configuration for VirtualBox
provider "virtualbox" {
  version = "~> 2.5"
}

# Create a VirtualBox VM for Minikube
resource "virtualbox_vm" "minikube" {
  name           = "minikube"
  image          = "ubuntu/focal64"
  memory         = 4096
  cpu_cores      = 2
  network_adapter {
    nat {
      network = "nat_network"
    }
  }
}

# Network configuration for VirtualBox NAT
resource "virtualbox_nat_network" "nat_network" {
  name = "nat_network"
}

# Output the IP address of the Minikube VM
output "minikube_ip" {
  value = virtualbox_vm.minikube.network_adapter.0.nat.0.network
}
