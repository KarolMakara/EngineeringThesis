FROM alpine:3.20.1

RUN apk --no-cache add curl wget && \
    cd /root && \
    wget -O /usr/local/bin/statexec https://github.com/blackswifthosting/statexec/releases/download/0.8.0/statexec-linux-amd64 && \
    chmod +x /usr/local/bin/statexec && \
    wget https://github.com/esnet/iperf/releases/download/3.17.1/iperf-3.17.1.tar.gz && \
    tar xzf iperf-3.17.1.tar.gz && \
    cd iperf-3.17.1 && \
    apk --no-cache add build-base && \
    ./configure && \
    make && \
    make install && \
    apk del build-base wget curl

ENTRYPOINT ["statexec"]
