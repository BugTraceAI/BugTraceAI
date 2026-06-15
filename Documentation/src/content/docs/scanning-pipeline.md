---
title: Scanning Pipeline
---

# Scanning Pipeline

The BugTraceAI-CLI scanning engine operates as a six-phase pipeline. Each phase builds on the results of the previous phase, progressively narrowing from broad discovery to specific, validated findings with enriched PoC and comprehensive reports.

---

## Pipeline Overview

Before Phase 1 starts, BugTraceAI can optionally perform an authenticated login using a YAML auth config. Login flows can include username/password fields, environment-variable substitution, and TOTP/2FA generation via `$totp`.

```
Phase 1         Phase 2         Phase 3           Phase 4           Phase 5           Phase 6
DISCOVERY  -->  ANALYSIS   -->  CONSOLIDATION -->  EXPLOITATION  -->  VALIDATION   -->  REPORTING
(Crawl &        (Multi-AI       (Deduplicate &     (Specialized       (Browser +        (PoC Enrichment
 Spider)         Consensus)      Prioritize)        Agents)            Vision AI)         + AI Reports)
```

---

## Phase 1: Discovery

**Goal**: Map the target's attack surface through intelligent crawling and spidering.

### What Happens

1. The discovery agent receives the target URL
2. Crawls the target following links, forms, and JavaScript references
3. Spiders additional paths using wordlists and heuristics
4. Extracts parameters, endpoints, forms, and API paths
5. Identifies technologies, frameworks, and server configurations

If authenticated scanning is configured, discovery runs with the authenticated browser/session context so protected routes and APIs can be mapped.

### Output

- List of discovered URLs and endpoints
- Parameter map (query parameters, form fields, headers)
- Technology fingerprints
- Site structure graph

### Configuration

| Setting | Description | Default |
|---------|-------------|---------|
| `MAX_DEPTH` | Maximum crawl depth | 3 |
| `MAX_URLS` | Maximum URLs to process | 500 |

---

## Phase 2: Analysis

**Goal**: Evaluate discovered endpoints for potential vulnerabilities using AI-driven analysis.

### What Happens

1. Each discovered endpoint is analyzed by multiple AI personas
2. Personas independently assess vulnerability potential
3. **Consensus voting** determines which findings to pursue
4. Analysis considers context: technology stack, parameter types, response behavior

### Multi-Persona AI

The analysis phase uses multiple AI "personas" that evaluate findings from different angles. A finding must achieve consensus across personas before proceeding to exploitation. This reduces false positives significantly.

### Output

- Scored list of potential vulnerabilities
- Vulnerability type classification (XSS, SQLi, SSRF, etc.)
- Confidence scores per finding
- Recommended exploitation strategies

---

## Phase 3: Consolidation

**Goal**: Deduplicate, prioritize, and distribute findings to specialist queues.

### What Happens

1. **Deduplication**: Identical or near-identical findings are merged
2. **Prioritization**: Findings are scored by severity potential and confidence
3. **Queue Distribution**: Each finding is routed to the appropriate specialist agent queue
4. **Metrics**: Depth, throughput, and queue sizes are tracked

### Queue Assignment

| Vulnerability Type | Specialist Queue |
|-------------------|------------------|
| XSS (Reflected, Stored, DOM) | `xss_specialist` |
| SQL Injection | `sqli_specialist` |
| SSRF | `ssrf_specialist` |
| IDOR | `idor_specialist` |
| LFI / Path Traversal | `lfi_specialist` |
| RCE | `rce_specialist` |
| XXE | `xxe_specialist` |
| JWT Attacks | `jwt_specialist` |
| Open Redirect | `redirect_specialist` |
| Prototype Pollution | `prototype_specialist` |
| CSTI (Client-Side Template Injection) | `csti_specialist` |
| Mass Assignment | `mass_assignment_specialist` |
| Header Injection | `header_injection_specialist` |
| Broken Access Control | `bac_specialist` |

See [Queue and Event System](/queue-and-event-system) for details on queue management.

---

## Phase 4: Exploitation

**Goal**: Attempt to exploit each potential vulnerability using specialized agents.

### What Happens

