---
title: "BugTraceAI-CLI"
---

# BugTraceAI-CLI

BugTraceAI-CLI is the autonomous scanning engine at the heart of the BugTraceAI platform. It combines Python-based AI agents, Go high-speed fuzzers, and Playwright Chromium browser validation into a single scanning system that discovers, analyzes, exploits, and validates vulnerabilities independently.

**Repository**: [github.com/BugTraceAI/BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI)

---

## Overview

The CLI operates in two modes:

| Mode | Description | Use Case |
|------|-------------|----------|
| **Headless Server** | FastAPI on port 8000, REST API + WebSocket | Integration with WEB dashboard, CI/CD pipelines |
| **Interactive CLI** | Terminal-based interface | Direct pentesting, manual control |

### Key Capabilities

- **Autonomous scanning**: AI agents make independent decisions about targets, tools, and payloads
- **Multi-vulnerability coverage**: 15 specialist exploitation agents spanning XSS, SQLi, SSRF, IDOR, LFI, RCE, XXE, JWT attacks, Open Redirect, Prototype Pollution, CSTI/SSTI, HTTP Header Injection, Mass Assignment, File Upload, and API security
- **High-speed fuzzing**: Go binaries for XSS, SSRF, IDOR, and LFI fuzzing
- **Browser-based validation**: Playwright Chromium with CDP for DOM analysis and visual confirmation
- **AI-powered analysis**: Multi-persona consensus voting across OpenRouter, Anthropic (direct `x-api-key` Messages API), and Z.ai (GLM) providers
- **Real-time streaming**: WebSocket events for live scan monitoring
- **Persistent storage**: SQLite as the source of truth for all scan data
- **Authenticated scanning**: YAML auth configs with credentials, login flow steps, environment-variable substitution, and optional TOTP/2FA generation
- **Resumable scans**: `--resume` and recoverable state tracking continue interrupted scans without losing context
- **Integrated Model Lab**: benchmark and compare models through the CLI API (`/api/model-eval`), with per-slot leaderboards, calibrated suites, live WebSocket progress, and persisted history

### What's New in v3.7.12-beta

Highlights across the v3.6.5x -> v3.7.12 line:

- **Anthropic direct-API provider** (3.7.5) - Anthropic is now a first-class LLM provider using an API key (`x-api-key`, native Messages API). A new `api_format` preset field decouples the wire format from the provider path, so text generation, threaded generation, vision, and connectivity checks all route to the Messages API when Anthropic is active. OpenRouter and Z.ai (GLM) remain fully supported and unchanged.
- **Integrated Model Lab (model-eval)** (3.6.90 / 3.7.6 / 3.7.7 / 3.7.12) - model benchmarking is now a built-in CLI API feature (`GET /api/model-eval/models`, `POST /api/model-eval`, `GET /api/model-eval/test-key`) rather than a standalone script. It accepts a per-request OpenRouter key (`X-OpenRouter-Key`), streams live progress over WebSocket, and persists benchmark history. The 3.7.12 recalibration adds a quality-dominant composite, a **per-slot leaderboard** (MUTATION / SKEPTICAL / ANALYSIS / REPORTING), the discrimination-focused **quick-v3 / advanced-v2** suites, and an opt-in **MUTATION diversity probe**.
- **Reporting / enrichment failover** (3.7.11) - when a PoC or CVSS enrichment call on the active scan provider fails or degrades, that single enrichment call falls back to a secondary provider (`REPORTING_FAILOVER_PROVIDER`, default `anthropic`) without changing the scan's active provider. Provenance telemetry (`poc_enrichment_provenance`, `reporting_failover_count`) records when failover happened.
- **CDP AgenticValidator wired into the pipeline** (3.6.46-3.6.48) - a fail-safe Phase-5 CDP validation stage now runs on the hard queue, confirming XSS / CSTI / SSTI in a real Chromium via the Chrome DevTools Protocol instead of sitting as dead code.
- **Deliverable parity for pending findings** (3.7.8 / 3.7.9) - pending / POTENTIAL findings now appear in `validated_findings.json`, and the "Findings by Severity" totals plus manual-review ordering match across the Markdown, HTML, and JSON deliverables.
- **Dedup & detection fixes** (3.7.7 / 3.7.10) - the RCE / command-injection family canonicalizes to a single type (no double-counting), genuine IDORs with strong evidence route to `MANUAL_REVIEW` instead of being hidden as pending, and boolean-blind SQLi diffing is capped and offloaded to avoid an event-loop stall (ReDoS-class hardening).
- **Bounded JavaScript endpoint mining** (3.6.92) - GoSpider mines same-origin scripts for API endpoints with configurable script-count, response-size, and timeout limits, while keeping JavaScript assets out of DAST.
- **AuthDiscovery visibility** (3.6.93) - verbose events now include the target, bounded URL count, per-URL progress, and final JWT / cookie totals.
- **DOM-scan and browser-XSS coverage** (3.6.49 / 3.6.50) - DOM-scan recon URLs are deduped by endpoint surface so pure DOM-sink pages survive the URL cap, and browser-only XSS candidates auto-escalate to the Playwright / CDP levels even at standard analysis depth.

---

## Architecture

