locals {
  statexec_client_output_path         = "${var.volume_mount_path}/statexec_client_${var.cni_name}_${var.scenario}.log"
  statexec_iperf_client_metrics_path  = "${var.volume_mount_path}/statexec_iperf_client_metrics_${var.cni_name}_${var.scenario}.prom"
  iperf_client_json_path              = "${var.volume_mount_path}/iperf_client_json_${var.cni_name}_${var.scenario}.json"
}
