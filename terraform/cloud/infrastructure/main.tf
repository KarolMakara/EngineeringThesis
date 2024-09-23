resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg${var.common_infix}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "cluster${var.common_infix}"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "dns${var.common_infix}"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.vm_type
    node_count = var.node_count
  }

  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "none"
    load_balancer_sku = "standard"
  }
}
