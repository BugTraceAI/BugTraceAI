---
title: "BugTraceAI-WEB"
---

# BugTraceAI-WEB

BugTraceAI-WEB is the visual security workspace for the BugTraceAI ecosystem. It combines the security toolkit, live scan console, report review, AIrepeater, Model Lab, and the BugTraceAI-API Connector in one browser interface.

**Repository**: [github.com/BugTraceAI/BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB)
**Current release**: `v2.0.24-beta`

---

## What changed in the 2.0 release

### API Connector

The API Connector is a typed client for [BugTraceAI-API](/bugtraceai-api). From WEB, an authorized user can start API scans, follow their status, inspect results and findings, retrieve OpenAPI and handoff artifacts, download reports, check health, and manage providers.

In a Launcher deployment the connector uses the same-origin `/btai-api` path. Nginx receives the Launcher-selected API REST port at startup and proxies over the shared Docker network. For a separately deployed service, the connector URL is editable in WEB settings. No browser bundle assumes a fixed API host port.

### Refined visual language

The public visual system is now inspectable at `/design-system` (and under the base path as `/bugtraceai/design-system`). It is a state-free reference for the interface's colors, typography, interactive states, panels, and reusable component patterns.

The scan experience is more legible during long-running work:

- The **Live Swarm Graph** shows reconnaissance, strategy, specialists, validation, and reporting as one live flow.
- Specialist **L1–L6 escalation ladders** advance while an agent is still working rather than only after confirmation.
- **AuthDiscovery** progress and totals appear in the event stream and graph.
- API report rows separate the review state from the meaningful category, avoiding repeated review prefixes in finding names.

### AIrepeater workbench

AIrepeater is a three-pane Request / Response / AI Agent workbench for controlled HTTP testing. It has tabs, response search, per-vulnerability playbooks, report handoff, manual and agent-assisted modes, provider-aware model selection, and a dry-run test for the auto-auth macro.

### Model Lab as a workspace

Model Lab is now a top-level `/modellab` sidebar module rather than a sub-tab. It keeps an independent OpenRouter key, offers calibrated quick and advanced suites, provides live progress, cost visibility, cancellation and recovery, local history, a per-slot leaderboard, and an opt-in MUTATION diversity probe. See [Model Lab](/model-lab).

## Architecture

```
Browser
  |
  v
BugTraceAI-WEB frontend (Nginx)
  |-- /api/       --> WEB backend --> PostgreSQL (WEB-local data)
  |-- /cli-api/   --> BugTraceAI-CLI (when installed)
  '-- /btai-api/  --> BugTraceAI-API (when installed)
```

The Launcher selects the browser-facing `WEB_PORT` and injects the selected `CLI_PORT` and `BTAI_PORT` into the Compose/Nginx configuration. The browser uses same-origin paths, so deployment-specific service ports are never hard-coded into the frontend.

| Data | System of record |
|---|---|
| Chat history, settings, WEB-native analysis reports | WEB PostgreSQL |
| Autonomous scans, CLI findings, CLI reports | CLI SQLite and LanceDB |
| API scan artifacts, evidence, report archives | API mounted report storage |

WEB presents these sources but does not silently merge their databases.

## Security toolkit and scan management

WEB includes 20+ AI-powered security analysis tools that work even when a CLI scanner is not installed. When the CLI is present, the dashboard adds scan creation, authenticated scan configuration, resume controls, live progress, findings, and report downloads.

The API Connector is separate from CLI scan management: it operates BugTraceAI-API's evidence-first API workflow and retains its distinct report artifacts and provenance.

## Deployment

### Launcher deployment

Use the [BugTraceAI-Launcher](/bugtraceai-launcher) for the supported Docker topology. It generates service-specific environment files, creates the shared network, chooses available ports interactively, starts API before WEB where needed, and validates health through both direct and proxied routes.

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

Choose **Full Platform** for WEB + CLI + API or **Standalone WEB** for WEB + API without the CLI scanner.

### Direct WEB deployment

For a direct deployment, use the WEB repository's Compose configuration and provide the selected endpoints in its environment. The relevant connector variables are:

| Variable | Purpose |
|---|---|
| `VITE_CLI_API_URL` | CLI route or explicit CLI API address |
| `CLI_API_PORT` | CLI service port supplied to the Nginx template in a Launcher deployment |
| `VITE_BTAI_API_URL` | API Connector route or explicit API address |
| `BTAI_API_PORT` | API REST port supplied to the Nginx template in a Launcher deployment |
| `BTAI_SHARED_NETWORK` | Docker network shared with API and CLI services |
| `DATABASE_URL` | WEB PostgreSQL connection string |

The exact port values are operator choices. Use the values generated by the Launcher or set all related Compose variables consistently for a manual deployment.

## Connection states

The WEB workspace can remain useful when an optional connected service is unavailable:

| Service state | Available experience |
|---|---|
| CLI connected | Scan management, live monitoring, CLI reports, and Model Lab backend |
| API connected | API Connector scans, artifacts, reports, health, and provider management |
| CLI unavailable | Security toolkit and WEB-local data remain available; CLI scan controls are unavailable |
| API unavailable | WEB and CLI features remain available; API Connector actions show the service state |

## Further reading

| Page | Description |
|---|---|
| [Security Toolkit](/security-toolkit) | The standalone AI-powered tools |
| [AIrepeater](/airepeater) | Controlled HTTP request workbench |
| [Live Swarm Graph](/swarm-graph) | Real-time multi-agent visualization |
| [Model Lab](/model-lab) | Per-slot model benchmarking |
| [Real-time Scan Monitoring](/real-time-scan-monitoring) | CLI event stream and scan console |
| [BugTraceAI-API](/bugtraceai-api) | API Connector service and security boundary |

**See also**: [Architecture](/architecture) | [Deployment Modes](/deployment-modes) | [BugTraceAI-Launcher](/bugtraceai-launcher) | [BugTraceAI-CLI](/bugtraceai-cli)
