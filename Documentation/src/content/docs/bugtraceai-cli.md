---
title: Bugtraceai Cli
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
- **Multi-vulnerability coverage**: XSS, SQLi, SSRF, IDOR, LFI, RCE, XXE, JWT attacks, Open Redirect, Prototype Pollution
- **High-speed fuzzing**: Go binaries for XSS, SSRF, IDOR, and LFI fuzzing
- **Browser-based validation**: Playwright Chromium with CDP for DOM analysis and visual confirmation
- **AI-powered analysis**: Multi-persona consensus voting with OpenRouter API
- **Real-time streaming**: WebSocket events for live scan monitoring
- **Persistent storage**: SQLite as the source of truth for all scan data
- **Authenticated scanning**: YAML auth configs with credentials, login flow steps, environment-variable substitution, and optional TOTP/2FA generation
- **Resumable scans**: `--resume` and recoverable state tracking continue interrupted scans without losing context
- **Model evaluation**: `tools/model_eval.py` benchmarks configured OpenRouter models and writes `tools/model_eval_results.json`

### What's New in v3.5.7-beta

- `--auth-config` accepts YAML authentication files for login-protected targets.
- TOTP secrets can be supplied for 2FA-protected applications and injected into browser/login flows as `$totp`.
- Interrupted scans can be resumed with `--resume` or through the WEB dashboard resume API.
- `tools/model_eval.py` compares model behavior and latency for model-selection tuning.
- Lifecycle handling now tracks scan origin, recoverability, orphan cleanup, and safer delete/resume behavior.

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
| **OpenRouter API** | AI model access (Gemini, Claude, GPT) |

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
python tools/model_eval.py
```

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
| [[Scanning Pipeline]] | The six-phase scanning pipeline from discovery to reporting |
| [[Specialist Agents]] | Individual exploitation agents for each vulnerability class |
| [[Queue and Event System]] | Per-specialist task queues, deduplication, and the event bus |
| [[Validation System]] | CDP browser validation and Vision AI screenshot analysis |
| [[Report Generation]] | HTML, JSON, and Markdown report generation with PoC enrichment |
| [[Configuration]] | Runtime settings, model selection, safe mode, and API keys |

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

AI models are configured via OpenRouter in `provider/model` format. See [[Configuration]] for model selection.

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
- See [[Dual Database System]] for the full data architecture

---

**See also**: [[Architecture]] | [[API Reference]] | [[Getting Started]]
