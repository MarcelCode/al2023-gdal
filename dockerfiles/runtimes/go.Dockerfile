ARG GDAL_VERSION
FROM ghcr.io/marcelcode/lambda-al2023-gdal:${GDAL_VERSION} as builder

RUN dnf update -y && \
    dnf install -y tar zip gzip curl-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/lib/dnf/history

ARG GO_VERSION
RUN mkdir /tmp/go \
    && cd /tmp/go \
    && curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -zx -C /usr/local \
    && rm -rf /tmp/go

ARG GDAL_VERSION
FROM ghcr.io/marcelcode/lambda-al2023-gdal:${GDAL_VERSION}

COPY --from=builder /usr/local/go /usr/local/go

ENV PATH=$PATH:/usr/local/go/bin