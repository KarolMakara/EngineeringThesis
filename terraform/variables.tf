variable "test_duraction" {
  description = "Duration in seconds for the iperf test to run"
  default     = 30
}

variable "volume_mount_path" {
  description = "Path to volume mount on host"
  default     = "/mnt/k3s/metrics"
  type        = string
}

variable "image" {
  description = "Docker image name"
  default     = "karolmakara/iperf-statexec:1.1.2"
  type        = string
}

