---
title: Validation System
---

# Validation System

The validation system is the final phase of the [Scanning Pipeline](/scanning-pipeline). It uses headless Chromium via Playwright and Vision AI screenshot analysis to confirm or reject findings produced by the [Specialist Agents](/specialist-agents).

---

## Overview

Validation addresses a core problem in automated scanning: **false positives**. A finding that triggers a response pattern does not necessarily mean a vulnerability exists. The validation system provides ground-truth confirmation by:

1. Replaying the exploit in a real browser environment (Chromium via CDP)
2. Capturing screenshots of the result
3. Analyzing screenshots with Vision AI to confirm visual evidence
4. Assigning a definitive validation status

---

## Validation Statuses

| Status | Code | Description |
|--------|------|-------------|
| **Pending Validation** | `PENDING_VALIDATION` | Finding awaiting validation |
| **Validated Confirmed** | `VALIDATED_CONFIRMED` | Exploit reproduced and confirmed in browser |
| **Validated False Positive** | `VALIDATED_FALSE_POSITIVE` | Exploit did not reproduce; false positive |
| **Manual Review Recommended** | `MANUAL_REVIEW_RECOMMENDED` | AI uncertain; human review needed |
| **Skipped** | `SKIPPED` | Validation not applicable for this finding type |
| **Error** | `ERROR` | Validation encountered a technical error |

---

## CDP Browser Validation

### What is CDP?

CDP (Chrome DevTools Protocol) is the low-level protocol used to communicate with Chromium. Playwright wraps CDP to provide a high-level API for browser automation.

### How It Works

1. **Browser Launch**: Playwright launches a headless Chromium instance
2. **Navigation**: The browser navigates to the target URL with the exploit payload
3. **Execution**: The payload is executed in a real browser environment
4. **Observation**: CDP monitors DOM changes, JavaScript execution, network requests
5. **Screenshot**: A full-page screenshot is captured for Vision AI analysis
6. **Result**: The browser observation determines if the exploit succeeded

### Example: XSS Validation

```
1. Navigate to: https://example.com/search?q=<script>alert(1)</script>
2. Wait for page load
3. Check for:
   - JavaScript dialog (alert/confirm/prompt)
   - DOM mutation showing injected script
   - JavaScript execution in page context
4. Capture screenshot
5. If dialog detected or DOM mutation confirmed --> VALIDATED_CONFIRMED
6. If no evidence found --> VALIDATED_FALSE_POSITIVE
```

### CDP Capabilities Used

| Capability | Purpose |
|-----------|---------|
| Page navigation | Load target with payload |
| DOM inspection | Detect injected content |
| JavaScript evaluation | Check for code execution |
| Dialog handling | Detect alert/confirm/prompt |
| Network interception | Monitor requests triggered by payload |
| Screenshot capture | Visual evidence for Vision AI |
| Console monitoring | Detect JavaScript errors and console output |

---

## Vision AI Analysis

After the browser captures a screenshot, Vision AI provides a second layer of validation:

### How It Works

1. **Screenshot Capture**: Playwright captures a full-page screenshot as PNG
2. **AI Analysis**: The screenshot is sent to a vision-capable AI model via OpenRouter
3. **Prompt**: The AI is asked to analyze whether the screenshot shows evidence of the vulnerability
4. **Decision**: The AI provides a confidence-scored assessment

### What Vision AI Detects

| Evidence Type | Example |
|--------------|---------|
| Alert dialogs | JavaScript alert box visible |
| Injected content | Foreign HTML/text rendered on page |
| Error messages | Database errors, stack traces |
| Visual anomalies | Broken layout, injected images |
| Response differences | Content changes indicating injection |

### Vision AI + CDP Combined

The combination of CDP browser execution and Vision AI analysis provides high-confidence validation:

- **CDP**: Provides programmatic, deterministic evidence (DOM state, JS execution)
- **Vision AI**: Provides visual, semantic evidence (what the page looks like)
- **Combined**: Both must agree for `VALIDATED_CONFIRMED`, either can trigger `MANUAL_REVIEW_RECOMMENDED`

---

## Validation Flow

```
Finding from Exploitation Phase
         |
         v
+--------+--------+
| PENDING_VALIDATION|
+--------+--------+
         |
         v
   Launch Chromium
   Navigate to target
   Execute payload
         |
    +----+----+
    |         |
    v         v
 CDP detects  CDP detects
 evidence     nothing
    |         |
    v         v
 Capture     Capture
 screenshot  screenshot
    |         |
    v         v
 Vision AI   Vision AI
 confirms    analyzes
    |         |
    v         v
 VALIDATED   VALIDATED_FALSE
 _CONFIRMED  _POSITIVE
              |
              v
         (or MANUAL_REVIEW
          if uncertain)
```

---

## Configuration

| Setting | Description | Default |
|---------|-------------|---------|
| `HEADLESS_BROWSER` | Enable/disable browser validation | `true` |
| `REPORT_ONLY_VALIDATED` | Only include validated findings in reports | `true` |

When `HEADLESS_BROWSER` is set to `false`, findings skip browser validation and retain their `PENDING_VALIDATION` status. This is useful in environments where Chromium cannot run (e.g., minimal Docker containers).

---

## Error Handling

Validation errors are handled gracefully:

- **Browser crash**: Finding marked as `ERROR`, retried once
- **Navigation timeout**: Finding marked as `ERROR` with timeout details
- **Vision AI failure**: Falls back to CDP-only validation
- **Target unreachable**: Finding marked as `ERROR`

Findings with `ERROR` status are included in reports with a note explaining the validation failure.

---

## Performance

| Metric | Typical Value |
|--------|---------------|
| Browser launch time | 1-3 seconds |
| Per-finding validation | 3-10 seconds |
| Vision AI analysis | 2-5 seconds |
| Total per finding | 5-15 seconds |

Browser instances are reused across findings in the same scan to minimize launch overhead.

---

**Parent**: [BugTraceAI-CLI](/bugtraceai-cli)

**See also**: [Scanning Pipeline](/scanning-pipeline) | [Specialist Agents](/specialist-agents) | [Report Generation](/report-generation)
