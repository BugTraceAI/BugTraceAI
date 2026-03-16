---
title: BugTraceAI Documentation
---

# BugTraceAI

**Autonomous AI-Powered Security Scanning Platform**

BugTraceAI is an opensource, self-hosted security platform that combines autonomous AI agents with real exploitation tools to discover, analyze, exploit, and validate vulnerabilities -- independently and without human intervention. Built for pentesters, security teams, bug bounty hunters, and CI/CD pipelines.

**Author**: Albert C ([@yz9yt](https://github.com/yz9yt)) | **License**: MIT | **Website**: [BugTraceAI.com](https://BugTraceAI.com)

---

## Quick Navigation

### Getting Started

| Page | Description |
|------|-------------|
| [Overview](/overview) | What BugTraceAI is, its philosophy, and core components |
| [Getting Started](/getting-started) | Requirements, installation, and first scan |

### Architecture

| Page | Description |
|------|-------------|
| [Architecture](/architecture) | High-level system design, stacks, and communication |
| [Dual Database System](/dual-database-system) | SQLite (CLI) and PostgreSQL (WEB) explained |
| [API Reference](/api-reference) | CLI REST API endpoints and OpenAPI spec |
| [WebSocket Events](/websocket-events) | Real-time event streaming protocol |

### BugTraceAI-CLI (Autonomous Scanner)

| Page | Description |
|------|-------------|
| [BugTraceAI-CLI](/bugtraceai-cli) | The autonomous scanning engine overview |
| [Scanning Pipeline](/scanning-pipeline) | Six-phase scanning pipeline from discovery to reporting |
| [Specialist Agents](/specialist-agents) | Exploitation agents for XSS, SQLi, SSRF, IDOR, and more |
| [Queue and Event System](/queue-and-event-system) | Per-specialist queues, deduplication, and event bus |
| [Validation System](/validation-system) | CDP browser validation and Vision AI screenshot analysis |
| [Report Generation](/report-generation) | HTML, JSON, and Markdown report output with PoC enrichment |
| [Configuration](/configuration) | Runtime settings, model selection, and safe mode |

### BugStore (Practice Target)

| Page | Description |
|------|-------------|
| [BugStore](/bugstore) | Deliberately vulnerable e-commerce app for scanning practice |

### BugTraceAI-WEB (Dashboard)

| Page | Description |
|------|-------------|
| [BugTraceAI-WEB](/bugtraceai-web) | React dashboard with 20+ security tools |
| [Security Toolkit](/security-toolkit) | AI-powered chat-based security analysis tools |
| [Real-time Scan Monitoring](/real-time-scan-monitoring) | Live scan progress, findings, and phase tracking |

### BugTraceAI-Launcher (Deployment)

| Page | Description |
|------|-------------|
| [BugTraceAI-Launcher](/bugtraceai-launcher) | One-command Docker deployment wizard |
| [Deployment Modes](/deployment-modes) | Full Platform, Standalone WEB, and Standalone CLI |

---

## Core Principles

1. **Privacy First** -- Your data stays on your infrastructure. No telemetry, no tracking, no accounts required.
2. **Opensource Always** -- MIT licensed. Every line of code, every AI prompt, every algorithm is public and auditable.
3. **Self-Hosted by Design** -- Not a SaaS. Not a cloud service. Software you download, run, and control.
4. **Modular Architecture** -- Use CLI alone, WEB alone, or both together. No forced dependencies.
5. **No Vendor Lock-In** -- Standard formats (JSON, SQL, Markdown), standard protocols (HTTP, WebSocket), easy migration.

---

## Repositories

| Repository | Purpose | Tech Stack |
|------------|---------|------------|
| [BugTraceAI](https://github.com/BugTraceAI/BugTraceAI) | Main hub, documentation | Markdown |
| [BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI) | Autonomous scanner | Python + Go + Playwright |
| [BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB) | Dashboard frontend + backend | React + Express + PostgreSQL |
| [BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher) | Docker deployment | Bash + Docker Compose |

## Demo

**[Live Demo](https://demo.bugtraceai.com/bugtraceai)** -- Try BugTraceAI in your browser without installing anything.

Download a [sample scan report](https://github.com/BugTraceAI/BugTraceAI/releases/download/demo-report/BugTraceAI-Demo-Report.zip) to see what BugTraceAI produces -- 145 findings (43 validated) from a scan of our vulnerable practice app [BugStore](/bugstore).

---

## Community and Support

- **GitHub Issues**: Report bugs on the respective repository
- **GitHub Discussions**: [BugTraceAI Discussions](https://github.com/BugTraceAI/BugTraceAI/discussions)
- **Twitter**: [@yz9yt](https://x.com/yz9yt)

Contributions are welcome -- open issues, submit pull requests, improve documentation, or share your workflows.
