---
title: Bugstore
---

# BugStore

BugStore is a **deliberately vulnerable e-commerce application** designed as a practice target for BugTraceAI. It provides a realistic web application with intentionally planted security vulnerabilities, allowing users to test and benchmark the scanning pipeline against known issues.

**Live instance**: [bugstore.bugtraceai.com](https://bugstore.bugtraceai.com/)

---

## What is BugStore?

BugStore simulates a typical e-commerce platform (product listings, user accounts, shopping cart, forums) with 27+ tracked security vulnerabilities spanning all major vulnerability classes. It serves two purposes:

1. **Practice target** -- Learn how BugTraceAI works by scanning a real application with known vulnerabilities
2. **Benchmarking** -- Measure scanner detection rates against a controlled set of V-IDs (vulnerability identifiers)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | FastAPI (Python) |
| **Frontend** | Vite + React + Tailwind CSS |
| **Database** | SQLite |
| **Theme** | Dark "hive" theme (purple/coral palette) |

---

## Vulnerability Coverage

BugStore contains 27 tracked vulnerabilities (V-001 through V-027) across these categories:

| Category | Count | Examples |
|----------|-------|---------|
| SQL Injection | 9 | Login bypass, search injection, cookie-based SQLi |
| Cross-Site Scripting (XSS) | 7 | Reflected, stored (forum posts, reviews), DOM-based |
| IDOR | 3 | Order access, profile data, admin endpoints |
| Broken Access Control | 3 | Admin panel, role escalation, endpoint protection |
| Local File Inclusion | 2 | Path traversal, Nginx misconfiguration |
| Remote Code Execution | 2 | Command injection, insecure deserialization |
| CSTI | 1 | Client-side template injection |
| JWT Weaknesses | 1 | Weak signing secret |
| Open Redirect | 1 | URL parameter redirect |
| Prototype Pollution | 1 | Client-side via legacy JavaScript |
| GraphQL | 1 | Introspection enabled |
| Security Misconfigurations | 9+ | Missing headers, verbose errors, debug endpoints |

---

## Detection Benchmarks

Best BugTraceAI scan results against BugStore:

| Metric | Value |
|--------|-------|
| **V-IDs detected** | 19 out of 24 testable = **79.2%** |
| **Total findings** | 145 (43 validated) |
| **Vulnerability types found** | SQLi, XSS, IDOR, BAC, LFI, RCE, CSTI, JWT, Open Redirect, Prototype Pollution, GraphQL, Misconfig |

### Remaining Detection Gaps

| V-ID | Vulnerability | Why It's Hard |
|------|--------------|---------------|
| V-027 | SSTI in email preview | Requires POST + admin authentication |
| V-026 | Header Injection | Non-standard injection point |
| V-023 | Mass Assignment | Requires specific field knowledge |
| V-024 | Information Disclosure | Subtle data leakage patterns |

---

## Running BugStore Locally

BugStore is included in the BugTraceAI repository:

```bash
cd BugStore
pip install -r requirements.txt
python -m uvicorn src.main:app --host 0.0.0.0 --port 9000

# In a separate terminal
cd BugStore/frontend
npm install
npm run dev
```

---

## Demo Report

A complete scan report from BugStore is available:
- **[Live Demo](https://demo.bugtraceai.com/bugtraceai)** -- Browse the report interactively
- **[Download ZIP](https://github.com/BugTraceAI/BugTraceAI/releases/download/demo-report/BugTraceAI-Demo-Report.zip)** -- Full report with all artifacts

---

**See also**: [Scanning Pipeline](/scanning-pipeline) | [Specialist Agents](/specialist-agents) | [Getting Started](/getting-started)
