---
title: "AIrepeater"
---

# AIrepeater

The AIrepeater is a Burp/Caido-style HTTP request workbench built into BugTraceAI-WEB. It lets you send and modify raw HTTP requests, iterate on payloads with AI assistance, and turn a reproduced request/response into a tracked finding -- all with a human in control. Introduced in WEB 1.5.23.

---

## Overview

Where the scanner runs autonomously, the AIrepeater is the manual, interactive counterpart: an AI-guided repeater for finishing off a finding, confirming an edge case, or crafting a clean proof-of-concept by hand.

Each AIrepeater session:
- Is a **multi-tab** workbench -- open several independent sessions side by side, each with its own request, response and agent state
- Keeps inactive tabs **mounted** so a running agent in one tab keeps working while you switch to another
- Runs against the **active LLM provider** (OpenRouter, Anthropic, or Z.ai), reusing that provider's key and base URL
- **Persists** each tab's session in the browser (`localStorage`) so a page reload restores your work

---

## Layout

An AIrepeater tab is a three-pane workbench:

| Pane | Purpose |
|------|---------|
| **Request** | Editable raw HTTP request -- mutate it by hand or let the agent mutate it |
| **Response** | The response for the last send, viewable as **Pretty**, **Raw**, or **Headers** (with response byte size) |
| **AI Agent** | The agent drawer: reasoning, tool calls, mode controls, and session settings |

A prominent **Send** button issues the current request at any time.

---

## Manual and agent-driven modes

The AIrepeater supports two working modes, toggled per tab:

| Mode | Behaviour |
|------|-----------|
| **Manual** | Step-by-step. The agent proposes a mutation and pauses; you **Approve & send** it, or **Edit** the mutation first. Nothing is sent without you. |
| **Auto** | The agent takes over -- it mutates the request, re-sends it, reads the response, and iterates toward exploitation on its own. |

Because inactive tabs stay mounted, an Auto session keeps iterating in the background while you work in another tab.

### Agent iterations (hops)

The agent runs a tool loop and pauses after a configurable number of **tool-hops** so you can steer it. The default is 24 hops, adjustable in the tab and saved in your browser only.

---

## AI-assisted analysis

The agent operates directly on the request and response through a small set of tools, including:

- **Mutate** the request (set/replace query parameters)
- **Send** the request through the backend and read the response
- **Search the response** (`grep_response`) for a pattern -- useful when a response is large or truncated
- **Record a finding** -- promote a confirmed proof-of-concept into a tracked finding (persisted to the scan when a scan id is available)

After each send the agent inspects where and how the payload reflects, uses the surviving characters to choose the next breakout, and refines toward a clean, copy-pasteable, non-destructive PoC.

---

## Model selection

The AIrepeater has its own **independent, thinking-free model selector** for the exploit loop, separate from the chat model. This favours fast workhorse models (for example Kimi and DeepSeek) for a quick tool loop rather than slow reasoning models.

- The dropdown offers models the **active provider can actually serve**: OpenRouter shows the curated model pack; Anthropic and Z.ai show their own model lists.
- The default is taken from the scanner's `MUTATION_MODEL` when servable, or you can pick a curated model to override it for the session, or defer to the scanner/chat fallback.
- An unservable model id (e.g. an OpenRouter slug while Anthropic is active) is never shown as selected.

Anthropic tool-calling is normalized to the shared shape, so the multi-step tool loop works on Claude as well as on OpenRouter and Z.ai.

---

## Authenticated replay

To reproduce authenticated requests without leaking secrets to disk, the AIrepeater offers two mechanisms:

- **Live auth token** -- paste a fresh token that replaces the masked/redacted `Authorization` header at send time. It is kept only in the current browser session (cleared on tab close) and never written to the CLI's disk.
- **Auto-auth macro** -- automatically heal a `401`/`403` by either forging a JWT with a scan-cracked secret (no credentials needed) or re-logging in, then injecting the acquired token and retrying the send. A dry-run **test** button (WEB 1.5.38) runs the login/forge macro immediately and reports success or failure with a reason, so you can confirm it works before relying on it.

---

## Report handoff and playbooks

The AIrepeater is wired into the scan reports. From a past report you can **Send to Repeater** on an eligible finding, which loads it into a new tab as a seed carrying what the scanner already learned about it -- target, parameter, reflecting payloads, and captured request.

The agent is then primed with a **per-vulnerability playbook**: its system prompt specializes to the finding's vulnerability type, and its task differs depending on whether the scanner already confirmed the issue (reproduce it and craft the cleanest PoC) or only suspected it (finish exploiting it and land a working PoC). The full loop stays strictly non-destructive.

---

## Usage

### Reproduce a scanner finding
1. Open a completed scan report and choose **Send to Repeater** on a finding.
2. In the new tab, pick **Auto** to let the agent reproduce it, or **Manual** to drive each mutation yourself.
3. Watch the response pane; use the agent's response search to locate the reflection.
4. When the PoC fires, record it as a tracked finding.

### Explore a raw request
1. Open a blank AIrepeater tab and paste a request.
2. Choose an exploit model, edit the request, and **Send**.
3. Ask the agent to mutate and re-send, iterating toward a confirmation.

---

**Parent**: [BugTraceAI-WEB](/bugtraceai-web)

**See also**: [Security Toolkit](/security-toolkit) | [Provider Selection](/provider-selection) | [Real-time Scan Monitoring](/real-time-scan-monitoring) | [Report Generation](/report-generation)