```
+---------------------------------------------------------------+
|                      BugTraceAI-CLI                            |
|                                                                |
|  +------------------+    +------------------+                  |
|  | FastAPI Server   |    | CLI Interface    |                  |
|  | Port 8000        |    | (Interactive)    |                  |
|  +--------+---------+    +--------+---------+                  |
|           |                       |                            |
|           +-----------+-----------+                            |
|                       |                                        |
|           +-----------v-----------+                            |
|           |   Scanning Pipeline   |                            |
|           |                       |                            |
|           |  Phase 1: Discovery   |                            |
|           |  Phase 2: Analysis    |                            |
|           |  Phase 3: Consolidate |                            |
|           |  Phase 4: Exploitation|                            |
|           |  Phase 5: Validation  |                            |
|           |  Phase 6: Reporting   |                            |
|           +-----------+-----------+                            |
|                       |                                        |
|    +------------------+------------------+                     |
|    |                  |                  |                     |
|  +-v---------+  +-----v------+  +-------v--------+            |
|  | AI Agents |  | Go Fuzzers |  | Playwright     |            |
|  | (Python)  |  | (Compiled) |  | (Chromium CDP) |            |
|  +-----------+  +------------+  +----------------+            |
|                       |                                        |
|           +-----------v-----------+                            |
|           |  SQLite + LanceDB    |                            |
|           +----------------------+                            |
+---------------------------------------------------------------+
```

---

## Technology Stack

| Technology | Purpose |
|-----------|---------|
| **Python 3.10+** | Core language for agents, API, and orchestration |
| **FastAPI** | REST API and WebSocket server |
| **SQLite** | Persistent storage for scans, findings, and reports |
| **LanceDB** | Vector database for semantic search over findings |
| **Go** | High-speed fuzzer binaries (XSS, SSRF, IDOR, LFI) |
| **Playwright** | Headless Chromium for browser-based validation |
| **OpenRouter / Anthropic / Z.ai** | AI model access via OpenRouter (Gemini, Claude, GPT), Anthropic direct API (`x-api-key`), or Z.ai (GLM) |

---

## Running the CLI

### As a Headless Server (API Mode)

```bash
cd BugTraceAI-CLI
python3 -m uvicorn bugtrace.api.main:app --host 0.0.0.0 --port 8000
```

The server exposes:
- REST API at `http://localhost:8000/api/`
- Swagger docs at `http://localhost:8000/docs`
- WebSocket at `ws://localhost:8000/api/ws/`

### As an Interactive CLI

```bash
cd BugTraceAI-CLI
python -m bugtrace --help
python -m bugtrace scan url https://example.com
python -m bugtrace scan url https://example.com --auth-config auth-config.yaml
python -m bugtrace scan url https://example.com --resume
```

Model Lab (model-eval) runs as an integrated CLI API feature (`/api/model-eval`) driven from the WEB dashboard, not as a standalone script.

### Docker

```bash
docker build -t bugtrace-cli .
docker run -p 8000:8000 bugtrace-cli
```

---

## Sub-Pages

The CLI documentation is organized into the following sub-pages:

| Page | Description |
|------|-------------|
| [Scanning Pipeline](/scanning-pipeline) | The six-phase scanning pipeline from discovery to reporting |
| [Specialist Agents](/specialist-agents) | Individual exploitation agents for each vulnerability class |
| [Queue and Event System](/queue-and-event-system) | Per-specialist task queues, deduplication, and the event bus |
| [Validation System](/validation-system) | CDP browser validation and Vision AI screenshot analysis |
| [Report Generation](/report-generation) | HTML, JSON, and Markdown report generation with PoC enrichment |
| [Configuration](/configuration) | Runtime settings, model selection, safe mode, and API keys |

---

## AI Agent System

The CLI uses multiple AI agent personas that work together:

| Agent | Role |
|-------|------|
| **Discovery Agent** | Crawls and spiders the target to map the attack surface |
| **Analysis Agent** | Multi-persona AI with consensus voting to evaluate findings |
| **Specialist Agents** | Per-vulnerability exploitation (XSS, SQLi, SSRF, etc.) |
| **Validation Agent** | Confirms findings using headless Chromium and Vision AI |
| **Reporting Agent** | Generates structured reports from validated findings |

AI models are configured per provider - OpenRouter (`provider/model` slugs), Anthropic (direct `x-api-key` Messages API), or Z.ai (GLM). See [Configuration](/configuration) for model selection.

---

## Go Fuzzers

Purpose-built Go binaries provide high-throughput fuzzing:

| Fuzzer | Target |
|--------|--------|
| **XSS Fuzzer** | Reflected and stored XSS via parameter injection |
| **SSRF Fuzzer** | Server-side request forgery endpoint probing |
| **IDOR Fuzzer** | Insecure direct object reference enumeration |
| **LFI Fuzzer** | Local file inclusion path traversal |

The Go fuzzers run as child processes managed by the Python orchestrator, combining raw speed with AI-guided target selection.

---

## Data Storage

The CLI uses SQLite as its primary database, stored at `bugtrace.db` in the CLI working directory. The path is resolved via `settings.BASE_DIR`.

Key points:
- SQLite is the **source of truth** for all scan data
- LanceDB provides vector search capabilities over findings
- Data is accessible via the REST API or direct SQLite access
- See [Dual Database System](/dual-database-system) for the full data architecture

---

**See also**: [Architecture](/architecture) | [API Reference](/api-reference) | [Getting Started](/getting-started)
