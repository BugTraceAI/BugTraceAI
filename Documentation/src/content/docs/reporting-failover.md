---
title: "Reporting Failover"
---

# Reporting Failover

Reporting failover is a scoped resilience mechanism in BugTraceAI-CLI that keeps reports fully enriched even when the active scan provider is failing or saturated at reporting time. When a PoC or CVSS enrichment LLM call fails, the reporting layer falls back to a secondary provider **for that one enrichment call only**. Introduced in CLI 3.7.11.

---

## Overview

At the end of a scan, the reporting phase enriches findings with LLM-generated deliverables -- CVSS scoring and proof-of-concept write-ups. If the scan's active provider (for example OpenRouter) arrives at reporting time degraded, timed out, or saturated, those enrichment calls can fail and leave the report empty or un-enriched.

Reporting failover prevents that. When an enrichment call on the active provider fails or degrades (circuit-breaker fallback, timeout, saturation), the reporting layer retries that **single** call against a secondary provider.

**Key guarantee:** failover is scoped strictly to the individual enrichment call. It **never changes the scan's active provider and never mixes providers during the scan** -- detection and exploitation always ran, and continue to run, on the one provider you selected. Only the isolated reporting/enrichment call is allowed to recover elsewhere.

The failover call is self-contained and one-shot, built entirely from the fallback provider's own preset (base URL, key, wire format / `api_format`, and `REPORTING_MODEL`). Anthropic (API key) is supported natively as a fallback target.

---

## Configuration

Reporting failover is controlled by two settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `REPORTING_FAILOVER_ENABLED` | enabled | Whether reporting/enrichment failover is active |
| `REPORTING_FAILOVER_PROVIDER` | `anthropic` | The secondary provider used only for a failed enrichment call |

With the defaults, a failed PoC/CVSS enrichment call falls back to Anthropic. Set `REPORTING_FAILOVER_ENABLED` to off to disable the behaviour entirely.

---

## Enrichment provenance

So the source of every enriched deliverable is traceable, each finding records how its PoC was produced. The `poc_enrichment_provenance` field distinguishes:

| Value | Meaning |
|-------|---------|
| `llm` | Enriched by the active scan provider (the normal path) |
| `llm_<provider>_failover` | Recovered via failover using the named secondary provider (e.g. `llm_anthropic_failover`) |
| `deterministic_evidence` | Evidence-only fallback -- no LLM enrichment was available |

This makes it clear at a glance whether a given PoC came from the scan provider, from the failover provider, or from the deterministic evidence baseline.

---

## Telemetry

The `validated_findings.json` deliverable gains a `reporting_failover_count` meta field recording how many enrichment calls were served by the failover provider. Reporting-time saturation is therefore visible in the deliverable itself instead of silently degrading the report.

---

## Why it matters

- **No empty reports** on provider saturation -- the most valuable moment of the scan (turning findings into a report) is protected against a provider that is fine during scanning but overloaded at reporting time.
- **Provider integrity preserved** -- the scan's results are still entirely the product of the provider you chose; failover touches only the reporting enrichment call.
- **Auditable** -- provenance per finding plus the failover count in meta make any fallback transparent.

---

**Parent**: [BugTraceAI-CLI](/bugtraceai-cli)

**See also**: [Report Generation](/report-generation) | [Configuration](/configuration) | [Provider Selection](/provider-selection) | [Scanning Pipeline](/scanning-pipeline)
