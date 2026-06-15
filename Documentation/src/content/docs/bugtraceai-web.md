---
title: Bugtraceai Web
---

# BugTraceAI-WEB

BugTraceAI-WEB is the browser-based dashboard for the BugTraceAI platform. It provides 20+ AI-powered security analysis tools, real-time scan monitoring, and a complete interface for managing scans run by the [BugTraceAI-CLI](/bugtraceai-cli) engine.

**Repository**: [github.com/BugTraceAI/BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB)

---

## Overview

The WEB component has two layers:

| Layer | Technology | Port | Purpose |
|-------|-----------|------|---------|
| **Frontend** | React 18 + TypeScript + Vite + TailwindCSS | 6869 (Nginx) | Dashboard UI, security toolkit, scan monitoring |
| **Backend** | Express + TypeScript + Prisma | 3001 | API for chats, settings, analysis reports |

The frontend connects to:
- Its own Express backend (port 3001) for local WEB data
- The CLI FastAPI server (port 8000) for scan management and real-time monitoring

---

## Architecture

```
+-------------------------------------------------------+
|                    BugTraceAI-WEB                      |
|                                                        |
|  +-------------------+    +------------------------+  |
|  | React Frontend    |    | Express Backend        |  |
|  | Port 6869 (Nginx) |    | Port 3001              |  |
|  |                   |    |                        |  |
|  | - Dashboard       |    | - REST API             |  |
|  | - Security Tools  |    | - Prisma ORM           |  |
|  | - Scan Monitor    |    | - Authentication       |  |
|  | - Reports Viewer  |    |                        |  |
|  +--------+----------+    +----------+-------------+  |
|           |                          |                 |
|           |  HTTP                    |  SQL             |
|           v                          v                 |
|  +-------------------+    +------------------------+  |
|  | CLI API (:8000)   |    | PostgreSQL             |  |
|  | (External)        |    | (Local)                |  |
|  +-------------------+    +------------------------+  |
+-------------------------------------------------------+
```

---

## Technology Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| **React** | 18 | Component-based UI framework |
| **TypeScript** | -- | Type safety |
| **Vite** | 4+ | Build tool and dev server |
| **TailwindCSS** | -- | Utility-first CSS styling |
| **Express** | -- | Backend HTTP server |
| **Prisma** | -- | Type-safe ORM for PostgreSQL |
| **PostgreSQL** | 15 | Persistent storage for WEB data |
| **Nginx** | -- | Production static file serving and reverse proxy |
| **Docker** | -- | Containerized deployment |

---

## Features

### What's New in v0.8.6.1-beta

- **API Discovery**: Kiterunner-powered endpoint discovery with wordlists, speed selector, multi-filter views, tag-based sorting, and PostgreSQL persistence.
- **Authenticated Scanning**: Upload YAML auth configs from the scan form, including credentials and optional TOTP/2FA secrets.
- **Scan Resume Controls**: Resume recoverable scans from the dashboard through the CLI API.
- **Web Browsing Toggle**: Enable or disable real-time web lookups in WebSec Agent chat.
- **Improved CLI Configuration Tab**: Cleaner organization and validation for remote CLI settings.

### Security Toolkit

20+ specialized AI-powered security analysis tools, each with its own system prompt for targeted analysis. Tools include DAST, SAST, JWT analysis, payload generation, and more.

See [Security Toolkit](/security-toolkit) for the full tool listing.

### Scan Management

When connected to a CLI API server:
- **Create scans**: Launch new scans against target URLs
- **Authenticated scans**: Launch scans with YAML auth configs and optional TOTP/2FA support
- **Resume scans**: Continue recoverable scans without restarting the full workflow
- **Monitor progress**: Real-time progress bars, phase indicators, and active agent display
- **View findings**: Browse discovered vulnerabilities with severity and evidence
- **Download reports**: HTML, JSON, and Markdown reports
- **Real-time scan dashboard**: Pipeline bar showing current phase with progress, agent activity pills with finding count badges, and collapsible findings accordion
- **Responsive layout**: The scan dashboard adapts to screen width with a two-row layout that wraps agent pills on narrow screens
- **API Discovery**: Persist Kiterunner results to PostgreSQL with filters, speed controls, tags, and session history

See [Real-time Scan Monitoring](/real-time-scan-monitoring) for details.

### Reports Dashboard

- Browse all scans and their statuses
- Filter and sort findings by severity, type, and validation status
- View detailed finding evidence including payloads and screenshots
- Export reports in multiple formats
- **Sortable columns**: Both Findings and Detections tabs have clickable column headers for sorting
- **Tiebreaker sorting**: When values are identical, sorts by name/type as secondary key
- **Finding Name display**: Shows vulnerability type when no title is available

---

## Data Storage

The WEB uses PostgreSQL for its own local data:

| Data Type | Storage | Description |
|-----------|---------|-------------|
| Chat history | PostgreSQL | Conversations with security toolkit tools |
| Settings | PostgreSQL | User preferences, API key references |
| Analysis reports | PostgreSQL | AI-generated analysis from toolkit tools |
| API Discovery scans | PostgreSQL | Kiterunner endpoint discovery history, filters, tags, and results |
| Scan data | CLI SQLite (via API) | All scan data lives in the CLI, accessed via REST API |

The WEB does **not** duplicate CLI scan data into PostgreSQL. It reads autonomous scan data from the CLI API in real time, while WEB-native records such as chat history, settings, analysis reports, and API Discovery history remain in PostgreSQL.

See [Dual Database System](/dual-database-system) for the complete data architecture.

---

## Deployment

### Docker (Production)

```bash
cd BugTraceAI-WEB
docker compose up -d
# Frontend: http://localhost:6869
# CLI API proxied via /cli-api/ (no CORS issues)
```

The Nginx configuration includes a reverse proxy that routes `/cli-api/` requests to the CLI FastAPI server, including WebSocket upgrade for real-time scan events. This eliminates CORS issues in Docker deployments.

### Development Mode

```bash
cd BugTraceAI-WEB
npm install
npm run dev
# Frontend: http://localhost:5173
```

### Backend

```bash
cd BugTraceAI-WEB/backend
npm install
npx prisma migrate deploy
npm start
# Backend: http://localhost:3001
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `VITE_CLI_API_URL` | URL of the CLI API server (e.g., `http://localhost:8000`) |
| `DATABASE_URL` | PostgreSQL connection string |

In full deployment mode via the [BugTraceAI-Launcher](/bugtraceai-launcher), these are auto-configured.

---

## Connecting to CLI

The WEB dashboard connects to the CLI API server to manage scans. The CLI URL is configured via `VITE_CLI_API_URL`.

### Connection States

| State | Description |
|-------|-------------|
| **Connected** | CLI API reachable, scan management available |
| **Disconnected** | CLI API unreachable, toolkit tools still functional |
| **Reconnecting** | Attempting to re-establish connection |

When disconnected from the CLI, the WEB continues to function with its own security toolkit tools. Scan management features are unavailable until the connection is restored.

---

## Sub-Pages

| Page | Description |
|------|-------------|
| [Security Toolkit](/security-toolkit) | Detailed listing of all 20+ AI-powered security tools |
| [Real-time Scan Monitoring](/real-time-scan-monitoring) | WebSocket-based live scan progress and findings |

---

**See also**: [Architecture](/architecture) | [Dual Database System](/dual-database-system) | [BugTraceAI-CLI](/bugtraceai-cli)
