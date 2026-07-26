---
title: "BugTraceAI-WEB"
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
| **Vite** | 5 | Build tool and dev server |
| **TailwindCSS** | -- | Utility-first CSS styling |
| **Express** | -- | Backend HTTP server |
| **Prisma** | -- | Type-safe ORM for PostgreSQL |
| **PostgreSQL** | 16 | Persistent storage for WEB data |
| **Nginx** | -- | Production static file serving and reverse proxy |
| **Docker** | -- | Containerized deployment |

---

## Features

### What's New in v1.5.40-beta

Highlights across the v1.5.x line:

- **AIrepeater** (1.5.23) - a Burp/Caido-style HTTP request workbench with multiple tabs, manual and agent-driven exploit modes, response search, per-vulnerability playbooks, and one-click report handoff. The exploit-model picker is provider-aware and the auto-auth macro has a dry-run "test" button.
- **Live Swarm Graph** (1.5.23) - a real-time visualization of the scan pipeline across reconnaissance, strategy, specialist, validation, and reporting stages. Per-specialist **L1->L6 escalation ladders** climb live as each agent escalates (1.5.39), and the AuthDiscovery node shows its live status.
- **Model Lab** (1.5.23 -> 1.5.40) - an integrated model-comparison module at `/modellab` with its **own** OpenRouter API key. It runs quick and advanced benchmark suites (now the recalibrated **quick-v3 / advanced-v2**), streams live WebSocket progress, supports cancellation and cost visibility, keeps local run history, and recommends the best model **per scanner slot** (MUTATION / SKEPTICAL / ANALYSIS / REPORTING) with an opt-in MUTATION diversity probe. A "Test key" button validates the key before a run.
- **Anthropic chat provider** (1.5.33) - Anthropic (Claude Messages API) is selectable alongside OpenRouter and Z.ai. Enter an `sk-ant-...` key, pick a Claude model, and Test/Save from Settings; chat, analysis, and the Repeater all work on Claude with tool-calling normalized to the shared shape.
- **Curated model pack + Thinking control** (1.5.34) - the OpenRouter model picker loads a hand-picked, verified set instead of the full live catalog, and **Thinking / High / xHigh** entries send the same model with OpenRouter's reasoning parameter enabled.
- **AuthDiscovery visibility** (1.5.27) - scan events now show AuthDiscovery start, per-URL progress, and result totals, with live status on the Swarm Graph.

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
| [AIrepeater](/airepeater) | Burp/Caido-style HTTP request workbench with manual and agent-driven modes |
| [Model Lab](/model-lab) | Integrated model benchmarking with per-scanner-slot leaderboards |
| [Swarm Graph](/swarm-graph) | Real-time visualization of the multi-agent scan pipeline |

---

**See also**: [Architecture](/architecture) | [Dual Database System](/dual-database-system) | [BugTraceAI-CLI](/bugtraceai-cli) | [AIrepeater](/airepeater) | [Model Lab](/model-lab) | [Swarm Graph](/swarm-graph)
