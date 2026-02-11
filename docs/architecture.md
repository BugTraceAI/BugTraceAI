# BugTraceAI Architecture Overview

System design for the multi-agent security platform

---

## High-Level Architecture

BugTraceAI is a distributed security platform with three main components working together:

```
                    ┌─────────────────────────────────────┐
                    │           User Browser               │
                    └────────────────┬────────────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  BugTraceAI-WEB │       │ BugTraceAI-CLI  │       │    Launcher     │
│  (React + TS)   │◄─────►│    (Python)     │       │    (Bash)       │
│  Port 5173/6869 │  REST │    Port 8000    │       │   Deployment    │
└─────────────────┘  WS   └─────────────────┘       └─────────────────┘
         │                         │
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│   PostgreSQL    │       │   SQLite (CLI)  │
│   (WEB data)    │       │   (scan data)   │
└─────────────────┘       └─────────────────┘
```

**Component Roles:**

- **BugTraceAI-CLI**: Autonomous security scanner with 5-phase pipeline
- **BugTraceAI-WEB**: Interactive security toolkit and dashboard
- **BugTraceAI-Launcher**: One-command deployment automation
- **Communication**: WEB connects to CLI via REST API and WebSocket for real-time scan updates

---

## CLI Pipeline Architecture

The CLI implements a robust 6-phase penetration testing pipeline:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BUGTRACE SCAN PIPELINE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: DISCOVERY                    Concurrency: 1 (GoSpider)            │
│  ┌──────────────────┐                                                        │
│  │    GoSpider      │ → URLs discovered → stored in DB                      │
│  │  (URL Crawling)  │                                                        │
│  │    + Nuclei      │ → CVE scanning with templates                         │
│  └────────┬─────────┘                                                        │
│           │                                                                  │
│           ▼                                                                  │
│  PHASE 2: ANALYSIS                     Concurrency: 5 (configurable)        │
│  ┌──────────────────┐                                                        │
│  │   DASTySAST      │ → 5 LLM personas (Red Team, SAST, DAST, Fuzzer, etc.) │
│  │ (analysis_agent) │ → Consensus voting (4/5 required)                     │
│  │                  │ → SkepticalAgent (FP filtering with Claude Haiku)     │
│  └────────┬─────────┘                                                        │
│           │                                                                  │
│           ▼                                                                  │
│  PHASE 3: THINKING CONSOLIDATION       (Event-driven, no semaphore)         │
│  ┌──────────────────┐                                                        │
│  │ ThinkingConsol.  │ → Deduplication by (vuln_type, parameter, url_path)   │
│  │     Agent        │ → FP Filter (fp_confidence < 0.5 threshold)           │
│  │                  │ → SQLi BYPASSES FP filter (SQLMap decides)            │
│  │                  │ → probe_validated BYPASSES FP filter                  │
│  │                  │ → Priority scoring by severity + evidence             │
│  │                  │ → Queue distribution to specialist agents             │
│  └────────┬─────────┘                                                        │
│           │                                                                  │
│           ▼                                                                  │
│  PHASE 4: EXPLOITATION                 Concurrency: 10 (configurable)       │
│  ┌──────────────────┐                                                        │
│  │   Specialists    │ → XSSAgent (Playwright multi-context)                 │
│  │  (11 queues)     │ → SQLiAgent (SQLMap integration)                      │
│  │                  │ → CSTIAgent, LFIAgent, IDORAgent                      │
│  │                  │ → SSRFAgent, XXEAgent, RCEAgent                       │
│  │                  │ → JWTAgent, OpenRedirectAgent                         │
│  │                  │ → PrototypePollutionAgent, HeaderInjectionAgent       │
│  │                  │ → FileUploadAgent                                     │
│  └────────┬─────────┘                                                        │
│           │                                                                  │
│           ▼                                                                  │
│  PHASE 5: VALIDATION                   Concurrency: 1 (CDP HARDCODED)       │
│  ┌──────────────────┐                                                        │
│  │ AgenticValidator │ → CDP (Chrome DevTools Protocol)                      │
│  │  (Final Audit)   │ → Vision AI verification on screenshots              │
│  │                  │ → SINGLE-THREADED (CDP limitation)                    │
│  │                  │ → 45s timeout per finding to prevent alert() hangs    │
│  └────────┬─────────┘                                                        │
│           │                                                                  │
│           ▼                                                                  │
│  PHASE 6: REPORTING                    Concurrency: 1 (Sequential)          │
│  ┌──────────────────┐                                                        │
│  │  ReportingAgent  │ → Aggregate findings from all sources                 │
│  │                  │ → Generate JSON, Markdown, HTML reports               │
│  │                  │ → Final quality audit & artifact preservation         │
│  └──────────────────┘                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase Details

