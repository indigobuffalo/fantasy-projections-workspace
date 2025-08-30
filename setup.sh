#!/bin/bash

# Fantasy Projections Workspace Setup Script

echo "🏒 Setting up Fantasy Projections Workspace..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker Desktop."
        return 1
    fi
    return 0
}

echo ""
echo "📋 Checking prerequisites..."

# Check Docker
if command_exists docker; then
    echo "✅ Docker found"
    if check_docker; then
        echo "✅ Docker is running"
    else
        echo "⚠️  Docker found but not running"
        echo "   Please start Docker Desktop and re-run this script"
        exit 1
    fi
else
    echo "❌ Docker not found"
    echo "   Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check Git
if command_exists git; then
    echo "✅ Git found"
else
    echo "❌ Git not found"
    echo "   Please install Git and re-run this script"
    exit 1
fi

echo ""
echo "📦 Initializing git submodules..."

# Initialize and update submodules
git submodule init
git submodule update

echo "✅ Submodules initialized"

echo ""
echo "🏗️  Building Docker images..."

# Build Docker images
./docker-start.sh --build > /dev/null 2>&1 &
BUILD_PID=$!

# Show a spinner while building
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  Building Docker images..." "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    done
    printf "    \n"
}

spinner $BUILD_PID
wait $BUILD_PID
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ Docker images built successfully"
else
    echo "❌ Failed to build Docker images"
    echo "   Try running: ./docker-start.sh --build"
    exit 1
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "🚀 Next steps:"
echo "   1. Start the development environment: ./docker-start.sh"
echo "   2. Open your browser:"
echo "      - Frontend: http://localhost:3000"
echo "      - API: http://localhost:8000"
echo "      - API Docs: http://localhost:8000/docs"
echo ""
echo "💡 Useful commands:"
echo "   ./docker-start.sh --logs    # Start and follow logs"
echo "   ./docker-start.sh --cli     # Include CLI container"
echo "   ./docker-start.sh --down    # Stop all services"
echo ""
echo "📖 For more information, see README.md"