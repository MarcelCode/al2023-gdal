ARG GDAL_VERSION
FROM ghcr.io/marcelcode/al2023-gdal:${GDAL_VERSION}

ARG GO_VERSION
RUN mkdir /tmp/go \
    && cd /tmp/go \
    && curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -zx -C /usr/local \
    && rm -rf /tmp/go

ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin