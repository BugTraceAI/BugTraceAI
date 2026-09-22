---
title: "Deployment Modes"
---

# Deployment Modes

The [BugTraceAI-Launcher](/bugtraceai-launcher) composes the components that fit the workflow you choose. It asks for every external listener during setup and stores those choices for subsequent lifecycle commands.

## Comparison

| Capability | Full Platform | Standalone WEB | Standalone CLI |
|---|:---:|:---:|:---:|
| WEB dashboard and security toolkit | Yes | Yes | No |
| BugTraceAI-API and API Connector | Yes | Yes | No |
| CLI autonomous scanner | Yes | No | Yes |
| CLI MCP for AI assistants | Yes | No | Yes |
| CLI live monitoring | Yes | No | N/A |
| Model Lab workspace | Yes | Available when a CLI endpoint is configured | No browser workspace |
| API report review and downloads | Yes | Yes | API service separate |
| CI/CD / scripted CLI workflow | Yes | API-focused only | Yes |

## Full Platform

Choose **BugTraceAI Web + CLI (Full Platform)** for the complete ecosystem:

- WEB frontend and its backend/database
- BugTraceAI-CLI plus its MCP service
- BugTraceAI-API plus its MCP service
- Shared Docker networking and same-origin WEB proxy routes

```
Browser --> WEB
            |-- /cli-api/  --> CLI REST / WebSocket --> CLI data
            '-- /btai-api/ --> API REST              --> API report storage
```

Use this mode when you want the visual workspace, autonomous CLI scans, API-security scans, live monitoring, and human review together. The API and CLI keep separate evidence stores and can be used independently even though WEB makes both available in one interface.

## Standalone WEB

Choose **Solo BugTraceAI WEB** when you need the visual tools and API-security workflow but do not want the CLI scanner installed.

It includes:

- WEB security toolkit, AIrepeater, report review, and design-system reference
- BugTraceAI-API and the WEB API Connector
- WEB-local PostgreSQL persistence
- API evidence reports, OpenAPI artifacts, handoff packs, and downloads

It does not include autonomous CLI scans, CLI WebSocket monitoring, or the CLI MCP service. Model Lab remains a WEB workspace, but its benchmark backend requires a configured CLI API endpoint.

## Standalone CLI

Choose **Solo BugTraceAI CLI** for headless automated scanning. It includes the CLI REST/WebSocket service, specialist engine, persistence, browser validation, and the CLI MCP service.

Use it for CI/CD jobs, scripts, or an MCP-compatible assistant. The selected endpoint values are shown when setup finishes; use those values in your client configuration rather than assuming a port.

For an independent API-security engine, deploy [BugTraceAI-API](/bugtraceai-api) separately with its own Compose configuration and selected REST/MCP ports.

## Ports and service discovery

The Launcher owns the deployed port mapping. It chooses and records:

| Variable | Endpoint |
|---|---|
| `WEB_PORT` | WEB browser address |
| `CLI_PORT` | CLI REST and WebSocket API |
| `MCP_PORT` | CLI MCP endpoint |
| `BTAI_PORT` | API REST endpoint |
| `BTAI_MCP_PORT` | API MCP endpoint |

In Full Platform and Standalone WEB mode, the browser accesses API through `/btai-api/`; the Nginx startup configuration substitutes `BTAI_API_PORT` and routes it internally. In Full Platform, `/cli-api/` works the same way for CLI. This avoids fixed browser-side host or port configuration.

## Switching modes

Stop the current deployment, run the wizard again, and select the new mode:

```bash
./launcher.sh stop
./launcher.sh
```

Keep backups before changing a production topology. WEB database volumes, CLI state, API reports, and generated configuration have separate lifecycles; verify what a change or uninstall command will affect before confirming it.

## Production boundary

- Expose only the endpoints that the operator intentionally selected for remote access.
- Keep databases and service-to-service traffic on the Docker network.
- Add TLS and authentication at a reverse proxy for any remote REST/MCP access.
- Apply your retention policy to CLI reports, API evidence archives, and WEB records.

**Parent**: [BugTraceAI-Launcher](/bugtraceai-launcher)

**See also**: [Architecture](/architecture) | [Getting Started](/getting-started) | [BugTraceAI-API](/bugtraceai-api) | [BugTraceAI-WEB](/bugtraceai-web) | [BugTraceAI-CLI](/bugtraceai-cli)
