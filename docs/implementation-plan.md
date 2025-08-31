# Fantasy Draft Assistant - Implementation Plan

This document outlines a step-by-step plan for building the Fantasy Hockey Draft Day Assistant using Next.js + React frontend and FastAPI backend, organized into meaningful iterations that can be tested and delivered incrementally.

## Overview

**Architecture**: Next.js 14 + React frontend consuming Python FastAPI REST endpoints  
**Backend Repository**: Current repo (`fantasy-projections-api/`)  
**Frontend Repository**: Current repo (`fantasy-projections-web/`)  
**Timeline**: 8 iterations  
**Deployment**: Vercel (frontend) + Railway/Render (backend)
**Database Strategy**: Simplified approach using PostgreSQL with JSONB (relational + flexible documents), Redis (cache)

## 📊 Progress Status

### Backend Development
- ✅ **Iteration 0**: Docker Infrastructure & Testing Foundation - **COMPLETED**
- ✅ **Iteration 1**: Database Infrastructure & API Foundation - **COMPLETED**
- ✅ **Iteration 2**: File Upload & Background Processing - **COMPLETED**
- ✅ **Iteration 3**: Dynamic Rankings & Weight Updates - **COMPLETED**
- 🔄 **Iteration 3.5**: Authentication & User Management - **PENDING**
- 🔄 **Iteration 4**: Draft Session Management - **PENDING**
- 🔄 **Iteration 5**: Advanced Draft Features - **PENDING**
- 🔄 **Iteration 6**: Analytics Dashboard & Performance Monitoring - **PENDING**
- 🔄 **Iteration 7**: Real-Time Features & Polish - **PENDING**
- 🔄 **Iteration 8**: Final Testing & Deployment - **PENDING**

### Frontend Development
- ✅ **Iteration 1**: Project Setup & Foundation - **COMPLETED** 
- 🔄 **Iteration 1.5**: Authentication & User Management - **PENDING**
- 🔄 **Iteration 2**: Core UI Components & Data Display - **PENDING**
- 🔄 **Iteration 3**: File Upload Interface - **PENDING**
- 🔄 **Iteration 4**: Draft Status Management - **PENDING**
- 🔄 **Iteration 5**: Advanced Draft Features - **PENDING**
- 🔄 **Iteration 6**: Analytics Dashboard & Performance Monitoring - **PENDING**
- 🔄 **Iteration 7**: Polish & PWA Features - **PENDING**

---

## Iteration 1: Backend API Foundation + Database Setup
*Goal: Create REST API with core endpoints and database infrastructure*

### Backend Tasks (Current Repo)
- [ ] **1. Database Infrastructure Setup**
   - **PostgreSQL Setup**: Configure primary relational database
     - Set up user accounts, draft sessions, NHL players/teams tables
     - Create database migrations for core schema
     - Add connection pooling and environment configuration
   - **PostgreSQL JSONB Setup**: Configure flexible document storage within PostgreSQL
     - Add JSONB columns for projection sources, consolidated rankings
     - Configure GIN indexes for efficient JSON querying
     - Set up proper JSONB data types and constraints
   - **Redis Setup**: Configure caching layer
     - Set up session management and caching infrastructure
     - Configure connection pooling and failover

- [ ] **2. FastAPI Setup & Dependencies**
   - Add FastAPI, uvicorn, python-multipart to requirements
   - Add database dependencies: psycopg2, redis-py
   - Create `api/main.py` with basic FastAPI app
   - Add CORS middleware for frontend development
   - Create basic health check endpoint

- [ ] **3. Core Data Models (Pydantic)**
   ```python
   # api/models.py
   class Player(BaseModel):
       id: Optional[UUID]
       name: str
       position: str
       team: str
       rank: Optional[int]
       consensus_value_score: Optional[float]
       points: Optional[float]
       goals: Optional[int]
       assists: Optional[int]
       # ... other stats

   class RankingSource(BaseModel):
       id: Optional[str]
       name: str
       source_type: str  # "rankings", "projections", "adp", "historical"
       weight: float
       value_column: str  # "rank", "points", "adp", etc.
       players: List[Player]
       file_metadata: Optional[Dict]

   class ConsolidatedRanking(BaseModel):
       draft_session_id: UUID
       sources: List[RankingSource]
       consolidated_players: List[Player]
       source_weights: Dict[str, float]
       calculation_timestamp: datetime
   
   class DraftSession(BaseModel):
       id: Optional[UUID]
       user_id: UUID
       name: str
       league: str
       season: str
       num_teams: int
       scoring_categories: Optional[Dict]
       status: str = "active"
   ```

4. **Database Access Layer (DAO)**
   ```python
   # api/database/postgres_dao.py
   class PostgresDAO:
       async def create_draft_session(self, session: DraftSession) -> UUID
       async def get_nhl_players(self, search_term: str = None) -> List[Player]
       async def get_player_by_name(self, name: str) -> Optional[Player]
   
   # api/database/postgres_dao.py (enhanced with JSONB)
   class PostgresDAO:
       async def store_projection_source(self, source: RankingSource) -> str
       async def get_consolidated_rankings(self, draft_session_id: UUID) -> ConsolidatedRanking
       async def store_consolidated_rankings(self, rankings: ConsolidatedRanking)
   
   # api/database/redis_dao.py
   class RedisDAO:
       async def cache_rankings(self, key: str, rankings: dict, ttl: int = 3600)
       async def get_cached_rankings(self, key: str) -> Optional[dict]
       async def store_session_data(self, session_id: str, data: dict)
   ```

