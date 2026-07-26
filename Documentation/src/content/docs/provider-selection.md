---
title: "Provider Selection"
---

# Provider Selection

BugTraceAI supports three first-class LLM providers. A scan runs against **one** provider for its entire duration -- providers are never mixed mid-scan. You select the active provider up front, and each scanner slot draws its model from that provider's preset (with optional per-slot overrides).

---

## Supported Providers

| Provider | Wire format | Key | Notes |
|----------|-------------|-----|-------|
| **OpenRouter** | OpenAI-compatible `/chat/completions` | `OPENROUTER_API_KEY` | Default and recommended. One key, 200+ models across many upstream providers -- pick the best model per task |
| **Anthropic (direct)** | Anthropic Messages API | `ANTHROPIC_API_KEY` | Direct Claude API via `x-api-key`. Single-provider option (CLI 3.7.5 / WEB 1.5.33) |
| **Z.ai** | OpenAI-compatible `/chat/completions` | `GLM_API_KEY` | Direct Z.ai API using the GLM model family. Single-provider option |

Each provider ships as a **preset**: selecting it auto-configures the model for every scanner slot. You can still override individual slot models afterward.

---

## OpenRouter (Default)

OpenRouter is the recommended provider. A single OpenRouter key gives access to 200+ models from multiple upstream providers, so each scanner slot can use the best-suited model for its task (a diverse mutation model, a precise skeptical model, and so on).

```
OPENROUTER_API_KEY="sk-or-v1-..."
```

The recommended OpenRouter preset is tuned against an anti-BS benchmark for the security-reasoning slots.

---

## Anthropic (Direct API)

Anthropic is a first-class provider using an **API key** (`x-api-key`) against the Claude Messages API. Selecting the `anthropic` preset routes generation, threaded generation, vision, and connectivity checks to the Messages API.

```
ANTHROPIC_API_KEY="sk-ant-..."
```

### The `api_format` Field

Anthropic uses a different HTTP wire format than the OpenAI-compatible providers. A preset field named `api_format` (`apiFormat` in the WEB provider config) **decouples the wire format from the base URL**, so the client knows to build Anthropic-style requests (`x-api-key` header, top-level `system`, `content[]` blocks) instead of an OpenAI-style chat-completions body. OpenRouter and Z.ai keep the `openai` wire format; Anthropic uses `anthropic`.

> This API-key provider is distinct from an OAuth-based Claude mode. To use the API-key provider, select the `anthropic` preset and supply `ANTHROPIC_API_KEY`.

---

## Z.ai (GLM Family)

Z.ai is a direct, single-provider option using the GLM model family (for example `glm-4.7-flash`, `glm-4.6`, `glm-4.5`). It uses the OpenAI-compatible wire format.

```
GLM_API_KEY="..."
```

---

## Selecting a Provider

### In BugTraceAI-WEB

Use the **Provider** tab:

1. Select a provider preset.
2. Enter the provider's API key and click **Test** to validate it (the correct wire format is used per provider, so a valid Anthropic key is not misreported as invalid).
3. Click **Save**.

Switching providers at runtime re-applies the full provider configuration -- base URL, key, `api_format`, and every provider-scoped attribute -- as a single unit, so no stale wire format is left behind.

### In the CLI Configuration

The active provider is set in the `[PROVIDER]` section of `bugtraceaicli.conf`:

```ini
[PROVIDER]
# openrouter (recommended) | zai | anthropic
ACTIVE = openrouter
```

Changing the provider auto-configures all slot models from that provider's preset. Provider API keys are read from the environment (`.env`): `OPENROUTER_API_KEY`, `GLM_API_KEY`, or `ANTHROPIC_API_KEY`.

---

## One Provider Per Scan

A scan uses a single active provider from start to finish. BugTraceAI does not mix providers mid-scan, and switching providers does not affect a scan already in progress.

The one scoped exception is **reporting/enrichment failover**: if a PoC or CVSS enrichment call fails or degrades at reporting time, the reporting layer can fall back to a secondary provider **for that single enrichment call only**. This never changes the scan's active provider or mixes providers during detection. It is configurable via `REPORTING_FAILOVER_ENABLED` and `REPORTING_FAILOVER_PROVIDER` (default: enabled, falling back to `anthropic`). See [Report Generation](/report-generation) for details.

---

## Per-Slot Model Configuration

Within the active provider, each scanner slot draws its own model. Presets set sensible defaults; you can override any slot in the `[LLM_MODELS]` configuration section. The slots that Model Lab benchmarks map directly to these keys:

| Slot | Config key | Role |
|------|-----------|------|
| MUTATION | `MUTATION_MODEL` | Payload mutation / WAF bypass generation |
| SKEPTICAL | `SKEPTICAL_MODEL` | Per-finding skeptical review |
| ANALYSIS | `ANALYSIS_MODEL` | DASTySAST high-volume per-URL analysis |
| REPORTING | `REPORTING_MODEL` | Report enrichment (CVSS + PoC) |

Other slots include `DEFAULT_MODEL` (orchestration and strategy), `CODE_MODEL` (payload/bypass logic), and `VISION_MODEL` (screenshot validation).

Use [Model Lab](/model-lab) to benchmark candidate models per slot before committing to an assignment.

---

**Parent**: [Configuration](/configuration)

**See also**: [Model Lab](/model-lab) | [Configuration](/configuration) | [Report Generation](/report-generation)
