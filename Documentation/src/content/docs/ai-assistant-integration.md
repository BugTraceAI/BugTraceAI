---
title: "AI Assistant Integration"
---

# AI Assistant Integration

BugTraceAI exposes separate Model Context Protocol (MCP) services for the CLI scanner and API-security engine. Connect only from a trusted environment and only for targets you are authorized to test.

## Available MCP services

| Service | Installed by Launcher | Endpoint variable | Transport |
|---|---|---|---|
| **CLI MCP** | Full Platform and Standalone CLI | `MCP_PORT` | SSE endpoint at `/sse` |
| **API MCP** | Full Platform and Standalone WEB | `BTAI_MCP_PORT` | Streamable HTTP at `/mcp`, with compatible legacy SSE fallback |

The CLI MCP service controls CLI autonomous scans. The API MCP service controls the standalone BugTraceAI-API workflow. They have different tool sets and data stores.

## Get the selected endpoints

The Launcher selects and saves ports during setup. Do not copy a numeric port from an example—use the configured values printed by `status`:

```bash
cd BugTraceAI-Launcher
./launcher.sh status

export CLI_MCP_URL="http://localhost:${MCP_PORT}/sse"
export BTAI_MCP_URL="http://localhost:${BTAI_MCP_PORT}/mcp"
```

For remote clients, replace `localhost` with the protected reverse-proxy or management-network address. Use TLS and authentication before exposing either service outside a trusted network.

## Tool boundaries

### CLI MCP

CLI MCP is for the autonomous scanner: starting authorized scans, checking state, retrieving findings, and exporting CLI reports. It uses the CLI service's selected REST/MCP configuration and CLI data store.

### API MCP

API MCP provides these API-security operations:

- `api_scan`
- `get_scan_status`
- `get_results`
- `stop_scan`
- `investigate_api`

API-launched scans retain `engine: api` and `launch_origin: api` provenance. Results and report archives remain in the API service's mounted report storage.

## Configure an MCP client

Every MCP client names transport fields differently. Use the endpoint selected by the Launcher in your client's Streamable HTTP or SSE configuration. A conceptual configuration is:

```json
{
  "mcpServers": {
    "bugtrace-cli": { "url": "${CLI_MCP_URL}" },
    "bugtrace-api": { "url": "${BTAI_MCP_URL}" }
  }
}
```

Some clients expose separate `transport`, `baseUrl`, or command fields. Consult that client's documentation; the important part is that the endpoint comes from deployment state rather than a hard-coded port.

## Safety and data handling

- Keep provider credentials in generated environment files or the service's local provider configuration; never put them in MCP configuration committed to source control.
- Reports and tool results may contain endpoint details, evidence, payloads, and response excerpts. Treat assistant chat history and exported artifacts as sensitive.
- Do not grant a remote assistant unrestricted network reachability simply because it can call an MCP tool.

**See also**: [BugTraceAI-API](/bugtraceai-api) | [BugTraceAI-CLI](/bugtraceai-cli) | [BugTraceAI-Launcher](/bugtraceai-launcher) | [Deployment Modes](/deployment-modes)
