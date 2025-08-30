#!/bin/bash

# Fantasy Projections Docker Environment Starter

echo "🚀 Starting Fantasy Projections Docker Environment..."

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker Desktop and try again."
        exit 1
    fi
}

# Function to display usage
show_help() {
    echo "Usage: ./docker-start.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --cli         Start with CLI container (for running Python CLI commands)"
    echo "  --build       Force rebuild of all images"
    echo "  --logs        Follow logs after starting"
    echo "  --down        Stop and remove all containers"
    echo "  --clean       Stop containers and remove volumes (⚠️  deletes data)"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./docker-start.sh                # Start web + API + database"
    echo "  ./docker-start.sh --cli          # Start all services + CLI"
    echo "  ./docker-start.sh --build --logs # Rebuild and follow logs"
    echo "  ./docker-start.sh --down         # Stop all services"
}

# Parse arguments
BUILD_FLAG=""
LOGS_FLAG=""
CLI_PROFILE=""
ACTION="up"

while [[ $# -gt 0 ]]; do
    case $1 in
        --cli)
            CLI_PROFILE="--profile cli"
            shift
            ;;
        --build)
            BUILD_FLAG="--build"
            shift
            ;;
        --logs)
            LOGS_FLAG="--follow"
            shift
            ;;
        --down)
            ACTION="down"
            shift
            ;;
        --clean)
            ACTION="clean"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check Docker
check_docker

case $ACTION in
    "up")
        echo "📦 Starting containers..."
        if [[ -n "$LOGS_FLAG" ]]; then
            docker compose up $BUILD_FLAG $CLI_PROFILE --detach
            echo "✅ Containers started!"
            echo "🔗 Frontend: http://localhost:3000"
            echo "🔗 API: http://localhost:8000"
            echo "🔗 API Docs: http://localhost:8000/docs"
            echo ""
            echo "📋 Following logs (Ctrl+C to exit)..."
            docker compose logs --follow
        else
            docker compose up $BUILD_FLAG $CLI_PROFILE --detach
            echo "✅ Containers started!"
            echo "🔗 Frontend: http://localhost:3000"
            echo "🔗 API: http://localhost:8000"
            echo "🔗 API Docs: http://localhost:8000/docs"
            echo ""
            echo "💡 Run './docker-start.sh --logs' to follow logs"
            echo "💡 Run 'docker compose logs -f [service]' to follow specific service"
        fi
        ;;
    "down")
        echo "⏹️  Stopping containers..."
        docker compose down
        echo "✅ Containers stopped!"
        ;;
    "clean")
        echo "⚠️  This will delete all data in the database!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🧹 Stopping containers and removing volumes..."
            docker compose down --volumes --remove-orphans
            echo "✅ Cleanup complete!"
        else
            echo "❌ Cancelled"
        fi
        ;;
esac