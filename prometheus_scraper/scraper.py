import requests
import csv
import time
import os
import glob


metrics = {
    "cpu_system": "sum(irate(node_cpu_seconds_total{instance=\"$node\",job=\"$job\", mode=\"system\"}[5m])) / scalar(count(count(node_cpu_seconds_total{instance=\"$node\",job=\"$job\"}) by (cpu)))",
    "cpu_user": "sum(irate(node_cpu_seconds_total{instance=\"$node\",job=\"$job\", mode=\"user\"}[5m])) / scalar(count(count(node_cpu_seconds_total{instance=\"$node\",job=\"$job\"}) by (cpu)))",
    "cpu_iowait": "sum(irate(node_cpu_seconds_total{instance=\"$node\",job=\"$job\", mode=\"iowait\"}[5m])) / scalar(count(count(node_cpu_seconds_total{instance=\"$node\",job=\"$job\"}) by (cpu)))",
    "cpu_irq": "sum(irate(node_cpu_seconds_total{instance=\"$node\",job=\"$job\", mode=~\".*irq\"}[5m])) / scalar(count(count(node_cpu_seconds_total{instance=\"$node\",job=\"$job\"}) by (cpu)))",
    "cpu_other": "sum(irate(node_cpu_seconds_total{instance=\"$node\",job=\"$job\", mode!~\"idle|user|system|iowait|irq|softirq\"}[5m])) / scalar(count(count(node_cpu_seconds_total{instance=\"$node\",job=\"$job\"}) by (cpu)))",
    "cpu_idle": "sum(irate(node_cpu_seconds_total{instance=\"$node\",job=\"$job\", mode=\"idle\"}[5m])) / scalar(count(count(node_cpu_seconds_total{instance=\"$node\",job=\"$job\"}) by (cpu)))",  # Added idle metric
    "network_receive": "irate(node_network_receive_bytes_total{instance=\"$node\",job=\"$job\"}[5m])*8",
    "network_transmit": "irate(node_network_transmit_bytes_total{instance=\"$node\",job=\"$job\"}[5m])*8",
    "network_packets_transmit": "irate(node_network_transmit_packets_total{instance=\"$node\",job=\"$job\"}[5m])",
    "network_packets_receive": "irate(node_network_receive_packets_total{instance=\"$node\",job=\"$job\"}[5m])",
    "memory_usage": 'node_memory_MemTotal_bytes{instance=\"$node\",job=\"$job\"} - '
                   'node_memory_MemFree_bytes{instance=\"$node\",job=\"$job\"} - '
                   '(node_memory_Cached_bytes{instance=\"$node\",job=\"$job\"} + '
                   'node_memory_Buffers_bytes{instance=\"$node\",job=\"$job\"} + '
                   'node_memory_SReclaimable_bytes{instance=\"$node\",job=\"$job\"})'
}


def fetch_data(query):
    url = f"{base_url}?query={query}&start={start_time}&end={end_time}&step={step}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data: {e}")
        return None


def write_to_csv(filename, data, column_name='value'):
    try:
        with open(filename, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['timestamp', column_name])
            for item in data:
                writer.writerow(item)
    except Exception as e:
        print(f"Error writing to CSV file {filename}: {e}")


def sort_by_timestamp(data):
    return sorted(data, key=lambda x: x[0])


def merge_csv_files(file_pattern, output_file="merged_output.csv"):
    csv_files_loc = glob.glob(file_pattern)

    identifiers = {file.split(file_pattern.split("*")[0])[-1].split(".csv")[0]: file for file in csv_files_loc}

    timestamps = set()

    for identifier, file in identifiers.items():
        with open(file, mode='r') as f:
            reader = csv.reader(f)
            next(reader)
            for row in reader:
                timestamps.add(row[0])

    sorted_timestamps = sorted(timestamps)

    with open(output_file, mode='w', newline='') as file:
        writer = csv.writer(file)

        header = ['time'] + list(identifiers.keys())
        writer.writerow(header)

        for timestamp in sorted_timestamps:
            row = [timestamp]
            for identifier, file in identifiers.items():
                value = None
                with open(file, mode='r') as f:
                    reader = csv.reader(f)
                    next(reader)
                    for row_data in reader:
                        if row_data[0] == timestamp:
                            value = row_data[1]
                            break
                row.append(value)
            writer.writerow(row)
    for file in csv_files_loc:
        os.remove(file)

