---
title: "Getting Started"
---

# Getting Started

This guide installs the supported BugTraceAI topology, explains where the selected endpoints come from, and starts an authorized first workflow.

> Only test systems you own or have explicit written authorization to assess.

## Requirements

| Requirement | Minimum | Recommended |
|---|---|---|
| Docker Engine + Compose | Current supported release | Latest stable |
| Git | Recent version | Latest stable |
| Memory | 4 GB | 8 GB or more |
| Disk | 10 GB | 20 GB+ SSD |
| AI provider | One configured provider when AI review is needed | OpenRouter, Anthropic, Z.ai, or local Ollama as appropriate |

The Launcher validates the local prerequisites and asks for the provider configuration relevant to the selected deployment.

## Install with the Launcher

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

Choose one of these modes:

| Mode | Installed services |
|---|---|
| Full Platform | WEB + CLI + API + CLI MCP |
| Standalone WEB | WEB + API |
| Standalone CLI | CLI + CLI MCP |

During setup, choose the browser, CLI REST, CLI MCP, API REST, and API MCP ports that are available on your machine. When setup completes, copy the access addresses printed by the Launcher. They are stored in deployment state and are deliberately not fixed by this documentation.

Use `./launcher.sh status` at any time to see the configured endpoints and health.

## First workflow in WEB

1. Open the WEB address shown by the Launcher.
2. For an autonomous target scan, configure the CLI connection and open the scan console.
3. For an API-security workflow, open **API Connector**, set a direct API URL only if it is not the Launcher deployment, and create an authorized API scan.
4. Follow progress, review evidence, and download the generated artifact from the appropriate report view.

The security toolkit, AIrepeater, and existing WEB-local history remain usable when the CLI service is not installed. The API Connector works in Full Platform and Standalone WEB deployments.

## First API-security scan

Use the API address shown by the Launcher (or your selected direct deployment address). Export it rather than writing a numeric port into a script:

```bash
export BTAI_BASE_URL="http://localhost:${BTAI_PORT}"

curl -sS -X POST "$BTAI_BASE_URL/api/scan" \
  -H 'Content-Type: application/json' \
  -d '{
    "target_url": "https://api.example.test",
    "mode": "safe"
  }'
```

Poll the opaque scan identifier returned by the request:

```bash
curl -sS "$BTAI_BASE_URL/api/scan/<scan_id>"
curl -sS "$BTAI_BASE_URL/api/scan/<scan_id>/results"
curl -OJ "$BTAI_BASE_URL/api/scan/<scan_id>/report-zip"
```

For an OpenAPI contract or authorized authentication shapes, see [BugTraceAI-API](/bugtraceai-api) and its [repository README](https://github.com/BugTraceAI/BugTraceAI-API#readme).

## First CLI scan

Use the CLI REST address reported by the Launcher or your direct deployment. Keep it in a variable so scripts follow the selected port:

```bash
export CLI_BASE_URL="http://localhost:${CLI_PORT}"

curl -sS -X POST "$CLI_BASE_URL/api/scans" \
  -H 'Content-Type: application/json' \
  -d '{"target_url":"https://your-authorized-target.example"}'
```

The CLI API reference documents scan status, findings, reports, provider selection, Model Lab, and WebSocket endpoints. Use the schema served by your actual CLI deployment as the contract.

## Direct API deployment

BugTraceAI-API is also independently deployable:

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-API.git
cd BugTraceAI-API
cp .env.example .env
# Set API_PORT and MCP_PORT to the ports you selected.
docker compose up -d --build
```

Check the health and interactive schema on the selected REST address. API reports are kept under the mounted `reports/` directory; protect them as security-sensitive artifacts.

## Lifecycle commands

```bash
./launcher.sh status
./launcher.sh logs
./launcher.sh logs api
./launcher.sh stop
./launcher.sh start
./launcher.sh update
```

The Launcher checks public releases and reports when a deployed component has an update available. Review the release notes before updating a production installation.

## Troubleshooting

### A selected port is unavailable

Rerun the wizard and choose another available port. Do not edit only one service in isolation: the Launcher propagates the relevant selections to Compose, Nginx, and health checks.

### WEB cannot reach a connected service

1. Run `./launcher.sh status` and inspect the configured endpoints.
2. Use `./launcher.sh logs api`, `./launcher.sh logs cli`, or `./launcher.sh logs web`.
3. Verify the generated network and environment files belong to the same deployment.
4. For direct deployments, configure the explicit Connector or CLI URL and apply normal CORS/TLS controls.

### Provider or report security

Never paste provider credentials into source files or commit generated `.env` files. Keep API evidence archives and CLI reports on a trusted machine or protected network.

## Next steps

- [Architecture](/architecture) — component boundaries and data flows
- [Deployment Modes](/deployment-modes) — choose the right topology
- [BugTraceAI-API](/bugtraceai-api) — API REST/MCP service and report artifacts
- [BugTraceAI-WEB](/bugtraceai-web) — API Connector, Model Lab, and visual workspace
- [CLI API Reference](/api-reference) — CLI REST, WebSocket, and Model Lab endpoints
