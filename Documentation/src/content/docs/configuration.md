---
title: Configuration
---

# Configuration

BugTraceAI-CLI is configured via the REST API and environment variables. Configuration controls scanning behavior, AI model selection, safety limits, and reporting preferences.

---

## API Configuration

### Get Current Configuration

```http
GET /api/config
```

### Update Configuration

```http
PATCH /api/config
Content-Type: application/json

{
  "MAX_DEPTH": 5,
  "SAFE_MODE": true
}
```

Only the fields included in the PATCH request are updated. All other settings retain their current values.

---

## Scanning Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `SAFE_MODE` | boolean | `false` | Limits exploitation aggressiveness. When true, avoids destructive payloads |
| `MAX_DEPTH` | integer | `3` | Maximum crawl depth during the discovery phase |
| `MAX_URLS` | integer | `500` | Maximum number of URLs to process during discovery |
| `EARLY_EXIT_ON_FINDING` | boolean | `false` | Stop the scan after the first confirmed finding |
| `STOP_ON_CRITICAL` | boolean | `false` | Stop the scan when a CRITICAL severity finding is confirmed |

### Circuit Breaker

The circuit breaker automatically pauses scanning when the target becomes unresponsive, preventing wasted API calls and protecting the target.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `DAST_CONSECUTIVE_TIMEOUT_LIMIT` | integer | `5` | Pause after this many consecutive request timeouts |
| `DAST_TIMEOUT_PERCENT_LIMIT` | integer | `50` | Pause if the percentage of timed-out requests exceeds this threshold |
| `DAST_ANALYSIS_TIMEOUT` | integer | `30` | Timeout in seconds for individual DAST analysis requests |

When the circuit breaker triggers, all active specialist agents are paused and a `circuit_breaker` event is emitted to connected WEB dashboards. The scan can be resumed once the target recovers.

### URL Pattern Deduplication

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `URL_PATTERN_DEDUP` | boolean | `true` | Deduplicate URLs that follow similar patterns (e.g., `/products/1` and `/products/2`) |

When enabled, only structurally unique URL patterns are forwarded to specialist agents, reducing redundant testing without sacrificing coverage.

### Authenticated Scanning

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `auth_token` | string | `null` | Pre-existing auth token (Level 1) -- injected directly into all agent requests |
| `auth.login_url` | string | `null` | Login endpoint URL (Level 2) |
| `auth.credentials` | object | `null` | Username/password for automatic login (Level 2) |

Level 1 injects the token as-is. Level 2 posts credentials to the login URL, extracts JWT from the response, and injects it into all subsequent requests. See [Scanning Pipeline](/scanning-pipeline) for details.

### SAFE_MODE

When `SAFE_MODE` is enabled:
- No destructive payloads are used (e.g., no DROP TABLE)
- Rate limiting is more conservative
- Exploitation attempts are limited per target
- Payloads that could cause data modification are avoided

Use `SAFE_MODE` for production environments or when scanning targets you do not own.

### MAX_DEPTH and MAX_URLS

These settings control the scope of the discovery phase:
- `MAX_DEPTH`: How many link levels deep the crawler will follow (1 = only the target page, 3 = three levels of links)
- `MAX_URLS`: Hard cap on the total number of URLs processed

Increasing these values extends scan coverage but increases scan duration.

---

## AI Model Selection

AI models are specified in `provider/model` format, compatible with the OpenRouter API.

| Setting | Default | Purpose |
|---------|---------|---------|
| `DEFAULT_MODEL` | `google/gemini-2.5-flash` | General-purpose tasks, discovery, consolidation |
| `CODE_MODEL` | `anthropic/claude-sonnet-4` | Code analysis, payload generation, technical reasoning |
| `ANALYSIS_MODEL` | `google/gemini-2.5-pro` | Vulnerability analysis, multi-persona consensus |

### Model Format

Models follow the `provider/model` format used by OpenRouter:

```
google/gemini-2.5-flash
anthropic/claude-sonnet-4
openai/gpt-4o
meta-llama/llama-3.1-70b-instruct
```

### Changing Models

```http
PATCH /api/config
Content-Type: application/json

{
  "DEFAULT_MODEL": "openai/gpt-4o",
  "CODE_MODEL": "anthropic/claude-sonnet-4",
  "ANALYSIS_MODEL": "google/gemini-2.5-pro"
}
```

Model selection affects cost, speed, and analysis quality. Faster models (Gemini Flash) are good for high-volume tasks. Larger models (Gemini Pro, Claude Sonnet) provide better analysis quality.

---

