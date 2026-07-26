---
title: "API Reference"
---

# API Reference

The BugTraceAI-CLI exposes a REST API via FastAPI on port 8000. This API provides complete programmatic access to scan management, findings, reports, configuration, and metrics. The API follows the OpenAPI 3.1 specification.

---

## Base URL

```
http://localhost:8000
```

Interactive API documentation (Swagger UI) is available at:

```
http://localhost:8000/docs
```

---

## Scan Management

### Create a Scan

```http
POST /api/scans
Content-Type: application/json

{
  "target_url": "https://example.com",
  "scan_type": "full",
  "resume": false,
  "auth": {
    "login_url": "https://example.com/login",
    "credentials": {
      "username": "user@example.com",
      "password": "${TARGET_PASSWORD}",
      "totp_secret": "JBSWY3DPEHPK3PXP"
    }
  },
  "config": {
    "max_depth": 3,
    "max_urls": 500,
    "safe_mode": false
  }
}
```

**Response** (201 Created):
```json
{
  "id": "scan_abc123",
  "status": "QUEUED",
  "target_url": "https://example.com",
  "origin": "web",
  "created_at": "2026-02-10T14:30:00Z"
}
```

The `origin` field indicates where the scan was launched from:

| Value | Meaning |
|-------|---------|
| `"cli"` | Scan launched from the CLI directly |
| `"web"` | Scan launched from the WEB dashboard |
| `"unknown"` | Origin could not be determined |

### List Scans

```http
GET /api/scans
```

Returns all scans with their current status.

### Get Scan Status

```http
GET /api/scans/{id}/status
```

**Response**:
```json
{
  "id": "scan_abc123",
  "status": "RUNNING",
  "phase": "exploitation",
  "progress": 65,
  "findings_count": 12,
  "active_agents": ["XSS", "SQLi"],
  "elapsed_seconds": 342
}
```

### Stop a Scan

```http
POST /api/scans/{id}/stop
```

### Pause a Scan

```http
POST /api/scans/{id}/pause
```

### Resume a Scan

```http
POST /api/scans/{id}/resume
```

Resumes scans that have recoverable state, including scans paused by the circuit breaker, interrupted connections, or manual pauses. If system concurrency limits are reached, the API returns HTTP 429 instead of starting unbounded resume work.

### Delete a Scan

```http
DELETE /api/scans/{id}
```

Deletes scan metadata and performs cleanup using the scan origin and lifecycle state to avoid removing unrelated reports.

### Authenticated Scan Payloads

The scan creation payload accepts an optional `auth` object. WEB normally builds this object from an uploaded YAML auth config.

| Field | Description |
|-------|-------------|
| `auth.login_url` | Login endpoint used before scanning protected pages |
| `auth.credentials.username` | Username or email value |
| `auth.credentials.password` | Password value, usually substituted from an environment variable before submission |
| `auth.credentials.totp_secret` | Optional Base32 TOTP secret used to generate `$totp` codes for 2FA flows |
| `resume` | Start from recoverable state when available |

---

## Findings

### Get Scan Findings

```http
GET /api/scans/{id}/findings
```

**Response**:
```json
{
  "findings": [
    {
      "id": "finding_001",
      "type": "XSS",
      "subtype": "reflected",
      "severity": "HIGH",
      "confidence": 0.92,
      "url": "https://example.com/search?q=test",
      "parameter": "q",
      "payload": "<script>alert(1)</script>",
      "validation_status": "VALIDATED_CONFIRMED",
      "agent": "XSS",
      "discovered_at": "2026-02-10T14:35:22Z"
    }
  ],
  "total": 12
}
```


---

## Reports

### Generate Report

```http
GET /api/scans/{id}/report/{format}
```

**Supported formats**:

| Format | Content-Type | Description |
|--------|-------------|-------------|
| `html` | `text/html` | Interactive HTML viewer with filtering and sorting |
| `json` | `application/json` | Machine-readable structured data |
| `markdown` | `text/markdown` | Human-readable Markdown document |

### Download Report as ZIP

```http
GET /api/scans/{id}/report-zip
```

**Response**: Binary ZIP file containing the complete report directory (final report, validated findings, specialist results, reconnaissance data, PoC enrichment, and all evidence files).

```bash
curl -o report.zip http://localhost:8000/api/scans/{id}/report-zip
```

### Get Report Files

```http
GET /api/scans/{id}/files/{filename}
```

Returns individual files associated with a scan report (e.g., screenshots, evidence files).

---

## Configuration

### Get Current Configuration

```http
GET /api/config
```

**Response**:
```json
{
  "SAFE_MODE": false,
  "MAX_DEPTH": 3,
  "MAX_URLS": 500,
  "DEFAULT_MODEL": "google/gemini-3-flash-preview",
  "CODE_MODEL": "deepseek/deepseek-chat-v3-0324",
  "ANALYSIS_MODEL": "anthropic/claude-haiku-4.5",
  "HEADLESS_BROWSER": true,
  "EARLY_EXIT_ON_FINDING": false,
  "STOP_ON_CRITICAL": false,
  "REPORT_ONLY_VALIDATED": true,
  "OPENROUTER_API_KEY": "sk-or-...****"
}
```

Note: API keys are **masked** in GET responses for security.

### Update Configuration

```http
PATCH /api/config
Content-Type: application/json

{
  "MAX_DEPTH": 5,
  "SAFE_MODE": true
}
```

