# Fantasy Hockey Draft Day Assistant - Architecture

## System Overview

The Fantasy Hockey Draft Day Assistant is built using a modern web architecture with Next.js + React frontend consuming Python FastAPI REST endpoints. The system supports both the existing CLI interface and the new web application interface using the same underlying business logic.

## High-Level Architecture

```
┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐
│   Desktop Browser  │  │   Tablet Browser   │  │   Mobile Browser   │
│   (Primary Target) │  │   (Primary Target) │  │   (Responsive)     │
└─────────┬──────────┘  └─────────┬──────────┘  └─────────┬──────────┘
          │ HTTPS/REST API        │ HTTPS/REST API        │ HTTPS/REST API
          └─────────────────┬─────────────────────────────┘
                           │
┌─────────────────────────▼─────────────────────────────────────────┐
│                   Next.js 14 Web Application                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│  │   Server Side   │  │   Draft Status  │  │   PWA Features  │   │
│  │   Rendering     │  │   Icons        │  │   Offline Cache │   │
│  │   (Performance) │  │   (Click-based) │  │   (Limited)     │   │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│  │   REST Client   │  │   State Mgmt    │  │   Responsive    │   │
│  │   (fetch/axios) │  │   (Zustand)     │  │   Components    │   │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│  │  User Analytics │  │  Error Tracking │  │  Performance    │   │
│  │  (PostHog)      │  │  (Sentry)       │  │  Monitoring     │   │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘   │
└─────────────────────┬───────────────────────────────────────────┘
                      │ REST API Calls + Analytics Events
┌─────────────────────▼───────────────────────────────────────────┐
│                 Python FastAPI Backend                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ /api/rankings   │  │ /api/files/     │  │ /api/players/   │ │
│  │ /api/drafts     │  │ upload/process  │  │ search          │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ /api/analytics  │  │ /api/health     │  │ /api/admin/     │ │
│  │ events/metrics  │  │ monitoring      │  │ dashboard       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Existing Business Logic (Shared with CLI) + Analytics         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Controller     │  │    Service      │  │      DAO        │ │
│  │  Layer          │  │    Layer        │  │    Readers      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Analytics      │  │  Performance    │  │   Monitoring    │ │
│  │  Service        │  │  Tracking       │  │   Service       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Data Layer + External Integrations + Monitoring              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   PostgreSQL    │  │   Redis Cache   │  │   File Storage  │ │
│  │   (Primary DB)  │  │   (Performance  │  │   (Projections) │ │
│  │   + JSONB Data  │  │    + Sessions)  │  │   + Temp Files  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Excel Files   │  │   Fantasy APIs  │  │  External       │ │
│  │   (Projections) │  │   (Live Draft)  │  │  Monitoring     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                   Monitoring & Analytics Layer                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   DataDog/      │  │     Sentry      │  │   Log Aggr.     │ │
│  │   New Relic     │  │   Error Track   │  │   ELK/DataDog   │ │
│  │   (APM/Metrics) │  │   Performance   │  │   (Centralized) │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Alerting      │  │   Dashboards    │  │   Uptime Mon.   │ │
│  │   (PagerDuty/   │  │   (Grafana/     │  │   (StatusPage)  │ │
│  │    Slack)       │  │    DataDog)     │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Layered Architecture

The system maintains a clear separation of concerns through layered architecture:

### 1. Presentation Layer
**Responsibilities:**
- Handle user interactions and input validation
- Present data in appropriate formats for different interfaces
- Manage session state and user preferences

**Components:**
- **Web Interface**: Next.js 14 + React with responsive design
- **CLI Interface**: Existing cli.py for command-line usage
- **REST API**: FastAPI endpoints for web frontend consumption

### 2. Controller Layer
**Responsibilities:**
- Route and orchestrate requests between presentation and business layers
- Handle API endpoint logic and HTTP concerns
- Coordinate between multiple services for complex operations
- Input validation and transformation

**Components:**
- **ProjectionsController**: Manages projection comparisons and rankings
- **DraftController**: Handles draft session management and live draft operations
- **FileController**: Manages file uploads and processing workflows
- **UserController**: Handles user accounts and preferences

### 3. Service/Business Logic Layer
**Responsibilities:**
- Core business logic for projection analysis and draft management
- Data transformation and normalization across different analyst formats
- Weighted ranking calculations and consensus building
- Team balance analysis and draft recommendations

**Components:**
- **ProjectionsService**: Core projection comparison and averaging logic
- **DraftService**: Draft session management and team analysis
- **ValidationService**: Player name matching and data validation

### 4. Data Access Layer (DAO)
**Responsibilities:**
- Abstract data source access through consistent interfaces
- Handle different file formats and external API integrations
- Provide caching and optimization for data retrieval

**Components:**
- **Reader Classes**: Specialized parsers for different analysts (Blake, Dom, EP, Laidlaw, etc.)
- **DatabaseDAO**: Abstract database operations using PostgreSQL with JSONB for flexible data
- **ExternalAPIDAO**: NHL API, fantasy platform API integrations
- **FileDAO**: File upload, storage, and processing operations

### 5. Analytics & Monitoring Layer
**Responsibilities:**
- Track user behavior and application performance
- Collect and analyze business metrics
- Provide real-time monitoring and alerting
- Generate insights for product optimization

**Components:**
- **Analytics Service**: User event tracking and behavioral analysis
- **Performance Monitoring**: API response times, database query performance
- **Error Tracking**: Exception monitoring and debugging information
- **Business Metrics**: Draft completion rates, feature adoption, user engagement
- **Alert Management**: Threshold-based alerting and notification system

### Example Request Flow

1. **Web Frontend**: User uploads projection file and adjusts source weights
2. **FastAPI Controller**: Validates upload, processes file, updates weights
3. **Service Layer**: 
   - Processes file using appropriate reader
   - Validates player names against NHL database
   - Recalculates weighted rankings with new weights
   - Generates consolidated consensus scores
4. **Data Access Layer**: 
   - Stores processed data in PostgreSQL (JSONB columns for flexible data)
   - Caches results in Redis
   - Updates user preferences in PostgreSQL
5. **Controller**: Returns updated rankings with metadata
6. **Frontend**: Updates UI with new rankings and visual indicators

## Database Architecture

The system uses a **simplified two-tier database approach** optimized for performance and maintainability:

### PostgreSQL (Primary Relational Database)

**Purpose**: Structured, relational data requiring ACID compliance

```sql
-- Core Tables
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    preferences JSONB
);

CREATE TABLE draft_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    league VARCHAR(50) NOT NULL,
    season VARCHAR(20) NOT NULL,
    num_teams INTEGER NOT NULL,
    scoring_categories JSONB,
    draft_date TIMESTAMP,
    fantasy_playoff_start DATE,
    fantasy_playoff_end DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'active'
);