5. **API Endpoints**
   ```python
   @app.get("/api/rankings/{league}/{season}")
   async def get_rankings(
       league: str, 
       season: str,
       draft_session_id: Optional[UUID] = None,
       positions: Optional[str] = None,
       limit: Optional[int] = None,
       include_average: bool = True
   ) -> ConsolidatedRanking
   
   @app.post("/api/draft-sessions")
   async def create_draft_session(session: DraftSession) -> Dict[str, UUID]
   
   @app.get("/api/leagues")
   async def get_leagues() -> List[str]
   
   @app.get("/api/seasons/{league}")
   async def get_seasons(league: str) -> List[str]
   
   @app.get("/api/health")
   async def health_check() -> Dict[str, str]:
       # Basic health check - verify core functionality
       return {"status": "healthy"}
   ```

6. **Controller Integration**
   - Adapt existing `ProjectionsController` to work with FastAPI and databases
   - Transform existing DataFrame outputs to Pydantic models
   - Add database persistence for processed projections
   - Ensure proper error handling and HTTP status codes

### Testing
- [ ] Test all endpoints with curl/Postman
- [ ] Verify data processing matches expected output
- [ ] Test database connections and data persistence
- [ ] Test CORS for frontend development
- [ ] Verify caching layer functionality
- [ ] Basic health endpoint testing

### Deliverable
- [ ] Working REST API with database persistence for fantasy projection data

---

## Iteration 1.5: Authentication & User Management
*Goal: Implement secure user authentication system for both frontend and backend*

### Backend Authentication Tasks
- [ ] **1. JWT Authentication System**
   - Install authentication dependencies (passlib, python-jose, python-multipart)
   - Implement JWT token creation, validation, and refresh logic
   - Create secure password hashing with bcrypt
   - Set up token-based session management with Redis

- [ ] **2. User Database Schema**
   ```sql
   CREATE TABLE users (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       email VARCHAR(255) UNIQUE NOT NULL,
       password_hash VARCHAR(255) NOT NULL,
       name VARCHAR(255),
       tier VARCHAR(50) DEFAULT 'free' CHECK (tier IN ('free', 'premium', 'admin')),
       email_verified BOOLEAN DEFAULT FALSE,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
       is_active BOOLEAN DEFAULT TRUE,
       preferences JSONB DEFAULT '{}'::jsonb
   );

   CREATE TABLE user_sessions (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       user_id UUID REFERENCES users(id) ON DELETE CASCADE,
       refresh_token_hash VARCHAR(255) NOT NULL,
       expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Update draft_sessions table to associate with users
   ALTER TABLE draft_sessions ADD COLUMN user_id UUID REFERENCES users(id) ON DELETE CASCADE;
   ```

- [ ] **3. Authentication API Endpoints**
   ```python
   POST /api/auth/register     # User registration with email/password
   POST /api/auth/login        # User login returning JWT tokens
   POST /api/auth/refresh      # Refresh access token using refresh token
   POST /api/auth/logout       # Invalidate user session
   GET  /api/auth/me          # Get current user profile
   ```

- [ ] **4. Protected API Routes**
   - Add authentication middleware to all existing endpoints
   - Implement user authorization checks for draft session access
   - Add rate limiting with stricter limits on auth endpoints
   - Update existing endpoints to associate data with authenticated users

### Frontend Authentication Tasks
- [ ] **5. Authentication Components**
   ```typescript
   // Authentication UI components
   - LoginForm: Email/password login with validation
   - RegisterForm: Account creation with password strength validation
   - AuthModal: Modal wrapper for login/register forms
   - UserMenu: User avatar, settings, logout dropdown
   - ProtectedRoute: Route guard component for authenticated pages
   ```

- [ ] **6. Authentication State Management**
   ```typescript
   // Authentication context and hooks
   - useAuth(): JWT token management with auto-refresh
   - AuthProvider: Global authentication context provider
   - API client integration with Bearer token headers
   - Persistent session management with secure token storage
   ```

- [ ] **7. Navigation & Route Protection**
   - Update header navigation with user authentication status
   - Implement Next.js middleware for route protection
   - Add user profile and account settings pages
   - Show/hide features based on user tier (free/premium)

- [ ] **8. User-Associated Data**
   - Update draft session creation to associate with authenticated user
   - Add user dashboard showing personal draft sessions
   - Implement draft session sharing (public/private visibility)
   - Add user preferences and settings management

### Security & Accessibility
- [ ] **9. Security Implementation**
   - Rate limiting: 5 registrations/hour, 10 logins/minute per IP
   - Input validation for email/password with proper error messages
   - CSRF protection and secure token storage
   - Session timeout and automatic token refresh

- [ ] **10. Authentication Accessibility**
   - Accessible form components with proper ARIA labels
   - Screen reader announcements for auth state changes
   - Keyboard navigation for modals and form elements
   - High contrast support for authentication UI

### Testing
- [ ] Test user registration and login flows end-to-end
- [ ] Verify JWT token creation, validation, and refresh mechanisms
- [ ] Test protected route access and unauthorized redirects
- [ ] Validate rate limiting and security measures
- [ ] Test accessibility with screen readers and keyboard navigation
- [ ] Verify user data association and session management