1. Each specialist agent consumes from its own queue
2. Agents use AI for **intelligent payload mutation** -- payloads are adapted based on context
3. Go fuzzers handle high-speed payload delivery (XSS, SSRF, IDOR, LFI)
4. Python AI agents handle logic-based exploitation (SQLi, RCE, XXE, JWT)
5. Agents use **context-driven pruning (CDP)** to avoid wasting time on unproductive paths
6. Successful exploitation attempts are recorded with evidence

### Specialist Capabilities

Each specialist agent is purpose-built for its vulnerability class:

- **AI-driven**: Uses AI models to generate and mutate payloads intelligently
- **Context-aware**: Adapts strategy based on target technology and responses
- **Evidence-collecting**: Captures proof of exploitation (responses, screenshots)
- **Self-limiting**: Respects safe mode and depth limits

See [Specialist Agents](/specialist-agents) for detailed per-agent documentation.

### Go Fuzzer Integration

For vulnerability classes that benefit from high-throughput testing, Go fuzzers run alongside the AI agents:

```
AI Agent (Python)                    Go Fuzzer
   |                                    |
   +-- Selects targets & strategies     +-- High-speed payload delivery
   +-- Analyzes responses               +-- Parallel request execution
   +-- Decides next steps               +-- Rate limiting
   +-- Validates results                +-- Response capture
```

---

## Phase 5: Validation

**Goal**: Confirm exploited vulnerabilities using browser-based validation and Vision AI.

### What Happens

1. Findings from Phase 4 enter the validation queue
2. **CDP Browser Validation**: Playwright launches headless Chromium to replay the exploit
3. The browser executes the payload in a real browser environment
4. **Vision AI**: Screenshots are captured and analyzed by AI to confirm visual evidence
5. Findings are assigned a final validation status

### Validation Statuses

| Status | Meaning |
|--------|---------|
| `VALIDATED_CONFIRMED` | Exploit confirmed in browser |
| `VALIDATED_FALSE_POSITIVE` | Exploit did not reproduce |
| `MANUAL_REVIEW_RECOMMENDED` | AI uncertain, human review needed |
| `PENDING_VALIDATION` | Awaiting validation |
| `SKIPPED` | Validation not applicable |
| `ERROR` | Validation encountered an error |

See [Validation System](/validation-system) for the full validation architecture.

---

## Phase 6: Reporting

**Goal**: Enrich validated findings with detailed PoC and generate comprehensive reports.

### What Happens

1. Validated findings are **grouped by vulnerability type** (SQLi, XSS, LFI, etc.)
2. Each group receives **batch PoC enrichment** via a single LLM call per type
3. The LLM generates exploitation details, reproduction steps, and impact analysis
4. **WET/DRY traceability**: Raw LLM responses (WET) and parsed results (DRY) are saved separately for debugging
5. **AI-generated reports**: Technical assessment and executive summary are generated in parallel
6. Reports are output in Markdown, HTML, and JSON formats

### WET/DRY Traceability

The reporting phase uses a WET/DRY pipeline for full auditability:

| File | Content | Purpose |
|------|---------|---------|
| `poc_enrichment/wet/{type}_wet.json` | Raw LLM response | Debug LLM quality issues |
| `poc_enrichment/dry/{type}_dry.json` | Parsed PoC data | Debug parser issues |

- WET contains garbage → LLM problem (bad model, bad prompt, timeout)
- WET OK but DRY has failures → Parser problem (regex, JSON malformed)
- DRY OK but report bad → Report generation problem (template)

### Output

The report directory contains:

```
reports/{target}_{timestamp}/
├── final_report.md              # Full markdown report
├── validated_findings.json      # All findings with PoC
├── engagement_data.json         # Complete engagement data
├── report.html                  # Standalone HTML report
├── attack_chains.json           # Multi-step attack chains
├── recon/                       # Reconnaissance data
├── dastysast/                   # DASTySAST analysis per URL
├── specialists/                 # Specialist results (wet/dry/results)
└── poc_enrichment/              # PoC enrichment (wet/dry)
```

---

## Circuit Breaker

The scanning pipeline includes a **circuit breaker** mechanism that protects the target from being overwhelmed and prevents wasted scan time when a target becomes unresponsive.