CREATE TABLE nhl_players (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    normalized_name VARCHAR(255) NOT NULL,
    position VARCHAR(10) NOT NULL,
    team VARCHAR(10),
    nhl_id INTEGER UNIQUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE nhl_teams (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(10) UNIQUE NOT NULL,
    nhl_id INTEGER UNIQUE
);

CREATE TABLE nhl_schedule (
    id UUID PRIMARY KEY,
    team_id UUID REFERENCES nhl_teams(id),
    game_date DATE NOT NULL,
    opponent_id UUID REFERENCES nhl_teams(id),
    is_home BOOLEAN NOT NULL,
    season VARCHAR(20) NOT NULL,
    is_playoff BOOLEAN DEFAULT FALSE,
    games_that_night INTEGER, -- Total NHL games on this date
    INDEX idx_schedule_date (game_date),
    INDEX idx_schedule_season (season)
);

CREATE TABLE draft_picks (
    id UUID PRIMARY KEY,
    draft_session_id UUID REFERENCES draft_sessions(id),
    player_id UUID REFERENCES nhl_players(id),
    team_number INTEGER NOT NULL,
    pick_number INTEGER NOT NULL,
    round_number INTEGER NOT NULL,
    picked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(draft_session_id, pick_number)
);

CREATE TABLE sleeper_lists (
    id UUID PRIMARY KEY,
    draft_session_id UUID REFERENCES draft_sessions(id) UNIQUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sleeper_players (
    id UUID PRIMARY KEY,
    sleeper_list_id UUID REFERENCES sleeper_lists(id),
    player_id UUID REFERENCES nhl_players(id),
    priority VARCHAR(20) NOT NULL, -- 'high', 'medium', 'low'
    target_round_min INTEGER,
    target_round_max INTEGER,
    notes TEXT,
    position_in_list INTEGER,
    added_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE column_mappings (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    source_name VARCHAR(255) NOT NULL,
    original_column VARCHAR(255) NOT NULL,
    mapped_column VARCHAR(255) NOT NULL,
    confidence_score FLOAT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, source_name, original_column)
);

CREATE TABLE player_name_corrections (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    source_name VARCHAR(255),
    original_name VARCHAR(255) NOT NULL,
    corrected_player_id UUID REFERENCES nhl_players(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, source_name, original_name)
);

-- Analytics and Monitoring Tables
CREATE TABLE system_metrics (
    id UUID PRIMARY KEY,
    metric_name VARCHAR(255) NOT NULL,
    metric_value FLOAT NOT NULL,
    metric_type VARCHAR(50) NOT NULL, -- 'performance', 'business', 'system'
    dimensions JSONB, -- {database: 'postgres', operation: 'ranking_calc'}
    timestamp TIMESTAMP DEFAULT NOW(),
    INDEX idx_metrics_name_time (metric_name, timestamp),
    INDEX idx_metrics_type_time (metric_type, timestamp)
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(255) UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    started_at TIMESTAMP DEFAULT NOW(),
    last_activity TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    duration_seconds INTEGER,
    page_views INTEGER DEFAULT 0,
    actions_count INTEGER DEFAULT 0
);

CREATE TABLE error_logs (
    id UUID PRIMARY KEY,
    error_id VARCHAR(255),
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(255),
    error_type VARCHAR(100) NOT NULL,
    error_message TEXT,
    stack_trace TEXT,
    request_path VARCHAR(500),
    request_method VARCHAR(10),
    request_data JSONB,
    occurred_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP,
    INDEX idx_errors_type_time (error_type, occurred_at),
    INDEX idx_errors_user_time (user_id, occurred_at)
);
```

### PostgreSQL Extensions for Flexible Data

**Purpose**: Use PostgreSQL JSONB columns to handle varying projection formats without sacrificing ACID properties

```sql
-- Extended tables with JSONB for flexible data

-- Projection sources table with JSONB for varying analyst formats
CREATE TABLE projection_sources (
    id UUID PRIMARY KEY,
    draft_session_id UUID REFERENCES draft_sessions(id),
    source_name VARCHAR(255) NOT NULL,
    source_type VARCHAR(50) DEFAULT 'projections',
    file_metadata JSONB NOT NULL,
    column_mappings JSONB NOT NULL,
    value_column VARCHAR(100) NOT NULL,
    weight DECIMAL(3,2) DEFAULT 1.0,
    player_data JSONB NOT NULL, -- Array of player objects
    processing_status VARCHAR(50) DEFAULT 'pending',
    validation_issues JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Consolidated rankings cache
CREATE TABLE consolidated_rankings (
    id UUID PRIMARY KEY,
    draft_session_id UUID REFERENCES draft_sessions(id),
    source_weights JSONB NOT NULL,
    consolidated_players JSONB NOT NULL, -- Array of ranked players
    calculation_timestamp TIMESTAMP DEFAULT NOW(),
    cache_expiry TIMESTAMP
);

-- User analytics events
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(255),
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB DEFAULT '{}',
    timestamp TIMESTAMP DEFAULT NOW(),
    user_agent TEXT,
    ip_address INET,
    page_path VARCHAR(500),
    referrer VARCHAR(500)
);

-- Performance metrics
CREATE TABLE performance_metrics (
    id UUID PRIMARY KEY,
    operation VARCHAR(100) NOT NULL,
    duration_ms INTEGER NOT NULL,
    database_queries JSONB DEFAULT '{}',
    cache_performance JSONB DEFAULT '{}',
    request_context JSONB DEFAULT '{}',
    timestamp TIMESTAMP DEFAULT NOW(),
    server_instance VARCHAR(100)
);

-- Create indexes for performance
CREATE INDEX idx_projection_sources_draft_session ON projection_sources(draft_session_id);
CREATE INDEX idx_consolidated_rankings_draft_session ON consolidated_rankings(draft_session_id);
CREATE INDEX idx_analytics_events_user_timestamp ON analytics_events(user_id, timestamp);
CREATE INDEX idx_performance_metrics_operation_timestamp ON performance_metrics(operation, timestamp);

-- JSONB GIN indexes for fast queries on flexible data
CREATE INDEX idx_projection_sources_player_data ON projection_sources USING GIN (player_data);
CREATE INDEX idx_consolidated_rankings_players ON consolidated_rankings USING GIN (consolidated_players);
CREATE INDEX idx_analytics_events_data ON analytics_events USING GIN (event_data);
```

### Redis (Caching Layer)

**Purpose**: High-performance caching and session management

```
# Session Management
session:{session_id} -> {
  user_id: "uuid",
  draft_session_id: "uuid",
  expires_at: timestamp,
  last_activity: timestamp
}

# Real-time Draft State
draft:{draft_session_id}:state -> {
  available_players: ["player_id1", "player_id2"],
  drafted_players: {
    team_1: ["player_id3", "player_id4"],
    team_2: ["player_id5", "player_id6"]
  },
  current_pick: {
    team: 1,
    round: 3,
    pick: 25
  },
  last_updated: timestamp
}

# Calculated Rankings Cache
rankings:{draft_session_id}:{weights_hash} -> {
  consolidated_rankings: [...],
  calculation_time: timestamp,
  expires_at: timestamp
}

# NHL Schedule Cache
schedule:{season}:{team_abbr} -> {
  regular_season: [
    {date: "2024-10-12", opponent: "CGY", is_home: true, games_that_night: 8},
    // ... more games
  ],
  playoff_schedule: [...],
  off_nights: ["2024-10-15", "2024-11-03"],
  cached_at: timestamp,
  expires_at: timestamp
}

# Player Search Index
players:search:{query} -> [
  {id: "uuid", name: "Connor McDavid", position: "C", team: "EDM"},
  // ... matching players
]

# Analytics & Monitoring Cache
analytics:active_users -> {
  current_count: 45,
  last_updated: timestamp,
  peak_today: 78
}

analytics:realtime_metrics -> {
  api_requests_per_minute: 120,
  error_rate_5min: 0.02,
  avg_response_time_ms: 285,
  active_draft_sessions: 12,
  last_updated: timestamp
}

# Alert State Management
alerts:triggered -> {
  "high_error_rate": {
    triggered_at: timestamp,
    current_value: 0.06,
    threshold: 0.05,
    alert_sent: true
  },
  "slow_db_queries": {
    triggered_at: timestamp,
    avg_query_time: 850,
    threshold: 500,
    alert_sent: true
  }
}

# Performance Monitoring Cache
perf:db_query_times:{operation} -> [285, 320, 195, 410, 275] // last 5 queries
perf:api_response_times:{endpoint} -> {
  avg_1min: 245,
  avg_5min: 267,
  avg_15min: 289,
  p95_1min: 450,
  p99_1min: 850
}
```

### Database Relationships and Data Flow

```
┌─────────────────────────────────────────┐    ┌─────────────────┐
│              PostgreSQL                 │    │     Redis       │
│                                         │    │                 │
│ Relational Data:                        │◄──►│ • Sessions      │
│ • Users, Draft Sessions                 │    │ • Draft State   │
│ • NHL Players, Teams, Schedule          │    │ • Ranking Cache │
│ • Draft Picks, Sleepers                 │    │ • Search Cache  │
│ • Column/Name Mappings                   │    │ • Schedule Cache│
│                                         │    │                 │
│ JSONB Flexible Data:                    │    │                 │
│ • User Preferences (JSONB)              │    │                 │
│ • Projection Sources (JSONB)            │    │                 │
│ • Consolidated Rankings (JSONB)         │    │                 │
│ • Analytics Events (JSONB)              │    │                 │
└─────────────────────────────────────────┘    └─────────────────┘
                    │                                    │
                    └────────────────────────────────────┘
                                     │
                ┌────────────────────▼─────────────────────┐
                │           FastAPI Backend               │
                │                                         │
                │  • Single database coordination         │
                │  • JSONB for flexible data storage      │
                │  • Redis for caching & sessions        │
                │  • Simplified consistency model         │
                └─────────────────────────────────────────┘
```

**Data Flow Examples:**

1. **File Upload & Processing:**
   - Upload → PostgreSQL (raw data + metadata in JSONB)
   - Validation → PostgreSQL (player matching)
   - Processing → PostgreSQL (structured player data in JSONB)
   - Caching → Redis (processed results)

2. **Weight Adjustment:**
   - User changes weights → FastAPI endpoint
   - Recalculation → PostgreSQL (source data + player info in JSONB)
   - Updated rankings → PostgreSQL (consolidated results in JSONB)
   - Cache refresh → Redis (new rankings cache)

3. **Draft Pick (Polling-Based Updates):**
   - Pick made → PostgreSQL (draft_picks table)
   - State update → Redis (cached for next poll)
   - Frontend polls every 7-10 seconds for state changes
   - Recommendations → Recalculated from cached data

### Benefits of This Architecture

**PostgreSQL Benefits:**
- ACID compliance for critical draft operations
- Complex joins for team analysis and recommendations
- Strong consistency for user accounts and draft history
- Efficient queries for schedule calculations

**PostgreSQL JSONB Benefits:**
- Schema flexibility for varying analyst file formats using JSONB columns
- ACID compliance while maintaining document-like storage capabilities
- Powerful JSON querying with GIN indexes for fast retrieval
- Eliminates cross-database consistency issues
- Unified backup and monitoring strategy

**Redis Benefits:**
- Sub-millisecond response times for polling-based draft state retrieval
- Automatic expiration for calculated rankings
- Session management without database load
- Efficient state caching between poll requests (no pub/sub complexity)

**System Scalability:**
- Read replicas for PostgreSQL during high traffic
- PostgreSQL partitioning by draft session or date
- JSONB GIN indexing for fast flexible data queries
- Redis clustering for distributed caching
- Simplified two-database architecture reduces operational complexity

## Accessibility Architecture

### WCAG 2.1 AA Compliance Implementation

The application follows a comprehensive accessibility-first approach with specific implementation patterns for fantasy draft scenarios.

### Keyboard Navigation Patterns

**Draft Board Navigation:**
```typescript
// components/draft-board.tsx - Keyboard navigation for draft board
export function DraftBoard() {
  const [focusedCell, setFocusedCell] = useState<{row: number, col: number}>({row: 0, col: 0});
  
  const handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowUp':
        e.preventDefault();
        setFocusedCell(prev => ({...prev, row: Math.max(0, prev.row - 1)}));
        break;
      case 'ArrowDown':
        e.preventDefault();
        setFocusedCell(prev => ({...prev, row: Math.min(players.length - 1, prev.row + 1)}));
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        togglePlayerDraftStatus(players[focusedCell.row]);
        // Screen reader announcement
        announceToScreenReader(`${players[focusedCell.row].name} marked as drafted`);
        break;
    }
  };
  
  return (
    <div 
      role="grid" 
      aria-label="Fantasy draft player rankings"
      onKeyDown={handleKeyDown}
      tabIndex={0}
    >
      {/* Grid implementation */}
    </div>
  );
}
```

**Source Weight Adjustment:**
```typescript
// components/weight-slider.tsx - Accessible weight adjustment
export function WeightSlider({ source, weight, onChange }: WeightSliderProps) {
  return (
    <div className="weight-control">
      <label htmlFor={`weight-${source.id}`} className="sr-only">
        Adjust weight for {source.name}
      </label>
      <input
        id={`weight-${source.id}`}
        type="range"
        min="0"
        max="2"
        step="0.1"
        value={weight}
        onChange={(e) => {
          const newWeight = parseFloat(e.target.value);
          onChange(newWeight);
          // Live region announcement for weight changes
          setWeightAnnouncement(`${source.name} weight changed to ${newWeight}`);
        }}
        aria-describedby={`weight-${source.id}-description`}
        aria-valuetext={`Weight ${weight} out of 2.0`}
      />
      <div id={`weight-${source.id}-description`} className="sr-only">
        Use arrow keys to adjust the influence of {source.name} rankings. Higher values give more weight to this source.
      </div>
    </div>
  );
}
```

### Screen Reader Support

**Live Announcements for Draft Updates:**
```typescript
// lib/accessibility/announcements.tsx
export function useScreenReaderAnnouncements() {
  const [announcement, setAnnouncement] = useState('');
  
  const announcePlayerDrafted = (playerName: string, team: string) => {
    setAnnouncement(`${playerName} has been drafted by team ${team}`);
  };
  
  const announceRankingUpdate = (changedCount: number) => {
    setAnnouncement(`Rankings updated. ${changedCount} player positions changed.`);
  };
  
  const announceWeightChange = (sourceName: string, newWeight: number) => {
    setAnnouncement(`${sourceName} source weight adjusted to ${newWeight}`);
  };
  
  return (
    <>
      <div aria-live="polite" aria-atomic="true" className="sr-only">
        {announcement}
      </div>
      {/* Functions available for components to use */}
    </>
  );
}
```

**Table Structure for Rankings:**
```typescript
// components/rankings-table.tsx - Accessible table implementation
export function RankingsTable({ players, sources }: RankingsTableProps) {
  return (
    <table role="table" aria-label="Fantasy hockey player rankings">
      <caption className="sr-only">
        Player rankings comparing {sources.length} different sources. 
        Use arrow keys to navigate. Press space to mark players as drafted.
      </caption>
      <thead>
        <tr>
          <th scope="col" aria-sort="ascending">
            <button 
              onClick={() => sortBy('rank')}
              aria-label="Sort by overall rank"
            >
              Rank
              <span className="sort-indicator" aria-hidden="true">↑</span>
            </button>
          </th>
          <th scope="col">
            <span>Player Name</span>
          </th>
          <th scope="col">
            <span>Position</span>
          </th>
          {sources.map(source => (
            <th key={source.id} scope="col">
              <span>{source.name} Rank</span>
            </th>
          ))}
          <th scope="col">
            <span>Draft Status</span>
          </th>
        </tr>
      </thead>
      <tbody>
        {players.map((player, index) => (
          <tr 
            key={player.id}
            className={player.status === 'drafted' ? 'drafted' : ''}
            aria-rowindex={index + 2}
          >
            <td role="gridcell" aria-describedby={`player-${player.id}-description`}>
              {player.rank}
            </td>
            <td role="gridcell">
              <strong>{player.name}</strong>
              <span id={`player-${player.id}-description`} className="sr-only">
                {player.position}, {player.team}, 
                {player.status === 'drafted' ? 'already drafted' : 'available'}
              </span>
            </td>
            <td role="gridcell">{player.position}</td>
            {sources.map(source => (
              <td key={source.id} role="gridcell">
                {player.sourceRanks[source.id] || 'N/A'}
              </td>
            ))}
            <td role="gridcell">
              <button
                onClick={() => toggleDraftStatus(player)}
                aria-pressed={player.status === 'drafted'}
                aria-label={
                  player.status === 'drafted' 
                    ? `Mark ${player.name} as available` 
                    : `Mark ${player.name} as drafted`
                }
                className={`draft-toggle ${player.status}`}
              >
                <span aria-hidden="true">
                  {player.status === 'drafted' ? '✓' : '○'}
                </span>
                <span className="sr-only">
                  {player.status === 'drafted' ? 'Drafted' : 'Available'}
                </span>
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

### Color and Contrast Implementation

**Player Status Visual Indicators:**
```css
/* Accessible color scheme for player status */
.player-row {
  /* Ensure 4.5:1 contrast ratio minimum */
  color: #1a1a1a; /* Dark gray text */
  background: #ffffff; /* White background */
}

.player-row.drafted {
  background: #f0f9ff; /* Very light blue */
  border-left: 4px solid #0284c7; /* Blue border indicator */
}

.player-row.drafted .player-name {
  color: #0c4a6e; /* Darker blue for drafted players */
  text-decoration: line-through;
  opacity: 0.7;
}

.player-row.user-drafted {
  background: #f0fdf4; /* Very light green */
  border-left: 4px solid #16a34a; /* Green border indicator */
}

.player-row.others-drafted {
  background: #fef2f2; /* Very light red */
  border-left: 4px solid #dc2626; /* Red border indicator */
}

/* High contrast indicators don't rely only on color */
.draft-status-icon::before {
  content: attr(data-status);
  font-weight: bold;
  margin-right: 0.5rem;
}

.draft-status-icon[data-status="available"]::before {
  content: "○ ";
}

.draft-status-icon[data-status="drafted-by-user"]::before {
  content: "✓ ";
  color: #16a34a;
}

.draft-status-icon[data-status="drafted-by-others"]::before {
  content: "✗ ";
  color: #dc2626;
}
```

### Focus Management

**Modal Dialog Focus Trap:**
```typescript
// components/ui/modal.tsx - Focus trap implementation
export function Modal({ isOpen, onClose, children, title }: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);
  
  useEffect(() => {
    if (isOpen) {
      // Store previous focus
      previousFocus.current = document.activeElement as HTMLElement;
      
      // Focus the modal
      modalRef.current?.focus();
    } else {
      // Restore previous focus
      previousFocus.current?.focus();
    }
  }, [isOpen]);
  
  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose();
    }
    
    if (e.key === 'Tab') {
      // Implement focus trap logic
      const focusableElements = modalRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      
      if (focusableElements && focusableElements.length > 0) {
        const firstElement = focusableElements[0] as HTMLElement;
        const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement;
        
        if (e.shiftKey) {
          if (document.activeElement === firstElement) {
            e.preventDefault();
            lastElement.focus();
          }
        } else {
          if (document.activeElement === lastElement) {
            e.preventDefault();
            firstElement.focus();
          }
        }
      }
    }
  };
  
  if (!isOpen) return null;
  
  return (
    <div 
      className="modal-overlay" 
      role="dialog" 
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div 
        ref={modalRef}
        className="modal-content"
        tabIndex={-1}
        onKeyDown={handleKeyDown}
      >
        <h2 id="modal-title">{title}</h2>
        {children}
      </div>
    </div>
  );
}
```

### Skip Links and Navigation

**Page Structure with Skip Links:**
```typescript
// components/layout.tsx - Accessible page structure
export function Layout({ children }: LayoutProps) {
  return (
    <>
      {/* Skip links for keyboard users */}
      <div className="skip-links">
        <a href="#main-content" className="skip-link">
          Skip to main content
        </a>
        <a href="#rankings-table" className="skip-link">
          Skip to player rankings
        </a>
        <a href="#source-weights" className="skip-link">
          Skip to source weights
        </a>
      </div>
      
      <header role="banner">
        <nav role="navigation" aria-label="Main navigation">
          {/* Navigation implementation */}
        </nav>
      </header>
      
      <main id="main-content" role="main" tabIndex={-1}>
        <h1>Fantasy Draft Assistant</h1>
        {children}
      </main>
      
      <aside role="complementary" aria-label="Draft tools">
        <section id="source-weights" aria-labelledby="weights-heading">
          <h2 id="weights-heading">Source Weights</h2>
          {/* Weight controls */}
        </section>
      </aside>
    </>
  );
}
```

### Automated Testing Integration

**Accessibility Test Setup:**
```typescript
// __tests__/accessibility.test.tsx
import { axe, toHaveNoViolations } from 'jest-axe';
import { render } from '@testing-library/react';

expect.extend(toHaveNoViolations);

describe('Accessibility Tests', () => {
  test('Rankings table has no accessibility violations', async () => {
    const { container } = render(<RankingsTable players={mockPlayers} sources={mockSources} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
  
  test('Draft status controls are keyboard accessible', async () => {
    const { getByLabelText } = render(<DraftBoard players={mockPlayers} />);
    const firstPlayerToggle = getByLabelText(/Mark .* as drafted/);
    
    // Test keyboard interaction
    fireEvent.keyDown(firstPlayerToggle, { key: 'Enter' });
    expect(firstPlayerToggle).toHaveAttribute('aria-pressed', 'true');
  });
  
  test('Source weight sliders have proper ARIA labels', () => {
    const { getByLabelText } = render(<WeightSlider source={mockSource} weight={1.0} onChange={() => {}} />);
    const slider = getByLabelText(`Adjust weight for ${mockSource.name}`);
    expect(slider).toBeInTheDocument();
    expect(slider).toHaveAttribute('aria-valuetext');
  });
});
```

This comprehensive accessibility architecture ensures the application is usable by all users, including those using screen readers, keyboard navigation, and high contrast modes. The implementation provides specific guidance for fantasy draft scenarios while maintaining WCAG 2.1 AA compliance.

## Security Architecture

### File Upload Security

**Multi-Layer File Validation:**
```python
# api/security/file_validator.py
from magic import from_buffer
from pathlib import Path
import hashlib
import zipfile
import redis
from datetime import datetime
from typing import List, Optional

class FileSecurityValidator:
    # Security configuration constants
    MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB total per file
    MAX_DAILY_QUOTA_PER_USER = 200 * 1024 * 1024  # 200MB per user per day
    MAX_FILES_PER_HOUR_PER_USER = 10  # Prevent abuse
    VIRUS_SCAN_TIMEOUT = 30  # seconds
    
    # Allowed file types with multiple validation layers
    ALLOWED_EXTENSIONS = {'.xlsx', '.xls', '.csv'}
    ALLOWED_MIME_TYPES = {
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',  # .xlsx
        'application/vnd.ms-excel',  # .xls
        'text/csv'  # .csv
    }
    
    # Magic number signatures for file type verification
    FILE_SIGNATURES = {
        b'\x50\x4B\x03\x04': 'xlsx',  # ZIP header (XLSX files are ZIP archives)
        b'\xD0\xCF\x11\xE0': 'xls',   # OLE2 header for legacy Excel
        b'\x09\x08\x07\x06': 'xls',   # Alternative XLS signature
    }
    
    def __init__(self):
        self.quarantine_dir = Path('/tmp/quarantine')
        self.quarantine_dir.mkdir(exist_ok=True)
        self.redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)
    
    async def validate_upload(self, file_content: bytes, filename: str, user_id: str) -> dict:
        """Comprehensive file validation with security checks."""
        errors = []
        warnings = []
        
        # 1. User quota validation
        quota_check = await self._check_user_quota(user_id, len(file_content))
        if not quota_check['allowed']:
            errors.append(quota_check['reason'])
        
        # 2. File size validation
        if len(file_content) > self.MAX_FILE_SIZE:
            errors.append(f"File too large: {len(file_content)} bytes (max {self.MAX_FILE_SIZE})")
        
        if len(file_content) == 0:
            errors.append("Empty file uploaded")
        
        # 3. File extension validation
        file_ext = Path(filename).suffix.lower()
        if file_ext not in self.ALLOWED_EXTENSIONS:
            errors.append(f"Unsupported file type: {file_ext}")
        
        # 4. MIME type validation (from filename)
        detected_mime = self._detect_mime_type(file_content)
        if detected_mime not in self.ALLOWED_MIME_TYPES:
            errors.append(f"Invalid MIME type: {detected_mime}")
        
        # 5. Magic number validation (file signature)
        file_signature = file_content[:4]
        expected_type = self._validate_file_signature(file_signature)
        if not expected_type:
            errors.append("Invalid file signature - file may be corrupted or malicious")
        
        # 6. Excel macro detection and removal
        if file_ext in {'.xlsx', '.xls'} and not errors:
            macro_check = await self._detect_and_remove_macros(file_content, filename)
            errors.extend(macro_check.get('errors', []))
            warnings.extend(macro_check.get('warnings', []))
        
        # 7. Content validation for Excel files
        if file_ext in {'.xlsx', '.xls'} and not errors:
            content_validation = await self._validate_excel_content(file_content, filename)
            errors.extend(content_validation.get('errors', []))
            warnings.extend(content_validation.get('warnings', []))
        
        # 8. Virus scanning integration
        if not errors:
            virus_check = await self._scan_for_viruses(file_content, filename)
            if not virus_check['is_clean']:
                errors.append(f"Security threat detected: {virus_check['threat_type']}")
        
        # 9. Malware scanning (pattern-based)
        malware_check = self._basic_malware_scan(file_content)
        if malware_check['is_suspicious']:
            errors.append(f"Security risk detected: {malware_check['reason']}")
        
        return {
            'is_valid': len(errors) == 0,
            'errors': errors,
            'warnings': warnings,
            'file_info': {
                'size': len(file_content),
                'detected_type': expected_type,
                'mime_type': detected_mime,
                'hash': hashlib.sha256(file_content).hexdigest()
            }
        }
    
    def _validate_file_signature(self, signature: bytes) -> Optional[str]:
        """Validate file type based on magic number signature."""
        for magic_bytes, file_type in self.FILE_SIGNATURES.items():
            if signature.startswith(magic_bytes):
                return file_type
        return None
    
    async def _validate_excel_content(self, file_content: bytes, filename: str) -> dict:
        """Validate Excel file structure and content."""
        errors = []
        warnings = []
        
        try:
            # For XLSX files, validate ZIP structure
            if filename.endswith('.xlsx'):
                # XLSX files are ZIP archives - validate structure
                temp_path = self.quarantine_dir / f"temp_{hashlib.md5(file_content).hexdigest()}.xlsx"
                temp_path.write_bytes(file_content)
                
                try:
                    with zipfile.ZipFile(temp_path, 'r') as zip_file:
                        # Check for required XLSX files
                        required_files = ['[Content_Types].xml', 'xl/workbook.xml']
                        zip_contents = zip_file.namelist()
                        
                        for required_file in required_files:
                            if required_file not in zip_contents:
                                errors.append(f"Invalid XLSX structure: missing {required_file}")
                        
                        # Check for suspicious files in ZIP
                        suspicious_extensions = {'.exe', '.dll', '.bat', '.cmd', '.ps1', '.vbs'}
                        for file_name in zip_contents:
                            file_ext = Path(file_name).suffix.lower()
                            if file_ext in suspicious_extensions:
                                errors.append(f"Suspicious file in archive: {file_name}")
                        
                        # Validate XML content is well-formed
                        try:
                            xml_content = zip_file.read('[Content_Types].xml')
                            if b'<script' in xml_content.lower() or b'javascript:' in xml_content.lower():
                                errors.append("Suspicious script content detected in Excel file")
                        except Exception:
                            warnings.append("Could not validate Excel XML structure")
                
                finally:
                    # Clean up temp file
                    if temp_path.exists():
                        temp_path.unlink()
        
        except zipfile.BadZipFile:
            errors.append("Corrupted Excel file - invalid ZIP structure")
        except Exception as e:
            warnings.append(f"Excel validation error: {str(e)}")
        
        return {'errors': errors, 'warnings': warnings}
    
    def _basic_malware_scan(self, file_content: bytes) -> dict:
        """Basic pattern-based malware detection."""
        suspicious_patterns = [
            b'javascript:',
            b'<script',
            b'eval(',
            b'document.write',
            b'ActiveXObject',
            b'Shell.Application',
            b'WScript.Shell',
            b'cmd.exe',
            b'powershell',
        ]
        
        content_lower = file_content.lower()
        for pattern in suspicious_patterns:
            if pattern in content_lower:
                return {
                    'is_suspicious': True,
                    'reason': f'Suspicious pattern detected: {pattern.decode("utf-8", errors="ignore")}'
                }
        
        return {'is_suspicious': False, 'reason': None}
    
    def _detect_mime_type(self, file_content: bytes) -> str:
        """Detect MIME type from file content."""
        try:
            return from_buffer(file_content, mime=True)
        except Exception:
            return 'unknown/unknown'
    
    async def _check_user_quota(self, user_id: str, file_size: int) -> dict:
        """Check if user is within upload quota limits."""
        today = datetime.utcnow().strftime('%Y-%m-%d')
        hour = datetime.utcnow().strftime('%Y-%m-%d-%H')
        
        # Check daily quota
        daily_key = f"upload_quota:{user_id}:{today}"
        daily_usage = int(self.redis_client.get(daily_key) or 0)
        
        if daily_usage + file_size > self.MAX_DAILY_QUOTA_PER_USER:
            return {
                'allowed': False,
                'reason': f'Daily upload quota exceeded. Used: {daily_usage/1024/1024:.1f}MB, Available: {(self.MAX_DAILY_QUOTA_PER_USER - daily_usage)/1024/1024:.1f}MB'
            }
        
        # Check hourly file count
        hourly_key = f"file_count:{user_id}:{hour}"
        hourly_count = int(self.redis_client.get(hourly_key) or 0)
        
        if hourly_count >= self.MAX_FILES_PER_HOUR_PER_USER:
            return {
                'allowed': False,
                'reason': f'Too many files uploaded this hour. Limit: {self.MAX_FILES_PER_HOUR_PER_USER} files per hour'
            }
        
        # Update quotas
        self.redis_client.setex(daily_key, 86400, daily_usage + file_size)  # 24 hours
        self.redis_client.setex(hourly_key, 3600, hourly_count + 1)  # 1 hour
        
        return {'allowed': True, 'reason': None}
    
    async def _detect_and_remove_macros(self, file_content: bytes, filename: str) -> dict:
        """Detect and remove Excel macros for security."""
        errors = []
        warnings = []
        
        if filename.endswith('.xlsx'):
            # XLSX files should not contain macros, but check for .xlsm structure
            temp_path = self.quarantine_dir / f"macro_check_{hashlib.md5(file_content).hexdigest()}.xlsx"
            temp_path.write_bytes(file_content)
            
            try:
                with zipfile.ZipFile(temp_path, 'r') as zip_file:
                    zip_contents = zip_file.namelist()
                    
                    # Check for VBA macro files
                    macro_files = [f for f in zip_contents if 'vbaProject.bin' in f or 'macros/' in f.lower()]
                    if macro_files:
                        errors.append(f"Excel macros detected: {', '.join(macro_files)}")
                    
                    # Check for external links that could be malicious
                    external_links = [f for f in zip_contents if 'externalLinks' in f]
                    if external_links:
                        warnings.append("External links detected in Excel file - review for security")
                        
            except Exception as e:
                warnings.append(f"Unable to fully scan Excel structure: {str(e)}")
            finally:
                if temp_path.exists():
                    temp_path.unlink()
                    
        elif filename.endswith('.xls'):
            # Legacy Excel files - scan for VBA indicators
            if b'_VBA_PROJECT' in file_content or b'VBA' in file_content:
                errors.append("Legacy Excel file contains VBA macros")
                
            if b'HYPERLINK' in file_content.upper():
                warnings.append("Hyperlinks detected in legacy Excel file")
        
        return {'errors': errors, 'warnings': warnings}
    
    async def _scan_for_viruses(self, file_content: bytes, filename: str) -> dict:
        """Integration point for virus scanning service."""
        try:
            # Integration with ClamAV or similar service
            temp_path = self.quarantine_dir / f"virus_scan_{hashlib.md5(file_content).hexdigest()}_{filename}"
            temp_path.write_bytes(file_content)
            
            # Example integration with ClamAV
            import subprocess
            import asyncio
            
            try:
                # Run virus scan with timeout
                result = await asyncio.wait_for(
                    asyncio.create_subprocess_exec(
                        'clamscan', '--no-summary', str(temp_path),
                        stdout=asyncio.subprocess.PIPE,
                        stderr=asyncio.subprocess.PIPE
                    ),
                    timeout=self.VIRUS_SCAN_TIMEOUT
                )
                
                stdout, stderr = await result.communicate()
                scan_output = stdout.decode('utf-8', errors='ignore')
                
                if 'FOUND' in scan_output:
                    # Extract threat name from ClamAV output
                    threat_lines = [line for line in scan_output.split('\n') if 'FOUND' in line]
                    threat_type = threat_lines[0].split(':')[1].strip() if threat_lines else 'Unknown threat'
                    
                    return {
                        'is_clean': False,
                        'threat_type': threat_type,
                        'scan_result': scan_output
                    }
                else:
                    return {
                        'is_clean': True,
                        'threat_type': None,
                        'scan_result': 'Clean'
                    }
                    
            except asyncio.TimeoutError:
                return {
                    'is_clean': False,
                    'threat_type': 'Scan timeout - file too complex',
                    'scan_result': 'Timeout'
                }
            except FileNotFoundError:
                # ClamAV not installed - fallback to pattern matching only
                return {
                    'is_clean': True,
                    'threat_type': None,
                    'scan_result': 'No virus scanner available - using pattern matching only'
                }
            finally:
                if temp_path.exists():
                    temp_path.unlink()
                    
        except Exception as e:
            return {
                'is_clean': False,
                'threat_type': f'Scan error: {str(e)}',
                'scan_result': 'Error during scan'
            }
```

### API Security and Rate Limiting

**Request Validation and Rate Limiting:**
```python
# api/security/api_security.py
from fastapi import HTTPException, Request, Depends
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import hashlib
import hmac
from typing import Optional
import re

# Rate limiter configuration
limiter = Limiter(key_func=get_remote_address)

class APISecurityMiddleware:
    # Fantasy-specific rate limiting configuration
    RATE_LIMITS = {
        "/api/files/upload": "10/hour",           # File uploads - restrictive to prevent abuse
        "/api/files/process": "5/minute",         # File processing - CPU intensive
        "/api/rankings/*": "100/hour",            # Rankings queries - core functionality
        "/api/drafts/*": "50/hour",              # Draft operations - moderate usage
        "/api/players/search": "200/hour",        # Player searches - high frequency
        "/api/auth/login": "5/minute",           # Authentication - prevent brute force
        "/api/admin/*": "20/minute",             # Admin operations - limited access
        "default": "30/minute"                   # General API calls
    }
    
    # Input validation patterns for fantasy data
    SAFE_PATTERNS = {
        'league': re.compile(r'^[a-zA-Z0-9_-]{1,20}$'),
        'season': re.compile(r'^\d{4}-\d{4}$'),
        'player_name': re.compile(r'^[a-zA-Z\s\'-\.]{1,100}$'),
        'position': re.compile(r'^[CGDLRW]{1,3}$'),  # Hockey-specific positions
        'team_abbreviation': re.compile(r'^[A-Z]{2,4}$'),  # NHL team abbreviations
        'uuid': re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'),
        'draft_session_name': re.compile(r'^[a-zA-Z0-9\s_-]{1,50}$'),
        'source_name': re.compile(r'^[a-zA-Z0-9\s_-]{1,30}$')
    }
    
    # Fantasy data-specific sanitization patterns
    FANTASY_DATA_PATTERNS = {
        'player_stats': [
            r'^-?(\d+\.?\d*)$',  # Allow numbers and decimals for stats
            r'^[A-Z]{1,3}$'      # Position abbreviations
        ],
        'source_weights': [
            r'^([0-2]\.?\d*)$'   # Weights between 0-2.0
        ]
    }
    
    # SQL injection patterns
    SQL_INJECTION_PATTERNS = [
        r"('|(\\')|(;)|(\\;)|(\|)|(\*)|(%)|(--)|(;)",
        r"(union\s+select)|(drop\s+table)|(insert\s+into)|(delete\s+from)",
        r"(exec\s+xp_)|(sp_)|(xp_cmdshell)"
    ]
    
    def __init__(self):
        self.csrf_secret = "your-csrf-secret-key"  # Should be from environment
    
    @staticmethod
    def validate_input(input_value: str, input_type: str) -> bool:
        """Validate input against safe patterns."""
        if input_type not in APISecurityMiddleware.SAFE_PATTERNS:
            return False
        
        pattern = APISecurityMiddleware.SAFE_PATTERNS[input_type]
        return bool(pattern.match(input_value))
    
    @staticmethod
    def check_sql_injection(input_value: str) -> bool:
        """Check for SQL injection patterns."""
        input_lower = input_value.lower()
        
        for pattern in APISecurityMiddleware.SQL_INJECTION_PATTERNS:
            if re.search(pattern, input_lower, re.IGNORECASE):
                return True
        return False
    
    @staticmethod
    def sanitize_input(input_value: str) -> str:
        """Sanitize input by removing dangerous characters."""
        # Remove HTML/script tags
        input_value = re.sub(r'<[^>]*>', '', input_value)
        
        # Remove potential XSS patterns
        xss_patterns = [
            r'javascript:',
            r'on\w+\s*=',
            r'<script',
            r'</script>',
            r'eval\(',
            r'document\.',
            r'window\.'
        ]
        
        for pattern in xss_patterns:
            input_value = re.sub(pattern, '', input_value, flags=re.IGNORECASE)
        
        return input_value.strip()
    
    @staticmethod
    def sanitize_fantasy_data(data: dict) -> dict:
        """Sanitize fantasy-specific data inputs."""
        sanitized = {}
        
        for key, value in data.items():
            if key == 'player_name':
                # Allow only valid name characters, remove potential injections
                if isinstance(value, str):
                    # Remove non-printable characters
                    value = ''.join(char for char in value if char.isprintable())
                    # Validate against player name pattern
                    if re.match(r'^[a-zA-Z\s\'-\.]{1,100}$', value):
                        sanitized[key] = value.strip()
                    else:
                        sanitized[key] = re.sub(r'[^a-zA-Z\s\'-\.]', '', value)[:100].strip()
            
            elif key == 'position':
                # Hockey positions only
                if isinstance(value, str):
                    clean_pos = value.upper().strip()
                    if re.match(r'^[CGDLRW]{1,3}$', clean_pos):
                        sanitized[key] = clean_pos
                    else:
                        sanitized[key] = 'C'  # Default to center if invalid
            
            elif key in ['goals', 'assists', 'points', 'rank']:
                # Numeric stats - allow integers and floats
                if isinstance(value, (int, float)):
                    sanitized[key] = value
                elif isinstance(value, str):
                    try:
                        # Try to convert string numbers
                        if '.' in value:
                            sanitized[key] = float(value)
                        else:
                            sanitized[key] = int(value)
                    except ValueError:
                        sanitized[key] = 0  # Default to 0 if invalid
            
            elif key == 'source_weight':
                # Validate source weights (0.0 to 2.0)
                if isinstance(value, (int, float)):
                    sanitized[key] = max(0.0, min(2.0, float(value)))
                elif isinstance(value, str):
                    try:
                        weight = float(value)
                        sanitized[key] = max(0.0, min(2.0, weight))
                    except ValueError:
                        sanitized[key] = 1.0  # Default weight
            
            elif key == 'team_abbreviation':
                # NHL team abbreviations
                if isinstance(value, str):
                    clean_team = value.upper().strip()
                    if re.match(r'^[A-Z]{2,4}$', clean_team):
                        sanitized[key] = clean_team
                    else:
                        sanitized[key] = 'UNK'  # Unknown team
            
            else:
                # Default sanitization for other fields
                if isinstance(value, str):
                    sanitized[key] = APISecurityMiddleware.sanitize_input(value)
                else:
                    sanitized[key] = value
        
        return sanitized
    
    def generate_csrf_token(self, session_id: str) -> str:
        """Generate CSRF token for state-changing operations."""
        message = f"{session_id}:{self.csrf_secret}"
        return hmac.new(
            self.csrf_secret.encode(),
            message.encode(),
            hashlib.sha256
        ).hexdigest()
    
    def validate_csrf_token(self, token: str, session_id: str) -> bool:
        """Validate CSRF token."""
        expected_token = self.generate_csrf_token(session_id)
        return hmac.compare_digest(token, expected_token)

# Fantasy-specific rate limiting decorators
@limiter.limit(APISecurityMiddleware.RATE_LIMITS["/api/files/upload"])
async def rate_limit_file_uploads(request: Request):
    """Rate limit file uploads to prevent abuse."""
    pass

@limiter.limit(APISecurityMiddleware.RATE_LIMITS["/api/files/process"])  
async def rate_limit_file_processing(request: Request):
    """Rate limit CPU-intensive file processing operations."""
    pass

@limiter.limit(APISecurityMiddleware.RATE_LIMITS["/api/rankings/*"])
async def rate_limit_rankings(request: Request):
    """Rate limit ranking queries - core functionality."""
    pass

@limiter.limit(APISecurityMiddleware.RATE_LIMITS["/api/drafts/*"])
async def rate_limit_drafts(request: Request):
    """Rate limit draft operations.""" 
    pass

@limiter.limit(APISecurityMiddleware.RATE_LIMITS["/api/auth/login"])
async def rate_limit_auth(request: Request):
    """Strict rate limiting for authentication to prevent brute force."""
    pass

@limiter.limit(APISecurityMiddleware.RATE_LIMITS["default"])
async def rate_limit_default(request: Request):
    """Default rate limiting for general API calls."""
    pass

# API Versioning and Deprecation Strategy
class APIVersionManager:
    """Handles API versioning and deprecation for fantasy draft endpoints."""
    
    SUPPORTED_VERSIONS = ["v1", "v2"]  # Current supported versions
    DEFAULT_VERSION = "v2"  # Latest version
    DEPRECATED_VERSIONS = ["v1"]  # Versions scheduled for removal
    DEPRECATION_WARNINGS = {
        "v1": "API v1 is deprecated. Please migrate to v2 by 2024-12-01. See migration guide at /docs/v2-migration"
    }
    
    @staticmethod
    def get_api_version(request: Request) -> str:
        """Extract API version from request headers or URL path."""
        # Check Accept header first: Accept: application/vnd.fantasyapi.v2+json
        accept_header = request.headers.get("Accept", "")
        if "vnd.fantasyapi.v" in accept_header:
            version_match = re.search(r'v(\d+)', accept_header)
            if version_match:
                return f"v{version_match.group(1)}"
        
        # Check URL path: /api/v2/rankings/...
        path_parts = request.url.path.split('/')
        for part in path_parts:
            if part.startswith('v') and part[1:].isdigit():
                return part
                
        return APIVersionManager.DEFAULT_VERSION
    
    @staticmethod
    def add_deprecation_warning(response, version: str):
        """Add deprecation warning headers to response."""
        if version in APIVersionManager.DEPRECATED_VERSIONS:
            response.headers["X-API-Deprecation-Warning"] = APIVersionManager.DEPRECATION_WARNINGS[version]
            response.headers["X-API-Sunset-Date"] = "2024-12-01T00:00:00Z"
            response.headers["Link"] = '</docs/v2-migration>; rel="deprecation"'

# Input validation dependency
async def validate_request_data(request: Request, data: dict) -> dict:
    """Validate all request data for security."""
    security = APISecurityMiddleware()
    validated_data = {}
    
    for key, value in data.items():
        if isinstance(value, str):
            # Check for SQL injection
            if security.check_sql_injection(value):
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid input detected in {key}"
                )
            
            # Sanitize input
            validated_data[key] = security.sanitize_input(value)
        else:
            validated_data[key] = value
    
    return validated_data

# CSRF protection for state-changing operations
async def require_csrf_token(
    request: Request,
    csrf_token: Optional[str] = None,
    session_id: Optional[str] = None
):
    """Require valid CSRF token for state-changing operations."""
    if not csrf_token or not session_id:
        raise HTTPException(
            status_code=400,
            detail="CSRF token and session ID required"
        )
    
    security = APISecurityMiddleware()
    if not security.validate_csrf_token(csrf_token, session_id):
        raise HTTPException(
            status_code=403,
            detail="Invalid CSRF token"
        )
```

### Authentication and Authorization

**JWT-Based Session Management:**
```python
# api/security/auth.py
import jwt
from datetime import datetime, timedelta
from passlib.context import CryptContext
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import redis
from typing import Optional
import secrets

class AuthenticationManager:
    def __init__(self):
        self.secret_key = "your-jwt-secret-key"  # Should be from environment
        self.algorithm = "HS256"
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        self.redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)
        self.bearer = HTTPBearer()
        
        # Token expiration times
        self.access_token_expire = timedelta(hours=1)
        self.refresh_token_expire = timedelta(days=7)
    
    def hash_password(self, password: str) -> str:
        """Hash password using bcrypt."""
        return self.pwd_context.hash(password)
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify password against hash."""
        return self.pwd_context.verify(plain_password, hashed_password)
    
    def create_access_token(self, user_id: str, additional_claims: dict = None) -> str:
        """Create JWT access token."""
        expire = datetime.utcnow() + self.access_token_expire
        
        to_encode = {
            "sub": user_id,
            "exp": expire,
            "iat": datetime.utcnow(),
            "type": "access"
        }
        
        if additional_claims:
            to_encode.update(additional_claims)
        
        encoded_jwt = jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)
        
        # Store in Redis for revocation capability
        self.redis_client.setex(
            f"access_token:{user_id}:{encoded_jwt[-10:]}",  # Last 10 chars as identifier
            self.access_token_expire,
            "valid"
        )
        
        return encoded_jwt
    
    def create_refresh_token(self, user_id: str) -> str:
        """Create refresh token."""
        token = secrets.token_urlsafe(32)
        
        # Store refresh token in Redis
        self.redis_client.setex(
            f"refresh_token:{user_id}:{token}",
            self.refresh_token_expire,
            "valid"
        )
        
        return token
    
    def verify_access_token(self, token: str) -> dict:
        """Verify and decode access token."""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            
            # Check if token is in Redis (not revoked)
            token_key = f"access_token:{payload['sub']}:{token[-10:]}"
            if not self.redis_client.exists(token_key):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token has been revoked"
                )
            
            return payload
        
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired"
            )
        except jwt.JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )
    
    def revoke_token(self, user_id: str, token: str):
        """Revoke access token."""
        token_key = f"access_token:{user_id}:{token[-10:]}"
        self.redis_client.delete(token_key)
    
    def revoke_all_tokens(self, user_id: str):
        """Revoke all tokens for a user."""
        # Get all access tokens for user
        access_pattern = f"access_token:{user_id}:*"
        refresh_pattern = f"refresh_token:{user_id}:*"
        
        for pattern in [access_pattern, refresh_pattern]:
            for key in self.redis_client.scan_iter(match=pattern):
                self.redis_client.delete(key)

# Dependency to get current user from token
auth_manager = AuthenticationManager()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(auth_manager.bearer)) -> dict:
    """Get current user from JWT token."""
    token = credentials.credentials
    payload = auth_manager.verify_access_token(token)
    return payload

# Optional authentication (for public endpoints that can benefit from user context)
async def get_current_user_optional(authorization: Optional[str] = None) -> Optional[dict]:
    """Get current user if token is provided, otherwise None."""
    if not authorization:
        return None
    
    try:
        # Extract token from "Bearer <token>" format
        if not authorization.startswith("Bearer "):
            return None
        
        token = authorization[7:]  # Remove "Bearer " prefix
        return auth_manager.verify_access_token(token)
    except:
        return None
```

### Data Protection and Privacy

**Data Encryption and Privacy Controls:**
```python
# api/security/data_protection.py
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os
from typing import Dict, Any
import json

class DataProtectionManager:
    def __init__(self):
        # Generate or load encryption key (should be from secure environment variable)
        self.salt = b'stable_salt_for_fantasy_app'  # Should be from environment
        self.encryption_key = self._derive_key("your-encryption-password")
        self.cipher_suite = Fernet(self.encryption_key)
    
    def _derive_key(self, password: str) -> bytes:
        """Derive encryption key from password."""
        password_bytes = password.encode()
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=self.salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password_bytes))
        return key
    
    def encrypt_sensitive_data(self, data: str) -> str:
        """Encrypt sensitive data (PII, preferences, etc.)."""
        encrypted_data = self.cipher_suite.encrypt(data.encode())
        return base64.urlsafe_b64encode(encrypted_data).decode()
    
    def decrypt_sensitive_data(self, encrypted_data: str) -> str:
        """Decrypt sensitive data."""
        try:
            decoded_data = base64.urlsafe_b64decode(encrypted_data.encode())
            decrypted_data = self.cipher_suite.decrypt(decoded_data)
            return decrypted_data.decode()
        except Exception:
            raise ValueError("Failed to decrypt data - invalid or corrupted")
    
    def hash_pii_for_analytics(self, pii_data: str) -> str:
        """Hash PII for analytics while preserving uniqueness."""
        import hashlib
        return hashlib.sha256(f"{pii_data}:analytics_salt".encode()).hexdigest()[:16]
    
    def sanitize_user_data_for_logs(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """Remove sensitive data from logs and analytics."""
        sensitive_fields = {
            'email', 'password', 'ip_address', 'user_agent', 
            'session_id', 'csrf_token', 'refresh_token'
        }
        
        sanitized = {}
        for key, value in user_data.items():
            if key.lower() in sensitive_fields:
                # Replace with hash or redacted indicator
                if key == 'email':
                    sanitized[key] = self.hash_pii_for_analytics(str(value))
                else:
                    sanitized[key] = '[REDACTED]'
            else:
                sanitized[key] = value
        
        return sanitized

# Data retention and cleanup
class DataRetentionManager:
    def __init__(self):
        self.retention_periods = {
            'user_sessions': timedelta(days=30),
            'analytics_events': timedelta(days=90),
            'error_logs': timedelta(days=60),
            'file_uploads': timedelta(days=7),  # Temporary files
            'draft_sessions': timedelta(days=365),  # Keep draft history longer
        }
    
    async def cleanup_expired_data(self):
        """Clean up expired data according to retention policies."""
        current_time = datetime.utcnow()
        
        for data_type, retention_period in self.retention_periods.items():
            cutoff_date = current_time - retention_period
            
            # Implementation would depend on your database structure
            if data_type == 'user_sessions':
                # Clean up expired sessions from Redis
                pass
            elif data_type == 'analytics_events':
                # Archive old analytics data
                pass
            # ... other cleanup operations
```

### Security Headers and CORS Configuration

**Production Security Configuration:**
```python
# api/security/headers.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
import os

def configure_security_headers(app: FastAPI):
    """Configure security headers and middleware."""
    
    # CORS configuration
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["https://yourdomain.com", "https://www.yourdomain.com"],
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
        allow_headers=["Authorization", "Content-Type", "X-CSRF-Token"],
        expose_headers=["X-Total-Count", "X-Page-Count"]
    )
    
    # Trusted host middleware
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["yourdomain.com", "*.yourdomain.com", "localhost", "127.0.0.1"]
    )
    
    @app.middleware("http")
    async def add_security_headers(request, call_next):
        response = await call_next(request)
        
        # Security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' https://vercel.live https://*.vercel.com; "
            "style-src 'self' 'unsafe-inline'; "
            "img-src 'self' data: https:; "
            "font-src 'self'; "
            "connect-src 'self' https://api.yourdomain.com; "
            "frame-ancestors 'none';"
        )
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = (
            "camera=(), microphone=(), geolocation=(), interest-cohort=()"
        )
        
        return response
```

This comprehensive security architecture provides multiple layers of protection for file uploads, API access, user authentication, and data privacy while maintaining the performance needed for fantasy draft scenarios.

## Performance Scaling Architecture

### Background Job Processing

**Problem Addressed**: Current synchronous file processing doesn't scale for concurrent users. Large Excel files (10MB+) with complex projections can take 5-15 seconds to process, blocking API responses and degrading user experience.

**Solution**: Asynchronous background job processing with real-time status updates.

#### Background Job Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            File Upload & Processing Flow                        │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐    ┌──────────────┐    ┌──────────────────────────────────────────┐
│   Frontend   │    │   FastAPI    │    │            Background Jobs               │
│  (Next.js)   │    │   Backend    │    │         (Celery Workers)                 │
└──────┬───────┘    └──────┬───────┘    └──────────────────────────────────────────┘
       │                   │
       │ POST /api/files/upload
       │ (Excel file)      │
       ├──────────────────►│
       │                   │ 1. Validate file
       │                   │ 2. Store temporarily
       │                   │ 3. Queue background job
       │                   │ 4. Return job_id immediately
       │◄──────────────────┤
       │ 200 OK           │
       │ {job_id: "abc123"}│              ┌─────────────────────────────────────┐
       │                   │              │        Redis Job Queues             │
       │                   │              │                                     │
       │                   │              │ file_processing: [job1, job2]      │
       │                   │   Enqueue    │ calculations: [job3]                │
       │                   ├─────────────►│ validation: [job4, job5]            │
       │                   │              │ analysis: [job6]                    │
       │                   │              │ maintenance: [job7]                 │
       │                   │              └─────────────────────────────────────┘
       │                   │                            │
       │ GET /api/files/abc123/status                   │ Dequeue jobs
       │ (polling every 5-10s)                         ▼
       ├──────────────────►│              ┌─────────────────────────────────────┐
       │◄──────────────────┤              │         Celery Workers              │
       │ {status: "processing",             │                                     │
       │  progress: 0.75,   │              │ Worker 1: File Processing           │
       │  message: "Validating..."}        │ Worker 2: Ranking Calculations      │
       │                   │              │ Worker 3: Player Validation         │
       │                   │              │ Worker 4: Analysis & Recommendations│
       │                   │              │ ...                                 │
       │                   │              └─────────────────────────────────────┘
       │                   │                            │
       │                   │                            │ Update job status
       │                   │                            ▼
       │                   │              ┌─────────────────────────────────────┐
       │                   │              │      Redis Job Status Cache         │
       │                   │              │                                     │
       │                   │              │ job:abc123 -> {                     │
       │                   │              │   status: "completed",              │
       │                   │              │   progress: 1.0,                    │
       │                   │              │   result: {...},                    │
       │                   │              │   updated_at: "2024-01-15T10:30:00Z"│
       │                   │              │ }                                   │
       │                   │              └─────────────────────────────────────┘
       │                   │                            │
       │                   │                            │ Read status
       │                   │◄───────────────────────────┘
       │ Final status poll │
       ├──────────────────►│
       │◄──────────────────┤
       │ {status: "completed",
       │  result: {source_id: "xyz",
       │           player_count: 150}}
```

#### Job Queue Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Celery Queue Architecture                          │
└─────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐    ┌─────────────────────────┐
│                Redis Broker                    │    │    PostgreSQL Results   │
│  ┌──────────────────────────────────────────┐  │    │                         │
│  │            Queue: file_processing        │  │    │  Permanent storage for  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐     │  │    │  processed data and     │
│  │  │  Job 1  │ │  Job 2  │ │  Job 3  │     │  │    │  ranking results        │
│  │  │Priority:│ │Priority:│ │Priority:│     │  │    │                         │
│  │  │   HIGH  │ │  MEDIUM │ │   LOW   │     │  │    └─────────────────────────┘
│  │  └─────────┘ └─────────┘ └─────────┘     │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │           Queue: calculations            │  │    ┌─────────────────────────┐
│  │  ┌─────────┐ ┌─────────┐                 │  │    │    Redis Job Status     │
│  │  │Ranking  │ │Consensus│                 │  │    │                         │
│  │  │Calc Job │ │Avg Job  │                 │  │    │  job:abc123 -> status   │
│  │  └─────────┘ └─────────┘                 │  │    │  job:def456 -> progress │
│  └──────────────────────────────────────────┘  │    │  job:ghi789 -> result   │
│  ┌──────────────────────────────────────────┐  │    │                         │
│  │            Queue: validation             │  │    │  TTL: 1 hour            │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐     │  │    └─────────────────────────┘
│  │  │Player   │ │Name     │ │Data     │     │  │
│  │  │Lookup   │ │Matching │ │Quality  │     │  │
│  │  └─────────┘ └─────────┘ └─────────┘     │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │             Queue: analysis              │  │
│  │  ┌─────────┐ ┌─────────┐                 │  │
│  │  │Team     │ │Draft    │                 │  │
│  │  │Balance  │ │Recommendations            │  │
│  │  └─────────┘ └─────────┘                 │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │            Queue: maintenance            │  │
│  │  ┌─────────┐ ┌─────────┐                 │  │
│  │  │Cleanup  │ │Cache    │                 │  │
│  │  │Expired  │ │Warming  │                 │  │
│  │  └─────────┘ └─────────┘                 │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘

                            │
                            ▼
                            
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Celery Workers                                     │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   Worker Pool 1     │  │   Worker Pool 2     │  │   Worker Pool 3     │
│  (File Processing)  │  │   (Calculations)    │  │   (Validation)      │
│                     │  │                     │  │                     │
│ Concurrency: 4      │  │ Concurrency: 6      │  │ Concurrency: 8      │
│ Memory: 512MB each  │  │ Memory: 1GB each    │  │ Memory: 256MB each  │
│                     │  │                     │  │                     │
│ ┌─────────────────┐ │  │ ┌─────────────────┐ │  │ ┌─────────────────┐ │
│ │ Excel Parser    │ │  │ │ Ranking Engine  │ │  │ │ NHL Player DB   │ │
│ │ & File Handler  │ │  │ │ & Consensus     │ │  │ │ Lookup Service  │ │
│ └─────────────────┘ │  │ └─────────────────┘ │  │ └─────────────────┘ │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘

┌─────────────────────┐  ┌─────────────────────┐
│   Worker Pool 4     │  │   Worker Pool 5     │
│    (Analysis)       │  │   (Maintenance)     │
│                     │  │                     │
│ Concurrency: 2      │  │ Concurrency: 1      │
│ Memory: 1GB each    │  │ Memory: 512MB       │
│                     │  │                     │
│ ┌─────────────────┐ │  │ ┌─────────────────┐ │
│ │ Draft AI &      │ │  │ │ Cleanup &       │ │
│ │ Recommendations │ │  │ │ Cache Warming   │ │
│ └─────────────────┘ │  │ └─────────────────┘ │
└─────────────────────┘  └─────────────────────┘
```

#### Real-Time Status Updates

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Job Status Tracking Flow                               │
└─────────────────────────────────────────────────────────────────────────────────┘

Frontend Polling Cycle:                    Backend Job Processing:

┌──────────────┐                          ┌────────────────────────────────────┐
│   Browser    │                          │          Celery Worker             │
│              │                          │                                    │
│ Timer: 7s    │                          │  ┌─────────────────────────────┐   │
│ ┌──────────┐ │                          │  │     process_file_task()     │   │
│ │setInterval│ │                          │  │                             │   │
│ │  Poll     │ │                          │  │ 1. Parse Excel              │   │
│ │  Status   │ │                          │  │    update_status(           │   │
│ └──────────┘ │                          │  │      "processing",          │   │
│      │       │                          │  │      "Parsing file...",     │   │
│      ▼       │                          │  │      {progress: 0.2}        │   │
│ GET /status  │                          │  │    )                        │   │
│      │       │                          │  │                             │   │
│      ▼       │                          │  │ 2. Validate Players         │   │
│ ┌──────────┐ │                          │  │    update_status(           │   │
│ │ Display  │ │                          │  │      "processing",          │   │
│ │ Progress │ │                          │  │      "Validating...",       │   │
│ │ Bar/Msg  │ │                          │  │      {progress: 0.6}        │   │
│ └──────────┘ │                          │  │    )                        │   │
└──────────────┘                          │  │                             │   │
                                          │  │ 3. Store in DB              │   │
                                          │  │    update_status(           │   │
┌──────────────────────────────────┐      │  │      "processing",          │   │
│         Redis Status Cache       │      │  │      "Saving...",           │   │
│                                  │      │  │      {progress: 0.9}        │   │
│ job:abc123 -> {                  │◄─────┤  │    )                        │   │
│   status: "processing",          │      │  │                             │   │
│   message: "Validating...",      │      │  │ 4. Complete                 │   │
│   progress: 0.6,                 │      │  │    update_status(           │   │
│   updated_at: "10:30:15Z",       │      │  │      "completed",           │   │
│   estimated_completion: "10:32Z" │      │  │      "Success",             │   │
│ }                                │      │  │      {                      │   │
│                                  │      │  │        progress: 1.0,       │   │
│ TTL: 3600 seconds               │      │  │        result: {...}        │   │
└──────────────────────────────────┘      │  │      }                      │   │
                                          │  │    )                        │   │
                                          │  └─────────────────────────────┘   │
                                          └────────────────────────────────────┘

Status Response Evolution:
┌─────────────────────────────────────────────────────────────────────────────────┐
│ t=0s:  {status: "queued",     progress: 0.0, message: "Waiting in queue..."}   │
│ t=5s:  {status: "processing", progress: 0.2, message: "Parsing Excel file..."}  │
│ t=15s: {status: "processing", progress: 0.6, message: "Validating players..."}  │
│ t=25s: {status: "processing", progress: 0.9, message: "Saving to database..."} │
│ t=30s: {status: "completed",  progress: 1.0, result: {source_id: "xyz"}}       │
└─────────────────────────────────────────────────────────────────────────────────┘
```

#### Worker Scaling Strategy

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            Horizontal Worker Scaling                            │
└─────────────────────────────────────────────────────────────────────────────────┘

Load-Based Scaling:

Low Traffic (< 10 concurrent users):
┌─────────────────────────────────────────────────────────────────────────────────┐
│  Server Instance 1                                                              │
│  ┌─────────────────────┐  ┌─────────────────────┐                              │
│  │  FastAPI (1 proc)   │  │  Celery Workers     │                              │
│  │                     │  │                     │                              │
│  │  - File uploads     │  │  - 2 file workers   │                              │
│  │  - Status polling   │  │  - 2 calc workers   │                              │
│  │  - Rankings API     │  │  - 1 validation     │                              │
│  └─────────────────────┘  └─────────────────────┘                              │
└─────────────────────────────────────────────────────────────────────────────────┘

Medium Traffic (10-50 concurrent users):
┌─────────────────────────────────────────────────────────────────────────────────┐
│  Server Instance 1          │          Server Instance 2                       │
│  ┌─────────────────────┐    │    ┌─────────────────────┐                       │
│  │  FastAPI (2 proc)   │    │    │  FastAPI (2 proc)   │                       │
│  │                     │    │    │                     │                       │
│  │  + Load Balancer    │    │    │  + Load Balancer    │                       │
│  └─────────────────────┘    │    └─────────────────────┘                       │
│  ┌─────────────────────┐    │    ┌─────────────────────┐                       │
│  │  Celery Workers     │    │    │  Celery Workers     │                       │
│  │                     │    │    │                     │                       │
│  │  - 4 file workers   │    │    │  - 4 calc workers   │                       │
│  │  - 2 validation     │    │    │  - 2 analysis       │                       │
│  └─────────────────────┘    │    └─────────────────────┘                       │
└─────────────────────────────────────────────────────────────────────────────────┘

High Traffic (50+ concurrent users):
┌─────────────────────────────────────────────────────────────────────────────────┐
│  API Layer (3+ instances)       │     Worker Layer (5+ instances)               │
│  ┌─────────────────────┐        │  ┌─────────────────────┐                      │
│  │  FastAPI Cluster    │        │  │  File Processing    │                      │
│  │                     │        │  │  Workers            │                      │
│  │  - Auto-scaling     │        │  │                     │                      │
│  │  - Health checks    │        │  │  - 8 workers/node   │                      │
│  │  - Rate limiting    │        │  │  - Auto-scale       │                      │
│  └─────────────────────┘        │  └─────────────────────┘                      │
│                                 │  ┌─────────────────────┐                      │
│                                 │  │  Calculation        │                      │
│                                 │  │  Workers            │                      │
│                                 │  │                     │                      │
│                                 │  │  - 6 workers/node   │                      │
│                                 │  │  - Memory optimized │                      │
│                                 │  └─────────────────────┘                      │
│                                 │  ┌─────────────────────┐                      │
│                                 │  │  Validation &       │                      │
│                                 │  │  Analysis Workers   │                      │
│                                 │  │                     │                      │
│                                 │  │  - 4 workers/node   │                      │
│                                 │  │  - Database optimized│                     │
│                                 │  └─────────────────────┘                      │
└─────────────────────────────────────────────────────────────────────────────────┘

Auto-scaling Triggers:
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Queue Depth Monitoring:                                                         │
│ • file_processing queue > 10 jobs → Scale up file workers                      │
│ • calculations queue > 5 jobs → Scale up calculation workers                   │
│ • Average job wait time > 30 seconds → Scale up appropriate pool               │
│ • CPU usage > 70% for 5 minutes → Scale up horizontally                        │
│ • Memory usage > 80% → Scale up or redistribute workers                        │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Asynchronous File Processing:**
```python
# api/background/job_processor.py
import asyncio
from celery import Celery
from typing import Dict, Any, List
import pandas as pd
from datetime import datetime, timedelta
import redis
from contextlib import asynccontextmanager

# Celery configuration for background tasks with performance optimization
celery_app = Celery(
    'fantasy_draft_worker',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/0'
)

# Enhanced Celery configuration for high-performance concurrent processing
celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    # Optimized task routing for different workload types
    task_routes={
        'api.background.job_processor.process_projection_file': {'queue': 'file_processing'},
        'api.background.job_processor.calculate_consensus_rankings': {'queue': 'calculations'},
        'api.background.job_processor.cleanup_expired_data': {'queue': 'maintenance'},
        'api.background.job_processor.batch_player_validation': {'queue': 'validation'},
        'api.background.job_processor.generate_recommendations': {'queue': 'analysis'},
    },
    # Concurrent processing configuration
    worker_concurrency=8,  # Increased for better throughput
    worker_prefetch_multiplier=1,  # Prevent worker hogging
    task_acks_late=True,  # Ensure reliability
    worker_disable_rate_limits=True,  # Remove rate limits for internal processing
    # Performance optimizations
    task_compression='gzip',  # Compress large payloads
    result_compression='gzip',
    # Retry configuration for reliability
    task_default_retry_delay=60,  # 1 minute
    task_max_retries=3,
)

# Performance monitoring decorator for background tasks
def monitor_task_performance(func):
    async def wrapper(*args, **kwargs):
        start_time = datetime.utcnow()
        try:
            result = await func(*args, **kwargs)
            duration = (datetime.utcnow() - start_time).total_seconds() * 1000
            
            # Log performance metrics
            perf_monitor.record_metric({
                'operation': f'background_task_{func.__name__}',
                'duration_ms': duration,
                'success': True,
                'timestamp': start_time.isoformat()
            })
            
            return result
        except Exception as e:
            duration = (datetime.utcnow() - start_time).total_seconds() * 1000
            perf_monitor.record_metric({
                'operation': f'background_task_{func.__name__}',
                'duration_ms': duration,
                'success': False,
                'error': str(e),
                'timestamp': start_time.isoformat()
            })
            raise
    return wrapper

class FileProcessingJob:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)
        # Connection pooling for database operations in background tasks
        self.db_pool = None
        self.performance_thresholds = {
            'file_processing_ms': 15000,  # 15 seconds max
            'player_validation_ms': 5000,  # 5 seconds max
            'ranking_calculation_ms': 10000,  # 10 seconds max
        }
    
    @celery_app.task(bind=True, max_retries=3)
    @monitor_task_performance
    def process_projection_file(self, file_id: str, user_id: str, draft_session_id: str) -> Dict[str, Any]:
        """Process uploaded projection file in background."""
        processing_start = datetime.utcnow()
        
        try:
            # Update job status with enhanced tracking
            self.update_job_status(file_id, 'processing', 'Parsing Excel file...', {
                'started_at': processing_start.isoformat(),
                'estimated_duration_seconds': 10
            })
            
            # 1. Load file from storage with streaming for large files
            step_start = datetime.utcnow()
            file_data = await self._load_file_from_storage_async(file_id)
            load_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # Performance check: File loading
            if load_duration > 3000:  # 3 seconds
                self.update_job_status(file_id, 'processing', 'Large file detected, optimizing processing...')
            
            # 2. Parse Excel file with memory-efficient streaming
            step_start = datetime.utcnow()
            self.update_job_status(file_id, 'processing', 'Extracting player data...', {
                'progress_percent': 20
            })
            parsed_data = await self._parse_projection_file_async(file_data, file_id)
            parse_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 3. Parallel player name validation for performance
            step_start = datetime.utcnow()
            self.update_job_status(file_id, 'processing', 'Validating player names...', {
                'progress_percent': 50,
                'player_count': len(parsed_data.get('players', []))
            })
            
            # Use separate task for CPU-intensive validation
            validation_task = batch_player_validation.delay(
                parsed_data['players'], user_id, draft_session_id
            )
            validated_data = validation_task.get(timeout=30)  # 30 second timeout
            validation_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 4. Store processed data in database with transaction batching
            step_start = datetime.utcnow()
            self.update_job_status(file_id, 'processing', 'Saving to database...', {
                'progress_percent': 80
            })
            source_id = await self._store_projection_source_batch(
                validated_data, user_id, draft_session_id, file_id
            )
            storage_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 5. Trigger async ranking recalculation (don't wait)
            self.update_job_status(file_id, 'processing', 'Queuing ranking recalculation...', {
                'progress_percent': 90
            })
            # Use apply_async for non-blocking execution
            calculate_consensus_rankings.apply_async(
                args=[draft_session_id],
                queue='calculations',
                priority=8  # High priority for ranking calculations
            )
            
            # 6. Mark as completed with detailed performance metrics
            total_duration = (datetime.utcnow() - processing_start).total_seconds() * 1000
            result = {
                'source_id': source_id,
                'player_count': len(validated_data['players']),
                'validation_issues': validated_data.get('issues', []),
                'performance_metrics': {
                    'total_processing_time_ms': total_duration,
                    'file_load_time_ms': load_duration,
                    'parse_time_ms': parse_duration,
                    'validation_time_ms': validation_duration,
                    'storage_time_ms': storage_duration,
                },
                'processed_at': datetime.utcnow().isoformat()
            }
            
            # Performance alerting
            if total_duration > self.performance_thresholds['file_processing_ms']:
                await self._alert_slow_processing(file_id, total_duration, result['performance_metrics'])
            
            self.update_job_status(file_id, 'completed', 'File processed successfully', result)
            return result
            
        except Exception as exc:
            total_duration = (datetime.utcnow() - processing_start).total_seconds() * 1000
            
            # Enhanced error handling with context
            error_context = {
                'processing_duration_ms': total_duration,
                'user_id': user_id,
                'draft_session_id': draft_session_id,
                'error_type': type(exc).__name__,
                'retry_count': self.request.retries
            }
            
            # Retry logic with exponential backoff
            if self.request.retries < self.max_retries:
                backoff_delay = min(300, 60 * (2 ** self.request.retries))  # Max 5 minutes
                self.update_job_status(file_id, 'retrying', 
                    f'Error: {str(exc)}, retrying in {backoff_delay}s... (attempt {self.request.retries + 1})',
                    error_context
                )
                raise self.retry(countdown=backoff_delay, exc=exc)
            else:
                # Final failure - comprehensive error logging
                await self._log_processing_failure(file_id, exc, error_context)
                self.update_job_status(file_id, 'failed', 
                    f'Processing failed after {self.max_retries} attempts: {str(exc)}', 
                    error_context
                )
                raise exc
    
    # New optimized background task for batch player validation
    @celery_app.task(bind=True, max_retries=2)
    @monitor_task_performance
    def batch_player_validation(self, players: List[Dict], user_id: str, draft_session_id: str) -> Dict[str, Any]:
        """Validate player names in parallel batches for better performance."""
        try:
            # Split players into batches for parallel processing
            batch_size = 100  # Process 100 players at a time
            batches = [players[i:i + batch_size] for i in range(0, len(players), batch_size)]
            
            validation_results = []
            issues = []
            
            for batch_idx, batch in enumerate(batches):
                batch_results = await self._validate_player_batch(batch, user_id)
                validation_results.extend(batch_results['validated_players'])
                issues.extend(batch_results['issues'])
                
                # Progress tracking
                progress = ((batch_idx + 1) / len(batches)) * 100
                self.update_job_status(
                    f'validation_{draft_session_id}', 
                    'processing', 
                    f'Validated batch {batch_idx + 1}/{len(batches)}',
                    {'progress_percent': progress}
                )
            
            return {
                'players': validation_results,
                'issues': issues,
                'validation_stats': {
                    'total_players': len(players),
                    'validated_players': len(validation_results),
                    'validation_issues': len(issues),
                    'batches_processed': len(batches)
                }
            }
            
        except Exception as exc:
            if self.request.retries < self.max_retries:
                raise self.retry(countdown=30, exc=exc)
            else:
                raise exc
    
    @celery_app.task(bind=True, queue='calculations')
    @monitor_task_performance
    def calculate_consensus_rankings(self, draft_session_id: str) -> Dict[str, Any]:
        """Recalculate consensus rankings for a draft session."""
        calculation_start = datetime.utcnow()
        job_id = f"ranking_calc_{draft_session_id}"
        
        try:
            self.update_job_status(job_id, 'processing', 'Loading projection sources...', {
                'started_at': calculation_start.isoformat(),
                'estimated_duration_seconds': 30
            })
            
            # 1. Load all projection sources with caching
            step_start = datetime.utcnow()
            
            # Check cache first to avoid expensive database queries
            cache_key = f"sources:{draft_session_id}"
            cached_sources = await self.redis_client.get(cache_key)
            
            if cached_sources:
                sources = json.loads(cached_sources)
                self.update_job_status(job_id, 'processing', 'Using cached projection sources')
            else:
                sources = await self._load_projection_sources_optimized(draft_session_id)
                # Cache for 30 minutes
                await self.redis_client.setex(cache_key, 1800, json.dumps(sources))
            
            load_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 2. Calculate weighted consensus with performance optimizations
            step_start = datetime.utcnow()
            self.update_job_status(job_id, 'processing', 'Calculating weighted rankings...', {
                'progress_percent': 30,
                'source_count': len(sources)
            })
            
            # Use vectorized operations for large datasets
            consensus_data = await self._calculate_weighted_consensus_optimized(sources)
            consensus_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 3. Apply percentile scoring with parallel processing
            step_start = datetime.utcnow()
            self.update_job_status(job_id, 'processing', 'Applying percentile scores...', {
                'progress_percent': 60
            })
            scored_data = await self._apply_percentile_scoring_parallel(consensus_data)
            scoring_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 4. Multi-level caching strategy
            step_start = datetime.utcnow()
            self.update_job_status(job_id, 'processing', 'Caching results...', {
                'progress_percent': 80
            })
            
            # Cache at multiple levels for optimal performance
            await self._cache_rankings_multi_level(draft_session_id, scored_data, sources)
            cache_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 5. Async database storage (non-blocking)
            step_start = datetime.utcnow()
            self.update_job_status(job_id, 'processing', 'Persisting to database...', {
                'progress_percent': 95
            })
            
            # Use background task for database storage to avoid blocking
            store_rankings_task = store_consensus_rankings.apply_async(
                args=[draft_session_id, scored_data],
                queue='database_writes'
            )
            storage_duration = (datetime.utcnow() - step_start).total_seconds() * 1000
            
            # 6. Comprehensive result with performance metrics
            total_duration = (datetime.utcnow() - calculation_start).total_seconds() * 1000
            result = {
                'total_players': len(scored_data['players']),
                'source_count': len(sources),
                'performance_metrics': {
                    'total_calculation_time_ms': total_duration,
                    'source_load_time_ms': load_duration,
                    'consensus_calculation_time_ms': consensus_duration,
                    'scoring_time_ms': scoring_duration,
                    'cache_time_ms': cache_duration,
                    'storage_time_ms': storage_duration
                },
                'cache_status': {
                    'rankings_cached': True,
                    'cache_ttl_seconds': 3600,
                    'cache_key': f"rankings:{draft_session_id}"
                },
                'calculation_timestamp': calculation_start.isoformat()
            }
            
            # Performance monitoring and alerting
            if total_duration > self.performance_thresholds['ranking_calculation_ms']:
                await self._alert_slow_calculation(job_id, total_duration, result['performance_metrics'])
            
            self.update_job_status(job_id, 'completed', 'Rankings calculated successfully', result)
            
            # Trigger dependent calculations asynchronously
            generate_recommendations.apply_async(
                args=[draft_session_id],
                queue='analysis',
                countdown=5  # Wait 5 seconds for database consistency
            )
            
            return result
            
        except Exception as exc:
            total_duration = (datetime.utcnow() - calculation_start).total_seconds() * 1000
            
            error_context = {
                'calculation_duration_ms': total_duration,
                'draft_session_id': draft_session_id,
                'error_type': type(exc).__name__,
                'retry_count': self.request.retries
            }
            
            # Retry with exponential backoff for transient failures
            if self.request.retries < self.max_retries and self._is_retryable_error(exc):
                backoff_delay = 30 * (2 ** self.request.retries)  # 30s, 60s, 120s
                self.update_job_status(job_id, 'retrying', 
                    f'Calculation error: {str(exc)}, retrying in {backoff_delay}s...',
                    error_context
                )
                raise self.retry(countdown=backoff_delay, exc=exc)
            else:
                await self._log_calculation_failure(job_id, exc, error_context)
                self.update_job_status(job_id, 'failed', 
                    f'Ranking calculation failed: {str(exc)}', 
                    error_context
                )
                raise exc
    
    def update_job_status(self, job_id: str, status: str, message: str, result: Dict = None):
        """Update job status in Redis for real-time tracking."""
        job_data = {
            'status': status,
            'message': message,
            'updated_at': datetime.utcnow().isoformat(),
        }
        
        if result:
            job_data['result'] = result
        
        self.redis_client.setex(f"job:{job_id}", 3600, json.dumps(job_data))
    
    def _parse_projection_file(self, file_data: bytes) -> Dict[str, Any]:
        """Parse Excel file and extract player projections."""
        import io
        
        # Use existing reader classes from the CLI codebase
        # This maintains consistency with current functionality
        df = pd.read_excel(io.BytesIO(file_data))
        
        # Apply column mapping and normalization
        # Implementation would use existing DAO reader classes
        return {
            'players': [],  # Processed player data
            'metadata': {},  # File metadata
            'processing_time_ms': 1250
        }

# Maintenance tasks
@celery_app.task
def cleanup_expired_data():
    """Clean up expired cache entries and temporary files."""
    redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)
    
    # Clean up expired job status entries
    pattern = "job:*"
    for key in redis_client.scan_iter(match=pattern):
        ttl = redis_client.ttl(key)
        if ttl == -2:  # Key doesn't exist
            redis_client.delete(key)
    
    # Clean up old ranking caches (keep last 3 versions)
    pattern = "rankings:*"
    ranking_keys = list(redis_client.scan_iter(match=pattern))
    for draft_session in set(key.split(':')[1] for key in ranking_keys):
        session_keys = [k for k in ranking_keys if k.startswith(f"rankings:{draft_session}")]
        if len(session_keys) > 3:
            # Remove oldest entries
            oldest_keys = sorted(session_keys)[:-3]
            for key in oldest_keys:
                redis_client.delete(key)

# Periodic task scheduling
from celery.schedules import crontab

celery_app.conf.beat_schedule = {
    'cleanup-expired-data': {
        'task': 'api.background.job_processor.cleanup_expired_data',
        'schedule': crontab(minute=0, hour='*/6'),  # Every 6 hours
    },
}
```

### API Endpoint Updates for Background Processing

**Updated File Upload Endpoint:**
```python
# api/endpoints/files.py  
from fastapi import BackgroundTasks, HTTPException, status
from api.background.job_processor import process_projection_file

@app.post("/api/files/upload")
async def upload_projection_file(
    draft_session_id: UUID = Form(...),
    file: UploadFile = File(...),
    source_name: str = Form(...),
    source_type: str = Form(...),
    background_tasks: BackgroundTasks = BackgroundTasks()
) -> Dict[str, Any]:
    """Upload file and queue for background processing."""
    
    # Quick validation and size checks
    if file.size > 50 * 1024 * 1024:  # 50MB limit
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="File too large. Maximum size is 50MB"
        )
    
    # Check user quota
    user_id = get_current_user_id()  # From auth context
    quota_check = await check_user_upload_quota(user_id)
    if not quota_check['allowed']:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=quota_check['reason']
        )
    
    # Generate unique file ID and store temporarily
    file_id = str(uuid.uuid4())
    file_content = await file.read()
    
    # Store file temporarily in Redis/S3 for background processing
    await store_temp_file(file_id, file_content, {
        'filename': file.filename,
        'content_type': file.content_type,
        'size': len(file_content),
        'uploaded_by': user_id,
        'uploaded_at': datetime.utcnow().isoformat()
    })
    
    # Queue background processing task
    task = process_projection_file.apply_async(
        args=[file_id, user_id, str(draft_session_id)],
        queue='file_processing',
        priority=8  # High priority for user uploads
    )
    
    # Return immediately with job tracking information
    return {
        'job_id': task.id,
        'file_id': file_id,
        'status': 'queued',
        'message': 'File uploaded successfully, processing started',
        'estimated_completion_seconds': 15,
        'status_check_url': f'/api/jobs/{task.id}/status'
    }

@app.get("/api/jobs/{job_id}/status")
async def get_job_status(job_id: str) -> Dict[str, Any]:
    """Get real-time job processing status."""
    
    # Check Redis for job status
    redis_client = redis.Redis(decode_responses=True)
    job_data = redis_client.get(f"job:{job_id}")
    
    if not job_data:
        # Check if job exists in Celery backend
        try:
            from celery.result import AsyncResult
            result = AsyncResult(job_id, app=celery_app)
            
            if result.state == 'PENDING':
                return {
                    'job_id': job_id,
                    'status': 'queued',
                    'message': 'Job is queued for processing'
                }
            elif result.state == 'STARTED':
                return {
                    'job_id': job_id,
                    'status': 'processing',
                    'message': 'Job is currently processing'
                }
            else:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Job not found"
                )
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Job not found"
            )
    
    try:
        job_info = json.loads(job_data)
        
        # Add helpful UI information
        if job_info['status'] == 'processing':
            job_info['can_cancel'] = True
            job_info['refresh_interval_ms'] = 2000  # Check every 2 seconds
        elif job_info['status'] in ['completed', 'failed']:
            job_info['can_cancel'] = False
            job_info['refresh_interval_ms'] = None  # Stop polling
        
        return job_info
        
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Invalid job status data"
        )