### Deliverable
- [ ] Complete authentication system enabling secure user accounts, login/logout, and user-associated data across both frontend and backend

---

## Iteration 2: Frontend Foundation & Basic Display
*Goal: Create Next.js app with basic data display from API*

### ✅ Frontend Tasks (Completed in fantasy-projections-web/)
- [x] **1. Next.js Project Setup**
   ```bash
   npx create-next-app@latest fantasy-draft-assistant --typescript --tailwind --app
   cd fantasy-draft-assistant
   npm install @tanstack/react-query axios lucide-react
   npm install -D @types/node @axe-core/react eslint-plugin-jsx-a11y
   ```

- [x] **2. Project Structure**
   ```
   src/
   ├── app/
   │   ├── layout.tsx
   │   ├── page.tsx
   │   └── dashboard/
   │       └── page.tsx
   ├── components/
   │   ├── ui/ (shadcn components)
   │   ├── projections-table.tsx
   │   └── layout/
   ├── lib/
   │   ├── api.ts
   │   ├── types.ts
   │   └── utils.ts
   └── hooks/
       └── use-projections.ts
   ```

- [x] **3. Type Definitions**
   ```typescript
   // lib/types.ts - Mirror backend Pydantic models
   export interface Player {
     name: string
     position: string
     team: string
     rank: number
     points?: number
     goals?: number
     assists?: number
   }

   export interface RankingSource {
     name: string
     weight: number
     value_column: string
     players: Player[]
   }

   export interface ConsolidatedRanking {
     sources: RankingSource[]
     consolidated_players: Player[]
   }
   ```

4. **API Client Setup**
   ```typescript
   // lib/api.ts
   const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

   export const api = {
     getRankings: (league: string, season: string, params?: any) =>
       axios.get<ConsolidatedRanking>(`${API_BASE_URL}/api/rankings/${league}/${season}`, { params })
   }
   ```

5. **Basic Data Display**
   - Create `ProjectionsTable` component with shadcn Table
   - Display consolidated rankings in sortable table
   - Show individual source tables (collapsible)
   - Add league/season selector dropdowns

6. **Accessibility Foundation**
   ```typescript
   // components/ui/table.tsx - Accessible table implementation
   // - Proper ARIA labels and roles
   // - Table headers with scope attributes
   // - Sortable column headers with ARIA sort indicators
   // - Focus management for keyboard navigation
   
   // lib/accessibility.ts - Accessibility utilities
   // - Skip link component
   // - Screen reader announcements
   // - Focus trap for modals
   // - Keyboard navigation helpers
   ```

### Testing
- Verify frontend connects to backend API
- Test data display matches backend responses  
- Test responsive design on desktop/tablet/mobile
- **Accessibility Testing**: Run axe-core automated accessibility tests
- **Keyboard Navigation**: Test all interactive elements are keyboard accessible
- **Screen Reader**: Verify table structure is announced correctly
- Focus management and keyboard navigation testing

### Deliverable
Working Next.js app displaying projection data from API

---

## Iteration 3: File Upload & Processing
*Goal: Enable file upload with rule-based processing and player name validation*

### Backend Tasks
1. **Background File Processing System (Updated)**
   ```python
   @app.post("/api/files/upload")
   async def upload_projection_file(
       draft_session_id: UUID = Form(...),
       file: UploadFile = File(...),
       source_name: str = Form(...),
       source_type: str = Form(...),  # "rankings", "projections", "adp", "historical"
       background_tasks: BackgroundTasks = BackgroundTasks()
   ):
       # UPDATED: Immediate upload acknowledgment with background processing
       file_id = str(uuid.uuid4())
       
       # Quick validation and quota check (synchronous)
       if file.size > 50 * 1024 * 1024:  # 50MB limit
           raise HTTPException(413, "File too large")
       
       # Store file temporarily and queue background processing
       task = process_projection_file.apply_async(
           args=[file_id, user_id, str(draft_session_id)],
           queue='file_processing'
       )
       
       return {
           'job_id': task.id,
           'file_id': file_id,
           'status': 'queued',
           'estimated_completion_seconds': 15
       }
   
   @app.get("/api/jobs/{job_id}/status")
   async def get_job_status(job_id: str):
       # UPDATED: Real-time job status with progress tracking
       # Returns: status, message, progress_percent, performance_metrics
   
   @app.delete("/api/jobs/{job_id}/cancel")
   async def cancel_job(job_id: str):
       # NEW: Allow users to cancel long-running file processing
   ```

2. **Enhanced Column Mapping System**
   ```python
   @app.get("/api/files/{file_id}/preview")
   async def preview_file_mapping(file_id: str):
       # UPDATED: Cached preview with intelligent column detection
       # Returns from Redis cache if available, otherwise processes async
   
   @app.post("/api/files/{file_id}/confirm-mapping")
   async def confirm_column_mapping(file_id: str, mapping: ColumnMappingRequest):
       # UPDATED: Store mappings with user learning for future uploads
       # Cache mapping patterns in Redis for instant reuse
       # Trigger background reprocessing with confirmed mappings
   ```

