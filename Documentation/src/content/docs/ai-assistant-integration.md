---
title: "AI Assistant Integration (MCP)"
---

# AI Assistant Integration (MCP)

BugTraceAI is **MCP-compatible** — you can control security scans directly from your AI assistant through natural conversation.

---

## What is MCP?

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io) is an open standard that lets AI assistants connect to external tools. BugTraceAI exposes its scanning engine as MCP tools via SSE (Server-Sent Events) transport, so your AI assistant can start scans, monitor progress, query findings, and retrieve reports — all through chat.

---

## Compatible AI Assistants

BugTraceAI works with any MCP-compatible client:

| Assistant | Type | MCP Support |
|-----------|------|-------------|
| [**OpenClaw**](https://openclaw.com) | Telegram-based AI assistant | Native MCP via mcporter |
| **Claude Code** | CLI AI assistant | Native MCP support |
| **Cursor** | AI-powered IDE | Native MCP support |
| **Windsurf** | AI-powered IDE | Native MCP support |
| Any MCP client | Various | SSE transport on port 8001 |

---

## Quick Setup with OpenClaw

[OpenClaw](https://openclaw.com) is a Telegram-based AI assistant that can install and control BugTraceAI for you. If you already have OpenClaw running, just send it this message:

> Clone https://github.com/BugTraceAI/BugTraceAI-CLI and deploy it with Docker. Copy `.env.example` to `.env` and ask me for the `OPENROUTER_API_KEY`. Run `docker compose up -d` to start both the API and MCP server. Then add the MCP server to your mcporter config with base URL `http://localhost:8001/sse`.

OpenClaw will:
1. Clone the repository
2. Ask you for the API key
3. Configure the environment
4. Start the Docker containers
5. Connect the MCP server to its tool registry

After setup, you can control BugTraceAI directly from Telegram:
- *"Scan https://example.com for vulnerabilities"*
- *"What's the status of my scan?"*
- *"Show me the critical findings"*
- *"Give me the report summary"*

---

## Manual MCP Setup

### 1. Deploy BugTraceAI

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-CLI
cd BugTraceAI-CLI
cp .env.example .env
# Edit .env and add your OPENROUTER_API_KEY
docker compose up -d
```

This starts two services:

| Service | Port | Description |
|---------|------|-------------|
| API | 8000 | REST API + health check |
| MCP | 8001 | SSE transport for AI assistants |

### 2. Verify

```bash
curl -f http://localhost:8000/health   # API health check
curl -sf http://localhost:8001/sse     # MCP SSE endpoint
```

### 3. Connect Your AI Assistant

Add BugTraceAI to your MCP client configuration:

```json
{
  "mcpServers": {
    "bugtraceai": {
      "baseUrl": "http://localhost:8001/sse",
      "description": "BugTraceAI Security Scanner"
    }
  }
}
```

---

## Using the Launcher

The [BugTraceAI-Launcher](/bugtraceai-launcher) starts the MCP server automatically with any CLI deployment — there is no separate menu option for it. Just install the CLI:

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher
cd BugTraceAI-Launcher
./launcher.sh
# Select: Standalone CLI  (or Full Platform)
```

The CLI container runs both `bugtrace_api` (port 8000) and `bugtrace_mcp` (port 8001). The wizard will:
- Configure the API (and the MCP server on 8001)
- Set up the environment
- Start the services
- Display the MCP configuration snippet ready to copy

See [Deployment Modes](/deployment-modes) for all available modes.

---

## Available MCP Tools

Once connected, your AI assistant has access to these tools:

### `start_scan`

Start a new security scan on a target URL.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target_url` | string | required | URL to scan (HTTP/HTTPS) |
| `scan_type` | string | `"full"` | Scan type: `full`, `hunter`, `manager` |
| `max_depth` | int | `2` | Crawl depth (1-5) |
| `max_urls` | int | `20` | Max URLs to scan (1-100) |

### `get_scan_status`

Check scan progress and current phase.

| Parameter | Type | Description |
|-----------|------|-------------|
| `scan_id` | int | The scan ID to check |

Returns: status, progress percentage, findings count, active agent, current phase, and uptime.

### `query_findings`

Retrieve vulnerability findings with optional filtering.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `scan_id` | int | required | The scan ID to query |
| `severity` | string | all | Filter: `critical`, `high`, `medium`, `low`, `info` |
| `vuln_type` | string | all | Filter: `xss`, `sqli`, `csrf`, etc. |
| `page` | int | `1` | Page number |
| `per_page` | int | `20` | Results per page (1-100) |

### `stop_scan`

Stop a running scan gracefully, allowing current tasks to complete.

| Parameter | Type | Description |
|-----------|------|-------------|
| `scan_id` | int | The scan ID to stop |

### `export_report`

Export a scan report in different detail levels.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `scan_id` | int | required | The scan ID to export |
| `section` | string | `"summary"` | Detail level: `summary`, `critical`, or `full` |

- **`summary`**: Executive overview with severity counts and top findings (~2-3 KB)
- **`critical`**: Detailed critical and high severity findings with payloads (~4-6 KB)
- **`full`**: Complete report (truncated to 8 KB to avoid LLM context overflow)

---

## Example Conversation (OpenClaw via Telegram)

```
You: Scan https://bugstore.bugtraceai.com for vulnerabilities

OpenClaw: Starting a security scan on bugstore.bugtraceai.com...
          Scan #1 created successfully. I'll monitor the progress.

You: How's the scan going?

OpenClaw: Scan #1 is at 45% — currently in the Exploitation phase.
          Found 12 vulnerabilities so far (3 critical, 4 high).
          Active agent: XSSAgent

You: Show me the critical findings

OpenClaw: Here are the critical findings from scan #1:
          1. [CRITICAL] SQL Injection — /api/products?category=...
          2. [CRITICAL] RCE — /api/admin/exec?cmd=...
          3. [CRITICAL] Weak JWT Secret — cracked via dictionary attack

You: Give me the full report

OpenClaw: [Sends the executive summary with all findings, severity breakdown,
           and remediation recommendations]
```

---

## Prerequisites

- **Docker & Docker Compose** installed and running
- **OpenRouter API key** ([get one here](https://openrouter.ai/keys)) — required for BugTraceAI's AI-powered analysis
- An MCP-compatible AI assistant

---

## Troubleshooting

### MCP endpoint not responding

```bash
# Check if the MCP container is running
docker ps | grep bugtrace_mcp

# Check MCP logs
docker logs bugtrace_mcp

# Verify the endpoint
curl -sf http://localhost:8001/sse
```

### AI assistant can't connect

- Verify the `baseUrl` in your MCP config matches the actual endpoint
- If running on a remote server, replace `localhost` with the server IP
- Check firewall rules allow port 8001

### Scan starts but AI doesn't get results

- The scan runs in the background — use `get_scan_status` to check progress
- Reports are only available after the scan completes
- Use `export_report` with `section="summary"` for the fastest response

---

**See also**: [Deployment Modes](/deployment-modes) | [Getting Started](/getting-started) | [BugTraceAI-CLI](/bugtraceai-cli) | [API Reference](/api-reference)
