ARG GDAL_VERSION
FROM lambda-al2023-gdal:${GDAL_VERSION} as builder

RUN dnf update -y && \
    dnf install -y tar zip gzip curl-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/lib/dnf/history

RUN mkdir /tmp/go \
    && cd /tmp/go \
    && curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | tar -zx -C /usr/local \
    && rm -rf /tmp/go

FROM lambda-gdal:latest

COPY --from=builder /usr/local/go /usr/local/go

ENV PATH=$PATH:/usr/local/go/bin