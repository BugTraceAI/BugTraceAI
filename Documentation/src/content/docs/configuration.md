---
title: "Configuration"
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
| `auth.credentials.totp_secret` | string | `null` | Optional Base32 TOTP secret used to generate 2FA codes |

Level 1 injects the token as-is. Level 2 posts credentials to the login URL, extracts JWT from the response, and injects it into all subsequent requests. YAML auth configs can also define browser-style login steps and `$totp` placeholders for 2FA flows. See [Scanning Pipeline](/scanning-pipeline) for details.

### YAML Auth Configs

Use `--auth-config` in the CLI or upload the YAML file from WEB's scan form:

```yaml
authentication:
  login_url: "https://target.example/login"
  credentials:
    username: "${TARGET_USER}"
    password: "${TARGET_PASSWORD}"
    totp_secret: "JBSWY3DPEHPK3PXP"
  login_flow:
    - "Enter $username in the email field"
    - "Enter $password in the password field"
    - "Enter $totp in the code field"
    - "Click the login button"
```

Environment variables are substituted before the scan starts. If `totp_secret` is present, BugTraceAI generates a current TOTP code and exposes it to the flow as `$totp`.

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

AI models are specified in `provider/model` format, compatible with the OpenRouter API. Beyond the general-purpose model, BugTraceAI uses a **per-slot taxonomy** so each task can run on the model best suited to it. The example values below reflect the curated OpenRouter pack; the exact per-slot defaults come from the active provider preset (see **Providers and Presets** below).

| Setting | Example | Purpose |
|---------|---------|---------|
| `DEFAULT_MODEL` | `google/gemini-3-flash-preview` | General-purpose tasks, discovery, consolidation |
| `CODE_MODEL` | `deepseek/deepseek-chat-v3-0324` | Code analysis, payload generation, technical reasoning |
| `ANALYSIS_MODEL` | `anthropic/claude-haiku-4.5` | Vulnerability analysis, multi-persona consensus |
| `MUTATION_MODEL` | `deepseek/deepseek-chat-v3-0324` | Payload mutation and diversity (needs a non-refusing model) |
| `SKEPTICAL_MODEL` | `anthropic/claude-haiku-4.5` | Skeptical review inside the DASTySAST agent |
| `REPORTING_MODEL` | `anthropic/claude-haiku-4.5` | PoC enrichment and CVSS scoring |

### Model Format

Models follow the `provider/model` format used by OpenRouter:

```
google/gemini-3-flash-preview
anthropic/claude-haiku-4.5
deepseek/deepseek-chat-v3-0324
openai/gpt-4o
```

### Changing Models

```http
PATCH /api/config
Content-Type: application/json

{
  "DEFAULT_MODEL": "google/gemini-3-flash-preview",
  "ANALYSIS_MODEL": "anthropic/claude-haiku-4.5",
  "MUTATION_MODEL": "deepseek/deepseek-chat-v3-0324"
}
```

Model selection affects cost, speed, and analysis quality. Faster models (Gemini Flash) are good for high-volume tasks; models with stronger anti-hallucination behaviour (Claude Haiku) are preferred for the ANALYSIS, SKEPTICAL and REPORTING slots where honesty matters most.

---

## Providers and Presets

BugTraceAI ships provider presets that bundle a base URL, wire format, key, and a full per-slot model map. Switch the active provider at runtime from the WEB Provider tab or the CLI provider API (see [API Reference](/api-reference)); switching re-applies the whole preset atomically, so the wire format and every provider-scoped model move together.

| Preset | Wire format (`api_format`) | Key env | Notes |
|--------|---------------------------|---------|-------|
| `openrouter` / `openrouter-v2` | OpenAI-compatible | `OPENROUTER_API_KEY` (`sk-or-v1-...`) | Default; `openrouter-v2` is the recommended curated pack |
| `anthropic` | `anthropic` (Messages API, `x-api-key`) | `ANTHROPIC_API_KEY` (`sk-ant-...`) | Single-provider Claude option, no OpenRouter dependency |
| `zai` | OpenAI-compatible | `GLM_API_KEY` | Z.ai / GLM models |

The `api_format` preset field decouples the wire format from the provider. Selecting the `anthropic` preset routes generation, threaded generation, vision and connectivity checks to the Anthropic Messages API (`x-api-key`) instead of the OpenAI-style chat-completions format. Existing OpenRouter/Z.ai behaviour is unchanged.

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
| `REPORTING_FAILOVER_ENABLED` | boolean | `true` | Fall back to a secondary provider for a failed reporting/enrichment call (scoped to reporting only, never the scan) |
| `REPORTING_FAILOVER_PROVIDER` | string | `anthropic` | Provider preset id used only for reporting failover |

When `true`, reports only contain findings with status `VALIDATED_CONFIRMED` or `MANUAL_REVIEW_RECOMMENDED`. When `false`, all findings are included regardless of validation status.

Reporting failover (CLI 3.7.11) retries only the individual PoC/CVSS enrichment call that failed on the active provider; it never changes the scan's provider. See [Report Generation](/report-generation) for the resulting `poc_enrichment_provenance` values and the `reporting_failover_count` meta field.

---

## Model Lab Scoring

The integrated Model Lab (model-eval) benchmark ranks candidate models with a quality-dominant composite. All scoring knobs are externalized (prefixed `MODELLAB_`) so a run stays self-describing; every run records its scoring version and effective weights. Recalibrated in **CLI 3.7.12** from real-scan ground truth.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `MODELLAB_SCORING_VERSION` | string | `v2-quality` | Scoring version stamped onto each run |
| `MODELLAB_W_CORRECTNESS` | float | `0.40` | Composite weight: correctness |
| `MODELLAB_W_SKEPTICISM` | float | `0.30` | Composite weight: skepticism |
| `MODELLAB_W_COMPLIANCE` | float | `0.15` | Composite weight: compliance |
| `MODELLAB_W_PERFORMANCE` | float | `0.15` | Composite weight: performance (latency) |
| `MODELLAB_GATE_MIN_CORRECTNESS` | float | `6.0` | Minimum correctness to pass the quality gate |
| `MODELLAB_GATE_MIN_SKEPTICISM` | float | `7.0` | Minimum skepticism to pass the quality gate |
| `MODELLAB_GATE_MIN_COMPLIANCE` | float | `6.0` | Minimum compliance to pass the quality gate |
| `MODELLAB_FAILURE_PENALTY` | float | `3.0` | Composite penalty scaled by the failure rate |
| `MODELLAB_LATENCY_STAT` | string | `median` | Latency statistic for performance scoring (`median` or `p95`) |
| `MODELLAB_MUTATION_DIVERSITY_WEIGHT` | float | `0.6` | Weight of payload diversity in the MUTATION-slot pick (quality = 1 - this) |

Weights are normalized to sum to 1.0 at read time, so a partial or misconfigured set stays safe. See [API Reference](/api-reference) for the Model Lab endpoints.

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
  default_model: "google/gemini-3-flash-preview"
  code_model: "deepseek/deepseek-chat-v3-0324"
  analysis_model: "anthropic/claude-haiku-4.5"

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

```bash
python -m bugtrace scan url https://target.example --auth-config auth-config.yaml
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
