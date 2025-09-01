# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is a fantasy hockey projection workspace containing two git submodules:
- **fantasy-projections-api/**: Git submodule containing Python FastAPI backend for fantasy hockey projections
- **fantasy-projections-web/**: Git submodule containing Next.js web application frontend

Each submodule has its own git repository and history. Use standard git submodule commands when working with them.

## Common Commands

### Fantasy Projections API (Python)

Navigate to `fantasy-projections-api/` directory for all Python commands.

#### Environment Setup
- Install dependencies: `uv sync --dev`
- Activate virtual environment: `source ./.venv/bin/activate`
- Run with uv (alternative): `uv run python <command>`

#### Main Usage
- Start API server: `uvicorn fantasy_projections.api.main:app --reload`
- API endpoints: http://localhost:8000/docs (FastAPI documentation)
- Available leagues: `kkupfl`, `pa`
- Available seasons: `2024-2025`, `2023-2024`

#### Code Quality
- Lint and fix: `ruff check --fix`
- Format code: `ruff format`
- Run tests: `pytest`

#### Testing Conventions
- Use pytest framework
  - Use `@pytest.fixture` for common fixtures that can be reused across tests
  - Use `@pytest.mark.parametrize` for parameterized tests
- Use hamcrest for assertions
  - Example: `assert_that(actual, is_(expected))`

### Fantasy Projections Web (Next.js)

Navigate to `fantasy-projections-web/` directory for all web commands.

#### Development
- Start dev server: `npm run dev`
- Build for production: `npm build`
- Start production: `npm start`
- Lint code: `npm run lint`

## Architecture Overview

### Fantasy Projections API
The Python application follows a layered architecture:

1. **API Layer** (`api/`): FastAPI endpoints with validation and documentation
2. **Controller Layer** (`controller/`): Request orchestration
3. **Service Layer** (`service/`): Business logic for ranking calculations and data aggregation
4. **Data Access Layer** (`dao/reader/`): Specialized parsers for different projection sources

#### Key Components
- **FastAPI Application**: REST API server with OpenAPI documentation
- **Authentication System**: JWT-based user authentication with registration, login, and password management
- **User Management**: Complete user lifecycle including account creation and deletion endpoints
- **ProjectionsController**: Main orchestrator handling API requests
- **ProjectionsSvc**: Core business logic for cross-source projection comparison  
- **Reader Classes**: Specialized parsers in `dao/reader/` for different analysts (Blake, Dom, EP, Laidlaw, etc.)
- **Average Rankings**: Weighted consensus rankings across all projection sources

#### Data Flow
1. API receives HTTP requests with query parameters (league, season, filters, average flag)
2. Controller validates inputs and creates service instance
3. Service coordinates multiple readers to fetch projection data from Excel files
4. Readers parse and normalize data from different sources
5. Service aggregates and ranks players across all sources
6. If `include_average=true` parameter, calculates weighted average rankings
7. Results returned as JSON through REST API endpoints

#### Data Sources
The application compares projections from multiple fantasy hockey analysts:
- KKUPFL ADP and Scoring (Discord community)
- Steve Laidlaw projections
- Dom Luszczyszyn (The Athletic)
- Elite Prospects
- Blake Reddit projections

Each reader in `src/fantasy_projections/dao/reader/` handles specific Excel formats and column naming conventions for its corresponding data source.

### Fantasy Projections Web
Next.js 14 application with TypeScript and Tailwind CSS, designed to consume REST API endpoints from a future FastAPI backend that will wrap the existing Python business logic.

## Key Directories
- `fantasy-projections-api/src/fantasy_projections/`: Python source code
- `fantasy-projections-api/data/`: Excel projection files organized by season
- `fantasy-projections-api/src/fantasy_projections/config/`: Configuration files (drafted players, filters, regex patterns)
- `fantasy-projections-web/src/app/`: Next.js app directory structure
- `docs/`: Architecture and implementation documentation
- `shared/`: Shared types and documentation

## Cross-Source Averaging Feature

The Python application includes sophisticated cross-source averaging:

### Usage
Enable with `include_average=true` parameter: `GET /api/rankings/kkupfl/2024-2025?include_average=true&limit=5`

### Implementation
- Each reader has configurable weight for reliability
- Weighted average rankings calculated across all sources
- "Avg Rank" column appears in output when enabled
- Smooths out individual analyst biases and outliers
- Only includes players found in multiple sources

## User Account Management

The API provides comprehensive user account deletion capabilities for both user-initiated and administrative deletion:

### User Deletion Endpoints

#### Self-Service Deletion
`DELETE /api/auth/delete-account`
- **Authentication Required**: User must be logged in with valid JWT token
- **Scope**: User can only delete their own account
- **Data Removed**: All user data and associations (see Data Deletion Scope below)

#### Administrative Deletion  
`DELETE /api/auth/admin/delete-user/{user_id}`
- **Authentication Required**: None (intended for direct backend access)
- **Scope**: Can delete any user by UUID
- **Data Removed**: All user data and associations (see Data Deletion Scope below)
- **Validation**: Validates UUID format and provides proper error responses

### Data Deletion Scope
Both endpoints permanently remove:
- User profile and authentication data (password, tokens, etc.)
- All draft sessions created by the user 
- All projection sources, consolidated rankings, and draft picks associated with user's sessions
- All sleeper lists and target players
- User analytics events (for privacy compliance)

**Note**: All deletions use CASCADE constraints and transactions with proper rollback on errors. This operation is irreversible.

### Implementation
- **Database Layer**: `user_queries.py:delete_user_and_data()` - Handles comprehensive data removal
- **API Models**: `UserDeletionResponse` - Structured response with success status and metadata
- **Error Handling**: Proper HTTP status codes, transaction rollback, and detailed error messages
- **Testing**: Comprehensive test coverage for both endpoints and database operations

## Comprehensive Documentation

### Architecture Overview
- **Wholistic System Architecture**: `docs/architecture.md` - Complete system architecture for both frontend and backend, including database design, security implementation, and performance optimizations
- **Frontend Architecture**: `fantasy-projections-web/docs/architecture.md` - Next.js application architecture, components, and user interface design
- **Backend Architecture**: `fantasy-projections-api/docs/architecture.md` - Python FastAPI backend, data processing, and API endpoints

### User Experience
- **User Specification**: `docs/fantasy-draft-assistant-user-specification.md` - Complete user experience, workflows, and feature requirements for web interface
  - THIS IS VERY IMPORTANT. KEEP THIS FILE IN MIND WHEN REASONING ABOUT APP CHANGES, AS IT INSTRUCTS WHAT THE USER EXPERIENCE SHOULD BE.

## Development Principles

Write modular code that promotes:
- **Readability**: Clear, self-documenting code with meaningful names and structure
- **Extensibility**: Easy to add new features, data sources, and functionality
- **Composability**: Components that work together seamlessly and can be combined in different ways

### Git Workflow
- **Commit in logical chunks**: Make frequent, focused commits that represent complete, working units of change
- Each commit should be atomic and represent a single logical change
- Use descriptive commit messages that explain the "why" behind changes

## Project Evolution
Changes are tracked in `fantasy-projections-api/CHANGELOG.md`, updated before merging pull requests to document all integrated changes.

**Implementation Plan Maintenance**: When making commits to `fantasy-projections-api/` or `fantasy-projections-web/`, always update the corresponding implementation plans to reflect current project states:
- `docs/implementation-plan.md` - Overall project status and coordination
- `fantasy-projections-api/docs/implementation-plan.md` - Backend progress and completed iterations
- `fantasy-projections-web/docs/implementation-plan.md` - Frontend progress and completed iterations

Mark completed tasks as `[x]` and update progress status indicators (`✅ COMPLETED`, `🟡 IN PROGRESS`, `🔄 PENDING`) to maintain accurate project tracking.

**Architecture Documentation Maintenance**: After any meaningful architectural changes, update the corresponding architecture documentation to maintain accurate system understanding:
- `docs/architecture.md` - Update after changes affecting the overall system architecture
- `fantasy-projections-api/docs/architecture.md` - Update after changes to backend architecture, data flow, or API structure
- `fantasy-projections-web/docs/architecture.md` - Update after changes to frontend architecture, components, or user interface patterns

This ensures accurate architectural documentation for the entire application as well as its individual backend and frontend components.