3. **Optimized Player Name Validation**
   - **Background Processing**: Run validation in parallel batches (100 players/batch)
   - **Caching Strategy**: Cache validation results in Redis to avoid re-processing
   - **Fuzzy Matching**: Use existing codebase logic with performance optimizations
   - **Database Optimization**: Index NHL players table for fast name lookups
   - **Batch Corrections**: Allow bulk corrections for efficiency

### Frontend Tasks
1. **File Upload Component**
   ```typescript
   // components/file-upload.tsx
   export function FileUpload() {
     // File upload with browse/select
     // Progress indicator
     // File type validation
   }
   ```

2. **Column Mapping Interface**
   - Preview uploaded data in table format
   - Dropdown selectors for column mapping
   - Save/confirm mapping functionality

3. **Player Validation Interface**
   - Show unmatched player names
   - Provide suggestions from fuzzy matching
   - Allow manual corrections

4. **Accessibility Enhancements**
   ```typescript
   // File upload accessibility
   // - Proper form labels and descriptions
   // - Error message announcements
   // - Progress indicators with ARIA live regions
   // - Keyboard-accessible file selection
   
   // Column mapping accessibility  
   // - Clear labeling for dropdown selectors
   // - Table navigation with arrow keys
   // - Status announcements for mapping changes
   ```

### Testing
- **Performance Testing**: Test concurrent file uploads (10+ simultaneous)
- **Large File Testing**: Test files up to 50MB with 10,000+ player records
- **Background Processing**: Verify job status updates work correctly
- **Cancel Functionality**: Test job cancellation during processing
- **Error Recovery**: Test retry logic for failed processing
- **Cache Efficiency**: Verify mapping reuse reduces processing time
- **Database Performance**: Test JSONB query performance under load
- **Accessibility Testing**: Verify file upload process is screen reader accessible
- **Keyboard Navigation**: Test column mapping without mouse interaction
- **Error Handling**: Ensure validation errors are properly announced
- **Load Testing**: Test API response times with multiple concurrent file uploads

### Deliverable
High-performance file upload system with background processing, real-time status updates, and optimized database persistence

**Performance Targets:**
- Upload acknowledgment: < 2 seconds
- Background processing: < 15 seconds for 5MB files
- Concurrent uploads: Support 20+ simultaneous users
- Success rate: > 95% for valid files

---

## Iteration 4: Source Weighting System
*Goal: Interactive source weighting with polling-based ranking updates*

### Backend Tasks
1. **Optimized Weighting Calculation Logic**
   ```python
   @app.post("/api/rankings/{draft_session_id}/update-weights")
   async def update_source_weights(
       draft_session_id: UUID,
       weights: Dict[str, float]
   ) -> ConsolidatedRanking:
       # UPDATED: Background processing for heavy calculations
       
       # Quick cache check for existing calculation
       cache_key = f"rankings:{draft_session_id}:{hash_weights(weights)}"
       cached_result = await redis_client.get(cache_key)
       if cached_result:
           return json.loads(cached_result)  # Instant response
       
       # Queue background calculation if not cached
       task = calculate_consensus_rankings.apply_async(
           args=[draft_session_id, weights],
           queue='calculations',
           priority=9  # High priority for user-initiated requests
       )
       
       return {
           'job_id': task.id,
           'status': 'calculating',
           'estimated_completion_seconds': 10,
           'cache_key': cache_key
       }
   
   @app.get("/api/rankings/{draft_session_id}/poll")
   async def poll_ranking_updates(draft_session_id: UUID, last_update: datetime = None):
       # NEW: Efficient polling endpoint that returns only changes
       # Reduces bandwidth and improves performance
   ```

2. **High-Performance Percentile Normalization**
   - **Vectorized Calculations**: Use NumPy/Pandas for fast percentile computation
   - **Parallel Processing**: Calculate percentiles for different positions concurrently
   - **Smart Caching**: Cache percentile distributions to avoid recalculation
   - **Database Optimization**: Use PostgreSQL window functions for efficient percentile queries
   - **Memory Management**: Stream processing for large datasets to avoid memory issues

### Frontend Tasks
1. **Enhanced Interactive Weight Controls**
   ```typescript
   // components/source-weights.tsx
   export function SourceWeights({ sources, onWeightChange }) {
     // UPDATED: Optimistic updates with fallback
     const [optimisticWeights, setOptimisticWeights] = useState(sources);
     const [isCalculating, setIsCalculating] = useState(false);
     
     // Debounced weight updates (500ms delay)
     const debouncedUpdate = useDebouncedCallback(onWeightChange, 500);
     
     // Show instant UI feedback, queue background calculation
     const handleWeightChange = (sourceId, newWeight) => {
       setOptimisticWeights(prev => updateWeight(prev, sourceId, newWeight));
       debouncedUpdate(sourceId, newWeight);
     };
   }
   ```

2. **Smart Polling System**
   ```typescript
   // hooks/use-ranking-updates.ts
   export function useRankingUpdates(draftSessionId: string) {
     // UPDATED: Intelligent polling that adapts to activity
     // Fast polling (2s) during active changes
     // Slower polling (10s) during idle periods
     // Stop polling when rankings are stable
     
     const pollingInterval = isActivelyChanging ? 2000 : 10000;
   }
   ```

3. **Enhanced Table Display**
   - Add "Consensus Value Score" column
   - Show source contribution indicators
   - Add confidence scores based on consensus level