**Phase 1 - Discovery:**
- GoSpiderAgent crawls target URL to enumerate all endpoints
- NucleiAgent scans for known CVEs using template database
- Results stored in SQLite database

**Phase 2 - Analysis:**
- DASTySAST Agent employs 5 distinct LLM personas to analyze each URL
- Consensus mechanism requires 4/5 personas to agree on vulnerability
- SkepticalAgent reviews findings for false positive indicators
- Supports multiple AI providers: Gemini, Claude, GPT-4, DeepSeek via OpenRouter

**Phase 3 - Thinking Consolidation:**
- Central routing brain that processes findings from Phase 2
- Deduplicates by (vulnerability_type, parameter, url_path) key
- Filters out low-confidence findings (fp_confidence < 0.5 threshold)
- **Exception:** SQLi bypasses FP filter (SQLMap is authoritative)
- **Exception:** probe_validated findings bypass FP filter (already confirmed)
- Prioritizes by severity score and routes to specialist queues
- Emits work_queued_* events for parallel specialist execution

**Phase 4 - Exploitation:**
- 11 specialist agents execute in parallel (default 10 workers)
- Each specialist validates findings with real exploitation attempts
- XSSAgent uses Playwright for multi-threaded browser automation
- SQLiAgent integrates SQLMap for deterministic SQL injection confirmation
- Findings marked as probe_validated when confirmed by tools

**Phase 5 - Validation:**
- AgenticValidator performs final audit on PENDING_VALIDATION findings
- Uses Chrome DevTools Protocol (CDP) for edge case detection
- Vision AI analyzes screenshots for visual confirmation
- **Single-threaded only** - CDP does not support concurrent connections
- 45-second timeout prevents infinite hangs from alert() popups
- Aggressive pre-filtering minimizes findings reaching this bottleneck

**Phase 6 - Reporting:**
- ReportingAgent consolidates all verified findings and metadata
- Generates standardized reports in multiple formats (JSON, MD, HTML)
- Ensures all artifacts (screenshots, logs) are correctly linked
- Provides a clean final output for user consumption

---

## Event-Driven Architecture

BugTraceAI uses an event bus for inter-agent communication:

```
Event Flow:
┌──────────────────┐
│  url_discovered  │ → GoSpider → Database
└──────────────────┘

┌──────────────────┐
│  url_analyzed    │ → DASTySAST → ThinkingConsolidation
└──────────────────┘

┌──────────────────┐
│ work_queued_xss  │ → ThinkingConsolidation → XSSAgent
│ work_queued_sqli │ → ThinkingConsolidation → SQLiAgent
│ work_queued_*    │ → ThinkingConsolidation → SpecialistAgent
└──────────────────┘

┌──────────────────┐
│finding_confirmed │ → Specialist → Database
└──────────────────┘

┌──────────────────┐
│validation_complete│ → AgenticValidator → ReportingAgent
└──────────────────┘
```

**Key Benefits:**
- Decoupled agent communication
- Queue-based parallel execution
- Backpressure handling with rate limiting
- Event replay capability for debugging

