# BugTraceAI - Ecosystem Overview

**Version**: 1.0.0
**Date**: 2026-01-26
**Author**: Albert C (@yz9yt)

---

## What is BugTraceAI?

**BugTraceAI** is the **first opensource, self-hosted framework designed specifically for bug bounty hunting and penetration testing**. It combines AI-powered vulnerability analysis with real security tools, creating a complete pentesting platform that respects your privacy and runs entirely on your infrastructure.

### Not a SaaS, Not a Cloud Service

BugTraceAI is **NOT**:
- ❌ A cloud-based SaaS platform
- ❌ A subscription service
- ❌ A product that requires internet (except for AI API calls)
- ❌ A centralized platform that stores your data

BugTraceAI **IS**:
- ✅ **Opensource**: MIT licensed, fully transparent code
- ✅ **Self-Hosted**: Runs on your own machine or server
- ✅ **Privacy-First**: Your data stays with you
- ✅ **Modular**: Use components independently or together
- ✅ **Docker-Based**: One-command deployment
- ✅ **Extensible**: Build your own tools and workflows

---

## The BugTraceAI Ecosystem

BugTraceAI is composed of **4 independent but interconnected components**:

```
┌─────────────────────────────────────────────────────────────────┐
│                        BugTraceAI                               │
│                    (Main Repository)                            │
│  - Documentation                                                │
│  - Project overview                                             │
│  - Community resources                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ BugTraceAI-WEB│   │ BugTraceAI-CLI│   │   Launcher    │
│  (Frontend)   │   │   (Backend)   │   │  (Orchestr.)  │
│               │   │               │   │               │
│ React + TS    │   │ Python + AI   │   │  Bash/Docker  │
│ AI Analysis   │◄──►│ Real Tools   │   │  Auto-Deploy  │
│ Port 6869     │   │ nmap, sqlmap │   │  Setup All    │
│               │   │ nuclei, ffuf │   │               │
└───────────────┘   └───────────────┘   └───────────────┘
```