4. **Accessibility for Interactive Controls**
   ```typescript
   // Weight adjustment accessibility
   // - ARIA slider roles for bar graph controls
   // - Keyboard controls (arrow keys, page up/down)
   // - Live announcements for weight changes
   // - Focus indicators for draggable elements
   // - Alternative text input for precise values
   ```

### Testing
- **Performance Testing**: Test weight adjustments with 1000+ players complete in < 10 seconds
- **Concurrent User Testing**: Verify multiple users can adjust weights simultaneously
- **Cache Performance**: Test Redis hit rates > 80% for repeated weight combinations
- **Database Load Testing**: Test PostgreSQL performance under concurrent ranking calculations
- **Memory Usage**: Verify ranking calculations don't cause memory leaks
- **Network Efficiency**: Test polling uses minimal bandwidth with delta updates
- **Error Recovery**: Test graceful fallback when background calculations fail
- **Accessibility Testing**: Verify weight controls work with keyboard and screen readers
- **Live Updates**: Test that ranking changes are announced to assistive technology
- **Focus Management**: Ensure focus remains logical during dynamic updates

### Deliverable
High-performance interactive source weighting system with optimized background calculations and smart caching

**Performance Targets:**
- Weight adjustment UI response: < 100ms (optimistic updates)
- Background calculation: < 10 seconds for 1000+ players  
- Cache hit rate: > 80% for common weight combinations
- Concurrent users: Support 50+ simultaneous weight adjustments
- Polling efficiency: < 1KB per poll request (delta updates only)

---

## Iteration 5: Draft Status Management Foundation
*Goal: Basic drafted icon system with player status management*

### Frontend Tasks
1. **Draft Status Icons Setup**
   ```bash
   npm install lucide-react @radix-ui/react-dialog
   ```

2. **Draft Board Layout**
   ```typescript
   // components/draft-board.tsx
   export function DraftBoard() {
     return (
       <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
         <AvailablePlayers />
         <DraftedPlayers />
       </div>
     )
   }
   ```

3. **Player Cards & Status Icons**
   ```typescript
   // components/player-card.tsx
   export function PlayerCard({ player, onDraftStatusChange }) {
     // Player representation with drafted icon
     // Show key stats and draft status indicator
     // Click handler for draft status changes
   }

   // components/draft-containers.tsx
   export function AvailablePlayers() {
     // Container for available players with status icons
     // Sortable by consensus value score
     // Each row has drafted icon for quick status changes
   }

   export function DraftedPlayers() {
     // Container showing all players drafted by other teams
     // Visual team balance indicators
   }
   ```

4. **Draft State Management**
   ```typescript
   // hooks/use-draft-state.ts
   export function useDraftState() {
     // Available players list
     // Drafted players by user/other teams
     // Draft history with undo/redo
     // Status change confirmation dialogs
   }
   ```

### Backend Tasks
1. **Draft Session Management**
   ```python
   @app.post("/api/drafts")
   async def create_draft_session(session: DraftSessionCreate):
       # Create new draft session in PostgreSQL
       # Initialize sleeper list
       # Return draft session ID
   
   @app.get("/api/drafts/{draft_id}")
   async def get_draft_session(draft_id: str):
       # Get current draft state from PostgreSQL and Redis
       # Called by frontend polling every 7-10 seconds during active drafts
       # Returns only changed data since last_update timestamp for efficiency
   
   @app.post("/api/drafts/{draft_id}/pick")
   async def make_draft_pick(draft_id: str, pick: DraftPickRequest):
       # Record draft pick in PostgreSQL
       # Update cached draft state in Redis for next poll
       # Recalculate recommendations
   ```

5. **Draft Status Accessibility**
   ```typescript
   // Draft icon accessibility
   // - ARIA buttons with descriptive labels
   // - Keyboard activation (Enter/Space)
   // - Screen reader announcements for status changes
   // - High contrast mode support
   // - Alternative text-based draft entry
   ```

### Testing
- Test drafted icon clicks work smoothly across all player rows
- Verify draft state updates correctly across PostgreSQL and Redis
- Test confirmation dialog functionality ("drafted by you" vs "drafted by other team")
- Test undo/redo functionality
- Verify polling-based state synchronization
- Test draft session persistence
- **Accessibility Testing**: Verify draft icons work with keyboard and assistive technology
- **Status Announcements**: Test that draft status changes are properly announced
- **High Contrast**: Verify icons remain visible in high contrast mode

### Deliverable
Basic drafted icon system with simplified team tracking and database persistence

---

## Iteration 6: Advanced Draft Features
*Goal: Sleeper management, team balance analysis, and draft recommendations*

### Frontend Tasks
1. **Sleepers Management**
   ```typescript
   // components/sleepers-list.tsx
   export function SleepersList() {
     // Add/remove players from sleepers
     // Priority levels (High/Medium/Low)
     // Target round ranges
     // Personal notes for each sleeper
   }
   ```

2. **Team Balance Analysis**
   ```typescript
   // components/team-analysis.tsx
   export function TeamAnalysis({ draftedPlayers }) {
     // Position distribution charts
     // Category strength analysis (goals, assists, hits)
     // Visual balance indicators
     // Team needs highlighting
   }
   ```

