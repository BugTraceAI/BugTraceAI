---
title: "BugTraceAI-API"
description: "Evidence-first API security testing over REST and MCP."
---

# BugTraceAI-API

BugTraceAI-API is the standalone API-security service in the BugTraceAI ecosystem. It discovers authorized API routes, resolves OpenAPI contracts, runs controlled checks, correlates evidence, investigates bounded hypotheses, and writes portable reports.

**Repository**: [github.com/BugTraceAI/BugTraceAI-API](https://github.com/BugTraceAI/BugTraceAI-API)
**Current release**: `v1.4.4-beta`

---

## When to use it

Use BugTraceAI-API when the target is an API or when an automation system needs a durable, evidence-rich API-testing workflow. It works without BugTraceAI-WEB or BugTraceAI-CLI:

- REST clients and CI/CD jobs can start and monitor scans programmatically.
- MCP clients can use the same capability from an AI-assistant workflow.
- The WEB API Connector offers a visual client for scans, results, OpenAPI documents, handoff packs, provider configuration, and downloads.
- A redacted API-to-CLI handoff pack is available when an API finding should become part of a broader authorized CLI workflow.

The handoff is optional. API, WEB, and CLI services do not have to be deployed together.

## Evidence model

The service deliberately separates confirmed evidence from suspicious, hardening, and insufficient-evidence states. A tool execution or unusual response alone is not represented as proof of a vulnerability. Each durable scan directory keeps its configuration, phase artifacts, normalized findings, investigation state, and final reports.

## REST and MCP interfaces

The canonical schema is available from the service's Swagger UI and `/openapi.json` on the REST address selected at deployment.

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/health` | Service, version, and active-provider health |
| `POST` | `/api/scan` | Start an authorized API scan |
| `GET` | `/api/scan/{scan_id}` | Read status and live phase progress |
| `GET` | `/api/scan/{scan_id}/results` | Read normalized results |
| `GET` | `/api/scans` | List durable scans |
| `GET` | `/api/scan/{scan_id}/openapi` | Download the resolved or generated contract |
| `GET` | `/api/scan/{scan_id}/handoff` | Retrieve the redacted CLI handoff pack |
| `GET` | `/api/scan/{scan_id}/report-zip` | Download the complete durable report archive |
| `POST` | `/api/investigate` | Run a bounded investigation over an existing scan |
| `GET` / `PUT` | `/api/provider` | Read or select the active provider without returning secrets |

On the separately selected MCP address, Streamable HTTP is available at `/mcp` (with legacy SSE fallback for compatible clients). The exposed tools are `api_scan`, `get_scan_status`, `get_results`, `stop_scan`, and `investigate_api`.

## Deployment and ports

The [BugTraceAI-Launcher](/bugtraceai-launcher) installs the API with both **Full Platform** and **Standalone WEB** modes. During setup it asks for the REST and MCP ports, stores the choices as `BTAI_PORT` and `BTAI_MCP_PORT`, and propagates the REST port to the WEB reverse proxy over the shared Docker network.

Do not depend on a numeric default in automation or documentation. Use the endpoint printed by the Launcher, the saved deployment state, or explicit environment variables instead:

```bash
curl "http://localhost:${BTAI_PORT}/health"
curl "http://localhost:${BTAI_PORT}/docs"
```

For an independent Docker deployment, copy the supplied environment example, set `API_PORT` and `MCP_PORT` to the ports you chose, then run `docker compose up -d --build`. The API image does not impose listener or host-port values.

## WEB API Connector

The WEB dashboard uses `/btai-api` as its same-origin connector route in a Launcher deployment. Nginx substitutes the selected API REST port at container start, so the browser never needs a fixed host port. For separate deployments, choose an explicit API Connector URL in the WEB settings.

The connector supports starting scans, status polling, results and finding review, OpenAPI and handoff artifacts, report downloads, service health, and provider management. It is a client of BugTraceAI-API; it does not merge API report storage into the WEB database.

## Providers, data, and security boundary

OpenRouter, Anthropic, Z.ai, and local Ollama profiles are available for investigation and evidence review. Provider credentials are local deployment secrets and must never be committed.

BugTraceAI-API has no built-in user authentication or tenant isolation. Keep it on a trusted management network. If remote access is required, restrict the Launcher-selected REST/MCP ports and put TLS plus authentication at a reverse proxy. Reports can contain sensitive endpoint names, response excerpts, and security evidence.

## Further reading

- [BugTraceAI-API README](https://github.com/BugTraceAI/BugTraceAI-API#readme) — complete request examples, authentication shapes, and report artifacts
- [BugTraceAI-API DeepWiki](https://deepwiki.com/BugTraceAI/BugTraceAI-API) — AI-powered codebase documentation and architecture exploration
- [Architecture](/architecture) — how WEB, API, CLI, and Launcher connect
- [Deployment Modes](/deployment-modes) — what the Launcher installs in each mode
- [BugTraceAI-WEB](/bugtraceai-web) — API Connector, visual workspace, and Model Lab
