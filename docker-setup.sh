#!/bin/bash

# Docker Setup Script for Supervision
# This script helps users quickly set up and run the Supervision library in Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi

    print_status "Docker is installed and running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi

    print_status "Docker Compose is available: $COMPOSE_CMD"
}

# Function to create data directory
create_data_dir() {
    if [ ! -d "data" ]; then
        mkdir -p data
        print_status "Created data directory"
    fi
}

# Function to display usage
usage() {
    print_header "Supervision Docker Setup Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup                Set up and build Docker images"
    echo "  run                  Run the main supervision container"
    echo "  dev                  Run the development container"
    echo "  examples             Run the examples container"
    echo "  jupyter              Start Jupyter Lab"
    echo "  build                Build Docker images"
    echo "  clean                Clean up Docker images and containers"
    echo "  status               Show status of containers"
    echo "  logs [service]       Show logs for a service"
    echo "  shell [service]      Open shell in a running container"
    echo "  stop                 Stop all containers"
    echo "  help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup             # Initial setup"
    echo "  $0 run               # Run main container"
    echo "  $0 dev               # Start development environment"
    echo "  $0 jupyter           # Start Jupyter Lab"
    echo "  $0 shell supervision # Open shell in supervision container"
}

# Function to build images
build_images() {
    print_status "Building Docker images..."
    $COMPOSE_CMD build
    print_status "Docker images built successfully"
}

# Function to run setup
setup() {
    print_header "Setting up Supervision Docker environment..."

    check_docker
    check_docker_compose
    create_data_dir
    build_images

    print_status "Setup completed successfully!"
    echo ""
    print_status "You can now run:"
    echo "  $0 run      # Start main container"
    echo "  $0 dev      # Start development container"
    echo "  $0 jupyter  # Start Jupyter Lab"
}

# Function to run main container
run_main() {
    print_status "Starting supervision container..."
    $COMPOSE_CMD up -d supervision
    print_status "Container started. Access with: $COMPOSE_CMD exec supervision bash"
}

# Function to run development container
run_dev() {
    print_status "Starting development container..."
    $COMPOSE_CMD up -d supervision-dev
    print_status "Development container started. Access with: $COMPOSE_CMD exec supervision-dev bash"
}

# Function to run examples container
run_examples() {
    print_status "Starting examples container..."
    $COMPOSE_CMD up -d supervision-examples
    print_status "Examples container started. Access with: $COMPOSE_CMD exec supervision-examples bash"
}

# Function to start Jupyter
start_jupyter() {
    print_status "Starting Jupyter Lab..."
    $COMPOSE_CMD up -d supervision-dev
    $COMPOSE_CMD exec supervision-dev jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
}

# Function to show status
show_status() {
    print_status "Container status:"
    $COMPOSE_CMD ps
}

# Function to show logs
show_logs() {
    if [ -z "$1" ]; then
        $COMPOSE_CMD logs
    else
        $COMPOSE_CMD logs "$1"
    fi
}

# Function to open shell
open_shell() {
    if [ -z "$1" ]; then
        SERVICE="supervision"
    else
        SERVICE="$1"
    fi

    print_status "Opening shell in $SERVICE container..."
    $COMPOSE_CMD exec "$SERVICE" bash
}

# Function to stop containers
stop_containers() {
    print_status "Stopping all containers..."
    $COMPOSE_CMD down
    print_status "All containers stopped"
}

# Function to clean up
cleanup() {
    print_warning "This will remove all supervision Docker images and containers"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping containers..."
        $COMPOSE_CMD down

        print_status "Removing images..."
        docker rmi supervision:latest supervision-dev:latest 2>/dev/null || true

        print_status "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Main script logic
case "$1" in
    "setup")
        setup
        ;;
    "run")
        check_docker
        check_docker_compose
        run_main
        ;;
    "dev")
        check_docker
        check_docker_compose
        run_dev
        ;;
    "examples")
        check_docker
        check_docker_compose
        run_examples
        ;;
    "jupyter")
        check_docker
        check_docker_compose
        start_jupyter
        ;;
    "build")
        check_docker
        check_docker_compose
        build_images
        ;;
    "status")
        check_docker
        check_docker_compose
        show_status
        ;;
    "logs")
        check_docker
        check_docker_compose
        show_logs "$2"
        ;;
    "shell")
        check_docker
        check_docker_compose
        open_shell "$2"
        ;;
    "stop")
        check_docker
        check_docker_compose
        stop_containers
        ;;
    "clean")
        check_docker
        check_docker_compose
        cleanup
        ;;
    "help"|"--help"|"-h")
        usage
        ;;
    "")
        print_error "No command specified"
        echo ""
        usage
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac
