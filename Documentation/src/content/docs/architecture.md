---
title: "Architecture"
---

# Architecture

This page describes the high-level system architecture of BugTraceAI, including the technology stacks, communication protocols, port assignments, and data flow between components.

---

## System Overview

BugTraceAI is a modular ecosystem where each component can function independently or work together as a unified platform.

```
+-------------------------------------------------------------+
|                     BugTraceAI Platform                      |
|                                                              |
|  +-------------------------+   +-------------------------+  |
|  |    BugTraceAI-WEB       |   |    BugTraceAI-CLI       |  |
|  |                         |   |                         |  |
|  |  Frontend (React)       |   |  FastAPI Server         |  |
|  |  Port 6869 (Nginx)      |   |  Port 8000              |  |
|  |                         |   |                         |  |
|  |  Backend (Express)      |   |  SQLite + LanceDB       |  |
|  |  Port 3001              |   |  Go Fuzzers             |  |
|  |                         |   |  Playwright Chromium     |  |
|  |  PostgreSQL             |   |                         |  |
|  +----------+--------------+   +------------+------------+  |
|             |                               |                |
|             +---------- REST API -----------+                |
|             +---------- WebSocket ----------+                |
+-------------------------------------------------------------+
```

---

## Component Stacks

### BugTraceAI-CLI Stack

The CLI is the core scanning engine. It exposes a REST API and WebSocket endpoints for integration.

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **API Server** | FastAPI (Python) | REST API + WebSocket endpoints |
| **Database** | SQLite | Source of truth for all scan data |
| **Vector Store** | LanceDB | Semantic search over findings |
| **Fuzzers** | Go binaries | High-speed XSS, SSRF, IDOR, LFI fuzzing |
| **Browser** | Playwright + Chromium | CDP-based validation, DOM analysis |
| **AI** | OpenRouter API | Multi-model agents (Gemini, Claude, GPT) |

**Port**: `8000` (FastAPI)

### BugTraceAI-WEB Stack

The WEB provides a browser-based dashboard that connects to the CLI API.

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | React 18 + TypeScript + Vite | Dashboard UI, 20+ security tools |
| **Styling** | TailwindCSS | Responsive design |
| **Backend** | Express + TypeScript | API for local WEB data |
| **ORM** | Prisma | Database access layer |
| **Database** | PostgreSQL | Chats, settings, analysis reports |
| **Proxy** | Nginx | Static file serving, reverse proxy |

**Ports**: `6869` (Nginx frontend), `3001` (Express backend)

### BugTraceAI-Launcher Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Scripts** | Bash | Interactive wizard, lifecycle management |
| **Orchestration** | Docker Compose | Multi-container deployment |
| **Configuration** | .env files | Environment variable management |

---

## Communication

### REST API

The WEB frontend communicates with the CLI via its FastAPI REST API on port 8000.

```
WEB Frontend  ---HTTP/REST--->  CLI FastAPI (:8000)
                                    |
                                    +---> /api/scans
                                    +---> /api/scans/{id}/status
                                    +---> /api/scans/{id}/findings
                                    +---> /api/scans/{id}/report/{format}
                                    +---> /api/config
                                    +---> /api/metrics
```

The CLI API follows the OpenAPI 3.1 specification. Interactive documentation is available at `/docs` (Swagger UI).

See [API Reference](/api-reference) for the complete endpoint listing.

### WebSocket

Real-time scan monitoring uses WebSocket connections:

```
WEB Frontend  ---WebSocket--->  CLI FastAPI (:8000)
                                    |
                                    +---> /ws/scans/{id}    (per-scan events)
                                    +---> /ws/global         (all-scan events)
```

WebSocket connections support reconnection via `last_seq` parameter for event replay.

See [WebSocket Events](/websocket-events) for the complete event protocol.

### Full Mode Data Flow

In full deployment mode (WEB + CLI connected):

1. User initiates a scan from the WEB dashboard
2. WEB sends `POST /api/scans` to CLI API
3. CLI begins autonomous scanning pipeline
4. CLI emits real-time events via WebSocket
5. WEB receives and displays progress, findings, and phase transitions
6. Scan results are persisted in CLI's SQLite database
7. WEB can fetch findings and reports via REST API