@app.delete("/api/jobs/{job_id}/cancel")
async def cancel_job(job_id: str) -> Dict[str, str]:
    """Cancel a background job if possible."""
    
    try:
        from celery.result import AsyncResult
        result = AsyncResult(job_id, app=celery_app)
        
        if result.state in ['PENDING', 'STARTED']:
            result.revoke(terminate=True)
            
            # Update status in Redis
            redis_client = redis.Redis(decode_responses=True)
            cancel_status = {
                'status': 'cancelled',
                'message': 'Job cancelled by user request',
                'cancelled_at': datetime.utcnow().isoformat()
            }
            redis_client.setex(f"job:{job_id}", 3600, json.dumps(cancel_status))
            
            return {
                'job_id': job_id,
                'status': 'cancelled',
                'message': 'Job cancelled successfully'
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot cancel job in state: {result.state}"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to cancel job: {str(e)}"
        )

@app.get("/api/rankings/{draft_session_id}/status")
async def get_rankings_status(draft_session_id: UUID) -> Dict[str, Any]:
    """Get current status of rankings for a draft session."""
    
    redis_client = redis.Redis(decode_responses=True)
    
    # Check if rankings are currently being calculated
    calc_job_key = f"job:ranking_calc_{draft_session_id}"
    calc_status = redis_client.get(calc_job_key)
    
    # Check if rankings are cached and fresh
    rankings_key = f"rankings:{draft_session_id}"
    rankings_exist = redis_client.exists(rankings_key)
    rankings_ttl = redis_client.ttl(rankings_key) if rankings_exist else 0
    
    status_info = {
        'draft_session_id': str(draft_session_id),
        'rankings_available': rankings_exist,
        'rankings_fresh': rankings_ttl > 300,  # Fresh if more than 5 minutes left
        'cache_ttl_seconds': rankings_ttl,
        'calculation_in_progress': calc_status is not None,
    }
    
    if calc_status:
        try:
            calc_info = json.loads(calc_status)
            status_info.update({
                'calculation_status': calc_info.get('status'),
                'calculation_message': calc_info.get('message'),
                'estimated_completion_seconds': 30 - ((datetime.utcnow() - datetime.fromisoformat(calc_info.get('updated_at', datetime.utcnow().isoformat()))).total_seconds())
            })
        except (json.JSONDecodeError, ValueError):
            status_info['calculation_status'] = 'unknown'
    
    return status_info
