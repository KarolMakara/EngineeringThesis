terraform {
  required_version = ">=1.9.4"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "1.15.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/EngineeringThesis/aks_terraform/azurek8s"
}

provider "azurerm" {
  subscription_id = "10a79cbd-9350-4de5-8011-ac3b9764fdc6"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}