---

## Key Components

### TeamOrchestrator (core/team.py)

Coordinates the entire scan lifecycle:

- Initializes pipeline phases sequentially
- Manages agent lifecycle (startup, health checks, shutdown)
- Handles graceful shutdown on Ctrl+C or errors
- Monitors scan progress and phase transitions
- Provides scan status reporting

### ThinkingConsolidationAgent (agents/thinking_consolidation_agent.py)

Central routing brain for the pipeline:

- **Classifies** findings to specialist types (xss, sqli, csti, etc.)
- **Deduplicates** by composite key: (vuln_type, parameter, url_path)
- **Filters** false positives: fp_confidence < 0.5 threshold
- **Bypasses FP filter** for SQLi (SQLMap is authoritative) and probe_validated
- **Prioritizes** by: severity * confidence * (1 - skeptical_score)
- **Distributes** to specialist queues with backpressure control
- **Tracks metrics**: deduplication rate, FP filter effectiveness

### WorkerPool (core/worker_pool.py)

Parallel execution engine per specialist:

- Default 5 workers per specialist type
- XSSAgent gets 8 workers (CPU-intensive Playwright operations)
- Dynamic scaling capability based on queue depth
- Backpressure with configurable rate limiting
- Graceful shutdown with work queue draining

### Phase Semaphores (core/phase_semaphores.py)

Granular concurrency control per pipeline phase:

```python
ScanPhase.DISCOVERY    → Semaphore(1)   # GoSpider single-threaded design
ScanPhase.ANALYSIS     → Semaphore(5)   # 5 URLs DAST in parallel
ScanPhase.EXPLOITATION → Semaphore(10)  # 10 specialists in parallel
ScanPhase.VALIDATION   → Semaphore(1)   # CDP HARDCODED - cannot change
ScanPhase.LLM_GLOBAL   → Semaphore(2)   # OpenRouter rate limiting
```

**Why Validation = 1 is hardcoded:**
- CDP (Chrome DevTools Protocol) does not support multiple concurrent connections
- One session per Chrome process (port 9222)
- alert() popups block CDP indefinitely
- Multiple connections cause state corruption or Chrome crashes
- Solution: Filter aggressively before CDP to minimize validation queue

### SkepticalAgent (agents/skeptic.py)

False positive reduction specialist:

- Reviews each finding from DASTySAST
- Assigns skeptical_score (0.0 = confident FP, 1.0 = confident TP)
- Looks for: benign patterns, missing evidence, logical inconsistencies
- Uses Claude Haiku for fast inference
- Findings with high skeptical_score are deprioritized

### Specialist Agents

**XSSAgent (agents/xss_v4.py):**
- Uses Playwright for browser automation (multi-context safe)
- Generates context-aware payloads (HTML, JS, attribute, URL contexts)
- Confirms execution in real browser
- Sets probe_validated=True on confirmed findings
- Captures screenshots as evidence

