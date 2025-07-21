# Docker Setup for Supervision

This directory contains Docker configuration files to containerize the Supervision computer vision library.

## Quick Start

### Build and Run with Docker Compose (Recommended)

```bash
# Build and start the main supervision container
docker-compose up -d supervision

# Access the container
docker-compose exec supervision bash

# Or run examples
docker-compose up -d supervision-examples
docker-compose exec supervision-examples bash
```

### Build and Run with Docker

```bash
# Build the image
docker build -t supervision .

# Run interactively
docker run -it --rm \
  -v $(pwd):/app \
  -v $(pwd)/data:/app/data \
  -p 8000:8000 \
  supervision

# Run a specific example
docker run -it --rm \
  -v $(pwd):/app \
  -w /app/examples/tracking \
  supervision bash
```

## Available Docker Configurations

### 1. Production Dockerfile (`Dockerfile`)
- Minimal Python 3.11 slim image
- Essential dependencies for running supervision
- Non-root user for security
- Optimized for production use

### 2. Development Dockerfile (`Dockerfile.dev`)
- Includes development tools and dependencies
- Jupyter Lab support
- Additional debugging and development utilities
- All optional dependencies included

### 3. Docker Compose (`docker-compose.yml`)
- **supervision**: Main service for running the library
- **supervision-examples**: Pre-configured for running examples
- **supervision-dev**: Development environment with all tools

## Usage Examples

### Running Examples

```bash
# Start the examples container
docker-compose up -d supervision-examples
docker-compose exec supervision-examples bash

# Navigate to a specific example
cd tracking
pip install -r requirements.txt
python ultralytics_example.py
```

### Development Environment

```bash
# Start development container with all tools
docker-compose up -d supervision-dev
docker-compose exec supervision-dev bash

# Run tests
python -m pytest test/

# Start Jupyter Lab
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

### Using the Entrypoint Script

The containers include a helpful entrypoint script:

```bash
# Start Jupyter Lab
docker run -it --rm -p 8888:8888 supervision ./docker-entrypoint.sh jupyter

# Run tests
docker run -it --rm supervision ./docker-entrypoint.sh test

# Run a specific example
docker run -it --rm supervision ./docker-entrypoint.sh example tracking

# Show help
docker run -it --rm supervision ./docker-entrypoint.sh help
```

## Volume Mounts

The Docker setup includes several useful volume mounts:

- `.:/app` - Mount the entire project for development
- `./data:/app/data` - Mount data directory for input/output files
- `./examples:/app/examples` - Mount examples directory

## Ports

- `8000`: General application port
- `8888`: Jupyter Lab/Notebook
- `8080`: Additional development server port

## Environment Variables

- `PYTHONPATH=/app` - Ensures the supervision package is in Python path
- `PYTHONUNBUFFERED=1` - Ensures Python output is not buffered
- `PYTHONDONTWRITEBYTECODE=1` - Prevents Python from writing .pyc files

## System Dependencies

The Docker images include all necessary system dependencies for:
- OpenCV and computer vision operations
- Scientific computing (NumPy, SciPy, etc.)
- Video processing (FFmpeg in dev image)
- Development tools (Git, editors, etc.)

## Security

- Containers run as non-root user `appuser`
- Minimal attack surface with slim base images
- No unnecessary packages in production image

## Troubleshooting

### Common Issues

1. **Permission Issues**: Make sure the mounted directories have proper permissions
2. **GPU Support**: For GPU acceleration, use nvidia-docker runtime
3. **Memory Issues**: Increase Docker memory limits for large video processing

### GPU Support (Optional)

To enable GPU support for accelerated inference:

```bash
# Install nvidia-docker2 first, then:
docker run --gpus all -it --rm supervision
```

### Building for Different Architectures

```bash
# Build for ARM64 (Apple Silicon)
docker buildx build --platform linux/arm64 -t supervision:arm64 .

# Build for AMD64
docker buildx build --platform linux/amd64 -t supervision:amd64 .
```

## Contributing

When contributing to the Docker setup:

1. Test both production and development Dockerfiles
2. Ensure examples work in containerized environment
3. Update this README with any new features
4. Keep images as minimal as possible while maintaining functionality
