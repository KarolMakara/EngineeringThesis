variable "test_duraction" {
  description = "Duration in seconds for the iperf test to run"
  default     = 60
}

variable "volume_mount_path" {
  description = "Path to volume mount on host"
  default     = "/mnt/k3s/metrics"
  type        = string
}

variable "image" {
  description = "Docker image name"
  default     = "karolmakara/iperf-statexec:2.0.0"
  type        = string
}

variable "CNI_NAME" {
  description = "The type of CNI to use"
  type        = string
}

variable "metrics_reference_time" {
  description = "Set fixed reference time for metrics, to see all charts in period of time"
  default = "1013158800000"
  type = string
}

variable "resource_group_location" {
  type        = string
  default     = "polandcentral"
  description = "Resources location"
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "thesis"
  description = "Prefix of the resource group in Azure subscription."
}

variable "node_count" {
  type        = number
  description = "Nodes quantity"
  default     = 2
}

variable "username" {
  type        = string
  description = "Admin username for cluster"
  default     = "azureadmin"
}

variable "vm_type" {
  description = "Azure vm type"
  default     = "Standard_A2_v2"
  type        = string
}

variable "SUBSCRIPTION" {
  description = "Azure subscription id"
  type        = string
}

variable "common_infix" {
  description = "Common infix for cloud resources"
  type        = string
  default     = "engineering_thesis"
}