3. **Draft Recommendations**
   ```typescript
   // components/draft-recommendations.tsx
   export function DraftRecommendations() {
     // Best available players by position
     // Value picks vs. reaches
     // Sleeper opportunity alerts
   }
   ```

### Backend Tasks
1. **Team Analysis Endpoints**
   ```python
   @app.get("/api/drafts/{draft_id}/team-analysis")
   async def analyze_team_balance(draft_id: str, team_id: str):
       # Calculate position distribution, category strengths using PostgreSQL joins
       # Cache frequently requested analyses in Redis
   
   @app.get("/api/drafts/{draft_id}/recommendations")
   async def get_draft_recommendations(draft_id: str):
       # Generate recommendations based on team needs
       # Use consolidated rankings from PostgreSQL JSONB + draft state from PostgreSQL
   ```

2. **Sleeper Tracking**
   ```python
   @app.post("/api/drafts/{draft_id}/sleepers")
   async def manage_sleepers(draft_id: str, sleepers: SleeperListUpdate):
       # Update sleeper targets in PostgreSQL (sleeper_players table)
       # Invalidate related caches in Redis
   
   @app.get("/api/drafts/{draft_id}/sleepers")
   async def get_sleepers(draft_id: str):
       # Get sleeper list from PostgreSQL with player details
   ```

### Testing
- Test sleeper management works across draft sessions
- Verify team analysis calculations are accurate using PostgreSQL joins
- Test recommendation updates as draft progresses
- Verify data consistency across PostgreSQL relational/JSONB data and Redis cache
- Test cache invalidation strategies

### Deliverable
Advanced draft features with sleeper management, team analysis, and simplified database architecture

---

## Iteration 7: Analytics Dashboard & Monitoring
*Goal: Comprehensive analytics dashboard and monitoring infrastructure*

### Backend Tasks
1. **Analytics Data Pipeline**
   ```python
   @app.post("/api/analytics/batch-events")
   async def batch_process_events(events: List[UserAnalyticsEvent]):
       # Batch process analytics events for performance
       # Store in PostgreSQL JSONB with proper indexing
       # Update aggregated metrics in Redis
   
   @app.get("/api/admin/dashboard-metrics")
   async def get_dashboard_metrics() -> DashboardMetrics:
       # Real-time metrics for admin dashboard
       # Active users, draft sessions, system performance
   ```

2. **Monitoring Alerts Setup**
   ```python
   # monitoring/alerts.py
   class AlertManager:
       async def check_database_performance(self):
           # Monitor query times across PostgreSQL, Redis
           # Alert if average response time > 500ms
       
       async def check_error_rates(self):
           # Monitor error rates from Sentry
           # Alert if error rate > 5% in 5-minute window
       
       async def check_draft_session_health(self):
           # Monitor active draft sessions
           # Alert if session failures > 2% of attempts
   ```

### Frontend Tasks
1. **Admin Analytics Dashboard**
   ```typescript
   // pages/admin/analytics.tsx
   export function AnalyticsDashboard() {
     // Real-time system metrics
     // User behavior analytics
     // Performance monitoring charts
     // Error rate tracking
   }
   ```

2. **Performance Monitoring Integration**
   ```typescript
   // lib/performance-monitoring.ts
   export class PerformanceTracker {
     static trackPageLoad(pageName: string) {
       // Track page load times
       // Monitor Core Web Vitals
     }
     
     static trackAPICall(endpoint: string, duration: number, success: boolean) {
       // Track API performance
       // Monitor success/failure rates
     }
   }
   ```

### Testing
- Test analytics data pipeline performance
- Verify dashboard metrics accuracy
- Test alert system triggers correctly
- Validate privacy compliance for user tracking

### Deliverable
Comprehensive analytics and monitoring system with polling-based dashboards

---

## Iteration 8: Polish, Testing & Deployment
*Goal: Production-ready application with deployment*

### Frontend Tasks
1. **UI Polish & Responsive Design**
   - Mobile browser optimization
   - Loading states and error handling
   - Performance optimization (lazy loading, code splitting)

2. **Comprehensive Accessibility Implementation**
   ```typescript
   // WCAG 2.1 AA Compliance
   // - Complete keyboard navigation support
   // - Screen reader optimization
   // - Color contrast validation (minimum 4.5:1 ratio)
   // - Focus management for dynamic content
   // - Skip links for main content areas
   // - Alternative text for all informative images/icons
   // - Form validation with accessible error messages
   // - ARIA landmarks and regions
   // - Heading hierarchy (h1-h6) structure
   // - High contrast mode support
   ```

3. **PWA Features**
   ```typescript
   // Add service worker for offline functionality
   // Implement caching strategy for draft data
   // Add manifest.json for app-like experience
   ```

4. **Testing & Quality**
   ```typescript
   // Add comprehensive component tests
   // E2E tests for critical user flows
   // Performance testing for draft status changes
   // Accessibility testing with automated and manual validation
   ```

5. **Accessibility Testing Suite**
   ```typescript
   // Automated testing with axe-core
   // Manual testing with screen readers (NVDA, JAWS, VoiceOver)
   // Keyboard navigation testing
   // Color contrast validation
   // Focus management testing
   // ARIA implementation validation
   ```

