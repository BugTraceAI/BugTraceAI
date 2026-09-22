---
title: "Architecture"
---

# Architecture

BugTraceAI is a modular, self-hosted ecosystem. The services can run independently, while the Launcher composes the supported combinations with a shared Docker network and deployment-specific configuration.

---

## System overview

```
                          authorised REST / MCP clients
                                       |
                                       v
                  +---------------- BugTraceAI-API ----------------+
                  | contract-aware API checks, evidence, reports    |
                  +-----------------+-------------------------------+
                                    | optional handoff / WEB client
                                    v
+---------------------+       +-----+---------------------+
| BugTraceAI-WEB      |<----->| BugTraceAI-CLI            |
| visual workspace    | REST, | autonomous scan engine    |
| API Connector       | WS    | REST, WebSocket, MCP      |
| Model Lab           |       | SQLite, LanceDB, browser  |
+---------------------+       +---------------------------+
          |
          +--> Express + PostgreSQL for WEB-local data
```

- **BugTraceAI-API** is an independent, evidence-first service for API-security workflows over REST and MCP.
- **BugTraceAI-CLI** is the autonomous scanning engine for broader target reconnaissance, specialist testing, validation, and reporting.
- **BugTraceAI-WEB** is the visual workspace: security tools, scan visibility, AIrepeater, Model Lab, report review, and the API Connector.
- **BugTraceAI-Launcher** selects the externally exposed ports, generates the environment files, and connects enabled services over a named Docker network.

## Component stacks

### BugTraceAI-API

| Layer | Technology | Purpose |
|---|---|---|
| **REST server** | FastAPI | Scan lifecycle, artifacts, health, provider management, OpenAPI schema |
| **MCP server** | Streamable HTTP with compatible SSE fallback | AI-assistant control of API scans |
| **Engine** | Python + packaged security tools | Route discovery, contract resolution, controlled checks, investigation |
| **Storage** | Mounted `reports/` and `config/` | Durable evidence, report archives, provider configuration |

The API service exposes its REST and MCP listeners through the Launcher-selected `BTAI_PORT` and `BTAI_MCP_PORT` values. Its report storage remains distinct from both the CLI database and WEB database.

### BugTraceAI-CLI

| Layer | Technology | Purpose |
|---|---|---|
| **API server** | FastAPI | REST API and WebSocket event stream |
| **MCP server** | HTTP transport | AI-assistant control of CLI scans |
| **Database** | SQLite | Source of truth for CLI scans, findings, and reports |
| **Vector store** | LanceDB | Semantic search over findings |
| **Fuzzers** | Go binaries | High-speed XSS, SSRF, IDOR, and LFI fuzzing |
| **Browser** | Playwright + Chromium | CDP validation, DOM analysis, and screenshot evidence |

The Launcher exports the chosen CLI REST and MCP values as `CLI_PORT` and `MCP_PORT`. Direct deployments must supply their own ports; no client should assume a fixed listener.

### BugTraceAI-WEB

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | React + TypeScript + Vite | Dashboard, security toolkit, Model Lab, reports, API Connector |
| **Backend** | Express + TypeScript | WEB-local data and integration helpers |
| **Data** | Prisma + PostgreSQL | Chats, settings, and WEB-native analysis reports |
| **Proxy** | Nginx | Same-origin routes to enabled API and CLI services |

The browser-facing WEB address is selected by the Launcher as `WEB_PORT`. The proxy maps `/cli-api/` and `/btai-api/` to the selected services over the shared Docker network, avoiding browser-side assumptions about host ports.

### BugTraceAI-Launcher

| Layer | Technology | Purpose |
|---|---|---|
| **Wizard** | Bash | Deployment selection, dependency checks, and interactive port choice |
| **Orchestration** | Docker Compose | Builds, starts, stops, logs, and updates enabled services |
| **Configuration** | Generated environment files | Keeps selected endpoints and secrets scoped to their service |
| **Health and updates** | HTTP checks + GitHub releases | Confirms readiness and notifies users of newer public releases |

