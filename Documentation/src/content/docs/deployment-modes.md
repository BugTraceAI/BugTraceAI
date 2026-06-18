---
title: Deployment Modes
---

# Deployment Modes

The [[BugTraceAI-Launcher]] supports three deployment modes, each targeting different use cases. This page describes each mode in detail, including what services are deployed, how they communicate, and when to use each one.

---

## Mode Comparison

| Feature | Full Platform | Standalone WEB | Standalone CLI |
|---------|:------------:|:--------------:|:--------------:|
| WEB Dashboard | Yes | Yes | No |
| CLI Scanner | Yes | No | Yes |
| MCP for AI Assistants | Yes | No | Yes |
| Real-time Monitoring | Yes | No | N/A |
| Security Toolkit (20+ tools) | Yes | Yes | No |
| Active Scanning | Yes | No | Yes |
| REST API | Yes | No | Yes |
| PostgreSQL | Yes | Yes | No |
| CI/CD Integration | Yes | No | Yes |
| Auto-connected | Yes | N/A | N/A |

> The MCP server (`bugtrace_mcp`, port 8001) ships with the CLI container, so it is available in both **Full Platform** and **Standalone CLI** — there is no separate "CLI + AI Assistant" deployment mode.

---

## Full Platform

**Command**: `./launcher.sh` then select "Full Platform"

### Description

Deploys both WEB and CLI, automatically configures the connection between them, and starts all supporting services. This is the recommended mode for most users.

### Services

| Service | Port | Container | Description |
|---------|------|-----------|-------------|
| CLI FastAPI | 8000 | `btai-cli` | Scanning engine and REST API |
| WEB Frontend | 6869 | `btai-web` | React dashboard (Nginx) |
| WEB Backend | 3001 | `btai-backend` | Express API |
| PostgreSQL | 5432 (internal) | `btai-postgres` | WEB database |

### Auto-Configuration

The Launcher automatically sets:
- `VITE_CLI_API_URL=/cli-api` on the WEB frontend (proxied through Nginx)
- CORS headers on the CLI to allow requests from the WEB origin
- Docker networking for inter-container communication
- PostgreSQL credentials and database initialization

### Data Flow

```
User --> WEB Dashboard (:6869)
             |
             +-- REST API --> CLI (:8000) --> SQLite
             |
             +-- WebSocket --> CLI (:8000) --> Event Bus
             |
             +-- HTTP --> WEB Backend (:3001) --> PostgreSQL
```

In Docker deployments, the WEB frontend's Nginx reverse proxy routes `/cli-api/` to the CLI FastAPI server. This eliminates CORS issues and simplifies networking.

### Best For

- Complete pentesting platform
- Bug bounty workflows
- Security team deployments
- Users who want everything in one setup

---

## Standalone WEB

**Command**: `./launcher.sh` then select "Standalone WEB"

### Description

Deploys only the WEB dashboard with its backend and database. Provides access to the 20+ AI-powered security toolkit tools without active scanning capabilities.

### Services

| Service | Port | Container | Description |
|---------|------|-----------|-------------|
| WEB Frontend | 6869 | `btai-web` | React dashboard (Nginx) |
| WEB Backend | 3001 | `btai-backend` | Express API |
| PostgreSQL | 5432 (internal) | `btai-postgres` | WEB database |

### What You Get

- All 20+ security toolkit tools (JWT Analyzer, Payload Forge, Code Analyzer, etc.)
- Chat-based AI interaction for security analysis
- Persistent storage of analyses and conversations
- No CLI scanner, no active scanning, no vulnerability exploitation

### What You Do NOT Get

- No active scanning capability
- No real-time scan monitoring
- No vulnerability exploitation or validation
- No report generation from scans

### Best For

- AI-assisted security analysis only
- Code review and vulnerability research
- Learning security concepts
- Environments where active scanning is not permitted

---

## Standalone CLI

**Command**: `./launcher.sh` then select "Standalone CLI"

### Description

Deploys only the CLI scanning engine as a headless API server. Provides full scanning capability via REST API and WebSocket without any graphical interface.

### Services

| Service | Port | Container | Description |
|---------|------|-----------|-------------|
| CLI FastAPI | 8000 | `btai-cli` | Scanning engine and REST API |

### What You Get

- Complete autonomous scanning engine
- REST API for scan management
- WebSocket for real-time event streaming
- All specialist agents and Go fuzzers
- Browser-based validation (Playwright)
- Report generation (HTML, JSON, Markdown)
- SQLite persistence

### What You Do NOT Get

- No graphical dashboard
- No security toolkit tools
- No chat-based AI interaction
- No PostgreSQL

### API Access

```bash
# Start a scan
curl -X POST http://localhost:8000/api/scans \
  -H "Content-Type: application/json" \
  -d '{"target_url": "https://example.com"}'

# Check status
curl http://localhost:8000/api/scans/{id}/status

# Download report
curl http://localhost:8000/api/scans/{id}/report/json > report.json
```

### Best For

- CI/CD pipeline integration
- Scripted and automated scanning
- Headless server environments
- API-only access
- Integration with custom dashboards or tools

---

## AI Assistant Control (built into the CLI)

**Command**: `./launcher.sh` then select **Standalone CLI** (or **Full Platform**) — no separate selection is needed.

### Description

The CLI container always starts an MCP (Model Context Protocol) server alongside the scanning engine, so every CLI deployment can be controlled from an AI assistant like [OpenClaw](https://openclaw.com), Claude Code, Cursor, or any MCP-compatible client. This is not a distinct deployment mode — it is a capability included with the CLI.

### Services

| Service | Port | Container | Description |
|---------|------|-----------|-------------|
| CLI FastAPI | 8000 | `bugtrace_api` | Scanning engine and REST API |
| MCP Server | 8001 | `bugtrace_mcp` | SSE transport for AI assistants |

### What You Get

- Complete autonomous scanning engine
- REST API for scan management
- **MCP tools accessible from AI assistants** (start scans, check status, get findings, export reports)
- All specialist agents and Go fuzzers
- Browser-based validation (Playwright)
- Report generation (HTML, JSON, Markdown)
- SQLite persistence

### What You Do NOT Get

- No graphical dashboard
- No security toolkit tools
- No PostgreSQL

### MCP Configuration

After deployment, add BugTraceAI to your AI assistant's MCP configuration:

```json
{
  "mcpServers": {
    "bugtraceai": {
      "baseUrl": "http://localhost:8001/sse",
      "description": "BugTraceAI Security Scanner"
    }
  }
}
```

### Best For

- **AI-driven security testing** via Telegram (OpenClaw), terminal (Claude Code), or IDE (Cursor)
- Users who prefer chat-based interfaces over dashboards
- Automated scanning controlled by AI agents
- Integration with AI workflows and assistants

See [[AI Assistant Integration]] for full setup instructions and available MCP tools.

---

## Choosing a Mode

```
Do you need a graphical dashboard?
  |
  +-- No --> Do you need active scanning?
  |            |
  |            +-- Yes --> Standalone CLI   (includes the MCP server for AI-assistant control)
  |            +-- No  --> (You may not need BugTraceAI)
  |
  +-- Yes --> Do you need active scanning?
               |
               +-- Yes --> Full Platform
               +-- No  --> Standalone WEB
```

---

## Switching Modes

You can switch between modes by stopping the current deployment and running the Launcher wizard again:

```bash
./launcher.sh stop
./launcher.sh
# Select a different mode
```

Data is preserved between mode switches:
- PostgreSQL data persists in Docker volumes
- SQLite data persists in the CLI container volume
- Configuration is regenerated for the new mode

---

## Manual Deployment

If you prefer to deploy without the Launcher, each component can be deployed independently:

### Manual CLI Deployment

```bash
cd BugTraceAI-CLI
docker build -t bugtrace-cli .
docker run -d -p 8000:8000 --name btai-cli bugtrace-cli
```

### Manual WEB Deployment

```bash
cd BugTraceAI-WEB
docker build -t bugtrace-web .
docker run -d -p 6869:6869 --name btai-web bugtrace-web
```

### Manual Full Stack

See the Docker Compose configuration examples in the [[Architecture]] page.

---

## Production Considerations

For production deployments:

| Concern | Recommendation |
|---------|---------------|
| **SSL/TLS** | Place Nginx reverse proxy with Let's Encrypt in front |
| **Firewall** | Allow only ports 6869 and 8000 externally |
| **Backups** | Schedule regular PostgreSQL and SQLite backups |
| **Updates** | Use `./launcher.sh update` for rolling updates |
| **Monitoring** | Use `./launcher.sh status` and `./launcher.sh logs` |
| **Resources** | 8 GB RAM recommended for Full Platform mode |

---

**Parent**: [[BugTraceAI-Launcher]]

**See also**: [[Architecture]] | [[Getting Started]] | [[BugTraceAI-CLI]] | [[BugTraceAI-WEB]]
