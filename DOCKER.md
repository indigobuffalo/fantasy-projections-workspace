# Docker Development Environment

This document explains how to use Docker Compose to run the complete Fantasy Projections application stack locally.

## Prerequisites

- Docker Desktop installed and running
- At least 4GB of available RAM
- Ports 3000, 5432, 6379, and 8000 available on your machine

## Quick Start

### Option 1: Using the Development Script (Recommended)

```bash
# Start the entire application stack
./scripts/docker-dev.sh start

# Check service status
./scripts/docker-dev.sh status

# View logs
./scripts/docker-dev.sh logs

# Stop services
./scripts/docker-dev.sh stop
```

### Option 2: Using Docker Compose Directly

```bash
# Start all services in detached mode
docker-compose up -d --build

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Services

The Docker Compose setup includes the following services:

### Core Services

| Service | Port | Description | Health Check |
|---------|------|-------------|--------------|
| **frontend** | 3000 | Next.js web application | `http://localhost:3000/api/health` |
| **api** | 8000 | Python FastAPI backend | `http://localhost:8000/api/health` |
| **postgres** | 5432 | PostgreSQL database | Internal health check |
| **redis** | 6379 | Redis cache/message broker | Internal health check |
| **celery-worker** | - | Background task processor | Internal health check |

### Access Points

- **Frontend Application**: http://localhost:3000
- **API Documentation**: http://localhost:8000/docs
- **API Health Check**: http://localhost:8000/api/health
- **Database Connection**: `postgresql://fantasy_user:fantasy_pass@localhost:5432/fantasy_draft`
- **Redis Connection**: `redis://localhost:6379/0`

## Environment Variables

The Docker setup uses the following environment variables (automatically configured):

### Backend (API & Celery)
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `ENVIRONMENT`: Set to `development`
- `PYTHONPATH`: Python path configuration
- `JWT_SECRET_KEY`: JWT signing key (development only)
- `CORS_ORIGINS`: Allowed CORS origins

### Frontend
- `NEXT_PUBLIC_API_URL`: Backend API URL
- `NODE_ENV`: Set to `development`
- `NEXT_TELEMETRY_DISABLED`: Disables Next.js telemetry

## Development Workflow

### Starting Development

```bash
# Start the entire stack
./scripts/docker-dev.sh start

# Wait for all services to be healthy
# The script will automatically wait and report status
```

### Making Code Changes

The Docker setup includes volume mounts for hot reloading:

- **Backend**: `fantasy-projections-api/src` is mounted, changes trigger auto-reload
- **Frontend**: The Next.js dev server automatically reloads on changes
- **Data**: `fantasy-projections-api/data` directory is mounted read-only

### Viewing Logs

```bash
# All services
./scripts/docker-dev.sh logs

# Specific service
./scripts/docker-dev.sh logs api
./scripts/docker-dev.sh logs frontend
./scripts/docker-dev.sh logs postgres
```

### Accessing Container Shells

```bash
# API container (default)
./scripts/docker-dev.sh shell

# Specific service
./scripts/docker-dev.sh shell frontend
./scripts/docker-dev.sh shell postgres
```

### Database Operations

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U fantasy_user -d fantasy_draft

# Run migrations (from API container)
docker-compose exec api python -m alembic upgrade head

# Create new migration
docker-compose exec api python -m alembic revision --autogenerate -m "Description"
```

## Troubleshooting

### Services Won't Start

1. **Check Docker is running**: Ensure Docker Desktop is running
2. **Port conflicts**: Make sure ports 3000, 5432, 6379, 8000 are available
3. **Check logs**: Use `./scripts/docker-dev.sh logs [service]` to identify issues

### Database Connection Issues

```bash
# Check if PostgreSQL is accessible
docker-compose exec postgres pg_isready -U fantasy_user -d fantasy_draft

# Reset database (WARNING: destroys data)
docker-compose down -v
docker-compose up -d postgres
```

### Redis Connection Issues

```bash
# Check Redis connectivity
docker-compose exec redis redis-cli ping

# View Redis logs
docker-compose logs redis
```

### Build Issues

```bash
# Clean rebuild
./scripts/docker-dev.sh clean
./scripts/docker-dev.sh build
./scripts/docker-dev.sh start
```

### Performance Issues

- Ensure Docker Desktop has sufficient memory allocated (4GB minimum)
- Close unnecessary applications
- Consider using Docker's built-in resource limits

## Data Persistence

- **Database**: PostgreSQL data is stored in a Docker volume (`postgres_data`)
- **Cache**: Redis data is stored in a Docker volume (`redis_data`) 
- **Application Data**: Fantasy projection files are mounted from `fantasy-projections-api/data`

### Backup and Restore

```bash
# Backup database
docker-compose exec postgres pg_dump -U fantasy_user fantasy_draft > backup.sql

# Restore database
docker-compose exec -T postgres psql -U fantasy_user fantasy_draft < backup.sql
```

## Production Considerations

This Docker setup is optimized for development. For production:

1. **Security**: Change default passwords and JWT secrets
2. **Environment**: Update environment variables for production
3. **Volumes**: Use bind mounts or cloud storage for data persistence
4. **Networking**: Configure proper reverse proxy and SSL
5. **Monitoring**: Add health monitoring and logging solutions
6. **Scaling**: Consider separate docker-compose files for different environments

## Development Scripts

The `scripts/docker-dev.sh` script provides convenient commands:

```bash
# Available commands
./scripts/docker-dev.sh help

# Most commonly used
./scripts/docker-dev.sh start    # Start all services
./scripts/docker-dev.sh status   # Check health status
./scripts/docker-dev.sh logs     # View all logs
./scripts/docker-dev.sh restart  # Restart everything
./scripts/docker-dev.sh stop     # Stop all services
```

## Network Architecture

All services communicate through a custom Docker network (`fantasy-network`):

- Services can reference each other by service name (e.g., `http://api:8000`)
- Frontend connects to backend via `http://api:8000` internally
- External access uses `localhost` with mapped ports
- Database and Redis are only accessible from within the network (plus mapped ports for development)

This setup ensures proper service isolation while enabling development convenience.