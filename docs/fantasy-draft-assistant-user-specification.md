# Fantasy Hockey Draft Day Assistant - User Specification

## Executive Summary

The Fantasy Hockey Draft Day Assistant is a web-based application designed to help individual fantasy hockey players optimize their draft strategy by consolidating projections from multiple analysts and providing intelligent draft recommendations. The application serves as both a pre-draft preparation tool and a live draft companion that continuously surfaces the best available players based on uploaded analyst projections.

**Primary Goal**: Eliminate the manual work of comparing multiple analyst projections during fantasy hockey drafts by providing a single, unified view of the best available players according to your trusted sources.

---

## User Profile

### Primary Users
- **Individual fantasy hockey players** participating in fantasy leagues
- **Technical Skill Level**: Average computer users comfortable with web browsers and file uploads
- **Usage Context**: Both pre-draft preparation (days/weeks before) and live draft assistance (real-time during draft)
- **Accessibility Needs**: Users with visual impairments, motor disabilities, cognitive disabilities, or temporary impairments
- **Assistive Technology**: Support for screen readers, keyboard-only navigation, voice control, and high contrast modes

### User Motivations
- **Save Time**: Avoid manually cross-referencing multiple analyst projection files during drafts
- **Make Better Picks**: Leverage multiple expert opinions to identify undervalued players
- **Stay Organized**: Track drafted players and see real-time availability during fast-paced drafts

---

## Core User Journey

### Phase 1: Pre-Draft Setup (Days/Weeks Before Draft)
1. **Account Creation/Login**
   - User creates account or logs into existing account
   - Data persistence across sessions for uploaded projections and custom settings

2. **Draft Session Creation**
   - User creates a new draft session for their specific league
   - Configures league details: name, number of teams (4-20, average 10), scoring categories
   - Sets draft date/time for preparation timeline

3. **Projection Data Upload & Processing**
   - **Primary Method**: User uploads Excel/CSV files from trusted sources
   - **Alternative Method**: Copy-paste text rankings from Discord, Reddit, forums (if implemented)
   - **Accessibility Features**:
     - Keyboard-accessible file selection dialog
     - Screen reader announcements for upload progress
     - Clear error messages for invalid file formats
     - Alternative drag-and-drop with keyboard equivalent
   - **Data Source Types**:
     - **Rankings**: Pure subjective player rankings sorted by analyst preference
     - **ADP (Average Draft Position)**: Empirical data showing where players are drafted on average (Yahoo, ESPN, etc.)
     - **Projections**: Statistical forecasts for goals, assists, hits, etc. with fantasy point calculations
     - **Historical Stats**: Past season performance data (raw stats, may also include league-specific fantasy point total columns)
   - **Automatic Type Detection**: System attempts to identify data type based on column patterns and content
   - **Manual Override**: User can correct detected type or manually categorize ambiguous uploads
   - System uses rule-based column mapping with fuzzy matching to identify standard categories
   - All text input is validated and sanitized for security

4. **Source Weighting Configuration**
   - **Trigger**: Presented after uploading final data source or when adding new sources
   - **Interactive Bar Graph Interface**: Visual weighting system for all uploaded sources
     - Each source represented by a draggable bar (starts at 100% default weight)
     - Real-time percentage display as user adjusts bar heights
     - Percentages shown over total for relative weighting (e.g., Source A: 120%, Source B: 80%)
     - Visual feedback with smooth animations during adjustment
   - **Accessibility Features**:
     - ARIA slider controls with keyboard navigation (arrow keys, page up/down)
     - Screen reader announcements for weight changes
     - Alternative text input for precise weight values
     - High contrast mode support for visual elements
     - Clear labels describing each source and current weight
   - **Weight Application**: System applies weights to create single consolidated ranking across all source types
     - Rankings from different source types (Projections, ADP, Historical, Rankings) weighted equally within each source
     - User's source weights applied to create unified ranking list
     - Cross-type normalization ensures fair comparison between different data formats
   - **Re-weighting**: User can adjust weights anytime new sources are added
   - **Saved Preferences**: Weight configurations saved per user for future draft sessions