```

### Load Testing and Performance Benchmarks

**Performance Testing Strategy:**
```python
# tests/performance/load_testing.py
import asyncio
import aiohttp
import time
from typing import List, Dict, Any
import statistics
from concurrent.futures import ThreadPoolExecutor

class PerformanceTestSuite:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.results: List[Dict[str, Any]] = []
    
    async def test_concurrent_file_uploads(self, num_concurrent: int = 10, file_size_mb: int = 5):
        """Test concurrent file upload performance."""
        print(f"Testing {num_concurrent} concurrent file uploads ({file_size_mb}MB each)")
        
        # Create test file data
        test_data = b'x' * (file_size_mb * 1024 * 1024)
        
        async with aiohttp.ClientSession() as session:
            tasks = []
            start_time = time.time()
            
            for i in range(num_concurrent):
                task = self._upload_test_file(session, f"test_file_{i}.xlsx", test_data)
                tasks.append(task)
            
            results = await asyncio.gather(*tasks, return_exceptions=True)
            end_time = time.time()
            
            # Analyze results
            successful_uploads = [r for r in results if not isinstance(r, Exception)]
            failed_uploads = [r for r in results if isinstance(r, Exception)]
            
            performance_metrics = {
                'test_type': 'concurrent_file_uploads',
                'concurrent_users': num_concurrent,
                'file_size_mb': file_size_mb,
                'total_duration_seconds': end_time - start_time,
                'successful_uploads': len(successful_uploads),
                'failed_uploads': len(failed_uploads),
                'success_rate': len(successful_uploads) / num_concurrent,
                'throughput_uploads_per_second': len(successful_uploads) / (end_time - start_time),
                'avg_response_time_ms': statistics.mean([r['response_time_ms'] for r in successful_uploads if 'response_time_ms' in r])
            }
            
            self.results.append(performance_metrics)
            return performance_metrics
    
    # Performance benchmarks and thresholds
    PERFORMANCE_BENCHMARKS = {
        'file_upload': {
            'max_response_time_ms': 2000,  # 2 seconds for upload acknowledgment
            'max_processing_time_ms': 15000,  # 15 seconds for background processing
            'min_success_rate': 0.95,  # 95% success rate
            'max_concurrent_uploads': 20  # Support 20 concurrent uploads
        },
        'ranking_calculation': {
            'max_calculation_time_ms': 10000,  # 10 seconds max
            'max_cache_miss_penalty_ms': 2000,  # 2 second penalty for cache miss
            'min_success_rate': 0.98,  # 98% success rate
        },
        'api_response': {
            'max_avg_response_time_ms': 500,  # 500ms average
            'max_p95_response_time_ms': 1000,  # 1 second 95th percentile
            'max_p99_response_time_ms': 2000,  # 2 seconds 99th percentile
            'min_sustained_rps': 100,  # Handle 100 RPS sustained
            'max_error_rate': 0.01  # 1% error rate maximum
        }
    }
