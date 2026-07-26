---
title: "Getting Started"
---

# Getting Started

This page covers everything you need to install, deploy, and run your first scan with BugTraceAI.

---

## Requirements

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **Docker** | 24.0+ | Latest stable |
| **Git** | Any recent version | Latest |
| **RAM** | 4 GB | 8 GB |
| **Disk** | 10 GB | 20 GB+ (SSD) |
| **Network** | Internet access | 10 Mbps+ |

### API Key

BugTraceAI requires an **OpenRouter API key** for AI functionality:

1. Go to [openrouter.ai](https://openrouter.ai)
2. Create an account
3. Generate an API key (starts with `sk-or-`)
4. Keep the key ready for the setup wizard

OpenRouter provides access to multiple AI models (Gemini, Claude, GPT) through a single API key. You pay for usage directly to OpenRouter -- BugTraceAI does not charge anything and has no intermediary.

---

## Try the Live Demo

Not ready to install? **[Try the live demo](https://demo.bugtraceai.com/bugtraceai)** to explore BugTraceAI's interface and see real scan results without installing anything.

---

## Quick Start (Recommended)

The fastest way to get BugTraceAI running is via the Launcher:

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

The interactive wizard will:
1. Check your system requirements (Docker, Git, RAM)
2. Ask you to choose a deployment mode
3. Pull and build Docker images
4. Ask for your OpenRouter API key
5. Configure all services
6. Start the platform
7. Run health checks
8. Display access URLs

After setup completes:
- **WEB Dashboard**: http://localhost:6869
- **CLI API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

---

## Alternative Installation Methods

### WEB Only (No Scanning)

If you only want the AI-powered security toolkit:

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-WEB.git
cd BugTraceAI-WEB
./dockerizer.sh
# Access: http://localhost:6869
```

### CLI Only (API Mode)

If you only want the scanning engine:

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-CLI.git
cd BugTraceAI-CLI
pip install -r requirements.txt
python3 -m uvicorn bugtrace.api.main:app --host 0.0.0.0 --port 8000
# API: http://localhost:8000
# Docs: http://localhost:8000/docs
```

### CLI Only (Docker)

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-CLI.git
cd BugTraceAI-CLI
docker build -t bugtrace-cli .
docker run -d -p 8000:8000 bugtrace-cli
```

### Development Mode

For contributors and developers:

```bash
# WEB (hot reload)
cd BugTraceAI-WEB
npm install
npm run dev
# Access: http://localhost:5173

# CLI (with auto-reload)
cd BugTraceAI-CLI
pip install -r requirements.txt
python3 -m uvicorn bugtrace.api.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## Your First Scan

### Via the WEB Dashboard

1. Open http://localhost:6869 in your browser
2. Navigate to the Scans page
3. Enter a target URL (e.g., a test application you control)
4. Click "Start Scan"
5. Watch real-time progress as the scan runs
6. Review findings when the scan completes
7. Download the report

### Via the API

```bash
# Create and start a scan
curl -X POST http://localhost:8000/api/scans \
  -H "Content-Type: application/json" \
  -d '{"target_url": "https://your-test-target.com"}'

# Note the scan ID from the response
# Check status
curl http://localhost:8000/api/scans/<scan-id>/status

# Get findings
curl http://localhost:8000/api/scans/<scan-id>/findings

# Download report
curl -o report.html http://localhost:8000/api/scans/<scan-id>/report/html
```

### Via the Interactive CLI

```bash
cd BugTraceAI-CLI
python -m bugtrace scan url https://your-test-target.com
```

> **Important**: Only scan targets you own or have explicit authorization to test. Unauthorized scanning is illegal in most jurisdictions.

---

## Using the Security Toolkit

The WEB dashboard includes 20+ AI-powered security tools that work without running scans:

1. Open http://localhost:6869
2. Browse the tool categories in the sidebar
3. Select a tool (e.g., JWT Analyzer, Payload Forge, Code Analyzer)
4. Interact via the chat interface
5. Provide URLs, code snippets, or tokens for analysis
6. Receive AI-powered security analysis

These tools work independently of the CLI scanner. See [Security Toolkit](/security-toolkit) for the complete tool listing.

---

## Configuration

### OpenRouter API Key

If you need to update your API key after installation:

```bash
# Via API
curl -X PATCH http://localhost:8000/api/config \
  -H "Content-Type: application/json" \
  -d '{"OPENROUTER_API_KEY": "sk-or-v1-new-key"}'
```

### Scanning Defaults

Adjust scanning behavior via the API:

```bash
curl -X PATCH http://localhost:8000/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "MAX_DEPTH": 3,
    "MAX_URLS": 500,
    "SAFE_MODE": false,
    "HEADLESS_BROWSER": true
  }'
```

See [Configuration](/configuration) for all available settings.

---

## Deployment Modes

The Launcher supports three deployment modes:

| Mode | What You Get | Command |
|------|-------------|---------|
| **Full Platform** | WEB + CLI, auto-connected | `./launcher.sh` (select Full) |
| **Standalone WEB** | Dashboard and toolkit only | `./launcher.sh` (select WEB) |
| **Standalone CLI** | Headless API scanner **+ MCP server** | `./launcher.sh` (select CLI) |

There is no separate "CLI + AI Assistant" mode: the CLI deployment already starts the MCP server (`bugtrace_mcp` on port 8001) alongside the API, so any **Standalone CLI** (or **Full Platform**) install lets you control scans from [OpenClaw](https://openclaw.com), Claude Code, Cursor, or any MCP-compatible AI assistant. See [AI Assistant Integration](/ai-assistant-integration) for details.

See [Deployment Modes](/deployment-modes) for detailed comparisons.

---

## Lifecycle Management

After installation, manage BugTraceAI with these commands:

```bash
cd BugTraceAI-Launcher

# Check status
./launcher.sh status

# Stop all services
./launcher.sh stop

# Start all services
./launcher.sh start

# Restart
./launcher.sh restart

# Update to latest version
./launcher.sh update

# View logs
./launcher.sh logs

# Uninstall
./launcher.sh uninstall
```

---

## Troubleshooting

### Docker Not Running

```bash
# Check Docker status
docker info

# Start Docker service
sudo systemctl start docker
```

### Port Already in Use

```bash
# Find what is using port 8000
sudo lsof -i :8000

# Or let the Launcher detect and suggest alternatives
./launcher.sh
```

### Permission Denied

```bash
# Add yourself to the docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Cannot Connect WEB to CLI

Verify the CLI API is accessible:
```bash
curl http://localhost:8000/docs
```

Check `VITE_CLI_API_URL` in the WEB configuration points to the correct CLI address.

### Out of Memory

BugTraceAI Full Platform requires at least 4 GB RAM. Check Docker memory allocation:
```bash
docker stats
```

If running Docker Desktop, increase memory in Settings > Resources.

---

## Authenticated Scanning

BugTraceAI can scan authenticated endpoints by providing credentials or tokens:

```bash
# Level 1: Inject a pre-existing token
curl -X POST http://localhost:8000/api/scans \
  -H "Content-Type: application/json" \
  -d '{
    "target_url": "https://your-test-target.com",
    "auth_token": "Bearer eyJhbGciOiJIUzI1NiIs..."
  }'

# Level 2: Automatic login flow
curl -X POST http://localhost:8000/api/scans \
  -H "Content-Type: application/json" \
  -d '{
    "target_url": "https://your-test-target.com",
    "auth": {
      "login_url": "https://your-test-target.com/api/auth/login",
      "credentials": {"username": "testuser", "password": "testpass"}
    }
  }'
```

See [Configuration](/configuration) for full authenticated scanning options.

---

## Next Steps

After your first scan:

- [Scanning Pipeline](/scanning-pipeline) -- Understand how scans work
- [Configuration](/configuration) -- Customize scanning behavior
- [Security Toolkit](/security-toolkit) -- Explore the 20+ analysis tools
- [Report Generation](/report-generation) -- Export and share reports
- [AI Assistant Integration](/ai-assistant-integration) -- Control scans from OpenClaw, Claude Code, or any MCP client
- [API Reference](/api-reference) -- Integrate with your tools and pipelines
- [BugStore](/bugstore) -- Practice scanning against a deliberately vulnerable app

---

## Resources

| Resource | Link |
|----------|------|
| GitHub Organization | [github.com/BugTraceAI](https://github.com/BugTraceAI) |
| CLI Repository | [github.com/BugTraceAI/BugTraceAI-CLI](https://github.com/BugTraceAI/BugTraceAI-CLI) |
| WEB Repository | [github.com/BugTraceAI/BugTraceAI-WEB](https://github.com/BugTraceAI/BugTraceAI-WEB) |
| Launcher Repository | [github.com/BugTraceAI/BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher) |
| API Documentation | http://localhost:8000/docs (when running) |
| Twitter | [@yz9yt](https://x.com/yz9yt) |

---

**See also**: [Overview](/overview) | [Architecture](/architecture) | [Deployment Modes](/deployment-modes)
