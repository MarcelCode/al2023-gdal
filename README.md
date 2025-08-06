# Lambda GDAL Docker for Amazon Linux 2023 (AL2023)

A minimal GDAL build for AWS Lambda using Amazon Linux 2023 (AL2023) runtime. This project provides Docker images with GDAL and optional Go support for geospatial processing in AWS Lambda environments.

## Features

- Built on Amazon Linux 2023 (AL2023) for compatibility with AWS Lambda
- Minimal build with essential GDAL components
- Go runtime support available
- Deployable as AWS Lambda layers

## Supported Formats

The following geospatial formats are supported:
- GTIFF, MEM, VRT, Derived, HFA
- GeoJSON, TAB, Shape, KML

## Versions

- GDAL: 3.11.3
- Go: 1.24.5 (for Go runtime)

## Building Locally

To build the Docker image locally:

```bash
# Clone the repository
git clone https://github.com/yourusername/al2023-gdal.git
cd al2023-gdal

# Build the Docker image
docker build -t al2023-gdal:3.11 \
  --build-arg GDAL_VERSION=3.11.3 \
  -f dockerfiles/x86/Dockerfile .

# Build the Go runtime image (optional)
docker build -t al2023-gdal-go:3.11-1.24 \
  --build-arg GDAL_VERSION=3.11 \
  --build-arg GO_VERSION=1.24.5 \
  -f dockerfiles/x86/runtimes/go.Dockerfile .
```

## Testing

### Running Tests Locally

You can test the Docker image locally using the provided test scripts:

```bash
# Run tests with volume mount
docker run --entrypoint bash \
  -v /path/to/your/local/repo:/local \
  --rm -it al2023-gdal:3.11 \
  /local/tests/tests.sh
```

Example with absolute path:

```bash
docker run --entrypoint bash \
  -v /home/marcel/PycharmProjects/al2023-gdal:/local \
  --rm -it al2023-gdal:3.11 \
  /local/tests/tests.sh
```

### Interactive Shell

To get an interactive shell in the container:

```bash
docker run --entrypoint bash \
  -v /home/marcel/PycharmProjects/al2023-gdal:/local \
  --rm -it al2023-gdal:3.11
```

## CI/CD

This project uses GitHub Actions for continuous integration and deployment. The workflow:
1. Builds the GDAL Docker image
2. Runs tests to verify functionality
3. Publishes the image to GitHub Container Registry
4. Creates and deploys AWS Lambda layers

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