**SQLiAgent (agents/sqli_agent_v3.py):**
- Integrates SQLMap (external authoritative tool)
- Bypasses FP filter in ThinkingConsolidation
- SQLMap confirmation is deterministic (if SQLMap says SQLi, it's SQLi)
- Supports WAF bypass strategies
- Extracts database info for confirmed SQLi

**CSTIAgent (agents/csti_agent.py):**
- Client-Side Template Injection detection
- Framework-specific payloads: AngularJS, Vue, React
- Detects unsafe template rendering
- Confirms with expression evaluation

**Other Specialists:**
- LFIAgent: Local File Inclusion with path traversal
- IDORAgent: Insecure Direct Object References
- SSRFAgent: Server-Side Request Forgery
- XXEAgent: XML External Entity Injection
- RCEAgent: Remote Code Execution
- JWTAgent: JWT security misconfigurations
- OpenRedirectAgent: Open redirect vulnerabilities
- PrototypePollutionAgent: JavaScript prototype pollution
- HeaderInjectionAgent: HTTP header injection attacks
- FileUploadAgent: File upload vulnerabilities

### AgenticValidator (agents/agentic_validator.py)

Final validation layer for edge cases:

- Processes findings with status PENDING_VALIDATION
- Uses Chrome DevTools Protocol (CDP) for low-level browser control
- Vision AI (GPT-4 Vision) analyzes screenshots for visual confirmation
- 45-second timeout per finding prevents alert() infinite hangs
- **Single-threaded only** - CDP architectural limitation
- Minimizing findings to this phase is critical for performance

---

## WEB Architecture

The web interface provides manual security analysis tools:

```
Frontend (React 18 + TypeScript 5)
├── Components (20+ security tools)
│   ├── JWT Analyzer
│   ├── XSS Payload Generator
│   ├── SQL Injection Tester
│   ├── DOM XSS Pathfinder
│   ├── WAF Bypass Generator
│   ├── SAST/DAST Assistants
│   └── ... (14 more tools)
├── Hooks (state management)
│   ├── useAIAnalysis
│   ├── useCLIConnection
│   └── useToolHistory
├── Services (API communication)
│   ├── CLIService (REST + WebSocket)
│   └── ToolService (CRUD operations)
└── Context (global state)
    ├── SettingsContext
    └── CLIConnectionContext
         │
         ▼
Backend (Express + Prisma)
├── REST API (CRUD for tools)
├── WebSocket (real-time CLI updates)
└── PostgreSQL (tool history, settings)
```

**Key Features:**

- 20+ specialized security tools for manual analysis
- Real-time CLI scan monitoring via WebSocket
- AI-powered SAST/DAST analysis assistants
- Persistent analysis history across sessions
- Tool-specific AI context for better results

---

## Integration Points

### WEB <-> CLI Communication

**REST API:**
- WEB calls CLI API at http://localhost:8000
- Endpoints: /api/scans, /api/findings, /api/health
- CLI connection status tracked in WEB UI

**WebSocket:**
- Real-time scan progress updates
- Event stream: url_analyzed, finding_confirmed, validation_complete
- Automatic reconnection on connection loss

**CLI Connector:**
- Health check polling (every 5 seconds)
- Dynamic URL configuration (supports custom CLI ports)
- Visual indicators: green (connected), red (disconnected), yellow (connecting)

### MCP Server Integration

Model Context Protocol server for Claude Desktop integration:

- STDIO transport for Claude Desktop
- Tool definitions for security analysis
- Context providers for scan history
- Workflow automation for common tasks

Location: BugTraceAI-CLI/bugtrace/mcp/

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| **CLI Core** | Python 3.10+, FastAPI, SQLAlchemy, asyncio |
| **CLI Tools** | SQLMap, Playwright, Nuclei, GoSpider |
| **CLI AI** | OpenRouter API (Gemini, Claude, GPT-4, DeepSeek) |
| **CLI Database** | SQLite (scan data), LanceDB (vector storage) |
| **CLI Validation** | Chrome DevTools Protocol (CDP), Vision AI |
| **WEB Frontend** | React 18, TypeScript 5, Vite, Tailwind CSS |
| **WEB Backend** | Express.js, Prisma ORM |
| **WEB Database** | PostgreSQL |
| **WEB AI** | OpenAI API (GPT-4, GPT-4 Vision) |
| **Deployment** | Docker, Docker Compose |
| **Launcher** | Bash, jq, docker CLI |

---

## Concurrency and Performance

### Phase-Specific Concurrency

Each pipeline phase has independent concurrency limits:

| Phase | Default | Configurable | Reason |
|-------|---------|--------------|--------|
| Discovery | 1 | No | GoSpider single-threaded design |
| Analysis | 5 | Yes (1-20) | Balances LLM rate limits vs throughput |
| Exploitation | 10 | Yes (1-30) | Parallel specialist validation |
| Validation | 1 | No | CDP architectural limitation |
| LLM Global | 2 | Yes | OpenRouter rate limiting |

### Performance Characteristics

**Typical Scan Times:**
- 10 URLs, 5 findings: 2-3 minutes
- 50 URLs, 15 findings: 8-12 minutes
- 100 URLs, 25 findings: 15-20 minutes

**Bottlenecks:**
- Phase 2 (Analysis): LLM API latency (2-5s per URL)
- Phase 5 (Validation): CDP single-threaded (45s max per finding)

**Optimization Strategies:**
- Aggressive FP filtering before CDP (minimizes validation queue)
- SQLi bypasses FP filter (SQLMap is fast and authoritative)
- Deduplication in Phase 3 (reduces specialist work)
- Parallel specialist execution (10 workers default)

---

## Database Schema

### CLI (SQLite)

**Tables:**
- scans: Scan metadata and status
- urls: Discovered URLs from GoSpider
- findings: Vulnerability findings from all phases
- validation_results: CDP validation outcomes
- agent_metrics: Performance tracking per agent

### WEB (PostgreSQL)

**Tables:**
- tools: Tool definitions and metadata
- analyses: Analysis history per tool
- settings: User preferences and CLI connection config

---

## Security Considerations

**API Security:**
- CORS configuration for WEB <-> CLI communication
- No authentication by default (localhost deployment)
- Docker network isolation in production

**Tool Safety:**
- SQLMap runs in isolated process
- Browser automation sandboxed via Playwright/CDP
- Payload generation limited to research purposes

**Data Privacy:**
- Scan data stored locally in SQLite
- No telemetry or external data transmission
- API keys stored in .env files (not committed)

---

## Deployment Architecture

### Docker Compose Deployment

```
Docker Network: bugtraceai-network
├── bugtrace-web-frontend (React app, port 6869)
├── bugtrace-web-backend (Express API, port 3000)
├── bugtrace-web-db (PostgreSQL, port 5432)
└── bugtrace-cli (FastAPI, port 8000)
```

**Deployment Modes:**
1. **Full Platform**: WEB + CLI + Databases
2. **WEB Only**: WEB + PostgreSQL (manual analysis tools)
3. **CLI Only**: CLI standalone (headless scanning)

**Launcher Features:**
- Interactive wizard for guided setup
- Automatic port conflict resolution
- Health checks and status dashboard
- Service management (start/stop/restart/logs)

---

## Extending the Platform

### Adding a New CLI Agent

1. Create agent file: `bugtrace/agents/{vuln}_agent.py`
2. Implement Hunter-Auditor pattern:
   - Hunter: Identify potential vulnerabilities
   - Auditor: Validate with real payloads
3. Add CWE mapping in reporting standards
4. Register in TeamOrchestrator
5. Add queue consumer for ThinkingAgent routing
6. Write tests in `tests/`

See: BugTraceAI-CLI/docs/architecture/AGENT_DEVELOPMENT.md

### Adding a New WEB Tool

1. Create component in `src/components/tools/`
2. Add tool definition to registry
3. Implement AI analysis hook
4. Add to sidebar navigation
5. Create Prisma schema migration if needed

---

## Architecture Evolution

**Version 1.0**: Single-threaded scanning, no AI
**Version 2.0**: Multi-threaded with basic LLM integration
**Version 3.0**: 5-phase pipeline with consensus voting
**Version 4.0**: Phase semaphores, FP filtering, CDP validation
**Current (v2.6)**: Docker integration, WEB dashboard, launcher wizard

**Next Steps:**
- Agent chain discovery (multi-step vulnerabilities)
- API security specialized scanning
- Distributed scanning across multiple nodes
- Enhanced reporting with executive summaries

---

For detailed agent documentation, see BugTraceAI-CLI/docs/agents/

For contribution guidelines, see docs/contributing.md

For deployment instructions, see docs/quickstart.md and docs/launcher.md
