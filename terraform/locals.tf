locals {
  iperf_server_log_path = "${var.volume_mount_path}/iperf_server.log"
  iperf_client_log_path = "${var.volume_mount_path}/iperf_client.log"
  statexec_iperf_server_metrics_path = "${var.volume_mount_path}/statexec_iperf_server_metrics.prom"
  statexec_iperf_client_metrics_path = "${var.volume_mount_path}/statexec_iperf_client_metrics.prom"
}
