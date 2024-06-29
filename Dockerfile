FROM alpine:3.20.1 AS builder

RUN apk --no-cache add curl wget build-base && \
    wget -O /usr/local/bin/statexec https://github.com/KarolMakara/statexec/releases/download/v1.0.1/statexec-linux-amd64.statexec-linux-amd64 && \
    chmod +x /usr/local/bin/statexec && \
    wget https://github.com/esnet/iperf/releases/download/3.17.1/iperf-3.17.1.tar.gz && \
    tar xzf iperf-3.17.1.tar.gz && \
    cd iperf-3.17.1 && \
    ./configure && \
    make && \
    make install


FROM alpine:3.20.1

RUN apk --no-cache add curl wget && \
    wget -O /usr/local/bin/statexec https://github.com/KarolMakara/statexec/releases/download/v1.0.0/statexec-linux-amd64 && \
    chmod +x /usr/local/bin/statexec

RUN apk del curl wget

COPY --from=builder /usr/local/bin/statexec /usr/local/bin/statexec
COPY --from=builder /usr/local/lib/libiperf.so.0 /usr/local/lib/libiperf.so.0
COPY --from=builder /usr/local/bin/iperf3 /usr/local/bin/iperf3

ENTRYPOINT ["/usr/local/bin/statexec"]
