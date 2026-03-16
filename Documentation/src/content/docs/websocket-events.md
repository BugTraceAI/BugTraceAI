---
title: Websocket Events
---

# WebSocket Events

BugTraceAI-CLI provides real-time event streaming via WebSocket connections. This allows the WEB dashboard (or any WebSocket client) to receive live updates during scan execution.

---

## Endpoints

| Endpoint | Scope | Description |
|----------|-------|-------------|
| `/ws/scans/{id}` | Per-scan | Events for a specific scan |
| `/ws/global` | Global | Events across all active scans |

### Connection Example

```javascript
// Per-scan WebSocket
const ws = new WebSocket("ws://localhost:8000/ws/scans/scan_abc123");

// Global WebSocket
const ws = new WebSocket("ws://localhost:8000/ws/global");
```

---

## Event Types

Every WebSocket message is a JSON object with a `type` field and a `seq` (sequence number) for ordering and reconnection.

### progress_update

Emitted periodically during scanning to report overall progress.

```json
{
  "type": "progress_update",
  "seq": 42,
  "scan_id": "scan_abc123",
  "progress": 65,
  "urls_processed": 128,
  "urls_total": 200,
  "findings_count": 7,
  "elapsed_seconds": 180
}
```

### phase_update

Emitted when the scan transitions between pipeline phases.

```json
{
  "type": "phase_update",
  "seq": 43,
  "scan_id": "scan_abc123",
  "phase": "exploitation",
  "previous_phase": "analysis",
  "message": "Starting exploitation phase with 15 targets"
}
```

### finding_discovered

Emitted when a new vulnerability finding is discovered.

```json
{
  "type": "finding_discovered",
  "seq": 44,
  "scan_id": "scan_abc123",
  "finding": {
    "id": "finding_007",
    "type": "XSS",
    "subtype": "reflected",
    "severity": "HIGH",
    "confidence": 0.88,
    "url": "https://example.com/search?q=test",
    "parameter": "q",
    "agent": "xss_specialist",
    "validation_status": "PENDING_VALIDATION"
  }
}
```

### log

General log messages from the scanning engine.

```json
{
  "type": "log",
  "seq": 45,
  "scan_id": "scan_abc123",
  "level": "info",
  "message": "XSS specialist processing 5 queued targets",
  "agent": "xss_specialist"
}
```

### scan_complete

Emitted when a scan finishes (successfully or with errors).

```json
{
  "type": "scan_complete",
  "seq": 100,
  "scan_id": "scan_abc123",
  "status": "COMPLETED",
  "total_findings": 12,
  "validated_findings": 9,
  "false_positives": 2,
  "elapsed_seconds": 542,
  "report_available": true
}
```

### error

Emitted when an error occurs during scanning.

```json
{
  "type": "error",
  "seq": 46,
  "scan_id": "scan_abc123",
  "error": "Connection timeout to target",
  "recoverable": true,
  "agent": "ssrf_specialist"
}
```

---

## Sequence Numbers

Every event includes a monotonically increasing `seq` (sequence number). This enables:

1. **Ordering**: Events can be processed in the correct order even if delivery is delayed
2. **Deduplication**: Duplicate events (from reconnection) can be detected and ignored
3. **Reconnection**: Clients can resume from where they left off after a disconnect

---

## Reconnection Protocol

If a WebSocket connection drops, the client can reconnect and request event replay using the `last_seq` query parameter:

```javascript
// Reconnect with event replay from sequence 42
const ws = new WebSocket("ws://localhost:8000/ws/scans/scan_abc123?last_seq=42");
```

The server will replay all events with `seq > 42` before switching to live streaming.

### Reconnection Best Practices

1. Track the last received `seq` number on the client
2. On disconnect, wait with exponential backoff before reconnecting
3. Reconnect with `?last_seq=N` where N is the last received sequence
4. Handle duplicate events gracefully (use `seq` for deduplication)

---

## Connection Close Codes

When the server closes the WebSocket connection, it uses standard close codes:

| Code | Meaning |
|------|---------|
| `1000` | Normal closure -- scan completed |
| `1008` | Policy violation -- invalid scan ID or unauthorized |

---

## Client Implementation Example

```javascript
class ScanWebSocket {
  constructor(scanId) {
    this.scanId = scanId;
    this.lastSeq = 0;
    this.connect();
  }

  connect() {
    const url = `ws://localhost:8000/ws/scans/${this.scanId}`;
    const params = this.lastSeq > 0 ? `?last_seq=${this.lastSeq}` : "";
    this.ws = new WebSocket(url + params);

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.lastSeq = data.seq;
      this.handleEvent(data);
    };

    this.ws.onclose = (event) => {
      if (event.code !== 1000) {
        // Reconnect after delay
        setTimeout(() => this.connect(), 2000);
      }
    };
  }

  handleEvent(event) {
    switch (event.type) {
      case "progress_update":
        // Update progress bar
        break;
      case "phase_update":
        // Update phase indicator
        break;
      case "finding_discovered":
        // Add finding to list
        break;
      case "scan_complete":
        // Show completion state
        break;
      case "error":
        // Display error notification
        break;
    }
  }
}
```

---

## Global WebSocket

The `/ws/global` endpoint streams events from **all active scans**. Each event includes a `scan_id` field to identify which scan it belongs to.

This endpoint is useful for:
- Dashboard views showing multiple concurrent scans
- Monitoring systems watching all activity
- Notification systems that need to react to any scan event

---

**Parent**: [Architecture](/architecture)

**See also**: [API Reference](/api-reference) | [Real-time Scan Monitoring](/real-time-scan-monitoring) | [Scanning Pipeline](/scanning-pipeline)