```
User --> WEB Dashboard --> CLI REST API --> Scanning Pipeline
                ^                              |
                |                              v
                +--- WebSocket Events ---  Event Bus
                                              |
                                              v
                                          SQLite DB
```

---

## Database Architecture

BugTraceAI uses a dual-database system:

| Database | Location | Purpose | Stores |
|----------|----------|---------|--------|
| **SQLite** | CLI (`bugtrace.db`) | Source of truth | Scans, findings, targets, reports |
| **PostgreSQL** | WEB backend | Local WEB data | Chats, settings, analysis reports |

Key design decisions:
- SQLite in the CLI is the **single source of truth** for all scan-related data
- PostgreSQL in the WEB stores only WEB-local data (chat history, tool settings, AI analysis reports)
- The databases work **autonomously OR together** -- they are not required to be co-located
- Multiple WEB instances can connect to a single CLI API server over the network
- The `origin` field tracks where each scan was launched (`"cli"`, `"web"`, or `"unknown"`). The system defaults to `"unknown"` rather than guessing -- it is better to not know than to lie about data provenance.

See [Dual Database System](/dual-database-system) for full details.

---

## Infrastructure Features

### Server-Side ZIP Generation

The CLI API can generate complete report archives server-side via `GET /api/scans/{id}/report-zip`. This includes all report artifacts (markdown, JSON, HTML, specialist results, PoC enrichment, reconnaissance data) in a single download, replacing the need for client-side file assembly.

### Circuit Breaker

The scanning pipeline includes a circuit breaker that automatically pauses all agents when the target becomes unresponsive (consecutive timeouts or high timeout percentage). This prevents wasted API calls and protects the target from being overwhelmed. See [Configuration](/configuration) for threshold settings.

---

## Port Assignments

| Port | Service | Protocol |
|------|---------|----------|
| `8000` | CLI FastAPI server | HTTP + WebSocket |
| `8001` | CLI MCP server (`bugtrace_mcp`) | HTTP/SSE |
| `6869` | WEB Nginx frontend | HTTP |
| `3001` | WEB Express backend | HTTP |
| `5432` | PostgreSQL (WEB) | TCP |

---

## Deployment Topologies

### Standalone CLI

```
+-------------------+
| BugTraceAI-CLI    |
| FastAPI :8000     |
| SQLite            |
+-------------------+
```

API-only, headless. Ideal for CI/CD and scripted usage.

### Standalone WEB

```
+-------------------+
| BugTraceAI-WEB    |
| Nginx :6869       |
| Express :3001     |
| PostgreSQL :5432  |
+-------------------+
```

Dashboard-only, with AI-powered security toolkit. No active scanning.

### Full Platform

```
+-------------------+        REST + WS        +-------------------+
| BugTraceAI-WEB    | <--------------------> | BugTraceAI-CLI    |
| Nginx :6869       |                         | FastAPI :8000     |
| Express :3001     |                         | SQLite            |
| PostgreSQL :5432  |                         | Go Fuzzers        |
+-------------------+                         | Playwright        |
                                              +-------------------+
```

Full integration. WEB sends scan requests to CLI API, receives real-time updates.

See [Deployment Modes](/deployment-modes) for detailed deployment options.

---

## Security Considerations

### Network Isolation

In production deployments, internal services should not be exposed:

- PostgreSQL (`5432`) and Express backend (`3001`) should be internal only
- Only Nginx (`6869`) and optionally CLI API (`8000`) should be externally accessible
- Use Docker network isolation to enforce boundaries

### API Authentication

- The CLI API supports API key authentication
- The WEB backend uses JWT tokens for user sessions
- API keys are stored encrypted (AES-256-GCM) in PostgreSQL

### Data Privacy

- No data is transmitted to BugTraceAI servers (there are none)
- The only external call is to OpenRouter API for AI functionality
- Users control what data is sent to AI models
- All scan data remains in the local SQLite/PostgreSQL databases

---

**Sub-pages**: [Dual Database System](/dual-database-system) | [API Reference](/api-reference) | [WebSocket Events](/websocket-events)

**See also**: [Deployment Modes](/deployment-modes) | [BugTraceAI-CLI](/bugtraceai-cli) | [BugTraceAI-WEB](/bugtraceai-web)
