---
title: Overview
---

# Overview

BugTraceAI is the first opensource, self-hosted framework designed specifically for autonomous security scanning. It is **not** a wrapper around existing tools -- it is an autonomous multi-agent system where AI agents independently discover, analyze, exploit, and validate vulnerabilities with minimal human intervention.

---

## What BugTraceAI Is

BugTraceAI is a modular security platform composed of three operational components:

- **BugTraceAI-CLI**: The autonomous scanning engine. Python-based with Go high-speed fuzzers (XSS, SSRF, IDOR, LFI), Playwright Chromium for browser-based validation, YAML authentication with TOTP/2FA, resumable scan state, and AI agents orchestrated via OpenRouter API. Runs as a headless server (FastAPI on port 8000) or as an interactive CLI.

- **BugTraceAI-WEB**: A React dashboard with 20+ specialized AI-powered security tools. Connects to the CLI API for scan management, scan resume controls, authenticated scan launch, API Discovery, and real-time monitoring. Features an Express + Prisma + PostgreSQL backend for persistence.

- **BugTraceAI-Launcher**: A one-command Docker deployment wizard that handles dependency detection, port management, service configuration, lifecycle management, and optional AI-assisted troubleshooting.

---

## Latest Release Highlights

| Component | Version | Highlights |
|-----------|---------|------------|
| **BugTraceAI-CLI** | `v3.5.7-beta` | YAML auth configs, TOTP/2FA, scan resumption, model evaluation script, lifecycle cleanup |
| **BugTraceAI-WEB** | `v0.8.6.1-beta` | API Discovery persistence, YAML auth upload, scan resume controls, WebSec Agent web browsing toggle, improved CLI configuration |
| **BugTraceAI-Launcher** | `v2.5.2` | AI-assisted installer, robust terminal prompts, macOS/Apple Silicon deployment improvements |

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
BugTraceAI-WEB (React + Express)         BugTraceAI-CLI (Python + Go + Playwright)
        |                                           |
        |  REST API + WebSocket                     |  FastAPI on port 8000
        +-------------------------------------------+
                                                    |
                                             SQLite (source of truth)
                                             LanceDB (vector search)
                                             Go Fuzzers (high-speed)
                                             Playwright (browser validation)
```

- The **CLI** is the scanning engine and API server
- The **WEB** dashboard connects to the CLI API for management, authenticated scan launch, resume controls, and monitoring
- **SQLite** in the CLI is the source of truth for all scan data
- **PostgreSQL** in the WEB stores local data (chats, settings, analysis reports, API Discovery history)
- Multiple WEB instances can connect to a single CLI server

For full architectural details, see [Architecture](/architecture).

---

## Philosophy

BugTraceAI is built on five non-negotiable principles:

1. **Privacy First**: No telemetry, no tracking, no data collection. Everything runs locally. The only external call is to OpenRouter API for AI (and you control what gets sent).

2. **Opensource Always**: AGPL-3.0 licensed. All code, all AI prompts, all algorithms are public. Closed-source security tools are unacceptable.

3. **Self-Hosted by Design**: Runs on your infrastructure. We will never offer BugTraceAI.cloud or a managed hosting service.

4. **Modular Architecture**: Each component works independently. Use CLI without WEB, WEB without CLI, or both together.

5. **No Vendor Lock-In**: Standard formats (JSON, SQL, Markdown), standard protocols (HTTP, WebSocket), standard databases (SQLite, PostgreSQL). Export your data anytime.

> "It's OK to not know. It's bad to lie." -- Design philosophy for the `origin` field and data integrity throughout the platform.

---

## Technology Stack

| Component | Technologies |
|-----------|-------------|
| **CLI Scanner** | Python 3.10+, FastAPI, SQLite, LanceDB, Go fuzzers, Playwright |
| **CLI AI** | OpenRouter API (multi-model: Gemini, Claude, GPT), model evaluation tooling |
| **WEB Frontend** | React 18, TypeScript, Vite, TailwindCSS |
| **WEB Backend** | Express, Prisma, PostgreSQL, API Discovery persistence |
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
| [BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI) | Autonomous scanning engine | v3.5.7-beta |
| [BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB) | Dashboard and security toolkit | v0.8.6.1-beta |
| [BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher) | Deployment automation | v2.5.2 |

---

**Next**: [Architecture](/architecture) | [Getting Started](/getting-started) | [BugTraceAI-CLI](/bugtraceai-cli)
