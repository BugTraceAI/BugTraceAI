---
title: Queue And Event System
---

# Queue and Event System

The BugTraceAI-CLI uses per-specialist task queues and an internal event bus to coordinate the scanning pipeline. This architecture enables parallel execution, deduplication, metrics tracking, and real-time event streaming.

---

## Queue Architecture

```
                    Consolidation Phase
                          |
          +---------------+---------------+
          |               |               |
    +-----v-----+  +-----v-----+  +-----v-----+
    | XSS Queue |  | SQLi Queue|  | SSRF Queue|  ...
    |  (15 items)|  |  (8 items) |  |  (5 items) |
    +-----+-----+  +-----+-----+  +-----+-----+
          |               |               |
    +-----v-----+  +-----v-----+  +-----v-----+
    | XSS Agent |  | SQLi Agent|  | SSRF Agent|
    +-----+-----+  +-----+-----+  +-----+-----+
          |               |               |
          +-------+-------+-------+-------+
                  |                       |
            +-----v-----+          +-----v-----+
            | Event Bus |          | Validation |
            |           |          | Queue      |
            +-----------+          +-----------+
```

---

## Per-Specialist Queues

Each [[Specialist Agents|specialist agent]] has its own dedicated task queue. Findings from the consolidation phase are distributed to the appropriate queue based on vulnerability type.

### Queue Properties

| Property | Description |
|----------|-------------|
| **Isolation** | Each specialist has its own queue -- no cross-contamination |
| **Priority** | Items are ordered by priority score from the analysis phase |
| **Bounded** | Queues have configurable maximum size |
| **Persistent** | Queue state survives agent restarts |

### Queue Mapping

| Queue Name | Specialist Agent | Fuzzer |
|-----------|-----------------|--------|
| `xss` | XSS Agent | Go XSS Fuzzer |
| `sqli` | SQLi Agent | Python AI |
| `ssrf` | SSRF Agent | Go SSRF Fuzzer |
| `idor` | IDOR Agent | Go IDOR Fuzzer |
| `lfi` | LFI Agent | Go LFI Fuzzer |
| `rce` | RCE Agent | Python AI |
| `xxe` | XXE Agent | Python AI |
| `jwt` | JWT Agent | Python AI |
| `openredirect` | Redirect Agent | Python AI |
| `prototype_pollution` | Prototype Agent | Python AI |

---

## Deduplication

Before a finding is added to any specialist queue, it passes through deduplication logic:

1. **URL + Parameter matching**: Identical URL and parameter combinations are merged
2. **Payload similarity**: Near-identical payloads targeting the same endpoint are deduplicated
3. **Cross-phase dedup**: Findings already in the validation queue are not re-queued

This prevents specialist agents from wasting time on duplicate targets.

---

## Metrics Tracking

The queue system tracks detailed metrics for monitoring and performance analysis:

### Per-Queue Metrics

| Metric | Description |
|--------|-------------|
| `queue_depth` | Current number of items in the queue |
| `items_processed` | Total items consumed by the specialist |
| `items_remaining` | Items still waiting to be processed |
| `processing_rate` | Items processed per second |
| `average_latency` | Average time from queue entry to processing |

### Per-Agent Metrics

| Metric | Description |
|--------|-------------|
| `findings_discovered` | Number of vulnerabilities found |
| `payloads_attempted` | Total payloads tested |
| `success_rate` | Percentage of attempts that found vulnerabilities |
| `elapsed_time` | Total agent runtime |

### Global Metrics

| Metric | Description |
|--------|-------------|
| `total_depth_reached` | Maximum crawl depth achieved |
| `total_urls_processed` | Total URLs processed across all phases |
| `total_throughput` | Aggregate requests per second |
| `scan_duration` | Total wall-clock scan time |

Metrics are accessible via the `GET /api/scans/{id}/metrics` API endpoint.

---

## Event Bus

The internal event bus is the communication backbone of the scanning engine. All scan events flow through the event bus, which distributes them to interested consumers.

### Event Flow

```
Scanning Engine --> Event Bus --> WebSocket Endpoints
                       |
                       +--> Metrics Collector
                       |
                       +--> Logger
                       |
                       +--> Internal Consumers
```

### Published Events

| Event | Source | Description |
|-------|--------|-------------|
| `scan_started` | Pipeline | Scan execution began |
| `phase_transition` | Pipeline | Moving to a new pipeline phase |
| `target_discovered` | Discovery | New URL or endpoint found |
| `finding_queued` | Consolidation | Finding added to specialist queue |
| `exploitation_attempt` | Specialist | Payload delivery attempted |
| `finding_discovered` | Specialist | Vulnerability confirmed |
| `validation_started` | Validation | Browser validation initiated |
| `validation_complete` | Validation | Browser validation finished |
| `scan_complete` | Pipeline | Scan execution finished |
| `error` | Any | Error occurred in any component |

### Event Structure

```json
{
  "event": "finding_discovered",
  "scan_id": "scan_abc123",
  "timestamp": "2026-02-10T14:35:22Z",
  "seq": 44,
  "data": {
    "finding_id": "finding_007",
    "type": "XSS",
    "severity": "HIGH",
    "agent": "xss"
  }
}
```

### WebSocket Consumption

The event bus feeds directly into the WebSocket endpoints (`/ws/scans/{id}` and `/ws/global`). Events are transformed into the WebSocket event format documented in [[WebSocket Events]].

---

## Queue Lifecycle

### During a Scan

1. **Phase 1-2**: Discovery and analysis populate the potential findings list
2. **Phase 3**: Consolidation deduplicates and distributes to specialist queues
3. **Phase 4**: Specialists consume from their queues in priority order
4. **Phase 4**: Successfully exploited findings are placed in the validation queue
5. **Phase 5**: The validation agent processes the validation queue

### Queue States

| State | Description |
|-------|-------------|
| `EMPTY` | No items in queue |
| `ACTIVE` | Items present, specialist is consuming |
| `PAUSED` | Scan is paused, queue frozen |
| `DRAINING` | Scan stopping, processing remaining items |
| `COMPLETE` | All items processed |

---

**Parent**: [[BugTraceAI-CLI]]

**See also**: [[Scanning Pipeline]] | [[Specialist Agents]] | [[WebSocket Events]]