| Setting | Default | Description |
|---------|---------|-------------|
| `DAST_CONSECUTIVE_TIMEOUT_LIMIT` | `5` | Auto-pause after this many consecutive timeouts |
| `DAST_TIMEOUT_PERCENT_LIMIT` | `50` | Auto-pause if timeout percentage exceeds this threshold |

When triggered, the circuit breaker pauses all active specialist agents and emits an event to connected WEB dashboards. Scanning can be resumed manually once the target recovers.

### Resumable Scans

Recoverable scans store phase progress, retry counters, and previous scan linkage. Use `--resume` in the CLI or the WEB dashboard resume action to continue interrupted, paused, or circuit-breaker-paused scans without restarting the full workflow.

---

## Authenticated Scanning

BugTraceAI supports two levels of authenticated scanning to test endpoints that require authentication:

### Level 1: Token Injection

Provide a pre-existing token (JWT, session cookie, API key) directly:

```json
{
  "target_url": "https://example.com",
  "auth_token": "Bearer eyJhbGciOiJIUzI1NiIs..."
}
```

The token is injected into all HTTP requests made by specialist agents via the `Authorization` header.

### Level 2: Automatic Login

Provide login credentials and BugTraceAI will authenticate automatically:

```json
{
  "target_url": "https://example.com",
  "auth": {
    "login_url": "https://example.com/api/auth/login",
    "credentials": {
      "username": "testuser",
      "password": "testpass"
    }
  }
}
```

The CLI posts to the login URL, extracts JWT tokens from the response, and injects them into all subsequent agent requests. Discovered tokens are also passed to the JWT specialist for security testing (algorithm confusion, weak secrets, claim manipulation).

---

## URL Pattern Deduplication

During the consolidation phase, the pipeline deduplicates URLs that follow similar patterns (e.g., `/products/1`, `/products/2`, `/products/3`) to avoid redundant testing. This reduces scan time without sacrificing coverage -- only structurally unique URL patterns are forwarded to specialist agents.

---

## Pipeline Flow Example

```
Target: https://example.com

Phase 1 (Discovery):
  - 247 URLs discovered
  - 89 unique parameters found
  - Technology: PHP 8.1, Apache, jQuery 3.6

Phase 2 (Analysis):
  - AI consensus identifies 32 potential vulnerabilities
  - 15 XSS candidates, 8 SQLi candidates, 5 SSRF, 4 IDOR

Phase 3 (Consolidation):
  - 32 findings deduplicated to 28 unique
  - Distributed to 4 specialist queues

Phase 4 (Exploitation):
  - XSS specialist: 7 of 15 exploited successfully
  - SQLi specialist: 3 of 8 exploited successfully
  - SSRF specialist: 1 of 5 exploited successfully
  - IDOR specialist: 2 of 4 exploited successfully

Phase 5 (Validation):
  - 13 findings submitted for validation
  - 10 VALIDATED_CONFIRMED
  - 2 VALIDATED_FALSE_POSITIVE
  - 1 MANUAL_REVIEW_RECOMMENDED

Phase 6 (Reporting):
  - 10 validated findings grouped into 4 types
  - Batch PoC enrichment: 4 LLM calls (1 per type)
  - Technical assessment + executive summary generated
  - Output: Markdown, HTML, and JSON reports

Final Report: 10 confirmed vulnerabilities with full PoC
```

---

## Configuration

The scanning pipeline is controlled by several configuration settings:

| Setting | Effect |
|---------|--------|
| `MAX_DEPTH` | Controls crawl depth in Phase 1 |
| `MAX_URLS` | Limits total URLs processed in Phase 1 |
| `SAFE_MODE` | When true, limits exploitation aggressiveness in Phase 4 |
| `EARLY_EXIT_ON_FINDING` | Stops after first confirmed finding |
| `STOP_ON_CRITICAL` | Stops when a critical severity finding is confirmed |
| `REPORT_ONLY_VALIDATED` | Only includes validated findings in reports |
| `HEADLESS_BROWSER` | Enables/disables browser validation in Phase 5 |

See [Configuration](/configuration) for all available settings.

---

**Parent**: [BugTraceAI-CLI](/bugtraceai-cli)

**See also**: [Specialist Agents](/specialist-agents) | [Queue and Event System](/queue-and-event-system) | [Validation System](/validation-system)