```

### Advanced Caching Strategies

**Comprehensive Multi-Level Caching System with Performance Optimization:**
```python
# api/caching/cache_manager.py
import redis
import json
import hashlib
from typing import Any, Optional, Dict, List
from datetime import datetime, timedelta
import asyncio

class CacheManager:
    def __init__(self):
        # Redis connections for different cache types
        self.redis_general = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)
        self.redis_rankings = redis.Redis(host='localhost', port=6379, db=1, decode_responses=True) 
        self.redis_sessions = redis.Redis(host='localhost', port=6379, db=2, decode_responses=True)
        
        # Cache TTL configurations
        self.cache_ttls = {
            'player_rankings': 3600,        # 1 hour
            'consensus_rankings': 1800,      # 30 minutes  
            'nhl_player_data': 86400,       # 24 hours (static data)
            'user_preferences': 3600,        # 1 hour
            'draft_session': 7200,          # 2 hours
            'file_processing_status': 3600,  # 1 hour
            'api_responses': 300,           # 5 minutes
        }
    
    async def get_cached_rankings(self, draft_session_id: str, source_weights: Dict[str, float]) -> Optional[Dict]:
        """Get cached rankings with source weight consideration."""
        
        # Create cache key based on session + weight signature
        weight_hash = self._hash_source_weights(source_weights)
        cache_key = f"consensus:{draft_session_id}:{weight_hash}"
        
        cached_data = self.redis_rankings.get(cache_key)
        if cached_data:
            return json.loads(cached_data)
        
        return None
    
    async def cache_rankings(self, draft_session_id: str, source_weights: Dict[str, float], 
                           rankings_data: Dict, ttl: int = None):
        """Cache rankings with intelligent invalidation."""
        
        weight_hash = self._hash_source_weights(source_weights)
        cache_key = f"consensus:{draft_session_id}:{weight_hash}"
        
        ttl = ttl or self.cache_ttls['consensus_rankings']
        
        # Store main cache entry
        cache_entry = {
            'data': rankings_data,
            'cached_at': datetime.utcnow().isoformat(),
            'weight_signature': weight_hash,
            'player_count': len(rankings_data.get('players', []))
        }
        
        self.redis_rankings.setex(cache_key, ttl, json.dumps(cache_entry))
        
        # Maintain cache metadata for invalidation
        self._update_cache_metadata(draft_session_id, cache_key, weight_hash)
    
    async def invalidate_rankings_cache(self, draft_session_id: str):
        """Invalidate all ranking caches for a draft session."""
        
        pattern = f"consensus:{draft_session_id}:*"
        for key in self.redis_rankings.scan_iter(match=pattern):
            self.redis_rankings.delete(key)
        
        # Clear metadata
        self.redis_rankings.delete(f"cache_meta:{draft_session_id}")
    
    async def get_api_response_cache(self, endpoint: str, params: Dict) -> Optional[Any]:
        """Cache API responses with parameter-based keys."""
        
        cache_key = self._build_api_cache_key(endpoint, params)
        cached_response = self.redis_general.get(cache_key)
        
        if cached_response:
            cache_data = json.loads(cached_response)
            
            # Check if cache is still fresh
            cached_at = datetime.fromisoformat(cache_data['cached_at'])
            if datetime.utcnow() - cached_at < timedelta(seconds=self.cache_ttls['api_responses']):
                return cache_data['response']
        
        return None
    
    async def cache_api_response(self, endpoint: str, params: Dict, response: Any, ttl: int = None):
        """Cache API response with metadata."""
        
        cache_key = self._build_api_cache_key(endpoint, params)
        ttl = ttl or self.cache_ttls['api_responses']
        
        cache_data = {
            'response': response,
            'cached_at': datetime.utcnow().isoformat(),
            'endpoint': endpoint,
            'params_hash': self._hash_dict(params)
        }
        
        self.redis_general.setex(cache_key, ttl, json.dumps(cache_data))
    
    # Warming strategies
    async def warm_popular_caches(self):
        """Pre-warm caches for popular/predictable requests."""
        
        # Common league/season combinations
        popular_combinations = [
            ('kkupfl', '2024-2025'),
            ('pa', '2024-2025'),
        ]
        
        for league, season in popular_combinations:
            # Pre-calculate with default weights
            default_weights = {'Dom': 1.2, 'Laidlaw': 1.0, 'Blake': 0.8}
            
            # This would trigger background calculation if not cached
            await self._ensure_rankings_cached(league, season, default_weights)
    
    # Cache performance monitoring
    def get_cache_stats(self) -> Dict[str, Any]:
        """Get cache performance statistics."""
        
        stats = {}
        for db_name, redis_client in [
            ('general', self.redis_general),
            ('rankings', self.redis_rankings),
            ('sessions', self.redis_sessions)
        ]:
            info = redis_client.info('stats')
            stats[db_name] = {
                'keyspace_hits': info.get('keyspace_hits', 0),
                'keyspace_misses': info.get('keyspace_misses', 0),
                'used_memory_human': info.get('used_memory_human', '0B'),
                'connected_clients': info.get('connected_clients', 0),
            }
            
            # Calculate hit rate
            hits = stats[db_name]['keyspace_hits']
            misses = stats[db_name]['keyspace_misses']
            total = hits + misses
            stats[db_name]['hit_rate'] = hits / total if total > 0 else 0
        
        return stats
    
    def _hash_source_weights(self, weights: Dict[str, float]) -> str:
        """Create consistent hash for source weights."""
        # Sort keys for consistent hashing
        sorted_weights = sorted(weights.items())
        weight_string = json.dumps(sorted_weights, sort_keys=True)
        return hashlib.md5(weight_string.encode()).hexdigest()[:8]
    
    def _hash_dict(self, data: Dict) -> str:
        """Create hash for dictionary parameters."""
        data_string = json.dumps(data, sort_keys=True, default=str)
        return hashlib.md5(data_string.encode()).hexdigest()[:8]
    
    def _build_api_cache_key(self, endpoint: str, params: Dict) -> str:
        """Build consistent cache key for API responses."""
        params_hash = self._hash_dict(params)
        return f"api:{endpoint.replace('/', '_')}:{params_hash}"
    
    def _update_cache_metadata(self, draft_session_id: str, cache_key: str, weight_hash: str):
        """Update cache metadata for tracking and invalidation."""
        metadata_key = f"cache_meta:{draft_session_id}"
        
        metadata = {
            'keys': [cache_key],
            'last_updated': datetime.utcnow().isoformat(),
            'weight_signatures': [weight_hash]
        }
        
        # Merge with existing metadata if present
        existing = self.redis_rankings.get(metadata_key)
        if existing:
            existing_meta = json.loads(existing)
            metadata['keys'].extend(existing_meta.get('keys', []))
            metadata['weight_signatures'].extend(existing_meta.get('weight_signatures', []))
            
            # Remove duplicates
            metadata['keys'] = list(set(metadata['keys']))
            metadata['weight_signatures'] = list(set(metadata['weight_signatures']))
        
        self.redis_rankings.setex(metadata_key, 7200, json.dumps(metadata))  # 2 hour TTL