### 1. **BugTraceAI** (This Repository)
**Purpose**: Main project hub, documentation, community
**Contains**: README, guides, wiki, community resources
**GitHub**: [https://github.com/BugTraceAI/BugTraceAI](https://github.com/BugTraceAI/BugTraceAI)

### 2. **BugTraceAI-WEB**
**Purpose**: Browser-based AI vulnerability analysis interface
**Tech**: React 18 + TypeScript + Vite
**Features**: DAST, SAST, JWT analysis, payload generation, AI chat
**Status**: ✅ v0.1.2 Beta (Functional, no backend)
**GitHub**: [https://github.com/BugTraceAI/BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB)

### 3. **BugTraceAI-CLI**
**Purpose**: Command-line pentesting toolkit with real tools
**Tech**: Python 3 + AI Agents
**Features**: nmap, sqlmap, nuclei, ffuf, custom workflows
**Status**: ✅ v1.0.0 (Functional)
**GitHub**: [https://github.com/BugTraceAI/BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI)

### 4. **BugTraceAI-Launcher**
**Purpose**: One-command deployment orchestrator
**Tech**: Bash scripts + Docker Compose
**Features**: Auto-setup, environment config, health checks
**Status**: 🚧 In Development
**GitHub**: [https://github.com/BugTraceAI/BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher)

---

## Key Characteristics

### Independence First
Each component works **independently**:
- Use **WEB** alone for AI-powered analysis
- Use **CLI** alone for traditional pentesting
- Use **Launcher** to deploy everything together

No forced dependencies. Pick what you need.

### Modularity
```bash
# Scenario 1: Only AI analysis
docker run bugtrace-web

# Scenario 2: Only CLI tools
pip install bugtrace-cli && bugtrace

# Scenario 3: Full ecosystem
bugtrace-launcher start --mode full
```

### Privacy-First
- All data stored locally (localStorage, SQLite, PostgreSQL)
- No telemetry, no tracking, no data collection
- Only external call: OpenRouter API for AI (optional)

### Docker-Native
One-liner deployment for everything:
```bash
git clone https://github.com/BugTraceAI/BugTraceAI.git
cd BugTraceAI
bugtrace-launcher start
```

---

## Architecture Vision

### Current State (v0.1 - v1.0)

**BugTraceAI-WEB**:
- 100% client-side React app
- No backend, uses localStorage
- OpenRouter API for AI analysis
- Port 6869, Docker deployment

**BugTraceAI-CLI**:
- Python CLI tool
- Integrates nmap, sqlmap, nuclei, ffuf, etc.
- AI-powered agents for intelligent tool orchestration
- SQLite persistence

**BugTraceAI-Launcher**:
- Bash scripts for deployment
- Docker Compose orchestration

### Future Vision (v2.0+)

**Full-Stack Integration**:
```
┌──────────────────────────────────────────────────────┐
│  BugTraceAI-WEB (React Frontend)                     │
│  - AI Analysis UI                                    │
│  - CLI Tools Panel (NEW!)                           │
│  - Real-time job monitoring                         │
└──────────────────────────────────────────────────────┘
                     ↓ WebSocket
┌──────────────────────────────────────────────────────┐
│  BugTraceAI-Backend (Node.js + Express)              │
│  - REST API                                          │
│  - WebSocket Server                                  │
│  - Job Queue (BullMQ + Redis)                       │
│  - PostgreSQL persistence                            │
└──────────────────────────────────────────────────────┘
                     ↓ WebSocket/IPC
┌──────────────────────────────────────────────────────┐
│  BugTraceAI-CLI (Python Agent Mode)                  │
│  - Connects to backend                               │
│  - Executes real pentesting tools                   │
│  - Streams output in real-time                      │
└──────────────────────────────────────────────────────┘
```

**Key Improvements**:
- ✅ **Persistence**: PostgreSQL for reports, chats, jobs
- ✅ **Real Tools Integration**: Run nmap, sqlmap from WEB UI
- ✅ **Real-Time Streaming**: See tool output live
- ✅ **Job Queue**: Async execution with BullMQ
- ✅ **Multi-User**: Authentication with JWT
- ✅ **One-Command Deploy**: Launcher handles everything

---

## Technology Stack

### BugTraceAI-WEB
```
Frontend: React 18 + TypeScript + Vite
Styling: Tailwind CSS
AI: OpenRouter API (Gemini, Claude, GPT)
Storage: localStorage → PostgreSQL (v2.0)
Deployment: Docker + Nginx
Port: 6869
```

### BugTraceAI-CLI
```
Language: Python 3.10+
Tools: nmap, sqlmap, nuclei, ffuf, subfinder, httpx, nikto
AI: OpenRouter API
Storage: SQLite → PostgreSQL (v2.0)
Agents: Recon, Exploit, Skeptic, Reporting
```

### BugTraceAI-Backend (v2.0)
```
Runtime: Node.js + Express + TypeScript
Database: PostgreSQL 15
Queue: Redis + BullMQ
Auth: JWT (Passport.js)
WebSocket: Socket.io
ORM: Prisma
```

### BugTraceAI-Launcher
```
Language: Bash
Orchestration: Docker Compose
Config: .env files
Health Checks: Custom scripts
```

---

## Use Cases

### Bug Bounty Hunter
1. Deploy BugTraceAI with Launcher
2. Use WEB for subdomain enumeration, URL discovery
3. Use CLI for port scanning, directory bruteforce
4. Use WEB AI analysis to identify vulnerabilities
5. Use CLI tools to verify and exploit findings
6. Export reports from WEB

### Penetration Tester
1. Deploy full stack on internal network
2. Run CLI tools (nmap, nuclei) on target infrastructure
3. Use WEB for AI-powered code review (SAST)
4. Analyze JWT tokens, security headers
5. Generate payloads with AI assistance
6. Document findings in persistent reports

### Security Researcher
1. Use WEB for hypothesis generation (AI analysis)
2. Use CLI for validation (real tool execution)
3. Use AI agents to automate testing workflows
4. Store results in PostgreSQL for analysis
5. Share findings with team (v2.0)

---

## Quick Start

### Option 1: Full Ecosystem (Recommended)
```bash
# One-liner with Launcher
git clone https://github.com/BugTraceAI/BugTraceAI.git
cd BugTraceAI
./launcher/deploy.sh
```

Access:
- **WEB**: http://localhost:6869
- **CLI**: `bugtrace --help`
- **Backend API**: http://localhost:3000 (v2.0)

### Option 2: WEB Only
```bash
git clone https://github.com/BugTraceAI/BugTraceAI-WEB.git
cd BugTraceAI-WEB
./dockerizer.sh
```

Access: http://localhost:6869

### Option 3: CLI Only
```bash
git clone https://github.com/BugTraceAI/BugTraceAI-CLI.git
cd BugTraceAI-CLI
pip install -r requirements.txt
python -m bugtrace --help
```

---

## Component Documentation

Each component has its own comprehensive `.ai-context` documentation:

### BugTraceAI-WEB
- [README.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/.ai-context/README.md) - Project overview
- [ARCHITECTURE.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/.ai-context/ARCHITECTURE.md) - Technical architecture
- [PROJECT_CONTEXT.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/.ai-context/PROJECT_CONTEXT.md) - AI assistant context
- [ROADMAP.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/.ai-context/ROADMAP.md) - Future plans (PostgreSQL backend, CLI integration)
- [COMPONENT_GUIDE.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/.ai-context/guides/COMPONENT_GUIDE.md) - All 35+ components
- [QUICKSTART_GUIDE.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/.ai-context/QUICKSTART_GUIDE.md) - User guide

### BugTraceAI-CLI
- [README.md](https://github.com/BugTraceAI/BugTraceAI-CLI/blob/main/.ai-context/README.md) - Project overview
- [ARCHITECTURE.md](https://github.com/BugTraceAI/BugTraceAI-CLI/blob/main/.ai-context/architecture/architecture_overview.md) - System architecture
- [PROTOCOL](https://github.com/BugTraceAI/BugTraceAI-CLI/tree/main/protocol) - Agent prompts, security rules

### BugTraceAI-Launcher
- 🚧 Documentation in development

---

## Community & Support

### GitHub Repositories
- **Main**: [BugTraceAI/BugTraceAI](https://github.com/BugTraceAI/BugTraceAI)
- **WEB**: [BugTraceAI/BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB)
- **CLI**: [BugTraceAI/BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI)
- **Launcher**: [BugTraceAI/BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher)

### Resources
- **Wiki**: [DeepWiki](https://deepwiki.com/BugTraceAI/BugTraceAI)
- **Twitter**: [@yz9yt](https://x.com/yz9yt)
- **Issues**: Report bugs on respective GitHub repos
- **Discussions**: GitHub Discussions on main repo

### Contributing
We welcome contributions!
- Open issues for bugs/features
- Submit PRs for improvements
- Share your workflows and findings
- Improve documentation
- Build community tools

---

## License

**MIT License** - See LICENSE file in each repository

Free to use, modify, and distribute. No attribution required (but appreciated!).

---

## Project Philosophy

### 1. Privacy First
Your security work is sensitive. We never:
- Collect usage data
- Phone home with telemetry
- Store data on external servers
- Require accounts or registration

### 2. Opensource Always
Full transparency:
- All code is public
- All prompts are visible
- All algorithms are documented
- No black boxes, no secrets

### 3. Self-Hosted by Design
You control:
- Where your data lives
- What tools you run
- How you configure it
- Who has access

### 4. Modular Architecture
Use what you need:
- WEB without CLI
- CLI without WEB
- Backend optional (v2.0)
- Pick your own tools

### 5. No Vendor Lock-In
Standards-based:
- Standard Docker deployment
- Standard PostgreSQL database
- Standard REST APIs
- Export your data anytime

---

## Roadmap

### v0.1 - v1.0 (Current)
- ✅ BugTraceAI-WEB functional (client-side only)
- ✅ BugTraceAI-CLI functional (Python CLI)
- 🚧 BugTraceAI-Launcher in development

### v2.0 (8-Month Plan)
- 🔜 PostgreSQL backend for WEB
- 🔜 WebSocket integration WEB ↔ CLI
- 🔜 Job queue system (BullMQ + Redis)
- 🔜 Multi-user authentication
- 🔜 Persistent reports and chats
- 🔜 One-command deployment (Launcher)

### v3.0 (Future)
- Team collaboration features
- Advanced analytics dashboard
- Mobile app support
- Community payload library
- Plugin system
- API marketplace

---

## Getting Help

### Documentation
Start here:
1. Read this README
2. Check [ECOSYSTEM.md](ECOSYSTEM.md) for component relationships
3. Read component-specific docs in `.ai-context`
4. Check [DEPLOYMENT.md](DEPLOYMENT.md) for setup guides

### Troubleshooting
- Check GitHub Issues in respective repos
- Search GitHub Discussions
- Read component QUICKSTART guides
- Check Docker logs: `docker logs <container_name>`

### Contact
- **Author**: Albert C
- **GitHub**: [@yz9yt](https://github.com/yz9yt)
- **Twitter**: [@yz9yt](https://x.com/yz9yt)

---

## Frequently Asked Questions

**Q: Is this free?**
A: Yes, 100% opensource and free. You only pay for OpenRouter API usage (AI calls).

**Q: Can I use it offline?**
A: Partially. WEB and CLI work offline, but AI features require OpenRouter API (internet).

**Q: Is my data secure?**
A: Yes. Everything runs locally. Only AI analysis requests go to OpenRouter API.

**Q: Can I contribute?**
A: Absolutely! We welcome PRs, bug reports, feature requests, and documentation improvements.

**Q: Does it actually exploit vulnerabilities?**
A: WEB provides AI-powered hypotheses (non-invasive). CLI can run real tools (nmap, sqlmap) for active testing.

**Q: What's the difference between WEB and CLI?**
A: **WEB** = AI analysis in browser. **CLI** = Real pentesting tools in terminal. Both can work together.

**Q: When will v2.0 be ready?**
A: Estimated 8-month timeline from January 2026. See ROADMAP.md in WEB repo.

**Q: Can I deploy this in production?**
A: It's designed for self-hosted use, not public SaaS. Deploy on internal networks or personal servers only.

---

## Acknowledgments

Built with:
- React, TypeScript, Vite (WEB)
- Python, Click, Rich (CLI)
- Docker, Nginx (Deployment)
- OpenRouter API (AI)
- Countless opensource security tools

Inspired by the bug bounty community and the need for privacy-respecting security tools.

---

**Welcome to BugTraceAI! 🐛🔍**

Build your own self-hosted pentesting platform and take control of your security workflow.

---

**Last Updated**: 2026-01-26
**Maintained By**: Albert C (@yz9yt)
**License**: MIT
