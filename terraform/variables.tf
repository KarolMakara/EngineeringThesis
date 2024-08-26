variable "client_test_duraction" {
  description = "Duration in seconds for the iperf test to run"
  default     = 10
}

variable "server_test_duraction" {
  description = "Duration in seconds for the iperf test to run"
  default     = 15
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
  description = "Sets a fixed reference time for metrics, to see all charts in period of time"
  default = "1013122800000"
  type = string
}
