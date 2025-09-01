#!/bin/bash

# Fantasy Projections Docker Development Script

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
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if docker-compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose is not installed or not in PATH."
        exit 1
    fi
}

# Function to show service status
show_status() {
    print_header "=== Service Status ==="
    docker-compose ps
    echo
    
    print_header "=== Health Checks ==="
    
    # Check API health
    if curl -f http://localhost:8000/api/health > /dev/null 2>&1; then
        print_status "✅ API is healthy (http://localhost:8000)"
    else
        print_warning "❌ API health check failed"
    fi
    
    # Check Frontend health
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        print_status "✅ Frontend is healthy (http://localhost:3000)"
    else
        print_warning "❌ Frontend health check failed"
    fi
    
    # Check Database
    if docker-compose exec postgres pg_isready -U fantasy_user -d fantasy_draft > /dev/null 2>&1; then
        print_status "✅ Database is healthy"
    else
        print_warning "❌ Database health check failed"
    fi
    
    # Check Redis
    if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
        print_status "✅ Redis is healthy"
    else
        print_warning "❌ Redis health check failed"
    fi
}

# Function to wait for services to be healthy
wait_for_services() {
    print_status "Waiting for services to be healthy..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Attempt $attempt/$max_attempts"
        
        if curl -f http://localhost:8000/api/health > /dev/null 2>&1 && \
           curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
            print_status "✅ All services are healthy!"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "Services did not become healthy within expected time"
            show_status
            exit 1
        fi
        
        sleep 10
        ((attempt++))
    done
}

# Function to show logs
show_logs() {
    local service=${1:-""}
    if [ -n "$service" ]; then
        print_header "=== Logs for $service ==="
        docker-compose logs -f "$service"
    else
        print_header "=== All Service Logs ==="
        docker-compose logs -f
    fi
}

# Main script logic
case "${1:-help}" in
    "start"|"up")
        print_header "🚀 Starting Fantasy Projections Development Environment"
        check_docker
        check_docker_compose
        
        print_status "Building and starting services..."
        docker-compose up -d --build
        
        wait_for_services
        show_status
        
        print_header "🎉 Development environment is ready!"
        echo
        print_status "Access points:"
        print_status "  - Frontend: http://localhost:3000"
        print_status "  - API: http://localhost:8000"
        print_status "  - API Docs: http://localhost:8000/docs"
        print_status "  - Database: localhost:5432"
        print_status "  - Redis: localhost:6379"
        echo
        print_status "Use './scripts/docker-dev.sh logs' to view logs"
        print_status "Use './scripts/docker-dev.sh stop' to stop services"
        ;;
        
    "stop"|"down")
        print_header "🛑 Stopping Fantasy Projections Development Environment"
        docker-compose down
        print_status "Services stopped"
        ;;
        
    "restart")
        print_header "🔄 Restarting Fantasy Projections Development Environment"
        docker-compose down
        docker-compose up -d --build
        wait_for_services
        show_status
        ;;
        
    "status")
        show_status
        ;;
        
    "logs")
        show_logs "${2:-}"
        ;;
        
    "build")
        print_header "🔨 Building Docker Images"
        docker-compose build --no-cache
        print_status "Build complete"
        ;;
        
    "clean")
        print_header "🧹 Cleaning Up Docker Resources"
        print_warning "This will remove all containers, networks, and unused images"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v
            docker system prune -f
            docker volume prune -f
            print_status "Cleanup complete"
        else
            print_status "Cleanup cancelled"
        fi
        ;;
        
    "shell")
        service="${2:-api}"
        print_header "🐚 Opening shell in $service container"
        docker-compose exec "$service" /bin/bash
        ;;
        
    "help"|*)
        print_header "Fantasy Projections Docker Development Script"
        echo
        echo "Usage: $0 [command]"
        echo
        echo "Commands:"
        echo "  start, up      - Build and start all services"
        echo "  stop, down     - Stop all services"
        echo "  restart        - Restart all services"
        echo "  status         - Show service status and health"
        echo "  logs [service] - Show logs (optionally for specific service)"
        echo "  build          - Build Docker images"
        echo "  clean          - Clean up Docker resources (removes volumes)"
        echo "  shell [service]- Open shell in container (default: api)"
        echo "  help           - Show this help message"
        echo
        echo "Services: api, frontend, postgres, redis, celery-worker"
        ;;
esac