```

### Performance Monitoring and Optimization

**Application Performance Monitoring:**
```python
# api/monitoring/performance_monitor.py
import time
import psutil
from typing import Dict, Any, List
from datetime import datetime, timedelta
import asyncio
from contextlib import asynccontextmanager

class PerformanceMonitor:
    def __init__(self):
        self.metrics_buffer: List[Dict] = []
        self.buffer_size = 1000
        self.flush_interval = 60  # seconds
        
        # Performance thresholds
        self.thresholds = {
            'api_response_time': 500,        # ms
            'database_query_time': 100,      # ms
            'file_processing_time': 10000,   # ms (10 seconds)
            'memory_usage_percent': 80,      # %
            'cpu_usage_percent': 70,         # %
        }
    
    @asynccontextmanager
    async def monitor_operation(self, operation_name: str, context: Dict = None):
        """Context manager for monitoring operation performance."""
        start_time = time.time()
        start_memory = psutil.virtual_memory().percent
        start_cpu = psutil.cpu_percent()
        
        operation_context = context or {}
        
        try:
            yield
            
        finally:
            end_time = time.time()
            duration_ms = (end_time - start_time) * 1000
            end_memory = psutil.virtual_memory().percent
            end_cpu = psutil.cpu_percent()
            
            metric = {
                'operation': operation_name,
                'duration_ms': duration_ms,
                'memory_start': start_memory,
                'memory_end': end_memory,
                'cpu_start': start_cpu,
                'cpu_end': end_cpu,
                'timestamp': datetime.utcnow().isoformat(),
                'context': operation_context,
                'is_slow': duration_ms > self.thresholds.get(f"{operation_name}_time", 1000)
            }
            
            self.record_metric(metric)
    
    async def monitor_database_query(self, query: str, duration_ms: float, result_count: int = 0):
        """Monitor database query performance."""
        metric = {
            'operation': 'database_query',
            'query': query[:100] + '...' if len(query) > 100 else query,
            'duration_ms': duration_ms,
            'result_count': result_count,
            'timestamp': datetime.utcnow().isoformat(),
            'is_slow': duration_ms > self.thresholds['database_query_time']
        }
        
        self.record_metric(metric)
    
    async def monitor_cache_performance(self, operation: str, cache_type: str, hit: bool, key: str = None):
        """Monitor cache hit/miss performance."""
        metric = {
            'operation': 'cache_operation',
            'cache_type': cache_type,
            'cache_operation': operation,
            'cache_hit': hit,
            'cache_key': key[:50] + '...' if key and len(key) > 50 else key,
            'timestamp': datetime.utcnow().isoformat(),
        }
        
        self.record_metric(metric)
    
    def record_metric(self, metric: Dict[str, Any]):
        """Record a performance metric."""
        self.metrics_buffer.append(metric)
        
        # Flush buffer if it's getting full
        if len(self.metrics_buffer) >= self.buffer_size:
            asyncio.create_task(self.flush_metrics())
    
    async def flush_metrics(self):
        """Flush metrics buffer to storage/monitoring system."""
        if not self.metrics_buffer:
            return
        
        # In production, send to monitoring service (DataDog, New Relic, etc.)
        metrics_to_flush = self.metrics_buffer.copy()
        self.metrics_buffer.clear()
        
        # For now, log slow operations
        slow_operations = [m for m in metrics_to_flush if m.get('is_slow')]
        for metric in slow_operations:
            print(f"SLOW OPERATION: {metric['operation']} took {metric.get('duration_ms', 0)}ms")
    
    def get_performance_summary(self, hours: int = 24) -> Dict[str, Any]:
        """Get performance summary for the last N hours."""
        cutoff_time = datetime.utcnow() - timedelta(hours=hours)
        
        # In production, query from monitoring database
        # For now, return system stats
        return {
            'system_stats': {
                'cpu_percent': psutil.cpu_percent(interval=1),
                'memory_percent': psutil.virtual_memory().percent,
                'disk_percent': psutil.disk_usage('/').percent,
            },
            'cache_stats': self._get_cache_performance_summary(),
            'slow_operations_count': len([m for m in self.metrics_buffer if m.get('is_slow')]),
            'total_operations': len(self.metrics_buffer)
        }
    
    def _get_cache_performance_summary(self) -> Dict[str, Any]:
        """Get cache performance summary."""
        cache_metrics = [m for m in self.metrics_buffer if m.get('operation') == 'cache_operation']
        
        if not cache_metrics:
            return {'hit_rate': 0, 'total_operations': 0}
        
        hits = len([m for m in cache_metrics if m.get('cache_hit')])
        total = len(cache_metrics)
        
        return {
            'hit_rate': hits / total if total > 0 else 0,
            'total_operations': total,
            'hits': hits,
            'misses': total - hits
        }

