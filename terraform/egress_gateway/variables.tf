variable "test_duration" {
  description = "Duration in seconds for the iperf test to run"
}

variable "volume_mount_path" {
  description = "Path to volume mount on host"
  type        = string
}

variable "image" {
  description = "Docker image name"
  default     = "karolmakara/iperf-statexec:2.0.0"
  type        = string
}

variable "cni_name" {
  description = "The type of CNI to use"
  type        = string
}

variable "scenario" {
  description = "Scenario name"
  type        = string
}

variable "metrics_reference_time" {
  description = "Set fixed reference time for metrics, to see all charts in period of time"
  default = "1013158800000"
  type = string
}

variable "real_host_ip" {
  description = "Real host machine ip"
  type        = string
}