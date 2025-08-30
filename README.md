# Fantasy Projections Workspace

A comprehensive fantasy hockey projection system with both CLI and web interfaces, comparing projections from multiple analysts to help with draft decisions.

## 🏗️ Project Structure

- **`fantasy-projections-api/`** - Python CLI application and FastAPI backend
- **`fantasy-projections-web/`** - Next.js web application frontend
- **`shared/`** - Shared types and documentation
- **`docs/`** - Architecture and system documentation

## 🐳 Docker Quick Start

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### Start the Complete Environment

```bash
# Start all services (database, API, web frontend)
./docker-start.sh

# Or start with CLI container for running Python commands
./docker-start.sh --cli
```

**Access Points:**
- 🌐 **Web App**: http://localhost:3000
- 🔗 **API**: http://localhost:8000
- 📚 **API Docs**: http://localhost:8000/docs

### Docker Commands

```bash
# Basic usage
./docker-start.sh                 # Start web + API + database
./docker-start.sh --logs          # Start and follow logs
./docker-start.sh --build         # Force rebuild images
./docker-start.sh --cli           # Include CLI container

# Management
./docker-start.sh --down          # Stop all containers
./docker-start.sh --clean         # Stop and remove all data ⚠️

# Manual Docker Compose (alternative)
docker compose up -d              # Start detached
docker compose down               # Stop containers
docker compose logs -f api        # Follow API logs
```

### Development Workflow

The Docker setup includes hot reloading for both frontend and backend:

1. **Start Environment**: `./docker-start.sh --logs`
2. **Edit Code**: Changes automatically reload in containers
3. **View Logs**: All service logs are displayed
4. **Access Services**: Web app, API, and docs available on localhost

### Using the CLI Container

When started with `--cli`, you can run Python CLI commands:

```bash
# Execute commands in the CLI container
docker compose exec cli python cli.py kkupfl 2024-2025 --limit 10

# Or get a shell
docker compose exec cli bash
```

## 📁 Docker Files Explained

### Core Files
- **`docker-compose.yml`** - Main service definitions (database, API, web)
- **`docker-compose.override.yml`** - Development overrides (hot reloading, debug mode)
- **`docker-start.sh`** - Convenient startup script with options
- **`.dockerignore`** - Files excluded from Docker builds

### Individual Dockerfiles
- **`fantasy-projections-api/Dockerfile`** - Python/FastAPI backend image
- **`fantasy-projections-web/Dockerfile`** - Next.js frontend image

### Services Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Web Frontend  │────│   API Backend   │
│   (Next.js)     │    │   (FastAPI)     │
│   Port: 3000    │    │   Port: 8000    │
└─────────────────┘    └─────────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            │                 │                 │
    ┌───────────────┐  ┌─────────────┐  ┌─────────────┐
    │  PostgreSQL   │  │    Redis    │  │ CLI Runner  │
    │  Port: 5432   │  │ Port: 6379  │  │ (Optional)  │
    └───────────────┘  └─────────────┘  └─────────────┘
```

## 🛠️ Development Without Docker

### Backend (Python)
```bash
cd fantasy-projections-api/
uv sync --dev
source .venv/bin/activate
python cli.py kkupfl 2024-2025 --limit 10
```

### Frontend (Next.js)
```bash
cd fantasy-projections-web/
npm install
npm run dev
```

## 📊 Data and Configuration

- **Projection Data**: `fantasy-projections-api/data/` - Excel files organized by season
- **Configuration**: `fantasy-projections-api/src/fantasy_projections/config/` - Player lists, filters
- **Database Schema**: `fantasy-projections-api/database/schema/` - PostgreSQL initialization

## 🔧 Troubleshooting

### Common Issues

**Port Conflicts:**
```bash
# Check what's using ports
lsof -i :3000  # Frontend
lsof -i :8000  # API
lsof -i :5432  # Database

# Stop conflicting services or change ports in docker-compose.yml
```

**Docker Issues:**
```bash
# Restart Docker Desktop and try again
./docker-start.sh --clean  # Nuclear option: removes all data
docker system prune -f     # Clean up Docker resources
```

**Build Failures:**
```bash
# Force rebuild with no cache
docker compose build --no-cache
./docker-start.sh --build
```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f web
docker compose logs -f postgres
```

### Database Access

```bash
# Connect to PostgreSQL
docker compose exec postgres psql -U fantasy_user -d fantasy_draft

# Or use your favorite database client
# Host: localhost, Port: 5432
# Database: fantasy_draft, User: fantasy_user, Password: fantasy_pass
```

## 📋 Health Checks

All services include health checks:
```bash
# Check service status
docker compose ps

# View health check logs
docker compose logs postgres | grep health
```

## 🚀 Production Deployment

For production, create a `docker-compose.prod.yml`:
- Remove development volume mounts
- Use production environment variables
- Configure proper secrets management
- Enable HTTPS/TLS
- Set up proper logging and monitoring

## 📖 Additional Documentation

- **User Specification**: `docs/fantasy-draft-assistant-user-specification.md`
- **System Architecture**: `docs/architecture.md` 
- **API Documentation**: `fantasy-projections-api/docs/architecture.md`
- **Frontend Documentation**: `fantasy-projections-web/docs/architecture.md`

---

**Need Help?** Check the individual project READMEs in `fantasy-projections-api/` and `fantasy-projections-web/` for service-specific details.