## Communication paths

### WEB to CLI

In a Launcher deployment, the WEB frontend uses its same-origin `/cli-api/` route. Nginx resolves that route to the CLI service on the shared Docker network using the selected `CLI_PORT`. REST controls scan lifecycle and WebSocket paths stream live progress.

```
Browser --> WEB /cli-api/ --> Nginx --> BugTraceAI-CLI --> SQLite / event stream
```

The CLI's OpenAPI schema and WebSocket details are documented in [CLI API Reference](/api-reference) and [WebSocket Events](/websocket-events).

### WEB to API

The API Connector uses `/btai-api/` in a Launcher deployment. Nginx receives `BTAI_API_PORT` from the generated WEB environment and proxies to BugTraceAI-API by service name on the shared network. A separately deployed API can instead be configured with an explicit Connector URL.

```
Browser --> WEB /btai-api/ --> Nginx --> BugTraceAI-API --> durable API reports
```

The connector supports scan creation, status polling, findings and results, OpenAPI and handoff artifacts, report downloads, health checks, and provider management. It does not copy API report storage into PostgreSQL.

### API and CLI interoperability

API scans always preserve `engine: api` and `launch_origin: api` provenance. The API may produce a redacted handoff pack for a downstream CLI process, but neither service needs the other to complete its own work.

## Data boundaries

| Store | Owner | Contains |
|---|---|---|
| **CLI SQLite + LanceDB** | BugTraceAI-CLI | CLI scan state, findings, reports, and search data |
| **WEB PostgreSQL** | BugTraceAI-WEB | Chats, settings, and WEB-native analysis records |
| **API mounted reports** | BugTraceAI-API | API scan configuration, phase artifacts, evidence, OpenAPI, handoff, and report archives |

The components exchange structured data through APIs and explicit artifacts, not by directly sharing their databases.

## Deployment topologies

### Full Platform

The Launcher installs WEB, CLI, API, and the configured CLI MCP server. WEB has same-origin routes for both backend services, while API and CLI retain separate data stores and evidence models.

### Standalone WEB

The Launcher installs WEB and BugTraceAI-API. The security toolkit, visual API workflow, report review, and Model Lab are available; CLI scan management is not installed in this mode.

### Standalone CLI

The Launcher installs the CLI and its MCP service. It is suitable for headless REST, WebSocket, MCP, CI/CD, and scripted work. The API service is available separately through its own Compose deployment when an API-security workflow is required.

## Port selection and isolation

Every externally exposed service port is selected during Launcher setup. The generated values are recorded in deployment state and propagated to Compose and Nginx at startup:

| Variable | Selected endpoint |
|---|---|
| `WEB_PORT` | Browser-facing WEB frontend |
| `CLI_PORT` | CLI REST and WebSocket service |
| `MCP_PORT` | CLI MCP service |
| `BTAI_PORT` | BugTraceAI-API REST service |
| `BTAI_MCP_PORT` | BugTraceAI-API MCP service |

Internal database and backend services remain on the Docker network unless the operator deliberately exposes them. For remote use, restrict access to the selected ports, use TLS and authentication at a reverse proxy, and never expose reports or provider credentials unintentionally.

## Security boundary

- Only test systems you own or have explicit written authorization to assess.
- BugTraceAI-API has no built-in tenant isolation or user authentication; it belongs on a trusted management network or behind an authenticated reverse proxy.
- Provider credentials and generated deployment environments are secrets. They must not be committed or published.
- Evidence reports can contain sensitive endpoint names, response excerpts, payloads, and screenshots; apply your normal retention and access controls.

**Sub-pages**: [CLI API Reference](/api-reference) | [BugTraceAI-API](/bugtraceai-api) | [Dual Database System](/dual-database-system) | [WebSocket Events](/websocket-events)

**See also**: [Deployment Modes](/deployment-modes) | [BugTraceAI-CLI](/bugtraceai-cli) | [BugTraceAI-WEB](/bugtraceai-web) | [BugTraceAI-Launcher](/bugtraceai-launcher)
