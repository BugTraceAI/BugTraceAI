---
title: "Report Generation"
---

# Report Generation

BugTraceAI-CLI generates comprehensive scan reports in multiple formats. Reports are accessible via the REST API and include all findings, evidence, and scan metadata.

---

## Report Formats

| Format | Endpoint | Content-Type | Description |
|--------|----------|-------------|-------------|
| **HTML** | `GET /api/scans/{id}/report/html` | `text/html` | Interactive viewer with filtering, sorting, and evidence |
| **JSON** | `GET /api/scans/{id}/report/json` | `application/json` | Machine-readable structured data |
| **Markdown** | `GET /api/scans/{id}/report/markdown` | `text/markdown` | Human-readable document for documentation and sharing |

---

## HTML Report

The HTML report provides an interactive viewer that runs entirely in the browser (no server needed after download).

### Features

- **Filtering**: Filter findings by severity, type, validation status
- **Sorting**: Sort by severity, confidence, discovery time
- **Evidence viewer**: Expand findings to see payloads, responses, and screenshots
- **Summary statistics**: Total findings, severity distribution, validation results
- **Exportable**: Self-contained HTML file that can be shared directly

### Structure

```
HTML Report
|
+-- Executive Summary
|   +-- Scan target and scope
|   +-- Total findings by severity
|   +-- Validation statistics
|
+-- Findings Table
|   +-- Sortable columns (Type, Severity, URL, Status)
|   +-- Expandable rows with evidence
|
+-- Finding Details
|   +-- Vulnerability description
|   +-- Affected URL and parameter
|   +-- Payload used
|   +-- Response evidence
|   +-- Screenshot (if available)
|   +-- Remediation guidance
|
+-- Appendix
    +-- Scan configuration
    +-- Agent activity log
    +-- Methodology notes
```

---

## JSON Report

The JSON report is designed for programmatic consumption -- CI/CD integration, custom dashboards, or import into other tools.

### Structure

```json
{
  "report": {
    "version": "1.0",
    "generated_at": "2026-02-10T15:30:00Z",
    "scan": {
      "id": "scan_abc123",
      "target_url": "https://example.com",
      "started_at": "2026-02-10T14:30:00Z",
      "completed_at": "2026-02-10T15:25:00Z",
      "duration_seconds": 3300,
      "configuration": {
        "max_depth": 3,
        "max_urls": 500,
        "safe_mode": false
      }
    },
    "summary": {
      "total_findings": 10,
      "by_severity": {
        "CRITICAL": 1,
        "HIGH": 4,
        "MEDIUM": 3,
        "LOW": 2
      },
      "by_validation": {
        "VALIDATED_CONFIRMED": 8,
        "MANUAL_REVIEW_RECOMMENDED": 2
      }
    },
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
        "evidence": "...",
        "validation_status": "VALIDATED_CONFIRMED",
        "agent": "XSS",
        "discovered_at": "2026-02-10T14:35:22Z",
        "remediation": "Sanitize user input and implement Content Security Policy"
      }
    ]
  }
}
```

---

## Markdown Report

The Markdown report is ideal for documentation, issue trackers, and human reading.

### Structure

```markdown
# Security Scan Report

## Target: https://example.com
**Date**: 2026-02-10
**Duration**: 55 minutes
**Findings**: 10 vulnerabilities

## Summary

| Severity | Count |
|----------|-------|
| Critical | 1     |
| High     | 4     |
| Medium   | 3     |
| Low      | 2     |

## Findings

### [HIGH] Reflected XSS in /search

- **URL**: https://example.com/search?q=test
- **Parameter**: q
- **Payload**: `<script>alert(1)</script>`
- **Status**: Validated Confirmed
- **Remediation**: Sanitize user input...

...
```

---

## Report Files

Individual files associated with a scan (screenshots, evidence files) can be retrieved separately:

```http
GET /api/scans/{id}/files/{filename}
```

This endpoint serves:
- Validation screenshots (PNG)
- Response captures
- Evidence artifacts

### PoC Enrichment Files

Each scan also generates PoC enrichment traceability files:

```http
GET /api/scans/{id}/files/poc_enrichment/wet/sqli_wet.json   # Raw LLM response
GET /api/scans/{id}/files/poc_enrichment/dry/sqli_dry.json   # Parsed PoC data
```

---

## PoC Enrichment

After validation, the reporting phase enriches confirmed findings with detailed Proof of Concept data using batch LLM calls.

### How It Works

