---
title: Security Toolkit
---

# Security Toolkit

BugTraceAI-WEB includes 20+ specialized AI-powered security tools. Each tool provides a chat-based interface with a dedicated system prompt optimized for its specific security domain. All tool interactions are persisted in PostgreSQL.

---

## Overview

The security toolkit is designed around natural language interaction. Instead of complex configuration forms, users describe what they need in plain language, and the AI provides targeted security analysis, payload generation, or code review.

Each tool:
- Has a **specialized system prompt** tailored to its security domain
- Provides a **chat-based interface** for iterative analysis
- **Persists conversations** in PostgreSQL for reference
- Works **independently** of the CLI scanner (no CLI connection required)
- Uses **OpenRouter API** for AI model access

---

## Tool Categories

### Dynamic Analysis (DAST)

#### URL Analyzer
Analyze web application URLs for potential vulnerabilities. Supports three scan modes:

| Mode | Description |
|------|-------------|
| **Recon** | Passive reconnaissance: technology detection, header analysis, information leakage |
| **Active** | Active testing: parameter fuzzing, injection points, authentication flaws |
| **Grey Box** | Informed analysis with partial knowledge of the application internals |

Configurable recursion depth (1-5 levels) for controlling analysis thoroughness.

#### Headers Analyzer
Audit HTTP security headers against best practices:
- Missing security headers (CSP, HSTS, X-Frame-Options, etc.)
- Misconfigured headers
- Information disclosure via server headers
- Cookie security flags (Secure, HttpOnly, SameSite)

### Static Analysis (SAST)

#### Code Analyzer
AI-powered source code security review:
- Injection vulnerabilities (SQL, command, XSS)
- Authentication and authorization flaws
- Cryptographic weaknesses
- Hardcoded secrets and credentials
- Unsafe deserialization
- Path traversal vulnerabilities

Supports analysis of code snippets in any programming language.

#### DOM XSS Pathfinder
Specialized JavaScript data flow analysis for DOM-based XSS:
- Trace data from sources (location, document, window) to sinks (innerHTML, eval, document.write)
- Identify sanitization gaps
- Map JavaScript execution paths

### Token and Authentication

#### JWT Analyzer
Comprehensive JWT security assessment with dual modes:

| Mode | Description |
|------|-------------|
| **Blue Team** | Defensive analysis: identify weaknesses, recommend hardening |
| **Red Team** | Offensive analysis: exploitation techniques, attack vectors |

Analyzes:
- Algorithm security (none, HS256 vs RS256 confusion)
- Claim validation (exp, nbf, iss, aud)
- Key strength assessment
- Known JWT vulnerabilities

### Payload Generation

#### Payload Forge
AI-powered WAF bypass payload generation:
- XSS payloads with encoding and obfuscation
- SQLi payloads for various backends
- Context-aware payload adaptation
- Filter bypass techniques

#### SSTI Forge
Server-Side Template Injection payload generation:
- Jinja2, Twig, Freemarker, Velocity payloads
- Template engine fingerprinting
- Sandbox escape techniques

#### OOB Helper
Out-of-Band interaction payload generation:
- DNS-based exfiltration payloads
- HTTP callback payloads
- Blind vulnerability confirmation techniques

### Interactive Exploitation Assistants

#### XSS Assistant
Interactive cross-site scripting exploitation helper:
- Context analysis (HTML, attribute, JavaScript, URL)
- Payload suggestions based on filter behavior
- WAF bypass recommendations
- DOM XSS exploitation guidance

#### SQL Assistant
Interactive SQL injection exploitation helper:
- Database type identification
- Injection technique selection (union, blind, error-based)
- Data extraction guidance
- Privilege escalation queries

### Reconnaissance

#### JS Recon
Extract security-relevant information from JavaScript files:
- API endpoints and paths
- Hardcoded secrets and tokens
- Internal hostnames and IPs
- Authentication mechanisms
- Hidden functionality

#### URL Finder
Discover historical URLs using Wayback Machine integration:
- Historical endpoint discovery
- Parameter mining from archived pages
- Technology change detection

#### Subdomain Finder
Discover subdomains using Certificate Transparency logs:
- CT log query for SSL certificates
- Subdomain enumeration
- Wildcard certificate detection

### Other Tools

#### PrivEsc Pathfinder
Privilege escalation path discovery:
- Linux privilege escalation techniques
- Windows privilege escalation techniques
- Known exploit database search
- Misconfiguration detection

#### WebSec Agent
General-purpose AI security Q&A:
- Security concepts explained
- Methodology guidance
- Tool recommendations
- Best practices advice

---

## Architecture

### System Prompt Design

Each tool has a dedicated system prompt that:
1. Defines the AI's role and expertise domain
2. Structures the expected output format
3. Includes domain-specific knowledge
4. Sets safety boundaries (responsible disclosure guidance)

### Chat Persistence

All conversations are stored in PostgreSQL via the Express backend:

```
User message --> Express API (:3001) --> PostgreSQL
                      |
                      v
              OpenRouter API (AI)
                      |
                      v
AI response --> Express API (:3001) --> PostgreSQL
                      |
                      v
              Frontend display
```

### Tool Independence

The security toolkit operates independently of the CLI scanner:
- No CLI connection required
- Tools work with user-provided input (URLs, code, tokens)
- AI analysis only -- no active scanning or exploitation
- Can be used standalone even without the CLI component

---

## Usage

### Example: JWT Analysis

```
User: Analyze this JWT token:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIi
wibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2Q
T4fwpMeJf36POk6yJV_adQssw5c

AI: [Detailed analysis of algorithm, claims, signature strength,
     potential attack vectors, and remediation recommendations]
```

### Example: Payload Generation

```
User: I need XSS payloads that bypass a filter blocking <script> tags
and event handlers. The application uses Angular.

AI: [Context-aware payloads using Angular template injection,
     SVG-based execution, and encoding techniques]
```

---

## Data Privacy

- Chat content is stored in the local PostgreSQL database only
- AI requests go to OpenRouter API (the only external service)
- No data is sent to BugTraceAI servers
- Users control what content is sent to the AI
- API keys are stored encrypted

---

**Parent**: [BugTraceAI-WEB](/bugtraceai-web)

**See also**: [BugTraceAI-WEB](/bugtraceai-web) | [Real-time Scan Monitoring](/real-time-scan-monitoring) | [Configuration](/configuration)
