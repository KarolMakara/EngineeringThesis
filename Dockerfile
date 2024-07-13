FROM debian:stable-slim AS builder

RUN apt-get update && \
    apt-get install -y curl wget build-essential && \
    wget https://github.com/esnet/iperf/releases/download/3.17.1/iperf-3.17.1.tar.gz && \
    tar xzf iperf-3.17.1.tar.gz && \
    cd iperf-3.17.1 && \
    ./configure && \
    make && \
    make install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y curl wget && \
    wget -O /usr/local/bin/statexec https://github.com/KarolMakara/statexec/releases/download/v1.0.3/statexec-linux-amd64 && \
    chmod +x /usr/local/bin/statexec && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/libiperf.so.0 /lib
COPY --from=builder /usr/local/bin/iperf3 /usr/local/bin/iperf3

CMD ["/bin/bash"]
