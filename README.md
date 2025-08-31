# Fantasy Projections Workspace

A comprehensive fantasy hockey projection system with web interface, comparing projections from multiple analysts to help with draft decisions.

## 🏗️ Project Structure

- **`fantasy-projections-api/`** - Python FastAPI backend
- **`fantasy-projections-web/`** - Next.js web application frontend  
- **`shared/`** - Shared types and documentation
- **`docs/`** - Architecture and system documentation

## 🚀 Getting Started

This workspace uses git submodules for coordinated development. Each submodule has its own development environment and setup instructions.

### Backend (Python FastAPI)

```bash
cd fantasy-projections-api/
uv sync --dev
source .venv/bin/activate
uvicorn fantasy_projections.api.main:app --reload
```

**Access Points:**
- 🔗 **API**: http://localhost:8000
- 📚 **API Docs**: http://localhost:8000/docs

### Frontend (Next.js)

```bash
cd fantasy-projections-web/
npm install
npm run dev
```

**Access Points:**
- 🌐 **Web App**: http://localhost:3000

## 🛠️ Development Workflow

### Working with Git Submodules

```bash
# Initialize submodules (first time setup)
git submodule update --init --recursive

# Update submodules to latest commits
git submodule update --remote

# Make changes in a submodule
cd fantasy-projections-api/
# ... make changes ...
git add .
git commit -m "Your changes"
git push

# Update workspace to reference new submodule commits
cd ..
git add fantasy-projections-api/
git commit -m "Update API submodule"
```

### Development Tasks

**Backend Development:**
- Navigate to `fantasy-projections-api/` for all Python development
- Follow the API-specific README and documentation
- Run tests with `pytest`

**Frontend Development:**  
- Navigate to `fantasy-projections-web/` for all web development
- Follow the web-specific README and documentation
- Run tests with `npm test`

## 📊 Data and Configuration

- **Projection Data**: `fantasy-projections-api/data/` - Excel files organized by season
- **Configuration**: `fantasy-projections-api/src/fantasy_projections/config/` - Player lists, filters
- **Database Schema**: `fantasy-projections-api/database/schema/` - PostgreSQL initialization

## 🔧 System Architecture

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
    │  PostgreSQL   │  │    Redis    │  │    Files    │
    │  (Database)   │  │   (Cache)   │  │ (Data Store)│
    └───────────────┘  └─────────────┘  └─────────────┘
```

## 📖 Additional Documentation

- **User Specification**: `docs/fantasy-draft-assistant-user-specification.md`
- **System Architecture**: `docs/architecture.md` 
- **API Documentation**: `fantasy-projections-api/docs/architecture.md`
- **Frontend Documentation**: `fantasy-projections-web/docs/architecture.md`

---

**Need Help?** Check the individual project READMEs in `fantasy-projections-api/` and `fantasy-projections-web/` for service-specific details.