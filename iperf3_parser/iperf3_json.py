import json
from pprint import pprint
import matplotlib.pyplot as plt
import numpy as np


file_name = '/mnt/k3d/egress_gateway/iperf_client_json_cilium_egress_gateway.json'


with open(file_name, 'r') as file:
    data = json.load(file)

bits_per_second = []
for interval in data["intervals"]:
    for stream in interval["streams"]:
        bits_per_second.append(stream["bits_per_second"])


data = np.array(bits_per_second) / 1_000_000_000

x = np.arange(len(data))
mean_value = np.mean(data)


plt.plot(x, data, marker='o', label='Data')
plt.axhline(y=mean_value, color='r', linestyle='--', label=f'Mean = {mean_value:.2f}')

plt.title('Simple Array Plot')
plt.xlabel('Index')
plt.ylabel('Gb/s')
plt.grid(True)
plt.xticks(x)
plt.show()