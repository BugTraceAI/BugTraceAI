---
title: "BugTraceAI-Launcher"
---

# BugTraceAI-Launcher

BugTraceAI-Launcher is the supported one-command Docker deployment wizard for BugTraceAI. It installs the selected components, manages their lifecycle, generates their environment files with restrictive permissions, and keeps the integration topology consistent.

**Repository**: [github.com/BugTraceAI/BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher)
**Current release**: `v2.9.2`

---

## Quick start

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

The wizard checks dependencies, asks for a deployment mode and provider, selects available ports interactively, clones or updates the required public repositories, writes service-scoped configuration, builds containers, runs health checks, and displays the resulting access addresses.

## Deployment modes

| Mode | Installed components | Best for |
|---|---|---|
| **Full Platform** | WEB + CLI + API + CLI MCP | Complete visual and autonomous security workflow |
| **Standalone WEB** | WEB + API | Security toolkit and visual API-security workflow without CLI scanning |
| **Standalone CLI** | CLI + CLI MCP | Headless REST, WebSocket, MCP, CI/CD, and scripted scan work |

There is no separate API-only wizard option: use the [BugTraceAI-API](https://github.com/BugTraceAI/BugTraceAI-API) Compose deployment for that independent service. There is also no separate CLI-plus-MCP mode; the CLI deployment includes its MCP service.

## Ports are selected, never assumed

The Launcher proposes free ports and asks the operator to confirm or change every externally exposed listener. It writes the selections to deployment state and injects them into the right Compose and Nginx environments.

| Variable | Service |
|---|---|
| `WEB_PORT` | Browser-facing WEB frontend |
| `CLI_PORT` | CLI REST and WebSocket API |
| `MCP_PORT` | CLI MCP endpoint |
| `BTAI_PORT` | BugTraceAI-API REST endpoint |
| `BTAI_MCP_PORT` | BugTraceAI-API MCP endpoint |

Scripts, automation, reverse proxies, and documentation should use the displayed endpoint or these generated variables—not a numeric port constant. The Launcher preserves the values in `.launcher-state` so `status`, `start`, `stop`, `logs`, and `update` operate on the deployed topology.

## API and WEB integration

For Full Platform and Standalone WEB deployments, the Launcher:

1. Clones and configures BugTraceAI-API.
2. Creates the shared Docker network named by `BTAI_SHARED_NETWORK`.
3. Starts API before WEB so the proxy target is ready during frontend startup.
4. Writes the selected API REST port into WEB's generated environment.
5. Lets Nginx route browser requests from `/btai-api/` to the API service by Docker service name.
6. Checks direct API health as well as WEB-to-API and WEB-to-CLI proxy paths where those components are enabled.

This keeps the browser same-origin and removes the need to hard-code API or CLI host ports in WEB.

## Core features

| Feature | Description |
|---|---|
| **Interactive setup** | Dependency checks, provider selection, deployment mode, port selection, and access summary |
| **Shared networking** | Connects enabled services with a named Docker network and service aliases |
| **Generated configuration** | Writes scoped `.env` / `.env.docker` files with restrictive file permissions |
| **Lifecycle commands** | Start, stop, restart, update, uninstall, status, and service logs |
| **Health checks** | Validates the enabled services and proxy paths after startup |
| **Release awareness** | Checks the published component releases and notifies users when an installed version is behind |
| **AI Setup & Repair Assistant** | Optional guided install or diagnosis/repair workflow with confirmations for destructive actions |

The AI Setup & Repair Assistant can run with the supported OpenRouter or Anthropic paths configured by the wizard. It is optional; normal installation does not require it.

## Commands

| Command | Description |
|---|---|
| `./launcher.sh` | Run the interactive setup wizard |
| `./launcher.sh status` | Show deployed service status and configured endpoints |
| `./launcher.sh start` | Start enabled services from saved state |
| `./launcher.sh stop` | Stop enabled services |
| `./launcher.sh restart` | Restart enabled services |
| `./launcher.sh update` | Pull/rebuild enabled components and restart them |
| `./launcher.sh logs` | Follow logs from the deployment |
| `./launcher.sh logs api` | Follow BugTraceAI-API logs |
| `./launcher.sh uninstall` | Remove the deployment after confirmation |

## Security and operations

- Treat generated environment files as secrets. Provider credentials are scoped to their service and must not be committed.
- Keep API and MCP services on a trusted management network. Add TLS and authentication at a reverse proxy before providing remote access.
- Use `status` and `logs` after updates; the health checks catch connectivity issues between enabled services.
- The update notifier is advisory. Review release notes before changing a production deployment.

**See also**: [Deployment Modes](/deployment-modes) | [Architecture](/architecture) | [BugTraceAI-API](/bugtraceai-api) | [BugTraceAI-WEB](/bugtraceai-web)
