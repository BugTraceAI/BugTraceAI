---
title: "Swarm Graph"
---

# Swarm Graph

The Swarm Graph is a live, cinematic visualization of the scanning pipeline rendered in the BugTraceAI-WEB scan console. It makes the multi-agent swarm legible in real time -- reconnaissance handing off to specialists, specialists climbing their escalation ladders, and confirmed findings flowing into validation and reporting. Introduced in WEB 1.5.23, with live escalation ladders added in WEB 1.5.39.

---

## Overview

The scan console renders the pipeline as an animated graph driven by the real coarse signals streamed over the WebSocket (phase changes, active agents, findings, log lines). It is a **representation, not an event-by-event source of truth**: it shows the shape and progression of the swarm faithfully, but where a precise micro-signal isn't available it fills in an indicative view rather than a literal 1:1 trace of every request.

The graph maps the same six pipeline phases the scanner runs:

```
Reconnaissance -> Discovery -> Strategy -> Exploitation -> Validation -> Reporting
```

---

## View toggle

The scan console offers three view modes via a toggle at the top:

| View | Shows |
|------|-------|
| **Split** (default) | The full-bleed cinematic graph with the live event log superimposed -- the visual and the technical truth at once |
| **Graph** | The graph only |
| **Events** | The raw event/log stream only |

The graph is what you see by default (as part of the Split "director" view), with the events overlaid so nothing is hidden.

---

## What the graph shows

Reading left to right, the graph lays out the pipeline the way the design mockup does:

- **Recon tools** discovering **URLs**
- The **ThinkingAgent** consolidating and deduplicating candidates (WET -> DRY)
- **Specialist agents**, each with its own escalation ladder
- The **AgenticValidator** (CDP) confirming browser-executable findings
- The **Reporter** fanning out into parallel threads (CVSS scoring, per-type PoC generation, technical report, executive summary)

Each vulnerability type gets its own colour, applied to its node, its connecting line and its particles, so the swarm stays readable when many agents run at once. Active nodes beat to show where the pipeline currently is.

### AuthDiscovery node

A dedicated **AuthDiscovery** node shows authentication reconnaissance status live (WEB 1.5.27). It progresses from *starting*, through per-URL progress (`Auth scan i/N`), to a completed summary of what it found (for example `N JWT - N cookie`).

### Recon handoff and disconnect

When strategy begins, a flurry of coloured lights flies from the recon tools into the ThinkingAgent -- the strategy handoff. Once exploitation starts, reconnaissance and discovery have "left their files" and **disconnect**: the pipeline then runs on from the ThinkingAgent through the specialists, keeping the view focused on where the work is happening.

---

## Live escalation ladders

Each specialist node carries an **L1 -> L6 escalation ladder** -- the progressive, increasingly-expensive levels an agent climbs, stopping at the first level that confirms. The ladders mirror the real agent pipelines, for example:

| Agent | Ladder (representative rungs) |
|-------|-------------------------------|
| **XSS** | smart probe -> polyglot+OOB -> static bombing -> LLM bombing -> HTTP manipulator -> browser -> CDP |
| **CSTI** | smart probe -> WET payload -> template probe -> static bombing -> LLM bombing -> HTTP manipulator -> browser -> CDP |
| **SQLi** | WET payload -> error-based -> boolean+union -> OOB+time -> SQLMap |
| **IDOR** | retest diff -> HTTP methods -> impact -> horizontal -> vertical |

Before WEB 1.5.39 the ladder rungs lit only on confirmation, so an agent still working (e.g. XSS grinding many browser validations) looked frozen. The CLI already emits `exploit.<type>.level.started` / `.completed` events; the WEB now tracks a live per-vulnerability-type escalation level and lights the rungs up to the level the agent is currently on, so an in-progress agent visibly advances instead of appearing hung.

Because the exact confirming rung isn't reported by the backend, the "confirmed at" point shown on a ladder is indicative rather than exact.

---

## Findings flow

Confirmed findings route differently depending on how they were validated:

- **XSS / CSTI** (browser-executable) flow to the **AgenticValidator** (CDP) node for confirmation.
- Everything else (SQLi, LFI, RCE, IDOR, ...) self-validates over HTTP and flows **straight to the report**.

Both paths converge on the Reporter and its parallel reporting threads.

---

**Parent**: [BugTraceAI-WEB](/bugtraceai-web)

**See also**: [Real-time Scan Monitoring](/real-time-scan-monitoring) | [Scanning Pipeline](/scanning-pipeline) | [Specialist Agents](/specialist-agents) | [Validation System](/validation-system)
