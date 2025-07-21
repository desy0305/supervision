#!/bin/bash
set -e

# Function to display usage
usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  bash                 Start interactive bash shell"
    echo "  python               Start Python interpreter"
    echo "  jupyter              Start Jupyter Lab server"
    echo "  test                 Run tests"
    echo "  example [name]       Run a specific example"
    echo "  demo                 Run the demo notebook"
    echo "  help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 example tracking"
    echo "  $0 jupyter"
    echo "  $0 test"
}

# Main command handling
case "$1" in
    "bash")
        exec /bin/bash
        ;;
    "python")
        exec python
        ;;
    "jupyter")
        echo "Starting Jupyter Lab..."
        exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
        ;;
    "test")
        echo "Running tests..."
        exec python -m pytest test/
        ;;
    "example")
        if [ -z "$2" ]; then
            echo "Available examples:"
            ls -1 examples/
            exit 1
        fi
        EXAMPLE_DIR="examples/$2"
        if [ -d "$EXAMPLE_DIR" ]; then
            echo "Running example: $2"
            cd "$EXAMPLE_DIR"
            if [ -f "requirements.txt" ]; then
                pip install -r requirements.txt
            fi
            exec /bin/bash
        else
            echo "Example '$2' not found!"
            echo "Available examples:"
            ls -1 examples/
            exit 1
        fi
        ;;
    "demo")
        echo "Starting demo notebook..."
        exec jupyter notebook demo.ipynb --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
        ;;
    "help"|"--help"|"-h")
        usage
        ;;
    "")
        echo "No command specified. Starting interactive bash shell..."
        exec /bin/bash
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac
