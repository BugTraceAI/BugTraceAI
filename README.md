<p align="center">
  <img src="logo.png" alt="BugTraceAI" width="200"/>
</p>

<h1 align="center">BugTraceAI</h1>

<p align="center">
  Autonomous AI-powered security scanning platform
</p>

<p align="center">
  <a href="https://bugtraceai.com"><img src="https://img.shields.io/badge/Website-bugtraceai.com-blue?logo=google-chrome&logoColor=white" alt="Website"/></a>
  <a href="https://github.com/BugTraceAI/BugTraceAI/wiki"><img src="https://img.shields.io/badge/Wiki-Documentation-000?logo=wikipedia&logoColor=white" alt="Wiki"/></a>
  <a href="https://deepwiki.com/BugTraceAI/BugTraceAI"><img src="https://img.shields.io/badge/DeepWiki-AI_Docs-5A5AFF?logo=bookstack&logoColor=white" alt="DeepWiki"/></a>
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"/>
  <img src="https://img.shields.io/badge/Version-1.0.0_Beta-orange" alt="Version"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python_3.10+-3776AB?logo=python&logoColor=white" alt="Python"/>
  <img src="https://img.shields.io/badge/React_18-61DAFB?logo=react&logoColor=black" alt="React"/>
  <img src="https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white" alt="FastAPI"/>
  <img src="https://img.shields.io/badge/Go_Fuzzers-00ADD8?logo=go&logoColor=white" alt="Go"/>
  <img src="https://img.shields.io/badge/Playwright-2EAD33?logo=playwright&logoColor=white" alt="Playwright"/>
  <img src="https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white" alt="Docker"/>
</p>

---

## Disclaimer

This platform is provided for **educational and authorized security testing purposes only**.

- Only test applications for which you have **explicit, written authorization**
- AI output may contain inaccuracies, false positives, or false negatives
- It is **not** a substitute for professional security auditing
- The creators assume no liability for misuse or damage

**Always verify findings manually.**

---

## What is BugTraceAI?

**BugTraceAI** is an **opensource, self-hosted framework for bug bounty hunting and penetration testing**. It combines autonomous AI agents with real security tools to discover, analyze, exploit, and validate vulnerabilities independently.

This is **NOT** a wrapper around existing tools. It is an autonomous multi-agent system where AI agents make intelligent decisions about what to test, how to mutate payloads, and when findings are real.

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Privacy-First** | Everything runs locally. No telemetry, no tracking, no cloud dependency |
| **Opensource** | MIT licensed. All code, prompts, and algorithms are public |
| **Self-Hosted** | Your data stays on your infrastructure |
| **Modular** | Use components independently or together |
| **Docker-Native** | One-command deployment via Launcher |

---

## The Ecosystem

BugTraceAI is composed of **3 independent but interconnected components**:

<table>
  <tr>
    <th>Component</th>
    <th>Description</th>
    <th>Tech Stack</th>
    <th>Repository</th>
  </tr>
  <tr>
    <td><strong>BugTraceAI-CLI</strong></td>
    <td>Autonomous AI security scanner. Multi-agent pipeline with Go fuzzers, Playwright browser validation, and AI-driven analysis</td>
    <td>Python + FastAPI + Go + Playwright</td>
    <td><a href="https://github.com/BugTraceAI/BugTraceAI-CLI">BugTraceAI-CLI</a></td>
  </tr>
  <tr>
    <td><strong>BugTraceAI-WEB</strong></td>
    <td>Web dashboard with 20+ AI security tools, real-time scan monitoring, and CLI control center</td>
    <td>React + Express + PostgreSQL</td>
    <td><a href="https://github.com/BugTraceAI/BugTraceAI-WEB">BugTraceAI-WEB</a></td>
  </tr>
  <tr>
    <td><strong>BugTraceAI-Launcher</strong></td>
    <td>One-command Docker deployment wizard with interactive setup and service management</td>
    <td>Bash + Docker Compose</td>
    <td><a href="https://github.com/BugTraceAI/BugTraceAI-Launcher">BugTraceAI-Launcher</a></td>
  </tr>
</table>

Each component works **independently**. Use the WEB alone for AI analysis, the CLI alone for autonomous scanning, or deploy everything together with the Launcher.

---

## Architecture