5. **Data Validation & Correction**
   - System validates player names against NHL/prospect databases using fuzzy matching
   - User corrects any unmatched player names through suggestion interface
   - **Saved for Future Use**:
     - **Column Mappings**: When user confirms "Goals" column maps to standard "G" category
     - **Player Name Corrections**: When user corrects "McDavid, C" to "Connor McDavid"
     - **New Category Definitions**: When user defines custom categories not in system knowledge base
   - Corrections are associated with specific analyst sources for automatic reuse

### Phase 2: Pre-Draft Review & Preparation
1. **Projection Analysis**
   - **Multi-Source Dashboard**: All data sources displayed with consolidated ranking view
     - **Individual Source Tables**: Each uploaded source displayed in separate, collapsible tables
       - Tables show original data from each analyst/source
       - Source weight percentage displayed in table headers
       - Individual table controls for minimize/maximize
       - Color-coded headers indicating source type (Projections, Rankings, ADP, Historical)
     - **Consolidated Master Ranking**: Primary table showing weighted average across all sources
       - Single unified ranking based on weighted percentile scores from each source's specified value column
       - Value-based normalization ensures fair comparison between different data formats (points vs. rankings vs. ADP)
       - Confidence indicators showing how many sources contributed to each player's ranking
       - "Consensus Value Score" column showing final weighted percentile (0-100)
       - Prominence given to consolidated ranking as primary decision-making tool
     - **Weight Adjustment Access**: Quick access to modify source weights with mini bar graph
     - **Table Controls**: Individual minimize/maximize for any table (individual sources or consolidated)
   - **Visibility Controls**:
     - **Source Toggles**: Show/hide individual data sources by name
     - **Source Type Filters**: Filter view to show only specific source types (Projections, Historical, Rankings, ADP)
     - **Global Column Toggle**: Show/hide statistical categories across all visible tables
     - **Per-Source Toggle**: Show/hide categories for individual sources
     - **Consolidated View Controls**: Focus mode showing only consolidated ranking table
   - Apply filters by position, team, or custom criteria across all tables
   - Compare different data types to identify value opportunities and market inefficiencies

2. **Draft Strategy Configuration**
   - Set visual thresholds for player tier identification
   - Configure position balance targets for roster construction
   - Review and adjust scoring category weights if needed
   - **Sleepers List Management**: Create and maintain custom list of targeted sleeper picks
     - Add/remove players to personal sleepers watchlist
     - Assign sleeper priority levels (High, Medium, Low)
     - Add personal notes for each sleeper pick rationale
     - Set target round ranges for each sleeper (e.g., "rounds 8-12")

### Phase 3: Live Draft Assistance
1. **Main Toolbar**
   - **Players Per List**: Global setting controlling number of rows displayed in all tables (default: 20)
     - Updates all tables to specified number when changed
     - Individual tables can be expanded beyond this limit via table-specific expand icons
     - Changing global setting resets all tables to new default
   - **Position Filter**: Quick filter buttons for player positions (G, D, C, LW, RW, FWD, SKT)
     - Toggle filters to show only selected positions across all tables
     - Multiple positions can be selected simultaneously
     - "All" button to clear position filters
     - **Accessibility**: ARIA pressed states, keyboard navigation, clear labeling
   - **Player Search**: Auto-populating text input for quick player lookup
     - Live search across all available players
     - Dropdown suggestions with player name, position, team
     - Enter to highlight/jump to player in tables
     - **Accessibility**: ARIA live region for search results, keyboard navigation through suggestions
   - **Undo/Redo**: Action history controls for mistake correction
     - Undo last draft selection, filter change, or weight adjustment
     - Redo previously undone actions
     - Visual indicators showing available undo/redo actions
   - **Auto-Save**: Automatic session saving triggered by draft actions
     - Primary: Auto-save when players are marked as drafted
     - Fallback: Manual save button if auto-save implementation proves complex
     - Save status indicator showing last save time
   - **Settings Access**: Icon in top-right corner for configuration panel
     - Access to advanced settings, preferences, and account options
     - Separate from main toolbar to maintain clean interface during drafts

