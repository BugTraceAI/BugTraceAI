---
title: "Overview"
---

# Overview

BugTraceAI is the first opensource, self-hosted framework designed specifically for autonomous security scanning. It is **not** a wrapper around existing tools -- it is an autonomous multi-agent system where AI agents independently discover, analyze, exploit, and validate vulnerabilities with minimal human intervention.

---

## What BugTraceAI Is

BugTraceAI is a modular security platform composed of four operational components:

- **BugTraceAI-CLI**: The autonomous scanning engine. Python-based with Go high-speed fuzzers (XSS, SSRF, IDOR, LFI), Playwright Chromium for browser-based validation, and AI agents orchestrated via OpenRouter (default), Anthropic, or Z.ai providers. It can run headlessly behind a Launcher-selected REST/MCP interface or as an interactive CLI.

- **BugTraceAI-WEB**: A React dashboard with 20+ specialized AI-powered security tools, AIrepeater, a live Swarm Graph, Model Lab, and an API Connector. It connects to the CLI API for scan management and to BugTraceAI-API for API-security workflows. An Express + Prisma + PostgreSQL backend persists WEB-local data.

- **BugTraceAI-API**: A standalone, evidence-first API security-testing service. It accepts authorized REST and MCP jobs, resolves API contracts, preserves durable artifacts and can optionally hand results to the WEB workspace or CLI workflow.

- **BugTraceAI-Launcher**: A one-command Docker deployment wizard that handles dependency detection, interactive port selection, service configuration, shared Docker networking, updates, and lifecycle management.

---

## What BugTraceAI Is NOT

- Not a SaaS platform or cloud service
- Not a subscription product
- Not a wrapper around nmap, sqlmap, or nuclei
- Not a platform that stores your data on external servers
- Not a product that requires accounts or registration

---

## Key Differentiators

### Autonomous Multi-Agent System

Unlike tools that simply run predefined checks, BugTraceAI employs AI agents that:

- **Discover** attack surface through intelligent crawling and spidering
- **Analyze** findings using multi-persona AI with consensus voting
- **Exploit** vulnerabilities with specialized agents for each vulnerability class
- **Validate** results using headless Chromium (CDP) and Vision AI screenshot analysis

Each agent operates independently, consuming from its own task queue, making intelligent decisions about payload mutation and context-driven pruning.

### Go High-Speed Fuzzers

Purpose-built Go binaries handle high-throughput fuzzing for:
- XSS payload injection
- SSRF endpoint probing
- IDOR parameter enumeration
- LFI path traversal

These run alongside the Python AI agents, combining speed with intelligence.

### Browser-Based Validation

Playwright Chromium provides real browser execution for:
- DOM-based XSS confirmation
- JavaScript behavior analysis
- Visual screenshot capture for Vision AI analysis
- Full CDP (Chrome DevTools Protocol) integration

---

## Target Audience

| Audience | Use Case |
|----------|----------|
| **Penetration Testers** | Autonomous scanning during engagements, report generation |
| **Security Teams** | Continuous security assessment, CI/CD integration |
| **Bug Bounty Hunters** | Automated recon and exploitation, finding edge cases |
| **CI/CD Pipelines** | Headless API-driven scanning with programmatic access |
| **Security Researchers** | AI-assisted vulnerability analysis and hypothesis testing |

---

## Architecture at a Glance

```
          authorised REST / MCP clients
                      |
                      v
            BugTraceAI-API  <---->  BugTraceAI-CLI
             API evidence              autonomous scans
                   ^                         ^
                   |                         |
                   +------ BugTraceAI-WEB ---+
                    API Connector, reports, live scan console, Model Lab
```

- The **CLI** is the autonomous scanning engine and exposes a REST/WebSocket/MCP control surface
- The **API** is an independent API-security engine with its own REST/MCP surface and durable evidence artifacts
- The **WEB** dashboard connects to the CLI for management and monitoring, and to the API through its API Connector
- **SQLite** in the CLI is the source of truth for all scan data
- **PostgreSQL** in the WEB stores local data (chats, settings, analysis reports)
- API reports are stored by the API service; a redacted handoff is interoperable, not a runtime dependency
- Multiple WEB instances can connect to selected remote services when their access is explicitly configured

For full architectural details, see [Architecture](/architecture).

---

## Philosophy

BugTraceAI is built on five non-negotiable principles:

1. **Privacy First**: No telemetry, no tracking, no data collection. Everything runs locally. The only external call is to your configured AI provider — OpenRouter (default), Anthropic, or Z.ai (and you control what gets sent).

2. **Opensource Always**: Apache-2.0 licensed. All BugTraceAI-owned code, AI prompts, and algorithms are public. Closed-source security tools are unacceptable.

3. **Self-Hosted by Design**: Runs on your infrastructure. We will never offer BugTraceAI.cloud or a managed hosting service.

4. **Modular Architecture**: Each component works independently. Use API, CLI, or WEB alone where that fits, or connect them through the Launcher.

5. **No Vendor Lock-In**: Standard formats (JSON, SQL, Markdown), standard protocols (HTTP, WebSocket), standard databases (SQLite, PostgreSQL). Export your data anytime.

> "It's OK to not know. It's bad to lie." -- Design philosophy for the `origin` field and data integrity throughout the platform.

---

## Technology Stack

| Component | Technologies |
|-----------|-------------|
| **CLI Scanner** | Python 3.10+, FastAPI, SQLite, LanceDB, Go fuzzers, Playwright |
| **CLI AI** | OpenRouter API, Anthropic direct API (`x-api-key`, Messages API), and Z.ai providers (multi-model: Gemini, Claude, GPT) |
| **API Security Service** | Python, FastAPI, REST, MCP, Docker, contract-aware API testing |
| **WEB Frontend** | React 18, TypeScript, Vite, TailwindCSS |
| **WEB Backend** | Express, Prisma, PostgreSQL |
| **Deployment** | Docker, Docker Compose, Nginx, Bash |

---

## Quick Start

```bash
# Fastest path: use the Launcher
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

For detailed installation instructions, see [Getting Started](/getting-started).

---

## Repositories

| Repository | Description | Status |
|------------|-------------|--------|
| [BugTraceAI](https://github.com/BugTraceAI/BugTraceAI) | Main hub and documentation | Active |
| [BugTraceAI-API](https://github.com/BugTraceAI/BugTraceAI-API) | Evidence-first API security service | v1.4.4-beta |
| [BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI) | Autonomous scanning engine | v3.7.28-beta |
| [BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB) | Dashboard, Model Lab, and API Connector | v2.0.24-beta |
| [BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher) | Deployment automation | v2.9.2 |

---

**Next**: [Architecture](/architecture) | [Getting Started](/getting-started) | [BugTraceAI-API](/bugtraceai-api) | [BugTraceAI-CLI](/bugtraceai-cli)