def main():
    csv_files = {}

    for metric_name, query in metrics.items():
        query = query.replace("$node", node).replace("$job", job)

        if "memory_usage" in metric_name:
            params = {
            'query': 'node_memory_MemTotal_bytes{instance="$node",job="$job"} - '
                    'node_memory_MemFree_bytes{instance="$node",job="$job"} - '
                    '(node_memory_Cached_bytes{instance="$node",job="$job"} + '
                    'node_memory_Buffers_bytes{instance="$node",job="$job"} + '
                    'node_memory_SReclaimable_bytes{instance="$node",job="$job"})',
            'start': f"{start_time}",
            'end': f"{end_time}",
            'step': '5s'
            }
            params["query"] = params["query"].replace("$node", node).replace("$job", job)
            response_data = requests.get(base_url, params=params)
            response_data = response_data.json()
        else:
            response_data = fetch_data(query)

        if response_data is None or not response_data.get("data", {}).get("result"):
            print(f"No data returned for {metric_name}")
            continue

        if "network_" in metric_name:
            values = response_data.get("data", {}).get("result", [])
            for val in values:
                metric_data = []
                device_name = val["metric"]["device"]
                actual_values = val["values"]
                for timestamp, value in actual_values:
                    metric_data.append([time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(float(timestamp))), value])
                metric_data = sort_by_timestamp(metric_data)
                csv_filename = f"{folder_path}/{metric_name}_{device_name}_{cni_name}_{run_id}_{node}.csv"
                write_to_csv(csv_filename, metric_data)
        else:
            values = response_data.get("data", {}).get("result", [])
            metric_data = []

            for result in values:
                for timestamp, value in result.get("values", []):
                    metric_data.append([time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(float(timestamp))), value])

            metric_data = sort_by_timestamp(metric_data)
            header = ["timestamp", metric_name]
            csv_filename = f"{folder_path}/{metric_name}_{cni_name}_{run_id}_{node}.csv"
            if "memory_usage" in metric_name:
                write_to_csv(csv_filename, metric_data, column_name="memory_usage")
            else:
                write_to_csv(csv_filename, metric_data)
            csv_files[metric_name] = csv_filename

    with open(f"{folder_path}/cpu_metrics_{cni_name}_{run_id}_{node}.csv", mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['timestamp', 'system', 'user', 'iowait', 'irq', 'other', 'idle'])

        timestamps = set()
        for metric_name in ["cpu_system", "cpu_user", "cpu_iowait", "cpu_irq", "cpu_other", "cpu_idle"]:
            with open(csv_files[metric_name], mode='r') as f:
                reader = csv.reader(f)
                next(reader)
                for row in reader:
                    timestamps.add(row[0])

        for timestamp in sorted(timestamps):
            row = [timestamp]
            for metric_name in ["cpu_system", "cpu_user", "cpu_iowait", "cpu_irq", "cpu_other", "cpu_idle"]:
                with open(csv_files[metric_name], mode='r') as f:
                    reader = csv.reader(f)
                    next(reader)
                    value = None
                    for row_data in reader:
                        if row_data[0] == timestamp:
                            value = row_data[1]
                            break
                    row.append(value)
            writer.writerow(row)




    merge_csv_files(f"{folder_path}/network_receive_*.csv", output_file=f"{folder_path}/merged_network_receive_{cni_name}_{run_id}_{node}.csv")
    merge_csv_files(f"{folder_path}/network_transmit_*.csv", output_file=f"{folder_path}/merged_network_transmit_{cni_name}_{run_id}_{node}.csv")
    merge_csv_files(f"{folder_path}/network_packets_receive_*.csv", output_file=f"{folder_path}/merged_network_packets_receive_{cni_name}_{run_id}_{node}.csv")
    merge_csv_files(f"{folder_path}/network_packets_transmit_*.csv", output_file=f"{folder_path}/merged_network_packets_transmit_{cni_name}_{run_id}_{node}.csv")

    for file in csv_files.values():
        if not "memory_usage" in file:
            os.remove(file)


base_url = "http://74.248.106.84:9090/api/v1/query_range"
job = "aks-servers"
step = "5s"
cni_name = "antrea"

start_time = "2024-11-10T13:01:18Z"
end_time = "2024-11-10T13:03:18Z"
node = "aks-0"
run_id = "1"

folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)

main()
node = "aks-1"
folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)
main()

start_time = "2024-11-10T13:05:11Z"
end_time = "2024-11-10T13:07:11Z"
node = "aks-0"
run_id = "10"

folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)

main()
node = "aks-1"
folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)
main()

start_time = "2024-11-10T13:19:02Z"
end_time = "2024-11-10T13:21:02Z"
node = "aks-0"
run_id = "100"

folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)

main()
node = "aks-1"
folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)
main()

start_time = "2024-11-10T13:32:51Z"
end_time = "2024-11-10T13:34:51Z"
node = "aks-0"
run_id = "1000"

folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)

main()
node = "aks-1"
folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)
main()

start_time = "2024-11-10T13:36:45Z"
end_time = "2024-11-10T13:38:45Z"
node = "aks-0"
run_id = "10000"

folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)

main()
node = "aks-1"
folder_path = f"{cni_name}_{run_id}/{node}"
os.makedirs(folder_path, exist_ok=True)
main()