2. **Draft Board Interface**
   - **Left Panel**: Available players with consolidated ranking as primary display
     - **Consolidated Master Ranking**: Primary table prominently displayed at top
       - Single weighted ranking incorporating all user sources
       - Source contribution indicators showing which sources ranked each player
       - Confidence scores based on consensus across sources
       - Color-coded cells based on consolidated percentile rankings
       - Player strength icons showing specialties (🎯 goals, 👊 hits, 🎪 assists)
     - **Individual Source Tables**: Secondary display (collapsible/minimizable)
       - Each source shown in separate, smaller table
       - Source weight indicators in headers
       - Quick reference for drill-down analysis
     - **Weight Adjustment**: Quick access bar graph for real-time weight modifications
     - **Table Controls**: Individual minimize/maximize for consolidated or individual source tables
     - **Visibility Controls**: 
       - **Consolidated Focus Mode**: Show only master ranking table
       - **Source Toggles**: Show/hide individual sources by name
       - **Source Type Filters**: Show only specific types (Projections, Historical, Rankings, ADP)
       - **Global Column Toggle**: Show/hide statistical categories across all visible tables
     - Sortable by any category within consolidated or individual tables
   
   - **Right Panel**: Draft tracking and sleepers monitoring
     - "My Team" section with real-time balance analysis
     - "Other Teams" section showing all players drafted by opponents
     - Team composition charts and position balance indicators
     - **Sleepers Watchlist**: Dedicated section showing user's targeted sleepers
       - Live availability status for each sleeper pick
       - Priority indicators and target round ranges
       - Alert notifications when sleepers reach target rounds
       - Visual indicators when sleepers are drafted by other teams

2. **Draft Updates (Two Methods)**
   - **Preferred**: Automatic updates via fantasy platform integration
     - User authenticates with their fantasy provider (Yahoo, ESPN, Fantrax)
     - System automatically fetches draft updates in real-time
     - Players are removed from available pool as they're drafted
   
   - **Fallback**: Manual draft tracking
     - Click drafted icons on player rows to mark as drafted
     - Confirmation dialog asks "drafted by you" or "drafted by other team"
     - Auto-complete text input for quick player entry
     - Actions automatically trigger auto-save functionality
     - All draft actions integrated with toolbar undo/redo system
     - **Accessibility Features**:
       - ARIA button labels describing draft status for each player
       - Keyboard activation (Enter/Space) for draft icons
       - Screen reader announcements when players are drafted
       - Alternative text-based entry for keyboard-only users
       - High contrast indicators for drafted status

3. **Real-Time Recommendations**
   - System continuously recalculates best available players
   - Team balance analysis updates after each pick
   - Highlights team needs and recommended positions
   - Shows value picks and potential reaches
   - **Sleeper Alerts**: Proactive notifications for sleeper pick opportunities
     - Round-based alerts when entering sleeper target ranges
     - Value opportunity alerts when sleepers remain available late

### Phase 4: Post-Draft Analysis (Optional)
1. **Draft Results Review**
   - Complete roster with projected statistics
   - Team balance scorecard across all categories
   - Comparison of actual picks vs. projected values
   - **Sleepers Performance Analysis**: Review sleeper pick success rates
     - Which sleepers were successfully drafted vs. missed opportunities  
     - Round analysis comparing target ranges to actual draft positions
     - Sleepers picked by other teams and their projected impact
   - Export capabilities (PDF, Excel) for future reference

2. **Data Retention**
   - Draft sessions saved for 30 days for reference
   - Custom mappings and settings saved permanently
   - **Sleepers Lists**: Saved permanently across seasons for reuse and refinement
   - **Source Weight Configurations**: Weight settings saved per draft session with option to save as reusable presets
   - Option to share draft results or keep private