## Browser Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `HEADLESS_BROWSER` | boolean | `true` | Enable Playwright Chromium for validation |

When `HEADLESS_BROWSER` is `false`:
- Phase 5 (Validation) is skipped
- Findings retain `PENDING_VALIDATION` status
- Useful in environments where Chromium cannot run (minimal containers, CI runners)

---

## Report Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `REPORT_ONLY_VALIDATED` | boolean | `true` | Only include validated findings in reports |

When `true`, reports only contain findings with status `VALIDATED_CONFIRMED` or `MANUAL_REVIEW_RECOMMENDED`. When `false`, all findings are included regardless of validation status.

---

## API Keys

### OpenRouter API Key

Required for AI functionality. Set via environment variable or API:

```bash
# Environment variable
export OPENROUTER_API_KEY="sk-or-v1-..."
```

```http
PATCH /api/config
Content-Type: application/json

{
  "OPENROUTER_API_KEY": "sk-or-v1-..."
}
```

### Key Masking

When retrieving configuration via `GET /api/config`, API keys are **masked** for security:

```json
{
  "OPENROUTER_API_KEY": "sk-or-...****"
}
```

The full key is never returned in API responses.

---

## Environment Variables

Configuration can also be set via environment variables. Environment variables take precedence over API-set values.

| Variable | Description |
|----------|-------------|
| `OPENROUTER_API_KEY` | OpenRouter API key for AI models |
| `BUGTRACE_HOST` | FastAPI bind address (default: `0.0.0.0`) |
| `BUGTRACE_PORT` | FastAPI port (default: `8000`) |
| `BUGTRACE_DB_PATH` | Path to SQLite database file |
| `BUGTRACE_LOG_LEVEL` | Logging level (DEBUG, INFO, WARNING, ERROR) |

---

## Configuration File

The CLI also supports a YAML configuration file at `~/.bugtrace/config.yaml`:

```yaml
openrouter:
  api_key: "sk-or-v1-..."
  default_model: "google/gemini-2.5-flash"
  code_model: "anthropic/claude-sonnet-4"
  analysis_model: "google/gemini-2.5-pro"

scanning:
  max_depth: 3
  max_urls: 500
  safe_mode: false
  headless_browser: true

reporting:
  report_only_validated: true
```

**File permissions**: Set `chmod 600 ~/.bugtrace/config.yaml` to protect the API key.

### Configuration Precedence

1. **Environment variables** (highest priority)
2. **API-set values** (via PATCH /api/config)
3. **Configuration file** (`~/.bugtrace/config.yaml`)
4. **Built-in defaults** (lowest priority)

---

## Example Configurations

### Conservative (Production Target)

```json
{
  "SAFE_MODE": true,
  "MAX_DEPTH": 2,
  "MAX_URLS": 200,
  "EARLY_EXIT_ON_FINDING": false,
  "STOP_ON_CRITICAL": true,
  "REPORT_ONLY_VALIDATED": true,
  "HEADLESS_BROWSER": true,
  "DAST_CONSECUTIVE_TIMEOUT_LIMIT": 3,
  "DAST_TIMEOUT_PERCENT_LIMIT": 30
}
```

### Aggressive (Bug Bounty)

```json
{
  "SAFE_MODE": false,
  "MAX_DEPTH": 5,
  "MAX_URLS": 2000,
  "EARLY_EXIT_ON_FINDING": false,
  "STOP_ON_CRITICAL": false,
  "REPORT_ONLY_VALIDATED": false,
  "HEADLESS_BROWSER": true,
  "DAST_CONSECUTIVE_TIMEOUT_LIMIT": 10,
  "DAST_TIMEOUT_PERCENT_LIMIT": 70
}
```

### Authenticated Scan

```json
{
  "SAFE_MODE": false,
  "MAX_DEPTH": 3,
  "MAX_URLS": 500,
  "HEADLESS_BROWSER": true,
  "auth": {
    "login_url": "https://target.com/api/auth/login",
    "credentials": {
      "username": "testuser",
      "password": "testpass"
    }
  }
}
```

### CI/CD (Quick Scan)

```json
{
  "SAFE_MODE": true,
  "MAX_DEPTH": 2,
  "MAX_URLS": 100,
  "EARLY_EXIT_ON_FINDING": true,
  "STOP_ON_CRITICAL": true,
  "REPORT_ONLY_VALIDATED": true,
  "HEADLESS_BROWSER": false
}
```

---

**Parent**: [BugTraceAI-CLI](/bugtraceai-cli)

**See also**: [API Reference](/api-reference) | [Scanning Pipeline](/scanning-pipeline) | [Report Generation](/report-generation)
