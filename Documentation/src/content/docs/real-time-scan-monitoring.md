---
title: Real Time Scan Monitoring
---

# Real-time Scan Monitoring

BugTraceAI-WEB provides live scan monitoring by connecting to the CLI's WebSocket endpoint. This enables real-time visibility into scan progress, active agents, phase transitions, and newly discovered findings.

---

## Overview

When the WEB dashboard is connected to a CLI API server, it establishes a WebSocket connection to receive real-time events during scan execution.

```
BugTraceAI-WEB                          BugTraceAI-CLI
+------------------+    WebSocket       +------------------+
| Scan Monitor UI  | <===============> | /ws/scans/{id}   |
|                  |                    |                  |
| - Progress bar   |    Events:        | Event Bus        |
| - Active agents  |    - progress     |                  |
| - Phase display  |    - phase        | Scanning Engine  |
| - Finding feed   |    - finding      |                  |
| - Log stream     |    - log          |                  |
+------------------+    - complete     +------------------+
```

---

## Monitor Features

### Progress Tracking

Real-time progress display updated with each `progress_update` event:

| Indicator | Source | Description |
|-----------|--------|-------------|
| **Overall progress** | `progress` field | Percentage completion (0-100%) |
| **URLs processed** | `urls_processed` | Count of URLs analyzed |
| **Findings count** | `findings_count` | Total findings discovered so far |
| **Elapsed time** | `elapsed_seconds` | Wall-clock time since scan start |

### Phase Display

The scan monitor shows the current pipeline phase, updated with each `phase_update` event:

| Phase | Display |
|-------|---------|
| Discovery | Crawling and spidering the target |
| Analysis | AI analyzing discovered endpoints |
| Consolidation | Deduplicating and prioritizing findings |
| Exploitation | Specialist agents exploiting targets |
| Validation | Browser-based confirmation |
| Complete | Scan finished |

Phase transitions are displayed with timestamps and descriptive messages.

### Active Agent Information

During the exploitation phase, the monitor shows which specialist agents are currently active:

- Agent name (e.g., "XSS Specialist", "SQLi Specialist")
- Agent queue depth (items remaining)
- Current target being processed
- Findings discovered by this agent

### New Findings Feed

Each `finding_discovered` event adds a new entry to the findings feed:

- Vulnerability type and subtype
- Severity level (color-coded)
- Affected URL and parameter
- Confidence score
- Validation status

Findings appear in real time as they are discovered, giving immediate visibility into results.

### Log Stream

The `log` event type provides a running log of scan activity, useful for understanding what the scanning engine is doing at any moment.

---

## Scan Dashboard UI

The scan monitor renders a dedicated dashboard with several visual components arranged in a responsive layout.

### Pipeline Bar

Displayed at the top of the scan view, the pipeline bar shows all six pipeline phases as a horizontal progress indicator. The current active phase is highlighted, and completed phases are marked. This gives an immediate at-a-glance view of how far the scan has progressed.

### Metrics Bar

Below the pipeline bar, a metrics row shows key counters:
- **URLs Discovered**: Total URLs found during the discovery phase
- **URLs Analyzed**: Number of URLs that have been processed through analysis

### Agent Pills

During the exploitation phase, active specialist agents are displayed as pill-shaped badges. Each pill shows the agent name and a **red badge with pulse animation** indicating the number of findings that agent has discovered so far. Agent pills wrap naturally to multiple rows on narrow screens, ensuring the layout remains usable on smaller viewports.

### Findings Toggle

A collapsible accordion button allows users to expand or collapse the findings list. When expanded, findings are grouped by severity (Critical, High, Medium, Low) and displayed inline. This keeps the dashboard clean by default while providing immediate access to results when needed.

### Responsive Layout

The dashboard uses a **two-row responsive layout**:
- **Top row**: Pipeline progress bar (full width)
- **Bottom row**: Metrics counters + agent activity pills + findings toggle button

On wider screens the bottom row displays all elements in a single line. On narrower screens, elements wrap gracefully -- agent pills flow to additional rows and the findings toggle remains accessible.

---

## WebSocket Connection

### Connection Lifecycle

1. **Connect**: When a scan is selected, the WEB opens a WebSocket to `/ws/scans/{id}`
2. **Stream**: Events are received and rendered in the UI
3. **Disconnect handling**: If the connection drops, the WEB automatically reconnects
4. **Reconnection**: Uses `?last_seq=N` to resume from the last received event
5. **Close**: When the scan completes (close code 1000), the connection is closed

### Event Replay

The WebSocket protocol supports reconnection with event replay:

```javascript
// Track last sequence number
let lastSeq = 0;

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  lastSeq = data.seq;
  updateUI(data);
};

// On reconnect, resume from last known sequence
ws = new WebSocket(`ws://cli:8000/ws/scans/${scanId}?last_seq=${lastSeq}`);
```

This ensures no events are lost during brief network interruptions. See [WebSocket Events](/websocket-events) for the full protocol specification.

---

## Connection States

The scan monitor displays the current connection state:

| State | Indicator | Description |
|-------|-----------|-------------|
| **Connected** | Active | Receiving live events from CLI |
| **Reconnecting** | Warning | Connection lost, attempting to reconnect |
| **Disconnected** | Error | CLI unreachable, manual intervention may be needed |
| **Scan Complete** | Done | Scan finished, WebSocket closed normally |

---

## Multi-Scan Monitoring

The WEB dashboard can monitor multiple scans simultaneously by:
- Opening individual per-scan WebSocket connections (`/ws/scans/{id}`)
- Using the global WebSocket endpoint (`/ws/global`) for an overview of all active scans

The scans list page shows all scans with their current status, updated in real time.

---

## Mobile Dashboard

BugTraceAI-WEB includes a dedicated mobile-optimized dashboard accessible at the `/mobile` route. On small screens, the main dashboard automatically redirects to this view.

The mobile dashboard provides:
- **Scan progress** and phase tracking in a compact layout
- **Findings count** with severity breakdown
- **Scan configuration** fields (max_depth, max_urls) accessible on mobile
- **Version display** showing both WEB and CLI versions

---

## Configuration Viewer

The WEB dashboard includes a configuration viewer that displays and allows modification of CLI settings, including:
- Scanning settings (MAX_DEPTH, MAX_URLS, SAFE_MODE)
- Circuit breaker thresholds (DAST_CONSECUTIVE_TIMEOUT_LIMIT, DAST_TIMEOUT_PERCENT_LIMIT)
- URL pattern deduplication toggle
- DAST analysis timeout settings
- AI model selection

---

## Interaction with Reports

After a scan completes, the monitor transitions to the report view where users can:
- Browse all confirmed findings
- View detailed evidence for each finding
- **Download the complete report as a ZIP** via the server-side endpoint (includes all artifacts: markdown, JSON, HTML, specialist results, PoC enrichment, and reconnaissance data)
- Download individual reports in HTML, JSON, or Markdown format
- Filter findings by severity, type, or validation status

See [Report Generation](/report-generation) for report format details.

---

**Parent**: [BugTraceAI-WEB](/bugtraceai-web)

**See also**: [WebSocket Events](/websocket-events) | [Scanning Pipeline](/scanning-pipeline) | [BugTraceAI-CLI](/bugtraceai-cli)