---

## Detailed Feature Specifications

### File Upload & Processing System

#### Supported Data Sources
**Primary (Launch Features):**
- **Excel/Spreadsheet files** (.xlsx, .xls, .csv) from fantasy analysts
- **Google Sheets/Apple Numbers** exports in Excel format
- Maximum file size: 10MB per upload
- Multiple files can be uploaded for different sources

**Secondary (Nice-to-Have):**
- **Copy-Paste Text Input** for rankings from Discord, Reddit, forums
- Smart parsing of common text formats with user preview/correction
- Input validation and sanitization for security

**Future Consideration:**
- **Image/Screenshot Processing** (OCR) - evaluated post-launch based on user demand

#### Rule-Based Column Mapping
- **Automatic Recognition**: System recognizes common column patterns:
  - Player names: "Player", "Name", "Skater"
  - Statistics: "G", "Goals", "A", "Assists", "Pts", "Points"
  - Rankings: "Rank", "Overall", "#"
  - Positions: "Pos", "Position"
  - Advanced stats: "PPG", "SH%", "FOW", "+/-", "PIM", "Hits"
  - **Fantasy Value Columns**: "Fantasy Points", "Total Points", "VORP", "Value", "ADP", "Average Draft Position", "Rank", "Overall Rank"

#### Fuzzy Player Name Matching
- **Primary Matching**: Direct comparison against NHL player database
- **Fuzzy Matching**: Handles typos, abbreviations, and formatting differences
- **Prospect Integration**: Connects to prospect databases for upcoming players
- **Manual Override**: User can correct any unmatched names
- **Learning System**: App learns from corrections to improve future matching

#### Text Input Processing (Optional Feature)
- **Smart Text Parsing**: Handles common ranking formats from social media/forums
  - Numbered lists: "1. Connor McDavid C 150 pts"
  - Comma-separated: "McDavid, Connor (C) - 150 points"
  - Tab-delimited: "Connor McDavid    C    150"
- **Security First**: All text input sanitized to prevent injection attacks
- **User Preview**: Shows parsed results in table format before acceptance
- **Manual Correction**: Users can edit any parsing mistakes inline
- **Aggressive Parsing**: Attempts to extract data from various formats with fallback options

#### Custom Mapping Storage
- User-confirmed mappings saved for future uploads from same sources
- Ability to create new category mappings when analysts use unique columns
- System learns from user corrections to improve automatic mapping

### Sleepers List Management System

#### Sleepers List Creation & Management
- **Player Addition Methods**:
  - Direct selection from available players tables during pre-draft review
  - Search and add functionality with auto-complete
  - Import from external lists (copy-paste from notes, Discord, etc.)
  - Quick-add buttons throughout the interface when reviewing projections

- **Sleeper Configuration Options**:
  - **Priority Levels**: High (red indicators), Medium (yellow), Low (green)  
  - **Target Rounds**: Flexible range selection (e.g., "rounds 6-10", "after round 12")
  - **Personal Notes**: Free-text field for draft rationale, injury concerns, etc.
  - **Position Strategy**: Tag sleepers by positional need or strategy type
  - **ADP Comparison**: Show how sleeper ADP compares to target rounds

- **List Organization Features**:
  - Sort by priority, target round, position, or custom order
  - Group by position or strategy type  
  - Bulk operations (delete multiple, change priorities)
  - Duplicate detection when adding players already on main projections
  - Export sleepers list for external reference

#### Sleepers Integration with Main Interface
- **Visual Indicators**: Sleepers highlighted with special icons (⭐) in all player tables
- **Quick Actions**: One-click promote/demote between sleeper priority levels
- **Filter Integration**: Option to show only sleepers or exclude sleepers from main tables
- **Cross-Reference**: Compare sleeper value rankings across all data sources using their specified value columns
- **Mobile Optimization**: Swipe gestures for quick sleeper management on tablets

