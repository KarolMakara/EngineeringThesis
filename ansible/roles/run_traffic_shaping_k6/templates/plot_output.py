import re
import matplotlib.pyplot as plt
import numpy as np

echo1_count = 0
total_count = 0

curr_ratio = []

with open('output.log', 'r') as file:
    for line in file:
        match = re.search(r'(echo-\d)', line)
        if match:
            hostname = match.group(1)
            total_count += 1
            if hostname == 'echo-1':
                echo1_count += 1
        echo1_ratio = 100 * echo1_count / total_count
        curr_ratio.append(echo1_ratio)

x = np.arange(len(curr_ratio))
plt.plot(x, curr_ratio, color='skyblue')
plt.ylabel('Ratio')
plt.ylim(35, 45)
plt.title(f'echo-1 weight:40 pod')
plt.axhline(y=40, color='r', linestyle='--', label=f'Mean = {40:.2f}')
plt.show()