```
                    +----------------------------+
                    |      BugTraceAI-WEB        |
                    |   React + Express + PgSQL   |
                    |   Port 6869 / Port 3001    |
                    +-------------+--------------+
                                  |
                          REST API + WebSocket
                                  |
                    +-------------+--------------+
                    |      BugTraceAI-CLI        |
                    |   FastAPI + SQLite + LanceDB|
                    |        Port 8000           |
                    +---+--------+----------+----+
                        |        |          |
                   +----+--+ +---+---+ +----+----+
                   |Go     | |Playwright| |AI Agents|
                   |Fuzzers| |Browser  | |OpenRouter|
                   +-------+ +---------+ +---------+
```

**SQLite** is the source of truth for all scan data. **PostgreSQL** is local to each WEB instance for chats, settings, and analysis. They work **autonomously OR together** -- multiple WEB instances can connect to one CLI over the network.

For detailed architecture documentation, see the [Wiki](https://github.com/BugTraceAI/BugTraceAI/wiki/Architecture).

---

## Scanning Pipeline

The CLI runs a **5-phase autonomous pipeline**:

| Phase | Name | Description |
|-------|------|-------------|
| 1 | **Discovery** | Crawl and spider the target to map the attack surface |
| 2 | **Analysis** | Multi-persona AI analysis with consensus voting |
| 3 | **Consolidation** | Deduplicate findings and distribute to specialist queues |
| 4 | **Exploitation** | 10 specialist agents (XSS, SQLi, SSRF, IDOR, LFI, RCE, XXE, JWT, Open Redirect, Prototype Pollution) attempt exploitation with Go fuzzers and AI-mutated payloads |
| 5 | **Validation** | Chrome DevTools Protocol + Vision AI screenshot analysis confirms findings |

For the full pipeline documentation, see the [Wiki](https://github.com/BugTraceAI/BugTraceAI/wiki/Scanning-Pipeline).

---

## Quick Start

### Requirements

- Docker 24.0+
- Git
- 4 GB RAM (8 GB recommended)
- 10 GB disk space
- OpenRouter API key

### One-Command Install

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git ~/bugtraceai-launcher
~/bugtraceai-launcher/launcher.sh
```

The interactive wizard handles deployment mode selection, API key configuration, and port assignment.

### Deployment Modes

| Mode | What You Get | Use Case |
|------|-------------|----------|
| **Full Platform** | WEB + CLI auto-connected | Complete scanning + dashboard |
| **Standalone CLI** | Headless scanner + API | CI/CD pipelines, automation |
| **Standalone WEB** | Dashboard + AI tools | Manual analysis without scanning |

### Alternative: Individual Components

```bash
# CLI only
git clone https://github.com/BugTraceAI/BugTraceAI-CLI.git
cd BugTraceAI-CLI
pip install -r requirements.txt
python -m bugtrace --help

# WEB only
git clone https://github.com/BugTraceAI/BugTraceAI-WEB.git
cd BugTraceAI-WEB
docker compose up
```

---

## Documentation

Full documentation is available in the **[Project Wiki](https://github.com/BugTraceAI/BugTraceAI/wiki)**:

- [Overview](https://github.com/BugTraceAI/BugTraceAI/wiki/Overview) -- What BugTraceAI is and who it's for
- [Architecture](https://github.com/BugTraceAI/BugTraceAI/wiki/Architecture) -- System design and communication protocols
- [BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI/wiki/BugTraceAI-CLI) -- Autonomous scanner documentation
- [BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI/wiki/BugTraceAI-WEB) -- Web dashboard documentation
- [BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI/wiki/BugTraceAI-Launcher) -- Deployment guide
- [API Reference](https://github.com/BugTraceAI/BugTraceAI/wiki/API-Reference) -- REST API and WebSocket endpoints
- [Getting Started](https://github.com/BugTraceAI/BugTraceAI/wiki/Getting-Started) -- Installation and first scan

---

## Community & Support

| Resource | Link |
|----------|------|
| Website | [bugtraceai.com](https://bugtraceai.com) |
| Wiki | [GitHub Wiki](https://github.com/BugTraceAI/BugTraceAI/wiki) |
| DeepWiki | [AI-powered docs](https://deepwiki.com/BugTraceAI/BugTraceAI) |
| Issues | [GitHub Issues](https://github.com/BugTraceAI/BugTraceAI/issues) |
| Twitter | [@yz9yt](https://x.com/yz9yt) |

### Contributing

We welcome contributions: bug reports, feature requests, PRs, documentation improvements, and community tools. Open an issue on the respective repository to get started.

---

## License

**MIT License** -- Free to use, modify, and distribute.

See LICENSE file in each repository.

---

<p align="center">
  <strong>BugTraceAI</strong> -- Build your own self-hosted pentesting platform.<br/>
  <a href="https://github.com/yz9yt">Albert C (@yz9yt)</a>
</p>