### Draft Interface Features

#### Available Players Table
- **Consolidated Ranking Display**: Single primary table with weighted rankings from all sources
- **Visual Indicators**:
  - Color coding: Green (top percentile) → Yellow → Red (bottom percentile) based on consolidated value score
  - Player specialty icons based on statistical strengths across sources
  - Position eligibility clearly marked
  - Source contribution indicators (e.g., "4/5 sources" badge)
  - Confidence scores based on consensus level across sources
- **Value-Based Columns**:
  - **"Consensus Value Score"**: Primary sort column showing weighted percentile (0-100)
  - **Individual source value columns**: Each source's specified value column (Fantasy Points, ADP, Rank, etc.)
  - **Value column headers**: Clearly labeled with direction indicators (↑ for higher-is-better, ↓ for lower-is-better)
- **Interactive Features**:
  - Sort by consensus value score, individual source value columns, or other stats
  - Filter by position, team, or custom criteria
  - Search functionality with auto-complete
  - Column visibility toggles for individual source columns
  - Quick weight adjustment access via mini bar graph
- **Secondary Source Tables**: Collapsible individual analyst tables showing original data with their value columns highlighted

#### Real-Time Weight Adjustment
- **Mini Bar Graph**: Compact version of weighting interface accessible during draft
  - Source labels show name and value column for clarity
  - Appears as overlay or side panel without disrupting draft flow
  - Instant recalculation of consensus value scores when weights modified
  - "Undo" functionality to revert recent weight changes
- **Dynamic Ranking Updates**: Consolidated table updates immediately when weights change
  - Consensus Value Score column recalculates in real-time
  - Player rankings shift visually with smooth animations
- **Weight Change Indicators**: Visual cues when rankings shift due to weight adjustments
- **Value Column Validation**: System ensures selected value columns are appropriate for weighting (numerical data only)

#### Draft Tracking System
- **Team Management**: 
  - Visual representation of user's team with real-time balance analysis
  - Simple tracking of players drafted by other teams (single bucket)
  - Position requirements and roster construction guidance
- **Balance Analytics**:
  - Category strength analysis (goals, assists, defense, goaltending)
  - Position distribution charts
  - Team needs highlighting

#### Player Selection Methods
- **Desktop Optimized**: Primary click-based drafted icon interface
- **Tablet Friendly**: Touch-optimized icon taps with confirmation dialogs
- **Mobile Fallback**: Text input with auto-complete search

### Real-Time Integration Strategy

**Update Mechanism**: Polling-based approach (not WebSockets)
- **Rationale**: Fantasy draft pace (60-90 second pick timers) makes 5-10 second polling delays negligible
- **Performance Target**: Updates reflected within 5-10 seconds of occurrence
- **Implementation**: Simple HTTP polling - reliable, debuggable, and cost-effective

#### Fantasy Platform APIs (Preferred)
- **Supported Platforms**: Yahoo Fantasy, ESPN Fantasy, Fantrax
- **Authentication**: OAuth integration for secure API access
- **Polling Strategy**: Automatic polling every 7-10 seconds during active drafts only
- **Data Sync**: Bidirectional updates when possible (read draft status, potentially write picks)
- **Efficiency**: Polling only occurs during active draft sessions, stops when draft is complete

#### Manual Tracking (Fallback)
- **Drafted Icons**: Click icon on player rows to mark as drafted with confirmation dialog
- **Text Input**: Quick player entry with fuzzy search
- **Bulk Updates**: Handle multiple picks at once during breaks
- **Error Handling**: Undo/redo functionality for corrections
- **No Polling**: Manual mode relies entirely on user input, no automatic updates

### User Account & Data Management

#### Account Features
- **Registration**: Email/password or social login options
- **Data Persistence**: All projections, mappings, and drafts saved
- **Privacy Controls**: Users control data sharing and retention
- **Session Management**: Secure authentication with session timeout

