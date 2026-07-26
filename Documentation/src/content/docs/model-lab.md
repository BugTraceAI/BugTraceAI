---
title: "Model Lab"
---

# Model Lab

Model Lab (internally `model-eval`) is a side-by-side model benchmarking module for the BugTraceAI scanner. It runs a battery of security-reasoning prompts against a set of candidate LLMs, scores each one with a neutral judge, and ranks them so you can pick the best model **per scanner slot** instead of guessing.

Model Lab is a self-contained module that ships with BugTraceAI-WEB. It benchmarks models through the CLI API but is completely independent of the scanner: running it never starts or changes a scan.

---

## What It Is For

Different scanner slots ask very different things of a model. Payload mutation rewards diversity and creativity; skeptical review rewards precision and the discipline to reject a false positive; report enrichment rewards complete, correct CVSS and PoC write-ups. A single "best overall" model rarely wins every slot.

Model Lab measures each candidate against these axes and produces a **per-slot leaderboard**, so you can, for example, assign a diverse-but-cheap model to MUTATION and a precise model to SKEPTICAL.

---

## Opening Model Lab

Model Lab is a standalone sidebar module in BugTraceAI-WEB, reachable at:

```
/modellab
```

Open it from the WEB sidebar. It is no longer a sub-tab of the main scanner UI -- it is its own top-level module.

---

## Its Own OpenRouter Key

Model Lab uses its **own OpenRouter API key**, entered directly in the module and stored locally in the browser. This key is independent of the scanner's active provider:

- The benchmark always runs against OpenRouter models, even when the scanner's active provider is Anthropic or Z.ai.
- The key is sent to the CLI per request (request `api_key` field / `X-OpenRouter-Key` header) and stays server-side; it is not persisted into the scanner's provider configuration.
- If no module key is supplied, the CLI falls back to its configured provider key (backward-compatible behavior).

> Model Lab currently benchmarks **OpenRouter models only**. Select or configure an OpenRouter key before running it.

### Validate the Key First

Use the **Test key** button before starting a benchmark. It calls the key-validation endpoint, which hits OpenRouter's authenticated `/key` endpoint (returning the key's label and credit limits) and consumes zero tokens. This is a real check -- the public `/models` catalog returns `200` even for a bad key, so it cannot be used for validation.

---

## Benchmark Suites

Each suite is a fixed set of security-reasoning prompts. Prompts are graded by a neutral judge model against a **re-anchored strict rubric**: a correct and complete answer scores 7-8, not 10, and each prompt carries a discriminator so that competent models separate instead of all tying at the top.

| Suite | Prompts | Focus |
|-------|---------|-------|
| **quick-v3** | 9 | Fast pass across analysis, skepticism, and reporting |
| **advanced-v2** | 12 | quick-v3 plus harder cases built from real false-positive / false-negative traps (e.g. backslash-parity breakout, CSTI "49" baseline collision, JWT algorithm confusion, a TOCTOU race) |

The legacy `quick-v2` and `advanced-v1` suites are preserved for comparability with older runs.

---

## Composite Scoring

Each model receives a quality-dominant composite score. The judge grades four axes:

| Axis | Weight | What it measures |
|------|--------|------------------|
| **Correctness** | 0.40 | Is the technical reasoning actually sound? |
| **Skepticism** | 0.30 | Does it distinguish real, false, and inconclusive findings? |
| **Compliance** | 0.15 | Does it help with authorized offensive testing? |
| **Performance** | 0.15 | Latency (a side axis, not the decider) |

Latency is scored on the **median** across a run, so a single slow prompt in a small sample does not distort the ranking. It is reported as a side axis rather than the primary sort -- an earlier performance-heavy weighting effectively turned the ranking into a latency sort whenever the rubric saturated.

A model must clear the ranking gate (minimum correctness, skepticism, and compliance thresholds) to receive a composite score. All weights, gate thresholds, the latency statistic, and the diversity weight live in the `[MODELLAB]` configuration section, and every run records its `scoring_version` and effective weights so results stay self-describing and comparable across time.

---

## Per-Slot Leaderboard

Model Lab ranks models per scanner slot, not one global winner. The slots map directly onto the scanner's configurable model roles:

| Slot | Scanner role |
|------|--------------|
| **MUTATION** | Payload mutation / WAF bypass generation |
| **SKEPTICAL** | Per-finding skeptical review (false-positive discipline) |
| **ANALYSIS** | DASTySAST high-volume per-URL analysis |
| **REPORTING** | Report enrichment (CVSS scoring + PoC) |

Once you have the leaderboard, configure the winning model for each slot in the scanner's per-slot model settings. See [Provider Selection](/provider-selection) for the corresponding configuration keys.

---

## MUTATION Diversity Probe (Opt-In)

For the MUTATION slot, one-shot judge quality is not the whole story: what matters at scan time is generating **many valid, diverse payloads**. The optional MUTATION diversity probe samples payloads at scan temperature and counts the unique, breakout-valid ones.

When the probe runs, the MUTATION slot pick **blends** judge quality with this diversity score. Diversity is the signal that tracks real-scan MUTATION recall: validation confirmed that a model can top one-shot judge quality yet rank last on payload diversity -- matching the observed real scan, where a more diverse model recovered more findings. The diversity share of the blend is configurable (`MODELLAB_MUTATION_DIVERSITY_WEIGHT`).

The probe is off by default and must be explicitly enabled for a run.

---

## API Endpoints

Model Lab drives these CLI API endpoints:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/model-eval/models` | List models available on the active OpenRouter provider |
| `GET` | `/api/model-eval/test-key` | Validate an OpenRouter key (authenticated `/key`, zero tokens) |
| `POST` | `/api/model-eval` | Start a benchmark job (runs in the background) |
| `GET` | `/api/model-eval/{job_id}/results` | Fetch a job's status and results |
| `DELETE` | `/api/model-eval/{job_id}` | Cancel a running benchmark |
| `GET` | `/api/model-eval/history` | List persisted benchmark runs |
| `GET` | `/api/model-eval/history/{run_id}` | Fetch one persisted run |
| `DELETE` | `/api/model-eval/history/{run_id}` | Delete one persisted run |
| `WS` | `/api/ws/model-eval/{job_id}` | Stream live per-model progress events |

The `/api/model-eval/models` and `/api/model-eval` endpoints accept the module's OpenRouter key via the request `api_key` field or the `X-OpenRouter-Key` header.

### Live Progress

Starting a job returns a WebSocket URL (`/api/ws/model-eval/{job_id}`). Connect to it to stream per-model progress as the benchmark runs. Progress is buffered per job, so a client that connects slightly after start still receives the events. Benchmark runs are persisted locally, so completed runs remain available through the history endpoints.

---

## Notes and Costs

- A benchmark makes real LLM calls and consumes credits on the supplied OpenRouter key.
- The CLI API is intended for a local machine or trusted LAN and must not be exposed directly to the Internet.

---

**Parent**: [BugTraceAI-WEB](/bugtraceai-web)

**See also**: [Provider Selection](/provider-selection) | [Configuration](/configuration) | [API Reference](/api-reference)
