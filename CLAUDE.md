# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is a fantasy hockey projection workspace containing two git submodules:
- **fantasy-projections-api/**: Git submodule containing Python CLI application for comparing fantasy hockey projections
- **fantasy-projections-web/**: Git submodule containing Next.js web application (under development)

Each submodule has its own git repository and history. Use standard git submodule commands when working with them.

## Common Commands

### Fantasy Projections API (Python)

Navigate to `fantasy-projections-api/` directory for all Python commands.

#### Environment Setup
- Install dependencies: `uv sync --dev`
- Activate virtual environment: `source ./.venv/bin/activate`
- Run with uv (alternative): `uv run python <command>`

#### Main Usage
- Primary CLI: `python cli.py <league> <season> [options]`
- Example: `python cli.py kkupfl 2024-2025 --position SKT --limit 10 --average`
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

1. **CLI Layer** (`cli.py`): Argument parsing and user interaction
2. **Controller Layer** (`controller/`): Request orchestration
3. **Service Layer** (`service/`): Business logic for ranking calculations and data aggregation
4. **Data Access Layer** (`dao/reader/`): Specialized parsers for different projection sources

#### Key Components
- **ProjectionsController**: Main orchestrator handling user requests
- **ProjectionsSvc**: Core business logic for cross-source projection comparison
- **Reader Classes**: Specialized parsers in `dao/reader/` for different analysts (Blake, Dom, EP, Laidlaw, etc.)
- **Average Rankings**: Weighted consensus rankings across all projection sources

#### Data Flow
1. CLI parses user arguments (league, season, filters, average flag)
2. Controller validates inputs and creates service instance
3. Service coordinates multiple readers to fetch projection data from Excel files
4. Readers parse and normalize data from different sources
5. Service aggregates and ranks players across all sources
6. If `--average` flag enabled, calculates weighted average rankings
7. Results flow back through controller to CLI for display

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
Enable with `--average` flag: `python cli.py kkupfl 2024-2025 --average --limit 5`

### Implementation
- Each reader has configurable weight for reliability
- Weighted average rankings calculated across all sources
- "Avg Rank" column appears in output when enabled
- Smooths out individual analyst biases and outliers
- Only includes players found in multiple sources

## Comprehensive Documentation

### Architecture Overview
- **Wholistic System Architecture**: `docs/architecture.md` - Complete system architecture for both frontend and backend, including database design, security implementation, and performance optimizations
- **Frontend Architecture**: `fantasy-projections-web/docs/architecture.md` - Next.js application architecture, components, and user interface design
- **Backend Architecture**: `fantasy-projections-api/docs/architecture.md` - Python FastAPI backend, data processing, and API endpoints

### User Experience
- **User Specification**: `docs/fantasy-draft-assistant-user-specification.md` - Complete user experience, workflows, and feature requirements for both web and CLI interfaces
  - THIS IS VERY IMPORANT. KEEP THIS FILE IN MIND WHEN REASONING ABOUT APP CHANGES, AS IT INSTRUCTS WHAT THE USER EXPERIENCE SHOULD BE.

## Development Principles

Write modular code that promotes:
- **Readability**: Clear, self-documenting code with meaningful names and structure
- **Extensibility**: Easy to add new features, data sources, and functionality
- **Composability**: Components that work together seamlessly and can be combined in different ways

## Project Evolution
Changes are tracked in `fantasy-projections-api/CHANGELOG.md`, updated before merging pull requests to document all integrated changes.

**Implementation Plan Maintenance**: When making commits to `fantasy-projections-api/` or `fantasy-projections-web/`, always update the corresponding implementation plans to reflect current project states:
- `docs/implementation-plan.md` - Overall project status and coordination
- `fantasy-projections-api/docs/implementation-plan.md` - Backend progress and completed iterations
- `fantasy-projections-web/docs/implementation-plan.md` - Frontend progress and completed iterations

Mark completed tasks as `[x]` and update progress status indicators (`✅ COMPLETED`, `🟡 IN PROGRESS`, `🔄 PENDING`) to maintain accurate project tracking.