### Backend Tasks
1. **Production Readiness**
   - Environment configuration for all three databases
   - Database connection pooling and failover strategies
   - Comprehensive monitoring and alerting setup
   - Error handling improvements across database layers
   - API rate limiting with analytics tracking
   - Security hardening for database connections
   - **Production Analytics Setup**:
     - Configure production analytics pipeline
     - Set up automated reporting and alerts
     - Implement data retention policies
     - Configure monitoring dashboards

2. **Data Management & Optimization**
   ```python
   # Database migration scripts for PostgreSQL schema changes
   # PostgreSQL JSONB GIN index optimization for query performance  
   # Redis memory management and eviction policies
   # Backup and recovery procedures for all databases
   # Data archival strategies for draft sessions (30-day retention)
   ```

### Deployment
1. **Monitoring Infrastructure**
   - Set up DataDog/New Relic APM with multi-database monitoring
   - Configure Sentry error tracking with release management
   - Set up log aggregation (DataDog Logs/ELK stack)
   - Configure alerting channels (Slack, email, PagerDuty)
   - Set up uptime monitoring for all services

2. **Database Infrastructure**
   - Set up PostgreSQL (Supabase/Neon) with read replicas
   - Configure PostgreSQL with appropriate connection pooling and JSONB optimization
   - Set up Redis Cloud with persistence and clustering
   - Configure backup strategies for all databases
   - Set up database monitoring and performance alerts

3. **Backend Deployment**
   - Deploy FastAPI to Railway/Render
   - Configure database connection strings for all three databases
   - Set up environment variables for analytics and monitoring services
   - Configure CORS for production domain
   - Set up comprehensive monitoring and alerting
   - Configure analytics data pipeline for production scale

4. **Frontend Deployment**
   - Deploy Next.js to Vercel with Analytics integration
   - Configure API endpoints for production
   - Set up custom domain with monitoring
   - Configure CDN with performance tracking
   - Enable Vercel Analytics and Web Vitals monitoring

5. **Integration Testing**
   - Test full application flow in production
   - Performance testing under load with monitoring
   - Cross-database consistency testing with analytics
   - Database failover testing with alerting
   - Cross-browser compatibility testing
   - **Analytics & Monitoring Testing**:
     - Test all monitoring alerts fire correctly
     - Verify analytics data accuracy in production
     - Test performance monitoring under load
     - Validate error tracking captures issues correctly

### Testing
- Complete end-to-end user journey testing with analytics tracking
- Performance testing with comprehensive monitoring
- Security testing with error tracking validation
- Data consistency validation across all databases
- Backup and recovery testing procedures
- **Analytics & Monitoring Validation**:
  - Verify all user interactions are tracked correctly
  - Test performance metrics accuracy across all services
  - Validate error tracking captures and reports issues
  - Test alerting system responds to threshold breaches
  - Verify analytics data privacy compliance
- **Comprehensive Accessibility Testing**:
  - Automated axe-core testing in CI/CD pipeline
  - Manual screen reader testing (NVDA, JAWS, VoiceOver)
  - Keyboard-only navigation testing
  - Color contrast validation across all UI components
  - Focus management validation for dynamic content
  - WCAG 2.1 AA compliance audit

### Deliverable
Production-ready Fantasy Draft Assistant with comprehensive analytics, monitoring, and multi-database architecture

---

## Technical Considerations

### Real-Time Updates Strategy
**High-Performance Polling-Based Approach (Not WebSockets)**
- **Rationale**: Fantasy draft pace (60-90 second pick timers) makes 5-10 second polling delays negligible
- **Performance Target**: Updates reflected within 5-10 seconds (from user specification)
- **Implementation**: Optimized HTTP polling with delta updates and smart caching
- **Benefits**: Reliable, debuggable, cost-effective, no connection management complexity
- **Adaptive Polling**: 2-second intervals during active changes, 10-second during idle periods
- **Bandwidth Optimization**: Send only changed data, not full payloads
- **Background Processing**: Heavy calculations run async, polls check job status
- **Efficiency**: Polling stops automatically when draft is complete or inactive

```typescript
// Enhanced polling implementation with performance optimization
const useDraftPolling = (draftId: string, isActive: boolean) => {
  const [lastUpdate, setLastUpdate] = useState<string | null>(null);
  const [isActivelyChanging, setIsActivelyChanging] = useState(false);
  
  useEffect(() => {
    if (!isActive) return;
    
    // Adaptive polling interval based on activity
    const interval = isActivelyChanging ? 2000 : 7000;
    
    const pollUpdates = async () => {
      try {
        // Request only changes since lastUpdate (delta polling)
        const updates = await api.getDraftUpdates(draftId, lastUpdate);
        
        if (updates.hasChanges) {
          updateDraftState(updates);
          setLastUpdate(updates.timestamp);
          setIsActivelyChanging(true);
          
          // Reset activity flag after 30 seconds of no changes
          setTimeout(() => setIsActivelyChanging(false), 30000);
        }
        
        // Check for background job completions
        if (updates.pendingJobs?.length > 0) {
          const jobStatuses = await Promise.all(
            updates.pendingJobs.map(jobId => api.getJobStatus(jobId))
          );
          
          jobStatuses.forEach(status => {
            if (status.status === 'completed') {
              // Trigger data refresh for completed jobs
              updateDraftState({ refresh: true });
            }
          });
        }
        
      } catch (error) {
        console.error('Polling error:', error);
        // Exponential backoff on errors
        setTimeout(pollUpdates, Math.min(interval * 2, 30000));
        return;
      }
    };
    
    const intervalId = setInterval(pollUpdates, interval);
    
    return () => clearInterval(intervalId);
  }, [draftId, isActive, lastUpdate, isActivelyChanging]);
};
```