1. **Grouping**: Validated findings are grouped by vulnerability type (SQLi, XSS, LFI, etc.)
2. **Batch enrichment**: One LLM call per vulnerability type generates PoC details for all findings in that group. This is far more efficient than calling the LLM once per finding.
3. **WET/DRY traceability**: Each batch call saves both the raw LLM response (WET) and the parsed structured output (DRY) as separate files. This makes it easy to diagnose whether issues originate from the LLM, the parser, or the report template.
4. **Fallback**: If a batch enrichment call fails (e.g., due to token limits or LLM errors), the system falls back to individual per-finding enrichment calls to maximize coverage.

### Traceability Files

| File | Content | Purpose |
|------|---------|---------|
| `poc_enrichment/wet/{type}_wet.json` | Raw LLM response | Debug LLM quality issues |
| `poc_enrichment/dry/{type}_dry.json` | Parsed PoC data | Debug parser issues |

### Enrichment Provenance

Every enriched finding records how its PoC was produced in a `poc_enrichment_provenance` field, so a reader can tell real LLM enrichment apart from a fallback:

| Value | Meaning |
|-------|---------|
| `llm` | Enriched by the scan's active LLM provider |
| `llm_<provider>_failover` | The active provider failed or saturated, and the PoC was recovered via the reporting failover provider (e.g. `llm_anthropic_failover`) |
| `deterministic_evidence` | LLM enrichment was unavailable; the PoC was assembled from the finding's own captured evidence only |

### Reporting Failover

Introduced in **CLI 3.7.11**. When a PoC or CVSS enrichment call on the scan's active provider fails or degrades (circuit-breaker fallback, timeout, or an OpenRouter saturation), the reporting layer retries that single enrichment call on a secondary provider. This is scoped strictly to the reporting/enrichment step -- it never changes the scan's active provider and never mixes providers mid-scan. The fallback call is self-contained, using the failover provider's own preset (base URL, key, `api_format`, and `REPORTING_MODEL`); Anthropic (API key) is supported natively.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `REPORTING_FAILOVER_ENABLED` | boolean | `true` | Enable failover for reporting/enrichment calls |
| `REPORTING_FAILOVER_PROVIDER` | string | `anthropic` | Provider preset id used only for reporting failover |

The number of enrichment calls recovered this way is recorded in the `validated_findings.json` meta as `reporting_failover_count`, so reporting-time saturation is visible in the deliverable instead of silently degrading the report.

---

## Pending (POTENTIAL) Findings

Some findings carry strong evidence but cannot be auto-confirmed -- for example a blind vector with no OOB egress, or a re-test that could not reproduce a differential. These are reported as **pending** with a `PENDING_VALIDATION` / `PENDING` status and surfaced with a **POTENTIAL** badge so a human can confirm them.

Since **CLI 3.7.8**, pending findings are written to a dedicated `pending` array (with a count) in `validated_findings.json`, bringing all three deliverables into parity: the Markdown report, the engagement JSON, and the rich HTML/JSON viewer all surface pending findings. The "Findings by Severity" totals and the manual-review ordering are computed consistently across deliverables (validated + manual-review + pending).

---

## Configuration

The `REPORT_ONLY_VALIDATED` setting controls whether unvalidated findings are included in reports:

| Setting | Behavior |
|---------|----------|
| `true` (default) | Only findings with `VALIDATED_CONFIRMED` or `MANUAL_REVIEW_RECOMMENDED` appear in reports |
| `false` | All findings appear, including `PENDING_VALIDATION` and `VALIDATED_FALSE_POSITIVE` |

See [Configuration](/configuration) for all available settings.

---

## Programmatic Report Generation

### Generate and Download

```bash
# HTML report
curl -o report.html http://localhost:8000/api/scans/scan_abc123/report/html

# JSON report
curl -o report.json http://localhost:8000/api/scans/scan_abc123/report/json

# Markdown report
curl -o report.md http://localhost:8000/api/scans/scan_abc123/report/markdown
```

### CI/CD Integration Example

```bash
# Start scan, wait for completion, download JSON report
SCAN_ID=$(curl -s -X POST http://localhost:8000/api/scans \
  -H "Content-Type: application/json" \
  -d '{"target_url": "https://staging.example.com"}' | jq -r '.id')

# Poll until complete
while [ "$(curl -s http://localhost:8000/api/scans/$SCAN_ID/status | jq -r '.status')" != "COMPLETED" ]; do
  sleep 10
done

# Download report
curl -s http://localhost:8000/api/scans/$SCAN_ID/report/json > security-report.json

# Fail CI if critical findings
CRITICAL=$(jq '.report.summary.by_severity.CRITICAL // 0' security-report.json)
if [ "$CRITICAL" -gt 0 ]; then
  echo "CRITICAL vulnerabilities found!"
  exit 1
fi
```

---

**Parent**: [BugTraceAI-CLI](/bugtraceai-cli)

**See also**: [API Reference](/api-reference) | [Validation System](/validation-system) | [Configuration](/configuration)