# Global performance monitor instance
perf_monitor = PerformanceMonitor()

# Middleware to monitor API requests
from fastapi import Request
import time

@app.middleware("http")
async def performance_middleware(request: Request, call_next):
    start_time = time.time()
    
    async with perf_monitor.monitor_operation("api_request", {
        'method': request.method,
        'path': request.url.path,
        'query_params': str(request.query_params)
    }):
        response = await call_next(request)
    
    # Add performance headers
    process_time = (time.time() - start_time) * 1000
    response.headers["X-Process-Time"] = f"{process_time:.2f}ms"
    
    return response
```

### Database Query Optimization

**Optimized Database Access Patterns:**
```python
# api/database/optimized_queries.py
import asyncpg
from typing import List, Dict, Optional
import asyncio
from contextlib import asynccontextmanager

class OptimizedDatabaseManager:
    def __init__(self):
        self.connection_pool = None
        self.read_replica_pool = None
        self.prepared_statements = {}
        
    async def initialize_pools(self):
        """Initialize connection pools for primary and read replica."""
        
        # Primary database (writes + critical reads)
        self.connection_pool = await asyncpg.create_pool(
            host='localhost',
            port=5432,
            database='fantasy_draft',
            user='app_user',
            password='password',
            min_size=5,
            max_size=20,
            command_timeout=30
        )
        
        # Read replica (read-heavy operations)
        self.read_replica_pool = await asyncpg.create_pool(
            host='localhost-replica',  # Read replica host
            port=5432,
            database='fantasy_draft',
            user='app_user',
            password='password',
            min_size=10,
            max_size=30,
            command_timeout=30
        )
        
        await self._prepare_common_statements()
    
    async def _prepare_common_statements(self):
        """Prepare frequently used statements for better performance."""
        
        # Use read replica for prepared statements (they're read-only)
        async with self.read_replica_pool.acquire() as conn:
            # Player search with ranking data
            self.prepared_statements['player_search'] = await conn.prepare("""
                SELECT p.id, p.name, p.position, p.team,
                       pr.consensus_rank, pr.consensus_value_score,
                       pr.source_ranks
                FROM nhl_players p
                LEFT JOIN player_rankings pr ON p.id = pr.player_id 
                WHERE pr.draft_session_id = $1
                  AND ($2 IS NULL OR p.position = ANY($2::text[]))
                  AND ($3 IS NULL OR p.name ILIKE $3)
                ORDER BY pr.consensus_rank ASC NULLS LAST
                LIMIT $4 OFFSET $5
            """)
            
            # Draft session with player counts
            self.prepared_statements['draft_session_summary'] = await conn.prepare("""
                SELECT ds.*, 
                       COUNT(pr.player_id) as total_players,
                       COUNT(dp.player_id) as drafted_players
                FROM draft_sessions ds
                LEFT JOIN player_rankings pr ON ds.id = pr.draft_session_id
                LEFT JOIN draft_picks dp ON ds.id = dp.draft_session_id
                WHERE ds.id = $1
                GROUP BY ds.id
            """)
            
            # Consensus ranking calculation
            self.prepared_statements['source_data_for_consensus'] = await conn.prepare("""
                SELECT ps.source_name, ps.weight, ps.player_data
                FROM projection_sources ps
                WHERE ps.draft_session_id = $1 
                  AND ps.processing_status = 'completed'
                ORDER BY ps.created_at ASC
            """)
    
    @asynccontextmanager
    async def get_connection(self, read_only: bool = False):
        """Get database connection from appropriate pool."""
        pool = self.read_replica_pool if read_only else self.connection_pool
        
        async with pool.acquire() as conn:
            # Enable query monitoring
            async with perf_monitor.monitor_operation("database_connection"):
                yield conn
    
    async def get_optimized_player_rankings(
        self, 
        draft_session_id: str, 
        positions: Optional[List[str]] = None,
        search_term: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> List[Dict]:
        """Get player rankings with optimized query."""
        
        async with self.get_connection(read_only=True) as conn:
            start_time = time.time()
            
            # Use prepared statement
            stmt = self.prepared_statements['player_search']
            
            # Convert search term to ILIKE pattern
            search_pattern = f"%{search_term}%" if search_term else None
            
            rows = await stmt.fetch(
                draft_session_id, 
                positions, 
                search_pattern, 
                limit, 
                offset
            )
            
            duration_ms = (time.time() - start_time) * 1000
            await perf_monitor.monitor_database_query(
                "get_player_rankings", 
                duration_ms, 
                len(rows)
            )
            
            # Convert to dictionaries
            return [dict(row) for row in rows]
    
    async def batch_insert_player_data(self, draft_session_id: str, players_data: List[Dict]):
        """Efficiently insert large batches of player data."""
        
        async with self.get_connection(read_only=False) as conn:
            # Use COPY for bulk inserts (much faster than individual INSERTs)
            
            # Prepare data for COPY
            copy_data = []
            for player in players_data:
                copy_data.append([
                    player['id'],
                    player['name'],
                    player['position'],
                    player['team'],
                    draft_session_id,
                    player.get('rank'),
                    player.get('consensus_score'),
                    json.dumps(player.get('source_ranks', {}))
                ])
            
            # Use COPY for efficient bulk insert
            await conn.copy_records_to_table(
                'player_rankings',
                records=copy_data,
                columns=['player_id', 'name', 'position', 'team', 
                        'draft_session_id', 'consensus_rank', 'consensus_value_score', 'source_ranks'],
                timeout=30
            )
    
    async def get_draft_session_analytics(self, draft_session_id: str) -> Dict:
        """Get comprehensive draft session analytics efficiently."""
        
        # Use read replica for analytics queries
        async with self.get_connection(read_only=True) as conn:
            
            # Execute multiple queries concurrently
            tasks = [
                self._get_session_summary(conn, draft_session_id),
                self._get_position_breakdown(conn, draft_session_id),
                self._get_source_contributions(conn, draft_session_id),
                self._get_draft_progress(conn, draft_session_id)
            ]
            
            results = await asyncio.gather(*tasks)
            
            return {
                'summary': results[0],
                'position_breakdown': results[1],
                'source_contributions': results[2], 
                'draft_progress': results[3]
            }
    
    async def _get_session_summary(self, conn, draft_session_id: str) -> Dict:
        """Get session summary using prepared statement."""
        stmt = self.prepared_statements['draft_session_summary']
        row = await stmt.fetchrow(draft_session_id)
        return dict(row) if row else {}
    
    async def _get_position_breakdown(self, conn, draft_session_id: str) -> List[Dict]:
        """Get position breakdown for the session."""
        rows = await conn.fetch("""
            SELECT position, 
                   COUNT(*) as total_players,
                   COUNT(*) FILTER (WHERE dp.player_id IS NOT NULL) as drafted_count,
                   AVG(consensus_value_score) as avg_score
            FROM player_rankings pr
            LEFT JOIN draft_picks dp ON pr.player_id = dp.player_id AND pr.draft_session_id = dp.draft_session_id
            WHERE pr.draft_session_id = $1
            GROUP BY position
            ORDER BY total_players DESC
        """, draft_session_id)
        
        return [dict(row) for row in rows]
```

This comprehensive performance scaling architecture provides background job processing, advanced caching strategies, performance monitoring, and database optimization to handle high-traffic fantasy draft scenarios efficiently.

## CLI to Web Migration Strategy

### Current CLI Commands → Web Endpoints Mapping

The existing CLI functionality will be fully preserved while adding web access. Here's how CLI commands map to web endpoints:

| **CLI Command** | **Web Endpoint** | **Description** |
|-----------------|------------------|-----------------|
| `python cli.py kkupfl 2024-2025` | `GET /api/rankings?league=kkupfl&season=2024-2025` | Base rankings for league/season |
| `--position SKT` | `GET /api/rankings?positions=SKT` | Filter by position (goalkeeper) |
| `--limit 10` | `GET /api/rankings?limit=10` | Limit results count |
| `--average` | `GET /api/rankings?average=true` | Enable cross-source averaging |
| `--include "Connor.*McDavid"` | `GET /api/rankings?include=Connor.*McDavid` | Include regex pattern |
| `--exclude "injured_players"` | `GET /api/rankings?exclude=injured_players` | Exclude regex pattern |

### Migration Implementation Plan

**Phase 1: Dual Interface Support**
```python
# Enhanced controller supports both CLI and web
class ProjectionsController:
    def get_rankings(self, request: RankingsRequest) -> RankingsResponse:
        # Same business logic used by CLI and web
        # request can be from argparse (CLI) or FastAPI (web)
        pass

# CLI continues to work unchanged
if __name__ == "__main__":
    args = parse_cli_args()
    request = RankingsRequest.from_cli_args(args)
    controller = ProjectionsController()
    response = controller.get_rankings(request)
    print_cli_results(response)

# Web API uses same controller
@app.get("/api/rankings")  
async def get_rankings(
    league: str,
    season: str,
    positions: Optional[str] = None,
    limit: Optional[int] = None,
    average: bool = False,
    include: Optional[str] = None,
    exclude: Optional[str] = None
) -> RankingsResponse:
    request = RankingsRequest(
        league=league, season=season, positions=positions,
        limit=limit, average=average, include=include, exclude=exclude
    )
    controller = ProjectionsController()
    return controller.get_rankings(request)
```

**Phase 2: Enhanced Web Features**
- File upload endpoints: `POST /api/files/upload`
- Draft session management: `POST /api/drafts`, `GET /api/drafts/{id}`
- Player status updates: `PATCH /api/drafts/{id}/players/{player_id}`

### User Migration Path

**Existing CLI Users:**
1. **No disruption**: CLI continues working exactly as before
2. **Gradual adoption**: Users can try web interface while keeping CLI workflow
3. **Data consistency**: Same data sources and business logic ensure identical results

**CLI Power Users Benefits:**
- Web interface for visual draft boards and real-time collaboration
- File upload instead of manual file placement
- Cross-device access (mobile during drafts)
- Saved preferences and draft session persistence

**Migration Timeline:**
- **Week 1-2**: API endpoints match all CLI functionality
- **Week 3-4**: Web interface provides equivalent user experience
- **Week 5-8**: Enhanced web-only features (file upload, draft management)
- **Ongoing**: CLI and web interfaces maintained in parallel

## Real-Time Updates Strategy

**Polling-Based Approach**: The application uses HTTP polling instead of WebSockets for "real-time" updates.

**Rationale**:
- Fantasy draft timing (60-90 second pick timers) makes 5-10 second polling delays negligible
- Simpler to implement, debug, and maintain than WebSocket connections
- More reliable across different network conditions and proxies
- Cost-effective - no connection management overhead
- Easier to scale horizontally without sticky sessions

**Implementation**:
```javascript
// Frontend polling during active drafts
const pollDraftUpdates = async (draftId, lastUpdate) => {
  const response = await fetch(`/api/drafts/${draftId}/updates?since=${lastUpdate}`);
  return response.json();
};

// Automatic polling every 7-10 seconds when draft is active
setInterval(() => {
  if (isDraftActive) {
    pollDraftUpdates(draftId, lastUpdateTimestamp)
      .then(updates => {
        if (updates.hasChanges) {
          updateDraftState(updates);
        }
      });
  }
}, 7000);
```

**Benefits**:
- Simple HTTP requests - easy to cache and debug
- Works reliably across all network environments
- Automatic retry logic with standard HTTP libraries
- No connection state to manage
- Natural rate limiting (polling frequency controls load)

## Technology Stack Summary

### Frontend (Next.js 14 + React)
- **Framework**: Next.js 14 with App Router
- **UI Library**: React 18 with TypeScript
- **Styling**: Tailwind CSS with responsive design and accessibility utilities
- **Draft Status**: Click-based drafted icons for player status management
- **State Management**: Zustand for client state, React Query for server state
- **UI Components**: shadcn/ui for consistent design system
- **PWA**: Service workers for offline functionality
- **Accessibility**: 
  - WCAG 2.1 AA compliance with axe-core integration
  - React ARIA for accessible component patterns
  - Focus management with focus-trap-react
  - Screen reader optimization with proper ARIA implementation

### Backend (Python FastAPI)
- **API Framework**: FastAPI with automatic OpenAPI documentation
- **Business Logic**: Existing Python codebase (Controller → Service → DAO layers)
- **Data Validation**: Pydantic models for request/response validation
- **Authentication**: JWT-based sessions with Redis storage
- **File Processing**: pandas + openpyxl for Excel file handling
- **External APIs**: NHL API integration for schedule data

### Infrastructure & Deployment
- **Frontend Hosting**: Vercel (optimized for Next.js)
- **Backend Hosting**: Railway or Render (Python-friendly)
- **Databases**: PostgreSQL (Supabase/Neon), Redis Cloud
- **File Storage**: Cloud storage for uploaded projection files
- **CDN**: Automatic via Vercel for static assets and API caching
- **Monitoring**: Application monitoring and error tracking

## Accessibility Architecture

The application implements comprehensive accessibility features following WCAG 2.1 AA guidelines:

### Accessibility Technology Stack
```typescript
// Core accessibility dependencies
{
  "@axe-core/react": "^4.8.0",           // Automated accessibility testing
  "eslint-plugin-jsx-a11y": "^6.8.0",   // Accessibility linting
  "react-aria": "^3.32.0",              // Accessible component primitives
  "focus-trap-react": "^10.2.0",        // Focus management for modals
  "@reach/skip-nav": "^0.18.0"          // Skip navigation links
}
```

### Component-Level Accessibility Implementation

#### Accessible Data Tables
```typescript
// components/accessible-table.tsx
export function AccessibleTable({ data, columns, sortConfig, onSort }) {
  return (
    <table 
      role="table" 
      aria-label="Player rankings and statistics"
      aria-rowcount={data.length + 1}
    >
      <thead>
        <tr role="row" aria-rowindex={1}>
          {columns.map((column, index) => (
            <th
              key={column.key}
              scope="col"
              tabIndex={0}
              role="columnheader"
              aria-sort={getSortDirection(column.key, sortConfig)}
              onClick={() => onSort(column.key)}
              onKeyDown={(e) => handleKeySort(e, column.key)}
              className="focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {column.label}
              <SortIcon sortDirection={getSortDirection(column.key, sortConfig)} />
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((row, rowIndex) => (
          <tr key={row.id} role="row" aria-rowindex={rowIndex + 2}>
            {columns.map((column) => (
              <td key={`${row.id}-${column.key}`} role="cell">
                {formatCellContent(row[column.key], column.type)}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

#### Draft Status Controls with Accessibility
```typescript
// components/draft-status-button.tsx
export function DraftStatusButton({ player, onStatusChange }) {
  const [isDrafted, setIsDrafted] = useState(player.isDrafted);
  
  return (
    <button
      type="button"
      role="button"
      aria-label={`${isDrafted ? 'Mark as available' : 'Mark as drafted'}: ${player.name}`}
      aria-pressed={isDrafted}
      className="draft-status-btn focus:outline-none focus:ring-2 focus:ring-blue-500"
      onClick={handleClick}
      onKeyDown={handleKeyDown}
    >
      <span aria-hidden="true">
        {isDrafted ? <CheckedIcon /> : <UncheckedIcon />}
      </span>
      <span className="sr-only">
        {player.name} - {isDrafted ? 'Drafted' : 'Available'}
      </span>
    </button>
  );
  
  function handleClick() {
    const newStatus = !isDrafted;
    setIsDrafted(newStatus);
    onStatusChange(player.id, newStatus);
    
    // Announce status change to screen readers
    announceToScreenReader(
      `${player.name} marked as ${newStatus ? 'drafted' : 'available'}`
    );
  }
}
```

#### Interactive Weight Controls
```typescript
// components/weight-slider.tsx
export function WeightSlider({ source, weight, onWeightChange }) {
  return (
    <div className="weight-control-group">
      <label 
        id={`weight-label-${source.id}`}
        className="block text-sm font-medium"
      >
        {source.name} Weight: {weight}%
      </label>
      
      <div className="slider-container" role="group" aria-labelledby={`weight-label-${source.id}`}>
        {/* Visual slider for mouse users */}
        <input
          type="range"
          min="0"
          max="200"
          value={weight}
          onChange={handleSliderChange}
          aria-label={`${source.name} weight percentage`}
          className="visual-slider focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        
        {/* Text input for precise control */}
        <input
          type="number"
          min="0"
          max="200"
          value={weight}
          onChange={handleInputChange}
          aria-label={`${source.name} weight percentage (precise input)`}
          className="weight-input ml-2 w-16 px-2 py-1 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      
      <div id={`weight-description-${source.id}`} className="text-xs text-gray-600 mt-1">
        Use arrow keys or input field to adjust weight. Current: {weight}%
      </div>
    </div>
  );
}
```

### Focus Management Strategy
```typescript
// lib/focus-management.ts
export class FocusManager {
  private focusStack: HTMLElement[] = [];
  
  // Trap focus within modal/dialog components
  public trapFocus(container: HTMLElement) {
    const focusableElements = container.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    // Implementation for focus trapping
    return () => this.releaseFocus();
  }
  
  // Manage focus during dynamic content updates
  public announceDynamicChange(message: string, priority: 'polite' | 'assertive' = 'polite') {
    const announcement = document.createElement('div');
    announcement.setAttribute('aria-live', priority);
    announcement.setAttribute('aria-atomic', 'true');
    announcement.className = 'sr-only';
    announcement.textContent = message;
    
    document.body.appendChild(announcement);
    setTimeout(() => document.body.removeChild(announcement), 1000);
  }
  
  // Restore focus after modal closes
  public restoreFocus() {
    const previousFocus = this.focusStack.pop();
    if (previousFocus && document.contains(previousFocus)) {
      previousFocus.focus();
    }
  }
}
```

### Screen Reader Optimization
```typescript
// lib/screen-reader.ts
export const ScreenReaderAnnouncements = {
  // Live region for status updates
  announceRankingUpdate: (playerName: string, newRank: number) => {
    announceToScreenReader(
      `${playerName} now ranked number ${newRank}`, 
      'polite'
    );
  },
  
  // Draft status changes
  announceDraftPick: (playerName: string, team: string) => {
    announceToScreenReader(
      `${playerName} drafted by ${team}`, 
      'assertive'
    );
  },
  
  // Weight adjustments
  announceWeightChange: (sourceName: string, newWeight: number) => {
    announceToScreenReader(
      `${sourceName} weight adjusted to ${newWeight} percent`, 
      'polite'
    );
  }
};

// Utility function for screen reader announcements
function announceToScreenReader(message: string, priority: 'polite' | 'assertive' = 'polite') {
  const announcement = document.createElement('div');
  announcement.setAttribute('aria-live', priority);
  announcement.setAttribute('aria-atomic', 'true');
  announcement.className = 'sr-only';
  announcement.textContent = message;
  
  document.body.appendChild(announcement);
  setTimeout(() => {
    if (document.body.contains(announcement)) {
      document.body.removeChild(announcement);
    }
  }, 1000);
}
```

### Keyboard Navigation Implementation
```typescript
// lib/keyboard-navigation.ts
export const KeyboardHandlers = {
  // Table navigation with arrow keys
  handleTableNavigation: (event: KeyboardEvent, tableElement: HTMLTableElement) => {
    const { key } = event;
    const currentCell = event.target as HTMLTableCellElement;
    
    if (!['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(key)) {
      return;
    }
    
    event.preventDefault();
    
    const cells = Array.from(tableElement.querySelectorAll('td, th'));
    const currentIndex = cells.indexOf(currentCell);
    const columnsCount = tableElement.rows[0].cells.length;
    
    let nextIndex: number;
    
    switch (key) {
      case 'ArrowUp':
        nextIndex = currentIndex - columnsCount;
        break;
      case 'ArrowDown':
        nextIndex = currentIndex + columnsCount;
        break;
      case 'ArrowLeft':
        nextIndex = currentIndex - 1;
        break;
      case 'ArrowRight':
        nextIndex = currentIndex + 1;
        break;
    }
    
    if (nextIndex >= 0 && nextIndex < cells.length) {
      (cells[nextIndex] as HTMLElement).focus();
    }
  },
  
  // Skip navigation implementation
  handleSkipNavigation: () => {
    const skipLinks = [
      { key: 'main', label: 'Skip to main content', target: '#main-content' },
      { key: 'nav', label: 'Skip to navigation', target: '#main-navigation' },
      { key: 'draft', label: 'Skip to draft board', target: '#draft-board' }
    ];
    
    return skipLinks;
  }
};
```

### Accessibility Testing Integration
```typescript
// lib/accessibility-testing.ts
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

// Component accessibility tests
export const AccessibilityTestSuite = {
  async testComponent(component: ReactElement) {
    const { container } = render(component);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  },
  
  testKeyboardNavigation: async (component: ReactElement) => {
    const { container } = render(component);
    
    // Test tab navigation
    const focusableElements = container.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    // Verify all interactive elements are reachable via keyboard
    focusableElements.forEach((element) => {
      expect(element).toBeVisible();
      expect(element.getAttribute('tabindex')).not.toBe('-1');
    });
  }
};
```

### Color and Contrast Strategy
```css
/* tailwind.config.js - Custom accessibility-focused color palette */
module.exports = {
  theme: {
    extend: {
      colors: {
        // High contrast color scheme
        'a11y': {
          'text-primary': '#1a1a1a',      // 15.3:1 contrast ratio
          'text-secondary': '#4a5568',    // 7.5:1 contrast ratio
          'bg-primary': '#ffffff',
          'bg-secondary': '#f7fafc',
          'focus-ring': '#3182ce',        // 4.5:1 minimum for focus indicators
          'success': '#065f46',           // 7.2:1 contrast for success states
          'warning': '#92400e',           // 6.1:1 contrast for warnings
          'error': '#991b1b',            // 8.9:1 contrast for errors
        }
      }
    }
  },
  plugins: [
    // Custom plugin for accessibility utilities
    function({ addUtilities }) {
      addUtilities({
        '.sr-only': {
          position: 'absolute',
          width: '1px',
          height: '1px',
          padding: '0',
          margin: '-1px',
          overflow: 'hidden',
          clip: 'rect(0, 0, 0, 0)',
          whiteSpace: 'nowrap',
          border: '0',
        },
        '.focus-visible-only': {
          '&:focus:not(:focus-visible)': {
            outline: 'none',
          },
          '&:focus-visible': {
            outline: '2px solid #3182ce',
            outlineOffset: '2px',
          },
        }
      });
    }
  ]
};
```

This accessibility architecture ensures that the Fantasy Hockey Draft Day Assistant provides an inclusive experience for all users, including those using screen readers, keyboard navigation, voice control, or other assistive technologies. The implementation follows WCAG 2.1 AA guidelines and includes comprehensive testing strategies to maintain accessibility standards throughout development.

## Analytics & Monitoring Architecture

The system implements comprehensive analytics and monitoring to ensure optimal performance, user experience, and business insight generation.

### Analytics Data Pipeline

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   External      │
│   Events        │    │    Metrics      │    │   Services      │
│                 │    │                 │    │                 │
│ • User Actions  │───►│ • API Metrics   │───►│ • DataDog APM   │
│ • Page Views    │    │ • DB Performance│    │ • Sentry Errors │
│ • Interactions  │    │ • Cache Stats   │    │ • PostHog Events│
│ • Errors        │    │ • Business KPIs │    │ • Custom Alerts │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                       │                       │
          ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Data Storage Layer                         │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   PostgreSQL    │  │   File Storage  │  │     Redis       │ │
│  │                 │  │                 │  │                 │ │
│  │ • System Metrics│  │ • User Events   │  │ • Real-time     │ │
│  │ • User Sessions │  │ • Performance   │  │   Metrics       │ │
│  │ • Error Logs    │  │ • Business KPIs │  │ • Alert State   │ │
│  │ • Performance   │  │ • Analytics     │  │ • Cache Stats   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Analytics Processing Layer                     │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Aggregation   │  │   Alert Engine  │  │   Reporting     │ │
│  │                 │  │                 │  │                 │ │
│  │ • Time-series   │  │ • Threshold     │  │ • Dashboard     │ │
│  │   Rollups       │  │   Monitoring    │  │   Generation    │ │
│  │ • Trend Analysis│  │ • Notification  │  │ • Automated     │ │
│  │ • Correlations  │  │   Management    │  │   Reports       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Visualization & Alerts                      │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Admin         │  │   Monitoring    │  │   Stakeholder   │ │
│  │   Dashboard     │  │   Dashboards    │  │   Reports       │ │
│  │                 │  │                 │  │                 │ │
│  │ • Real-time     │  │ • System Health │  │ • Business      │ │
│  │   Metrics       │  │ • Performance   │  │   Metrics       │ │
│  │ • User Behavior │  │ • Error Rates   │  │ • User Insights │ │
│  │ • System Status │  │ • Alert Status  │  │ • Growth KPIs   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Key Metrics and KPIs

#### Performance Metrics
```typescript
interface PerformanceMetrics {
  // API Performance
  apiResponseTimes: {
    p50: number;      // 50th percentile response time
    p95: number;      // 95th percentile response time
    p99: number;      // 99th percentile response time
    average: number;  // Average response time
  };
  
  // Database Performance
  databaseMetrics: {
    postgresql: {
      connectionPool: number;
      queryTime: number;
      slowQueries: number;
    };
    jsonb_operations: {
      queryTime: number;
      indexUsage: number;
      documentScans: number;
    };
    redis: {
      hitRate: number;
      memoryUsage: number;
      commandLatency: number;
    };
  };
  
  // System Resources
  systemHealth: {
    cpuUsage: number;
    memoryUsage: number;
    diskUsage: number;
    networkLatency: number;
  };
}
```

#### Business Metrics
```typescript
interface BusinessMetrics {
  // User Engagement
  userActivity: {
    dailyActiveUsers: number;
    sessionDuration: number;
    pageViewsPerSession: number;
    bounceRate: number;
  };
  
  // Draft Performance
  draftMetrics: {
    completionRate: number;        // % of started drafts completed
    avgDraftDuration: number;      // Average time to complete draft
    playersPerDraft: number;       // Average players drafted
    sourceUsageDistribution: {     // Which projection sources are used most
      [sourceName: string]: number;
    };
  };
  
  // Feature Adoption
  featureUsage: {
    fileUploads: number;
    weightAdjustments: number;
    sleepersManagement: number;
    teamAnalysis: number;
  };
  
  // Performance Impact
  userSatisfaction: {
    errorRate: number;             // % of requests resulting in errors
    loadTimePerception: number;    // Subjective load time rating
    featureDiscovery: number;      // % of users who discover key features
  };
}
```

### Alert Configuration

```python
# monitoring/alert_config.py
ALERT_THRESHOLDS = {
    "performance": {
        "api_response_time_p95": {
            "warning": 500,   # milliseconds
            "critical": 1000,
            "window": "5m"
        },
        "database_query_time": {
            "warning": 300,
            "critical": 500,
            "window": "5m"
        },
        "cache_hit_rate": {
            "warning": 0.8,   # Below 80%
            "critical": 0.6,  # Below 60%
            "window": "10m"
        }
    },
    "errors": {
        "error_rate": {
            "warning": 0.02,  # 2%
            "critical": 0.05, # 5%
            "window": "5m"
        },
        "failed_draft_sessions": {
            "warning": 5,     # 5 failed sessions
            "critical": 10,   # 10 failed sessions
            "window": "1h"
        }
    },
    "business": {
        "user_drop_off_rate": {
            "warning": 0.3,   # 30% drop-off
            "critical": 0.5,  # 50% drop-off
            "window": "1d"
        },
        "draft_completion_rate": {
            "warning": 0.7,   # Below 70%
            "critical": 0.5,  # Below 50%
            "window": "1d"
        }
    },
    "system": {
        "active_connections": {
            "warning": 80,    # 80% of pool
            "critical": 95,   # 95% of pool
            "window": "5m"
        },
        "memory_usage": {
            "warning": 0.8,   # 80%
            "critical": 0.9,  # 90%
            "window": "5m"
        }
    }
}

# Alert notification channels
NOTIFICATION_CHANNELS = {
    "slack": {
        "webhook_url": "https://hooks.slack.com/...",
        "channels": {
            "critical": "#alerts-critical",
            "warning": "#alerts-warning"
        }
    },
    "email": {
        "smtp_server": "smtp.sendgrid.net",
        "recipients": {
            "critical": ["dev-team@company.com", "on-call@company.com"],
            "warning": ["dev-team@company.com"]
        }
    },
    "pagerduty": {
        "integration_key": "...",
        "severity_mapping": {
            "critical": "critical",
            "warning": "warning"
        }
    }
}
```

### Privacy and Compliance

The analytics system implements privacy-first design principles:

```typescript
// Privacy configuration
interface PrivacySettings {
  // Data minimization
  dataRetention: {
    userEvents: "90d";        // User analytics events
    performanceMetrics: "1y"; // System performance data
    errorLogs: "6m";         // Error and debugging logs
    userSessions: "30d";     // Session tracking data
  };
  
  // Data anonymization
  anonymization: {
    ipAddresses: "hash";     // Hash IP addresses
    userAgents: "truncate";  // Remove identifying details
    personalData: "encrypt"; // Encrypt any PII
  };
  
  // User consent
  consentManagement: {
    analyticsTracking: boolean;
    performanceMonitoring: boolean;
    errorReporting: boolean;
    functionalCookies: boolean;
  };
  
  // GDPR compliance
  gdprCompliance: {
    rightToAccess: boolean;    // Users can access their data
    rightToPortability: boolean; // Users can export their data
    rightToErasure: boolean;   // Users can delete their data
    dataProcessingBasis: "legitimate_interest" | "consent";
  };
}
```

### Monitoring Integration Implementation

```python
# monitoring/integration.py
class MonitoringService:
    def __init__(self):
        self.datadog = DataDogClient()
        self.sentry = SentryClient()
        self.custom_metrics = CustomMetricsCollector()
    
    async def track_request_metrics(self, 
                                   endpoint: str, 
                                   method: str, 
                                   duration_ms: int, 
                                   status_code: int,
                                   user_id: Optional[str] = None):
        """Track API request metrics across all monitoring systems"""
        
        # DataDog APM
        self.datadog.histogram('api.request.duration', duration_ms, 
                              tags=[f'endpoint:{endpoint}', f'method:{method}', 
                                   f'status:{status_code}'])
        
        # Custom metrics for business logic
        await self.custom_metrics.record_metric(
            name="api_request_duration",
            value=duration_ms,
            tags={
                "endpoint": endpoint,
                "method": method,
                "status_code": status_code,
                "user_id": user_id
            }
        )
        
        # Performance alerts
        if duration_ms > ALERT_THRESHOLDS["performance"]["api_response_time_p95"]["critical"]:
            await self.trigger_alert(
                severity="critical",
                message=f"Slow API response: {endpoint} took {duration_ms}ms",
                context={"endpoint": endpoint, "duration": duration_ms}
            )
```

This comprehensive analytics and monitoring architecture ensures that the Fantasy Hockey Draft Day Assistant maintains optimal performance, provides valuable business insights, and delivers an excellent user experience while respecting user privacy and maintaining system reliability.

This architecture provides a solid foundation for the Fantasy Hockey Draft Day Assistant that can scale from individual users to thousands of concurrent draft sessions while maintaining excellent performance, comprehensive monitoring, and user experience for all users, regardless of their abilities or the assistive technologies they use.