### Database Strategy & Performance
- **PostgreSQL**: ACID compliance for critical operations, complex joins for analysis
- **PostgreSQL JSONB**: Schema flexibility for projection data while maintaining ACID compliance  
- **Redis**: Sub-millisecond caching, session management, poll-based draft state updates
- **Connection Pooling**: Separate pools for read/write operations, read replicas for heavy queries
- **Query Optimization**: Prepared statements, strategic indexes, query result caching
- **Background Processing**: CPU-intensive calculations moved to Celery workers
- **Cache Warming**: Pre-calculate popular ranking combinations
- **Performance Monitoring**: Track query times, cache hit rates, job processing times

### State Management
- Use Zustand for client-side draft state
- React Query for server state and caching with database-aware strategies
- Local storage for user preferences
- Redis for server-side session and polling-based state management

### Performance Optimizations
- **Frontend Optimizations**:
  - Virtual scrolling for large player lists (1000+ players)
  - Debounced API calls (500ms) for weight adjustments
  - Optimistic updates with graceful error handling
  - Code splitting and lazy loading for faster initial load
  - Service worker caching for offline capability

- **Backend Optimizations**:
  - Background job processing for CPU-intensive tasks
  - Multi-level Redis caching (L1: hot data, L2: warm data, L3: compressed mobile)
  - Database connection pooling with read replicas
  - Prepared statements and query result caching
  - Batch processing for large datasets
  - Asynchronous task queuing with priority handling

- **Database Optimizations**:
  - PostgreSQL JSONB GIN indexes for fast JSON queries
  - Partitioned tables for time-series data
  - Query optimization with EXPLAIN ANALYZE monitoring
  - Read replica routing for heavy analytics queries

### Error Handling & Reliability
- **Graceful Degradation**:
  - Show cached data when real-time updates fail
  - Fallback to essential features when background jobs fail
  - Progressive enhancement for non-critical features

- **Retry Strategies**:
  - Exponential backoff for transient failures
  - Circuit breaker pattern for cascading failures
  - Job-level retries with different strategies per job type
  - Database connection retry with failover to read replicas

- **Monitoring & Alerting**:
  - Real-time error tracking with Sentry integration
  - Performance monitoring with custom metrics
  - Automated alerts for high error rates or slow responses
  - Health check endpoints for all critical services

- **User Experience**:
  - Clear error messages with actionable guidance
  - Loading states with progress indicators
  - Offline mode with service worker caching
  - Automatic recovery when services restore

### Accessibility Standards
- **WCAG 2.1 AA Compliance**: Full compliance with Web Content Accessibility Guidelines
- **Keyboard Navigation**: All interactive elements accessible via keyboard
- **Screen Reader Support**: Proper ARIA labels, roles, and live regions
- **Focus Management**: Logical focus flow and visual focus indicators
- **Color Accessibility**: Minimum 4.5:1 contrast ratio, no color-only information
- **Alternative Inputs**: Support for voice control and switch navigation
- **Responsive Accessibility**: Accessible experience across all device sizes
- **Error Accessibility**: Screen reader accessible error messages and validation

### Security
- **File Upload Security**: 50MB per file, 200MB daily quota per user, virus scanning integration
- **Excel Macro Detection**: Automatic detection and removal of VBA macros and external links
- **Input Sanitization**: Fantasy-specific data validation for player names, positions, stats, and weights
- **Rate Limiting**: Specific limits per endpoint type (10/hour file uploads, 100/hour rankings, 5/minute auth)
- **API Versioning**: Structured deprecation strategy with sunset dates and migration paths
- **Database Security**: Connection encryption, access control, and audit logging across PostgreSQL and Redis
- **CORS Configuration**: Production-ready cross-origin resource sharing policies
- **User Quotas**: Per-user upload limits with Redis-based tracking to prevent abuse

---

## Future Enhancements (Post-MVP)

1. **Real-Time Fantasy Platform Integration**
   - OAuth with Yahoo/ESPN APIs
   - Automatic draft pick updates
   - Live league scoring

2. **Advanced Analytics**
   - Historical draft performance analysis
   - Sleeper success rate tracking
   - Custom scoring system support

3. **Social Features**
   - Share draft results
   - League commissioner tools
   - Draft recap reports

4. **Mobile Apps**
   - React Native apps for iOS/Android
   - Push notifications for draft alerts
   - Offline-first functionality

---

## Success Metrics

### Technical Metrics
- **Page Load Time**: < 2 seconds initial load
- **Draft Status Performance**: Instant response to icon clicks
- **API Response Time**: < 500ms for ranking updates
- **Uptime**: 99.9% during draft season

### User Experience Metrics
- **Time to First Draft Pick**: < 30 seconds from login
- **File Processing Success Rate**: 95%+ automatic mapping
- **Mobile Usability**: Functional on tablets/phones
- **User Retention**: Return usage for multiple draft sessions

This plan provides a structured approach to building the Fantasy Draft Assistant with clear deliverables, testing criteria, and technical details for each iteration. Each step builds upon the previous one while delivering working functionality that can be tested and validated.