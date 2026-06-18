---
title: Api Reference
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
  "DEFAULT_MODEL": "qwen/qwen3-coder",
  "CODE_MODEL": "qwen/qwen3-coder",
  "ANALYSIS_MODEL": "qwen/qwen3-coder",
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

See [[Configuration]] for details on all configuration options.

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
| `GET /api/providers` | List available provider presets (e.g. `openrouter`, `openrouter-v2`, `zai`) |
| `GET /api/provider` | Get the currently active provider |
| `GET /api/providers/{id}` | Get a specific provider preset |
| `PUT /api/provider` | Switch the active provider |
| `POST /api/provider/test` | Test connectivity / key for a provider |
| `PATCH /api/provider/models` | Update the per-task model assignment |

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

See [[WebSocket Events]] for the full event protocol.

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

**Parent**: [[Architecture]]

**See also**: [[WebSocket Events]] | [[Configuration]] | [[BugTraceAI-CLI]]