#### Data Storage & Retention
- **Projection Files**: Processed data stored for entire season
- **Custom Mappings**: Permanently saved for reuse
- **Draft Sessions**: 30-day retention with export options
- **User Preferences**: Visual settings, column preferences, shortcuts
- **Sleepers Lists**: Permanently stored with versioning across multiple seasons
  - Historical sleepers performance tracking for strategy refinement
  - Season-specific sleepers lists with rollover options to next season
  - Backup and restore functionality for sleepers data

---

## Technical User Experience

### Performance Expectations
- **File Processing**: Upload and process typical projection file (200-500 players) within 10 seconds
- **Real-Time Updates**: Draft updates reflected within 5-10 seconds of occurrence
- **Search Response**: Player search results appear within 1 second
- **Platform Responsiveness**: Instant response to drafted icon clicks on desktop/tablet
- **Accessibility Performance**: Screen reader announcements without delays, smooth focus transitions

### Browser Compatibility
- **Primary**: Chrome, Firefox, Safari, Edge (latest 2 versions)
- **Platform Priority**: 
  1. Desktop/Laptop browsers (primary target)
  2. Tablet browsers (secondary)
  3. Mobile phone browsers (basic functionality)
- **Accessibility Support**: Compatible with major screen readers (NVDA, JAWS, VoiceOver, TalkBack)

### Offline Capabilities
- **Limited Offline Mode**: Previously loaded draft data remains accessible
- **Sync on Reconnect**: Updates sync when connection restored
- **Local Storage**: Critical draft state cached locally

### Error Handling & Recovery
- **Graceful Degradation**: System remains functional when external APIs fail
- **User Feedback**: Clear error messages with suggested actions
- **Data Recovery**: Automatic backup and restore of draft progress
- **Support Contact**: Easy access to help when issues occur

---

## User Success Metrics

### Pre-Draft Success
- **Time Saved**: Reduce projection comparison time from 30+ minutes to 5 minutes
- **Accuracy**: 95%+ automatic column mapping success rate
- **Coverage**: Support for 90%+ of popular fantasy analyst formats
- **Accessibility**: 100% keyboard navigable interface, WCAG 2.1 AA compliance

### Draft Day Success
- **Speed**: Enable pick decisions within 30 seconds of turn
- **Accuracy**: Eliminate accidental drafting of already-selected players
- **Strategy**: Provide actionable team balance insights throughout draft
- **Reliability**: 99.9% uptime during peak draft season (September-October)
- **Inclusive Experience**: Usable by fantasy players regardless of disability status

### Post-Draft Value
- **Analysis**: Provide meaningful draft performance insights
- **Learning**: Help users understand their draft strategy effectiveness
- **Preparation**: Enable better preparation for future seasons
- **Universal Access**: Equal functionality for all users, including those using assistive technology

---

## User Support & Documentation

### Getting Started
- **Onboarding Tutorial**: Interactive walkthrough for first-time users
- **Video Guides**: Screen recordings of common tasks with audio descriptions and captions
- **Sample Data**: Demo projections for testing features
- **Accessibility Guide**: Documentation for using the app with assistive technology

### Help & Support
- **In-App Help**: Contextual tooltips and help text (screen reader compatible)
- **Knowledge Base**: Searchable help articles with proper heading structure
- **Contact Support**: Email/chat support during draft season
- **Community**: User forums for tips and best practices
- **Accessibility Support**: Dedicated support for assistive technology users

### Advanced Features
- **Power User Tips**: Keyboard shortcuts and advanced workflows
- **Custom Integrations**: API documentation for advanced users
- **Data Export**: Multiple format options for external analysis
- **Accessibility Features**: Complete list of supported assistive technologies and keyboard shortcuts

---

This specification serves as the foundation for understanding how users will interact with the Fantasy Hockey Draft Day Assistant, ensuring that every feature serves the core goal of making fantasy drafts more efficient, accurate, and enjoyable.
