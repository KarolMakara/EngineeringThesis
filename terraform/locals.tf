locals {
  statexec_client_output_path = "${var.volume_mount_path}/statexec_client_$(date +%Y%m%d%H%M%S).log"
  statexec_server_output_path = "${var.volume_mount_path}/statexec_server_$(date +%Y%m%d%H%M%S).log"
  iperf_client_log_path = "${var.volume_mount_path}/iperf_client_$(date +%Y%m%d%H%M%S).log"
  iperf_server_log_path = "${var.volume_mount_path}/iperf_server_$(date +%Y%m%d%H%M%S).log"
  statexec_iperf_client_metrics_path = "${var.volume_mount_path}/statexec_iperf_client_metrics_$(date +%Y%m%d%H%M%S).prom"
  statexec_iperf_server_metrics_path = "${var.volume_mount_path}/statexec_iperf_server_metrics_$(date +%Y%m%d%H%M%S).prom"
  iperf_client_json_path = "${var.volume_mount_path}/iperf_client_json_$(date +%Y%m%d%H%M%S).json"
  iperf_server_json_path = "${var.volume_mount_path}/iperf_server_json_$(date +%Y%m%d%H%M%S).json"
}