See [Configuration](/configuration) for details on all configuration options.

---

## Metrics

### Get Scan Metrics

```http
GET /api/scans/{id}/detailed-metrics
```

Returns performance metrics for a specific scan including depth reached, URLs processed, throughput, and per-agent statistics.

### Get Global Metrics

```http
GET /api/metrics
```

Returns aggregate metrics across all scans. Sub-resources expose specific subsystems:

| Endpoint | Returns |
|----------|---------|
| `GET /api/metrics/queues` | Per-specialist queue depths and throughput |
| `GET /api/metrics/cdp` | Chrome DevTools Protocol validation metrics |
| `GET /api/metrics/parallelization` | Concurrency / worker utilization |
| `GET /api/metrics/deduplication` | Finding-deduplication statistics |
| `POST /api/metrics/reset` | Reset in-memory metrics counters |

### Re-enrich a Scan

```http
POST /api/scans/{id}/re-enrich
```

Re-runs PoC/evidence enrichment over an existing scan's findings without re-scanning.

---

## Provider Management

Manage the active LLM provider/preset used by the CLI.

| Endpoint | Purpose |
|----------|---------|
| `GET /api/providers` | List available provider presets (e.g. `openrouter`, `openrouter-v2`, `anthropic`, `zai`) |
| `GET /api/provider` | Get the currently active provider |
| `GET /api/providers/{id}` | Get a specific provider preset |
| `PUT /api/provider` | Switch the active provider |
| `POST /api/provider/test` | Test connectivity / key for a provider |
| `PATCH /api/provider/models` | Update the per-task model assignment |

---

## Model Lab

The integrated Model Lab (model-eval) benchmark compares OpenRouter models through the CLI API. It can run with its **own** OpenRouter key, independent of the scanner's active provider: the GET endpoints accept the key via an `X-OpenRouter-Key` header, and `POST /api/model-eval` accepts it as an `api_key` field in the request body. Without a supplied key, the active provider's key is used. The key always stays server-side.

| Endpoint | Purpose |
|----------|---------|
| `GET /api/model-eval/models` | Proxy the OpenRouter model catalog (id, name, pricing) |
| `GET /api/model-eval/test-key` | Validate an OpenRouter key against OpenRouter's authenticated `/key` endpoint (returns label/credit, consumes no tokens) before running a benchmark |
| `POST /api/model-eval` | Start a benchmark job; returns the job id and a WebSocket URL for live progress |
| `GET /api/model-eval/{job_id}/results` | Fetch results for a job |
| `DELETE /api/model-eval/{job_id}` | Cancel a running job |
| `GET /api/model-eval/history` | List recent benchmark runs |
| `GET /api/model-eval/history/{run_id}` | Fetch one persisted run with its ranked results |
| `DELETE /api/model-eval/history/{run_id}` | Delete a single persisted run |

### Start a Benchmark

```http
POST /api/model-eval
Content-Type: application/json

{
  "models": ["google/gemini-3-flash-preview", "anthropic/claude-haiku-4.5"],
  "suite_id": "quick-v3",
  "runs": 2,
  "mutation_probe": false,
  "api_key": "sk-or-v1-..."
}
```

The benchmark scores candidates with a quality-dominant composite and reports a per-slot leaderboard (best model for the MUTATION / SKEPTICAL / ANALYSIS / REPORTING slots). Suites: `quick-v3` (default) and `advanced-v2`. See [Configuration](/configuration) for the `MODELLAB_*` scoring knobs.

### Validate a Key

```http
GET /api/model-eval/test-key
X-OpenRouter-Key: sk-or-v1-...
```

### Live Progress (WebSocket)

```
/api/ws/model-eval/{job_id}
```

Streams per-model progress events while a benchmark runs, mirroring the REST job state.

---

## Health

| Endpoint | Purpose |
|----------|---------|
| `GET /health` | Liveness + status (version, provider readiness, active scans) |
| `GET /ready` | Readiness probe |
| `GET /` | Root info |

---

## WebSocket Endpoints

In addition to REST, the CLI provides WebSocket endpoints for real-time event streaming:

| Endpoint | Purpose |
|----------|---------|
| `/api/ws/scans/{id}` | Per-scan real-time events |
| `/api/ws/global` | Global events across all scans |

See [WebSocket Events](/websocket-events) for the full event protocol.

---

## Authentication

The CLI API supports API key authentication via the `Authorization` header:

```http
Authorization: Bearer <api-key>
```

API key configuration is managed through the CLI configuration file or environment variables.

---

## Error Responses

All error responses follow a consistent format:

```json
{
  "detail": "Scan not found",
  "status_code": 404
}
```

### Common Status Codes

| Code | Meaning |
|------|---------|
| `200` | Success |
| `201` | Resource created |
| `400` | Bad request (invalid parameters) |
| `404` | Resource not found |
| `409` | Conflict (e.g., scan already running) |
| `422` | Validation error |
| `500` | Internal server error |

---

## Rate Limiting

The API does not impose rate limits by default. In production deployments, rate limiting should be configured at the reverse proxy level (e.g., Nginx).

---

## OpenAPI Specification

The full OpenAPI 3.1 specification is auto-generated by FastAPI and available at:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **JSON Spec**: `http://localhost:8000/openapi.json`

---

**Parent**: [Architecture](/architecture)

**See also**: [WebSocket Events](/websocket-events) | [Configuration](/configuration) | [BugTraceAI-CLI](/bugtraceai-cli)
