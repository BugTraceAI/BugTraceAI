---
title: Specialist Agents
---

# Specialist Agents

During the exploitation phase of the [[Scanning Pipeline]], specialized agents handle each vulnerability class. Each agent consumes from its own task queue, applies AI-driven payload mutation, and reports findings with severity, confidence scores, and validation status.

---

## Agent Architecture

```
            Consolidation Phase (Phase 3)
                     |
    +----------------+----------------+------- ...
    |                |                |
    v                v                v
+----------+  +----------+  +----------+
| XSS      |  | SQLi     |  | SSRF     |  ...
| Specialist|  | Specialist|  | Specialist|
| Queue    |  | Queue    |  | Queue    |
+----+-----+  +----+-----+  +----+-----+
     |              |              |
     v              v              v
  AI Agent       AI Agent       AI Agent
  + Go Fuzzer    (Python)       + Go Fuzzer
     |              |              |
     v              v              v
  Findings       Findings       Findings
```

Each specialist:
- **Consumes** from its own per-specialist queue
- **Uses AI** for intelligent payload mutation and context-driven pruning
- **Uses Go fuzzers** (where applicable) for high-speed payload delivery
- **Reports** severity, confidence score, and validation status
- **Collects evidence** (responses, payloads, screenshots)

---

## Specialist Agents

### XSS Specialist

**Queue**: `xss`
**Fuzzers**: Go XSS Fuzzer + AI Agent

Handles reflected, stored, and DOM-based cross-site scripting.

| Capability | Description |
|-----------|-------------|
| Reflected XSS | Parameter injection with context-aware payloads |
| Stored XSS | Persistent payload injection and retrieval verification |
| DOM XSS | JavaScript data flow analysis via CDP browser |
| WAF Bypass | AI-generated encoding and obfuscation techniques |

The Go XSS fuzzer handles high-speed payload delivery while the AI agent analyzes responses and adapts payloads based on filtering behavior.

### SQLi Specialist

**Queue**: `sqli`
**Fuzzers**: AI Agent (Python)

Handles SQL injection across multiple database backends.

| Capability | Description |
|-----------|-------------|
| Error-based | Trigger database errors to extract information |
| Union-based | UNION SELECT data extraction |
| Blind (boolean) | True/false inference attacks |
| Blind (time-based) | Time delay inference attacks |
| Second-order | Injection via stored data |

### SSRF Specialist

**Queue**: `ssrf`
**Fuzzers**: Go SSRF Fuzzer + AI Agent

Probes for server-side request forgery vulnerabilities.

| Capability | Description |
|-----------|-------------|
| Internal network | Access to internal services (127.0.0.1, metadata endpoints) |
| Cloud metadata | AWS/GCP/Azure metadata endpoint access |
| Protocol smuggling | File://, gopher://, dict:// protocol abuse |
| DNS rebinding | Bypass SSRF protections via DNS rebinding |

### IDOR Specialist

**Queue**: `idor`
**Fuzzers**: Go IDOR Fuzzer + AI Agent

Tests for insecure direct object reference vulnerabilities.

| Capability | Description |
|-----------|-------------|
| Sequential IDs | Enumerate numeric object identifiers |
| UUID guessing | Test predictable UUID patterns |
| Parameter tampering | Modify object references in requests |
| Authorization bypass | Access objects belonging to other users |

### LFI Specialist

**Queue**: `lfi`
**Fuzzers**: Go LFI Fuzzer + AI Agent

Tests for local file inclusion and path traversal.

| Capability | Description |
|-----------|-------------|
| Path traversal | `../` sequences to escape web root |
| Null byte injection | Bypass file extension restrictions |
| Filter bypass | Encoding and double-encoding techniques |
| Log poisoning | Inject payloads via log files |

### RCE Specialist

**Queue**: `rce`
**Fuzzers**: AI Agent (Python)

Tests for remote code execution vulnerabilities.

| Capability | Description |
|-----------|-------------|
| Command injection | OS command injection via user input |
| Code injection | Server-side code execution (eval, exec) |
| Deserialization | Unsafe deserialization exploitation |
| Template injection | Server-side template injection (see also SSTI) |

### XXE Specialist

**Queue**: `xxe`
**Fuzzers**: AI Agent (Python)

Tests for XML external entity injection.

| Capability | Description |
|-----------|-------------|
| File disclosure | Read server files via XXE |
| SSRF via XXE | Internal network access through XML parser |
| Blind XXE | Out-of-band data exfiltration |
| Parameter entities | Entity-based payload techniques |

### JWT Specialist

**Queue**: `jwt`
**Fuzzers**: AI Agent (Python)

Tests JSON Web Token security.

| Capability | Description |
|-----------|-------------|
| Algorithm confusion | alg:none and RS256/HS256 confusion attacks |
| Key brute force | Weak secret key testing |
| Claim manipulation | Modify claims (sub, role, exp) |
| JWK injection | Embed attacker-controlled keys |

### Open Redirect Specialist

**Queue**: `openredirect`
**Fuzzers**: AI Agent (Python)

Tests for open redirect vulnerabilities.

| Capability | Description |
|-----------|-------------|
| URL parameter | Redirect via URL parameters |
| Header injection | Host header manipulation |
| JavaScript redirect | Client-side redirect manipulation |
| Filter bypass | URL encoding and parsing differential tricks |

### Prototype Pollution Specialist

**Queue**: `prototype_pollution`
**Fuzzers**: AI Agent (Python)

Tests for JavaScript prototype pollution.

| Capability | Description |
|-----------|-------------|
| Server-side | Node.js prototype pollution via JSON merge |
| Client-side | DOM-based prototype pollution |
| Gadget chains | Known prototype pollution gadgets |

### CSTI Specialist

**Queue**: `csti`
**Fuzzers**: AI Agent (Python)

Tests for client-side template injection in JavaScript frameworks.

| Capability | Description |
|-----------|-------------|
| Angular | Expression injection in Angular templates |
| Vue.js | Template interpolation attacks |
| React | Unsafe rendering via dangerouslySetInnerHTML |
| Framework detection | Automatic JavaScript framework identification |

### Mass Assignment Specialist

**Queue**: `mass_assignment`
**Fuzzers**: AI Agent (Python)

Tests for mass assignment / parameter binding vulnerabilities.

| Capability | Description |
|-----------|-------------|
| Role escalation | Inject `role`, `is_admin`, `permissions` fields |
| Price manipulation | Modify `price`, `total`, `amount` fields |
| Profile tampering | Add unexpected fields to profile/user update endpoints |
| Privilege fields | Tests a curated list of commonly exploitable fields |

### Header Injection Specialist

**Queue**: `header_injection`
**Fuzzers**: AI Agent (Python)

Tests for HTTP header injection vulnerabilities.

| Capability | Description |
|-----------|-------------|
| Response splitting | CRLF injection in HTTP headers |
| Host header attacks | Host header manipulation for cache poisoning |
| Header override | X-Forwarded-For, X-Original-URL abuse |

### API Security Specialist

**Queue**: `api_security`
**Fuzzers**: AI Agent (Python)

Tests REST/GraphQL API surfaces, including broken access control (horizontal/vertical privilege, method tampering) and API-specific misconfigurations. Access-control testing is shared with the IDOR specialist; there is no separate "BAC" specialist — BAC is a reporting classification, not a dispatched agent.

| Capability | Description |
|-----------|-------------|
| Horizontal privilege | Access resources belonging to other users |
| Vertical privilege | Access admin/higher-privilege endpoints as a regular user |
| Method tampering | HTTP method override (GET vs POST vs PUT) |
| API misconfig | Verbose errors, missing authz on API routes, GraphQL introspection |

### File Upload Specialist

**Queue**: `file_upload`
**Fuzzers**: AI Agent (Python)

Tests file-upload endpoints for unrestricted upload, content-type/extension bypasses, and path-based write primitives that can lead to RCE.

---

## Autonomous Discovery

All specialist agents implement **autonomous parameter discovery**. When a specialist receives a finding from the consolidation phase, it does NOT only test the hinted parameter. Instead:

1. Receives the URL as a "signal"
2. Fetches the page HTML with a browser
3. Extracts ALL parameters: URL query params + HTML form fields + JavaScript variables
4. Tests EVERY discovered parameter with its full payload arsenal

This means specialists can find vulnerabilities in parameters that the analysis phase never saw. For example, the XSS specialist may receive a hint about `?category=` but discover and exploit XSS in a `searchTerm` form field.

Each specialist implements a `_discover_{type}_params()` method with vulnerability-specific logic:
- **SQLiAgent**: Includes CSRF tokens (may have SQLi in token validation)
- **IDORAgent**: Extracts path segments (`/users/123` → `user_id: "123"`) and UUIDs
- **XXEAgent**: Discovers XML upload endpoints and multipart forms
- **JWTAgent**: Searches for JWT patterns in URL, body, cookies, and localStorage
- **PrototypePollutionAgent**: Probes JSON POST acceptance on endpoints

---

## Finding Output

Each specialist produces findings with a consistent structure:

| Field | Description |
|-------|-------------|
| `type` | Vulnerability class (XSS, SQLi, SSRF, etc.) |
| `subtype` | Specific variant (reflected, blind, etc.) |
| `severity` | LOW, MEDIUM, HIGH, or CRITICAL |
| `confidence` | Float 0.0 to 1.0 indicating agent confidence |
| `url` | Affected URL |
| `parameter` | Affected parameter (if applicable) |
| `payload` | Payload that triggered the vulnerability |
| `evidence` | Response data or screenshot proving exploitation |
| `validation_status` | Current validation status |
| `agent` | Which specialist discovered the finding |

---

## AI-Driven Payload Mutation

Specialists do not use static payload lists. Instead, AI drives payload generation:

1. **Context Analysis**: The agent examines the target's technology, response behavior, and filtering patterns
2. **Initial Payload**: An appropriate base payload is selected for the context
3. **Mutation**: If the payload is blocked or filtered, the AI mutates it based on the observed filtering
4. **Adaptation**: The agent learns from each response, narrowing to effective payload classes
5. **Pruning**: If a target is determined to be not vulnerable after sufficient attempts, the agent moves on

This approach is significantly more efficient than brute-forcing large payload dictionaries.

---

## Go Fuzzer vs. AI Agent

| Aspect | Go Fuzzer | AI Agent |
|--------|-----------|----------|
| **Speed** | Thousands of requests/second | Tens of requests/second |
| **Intelligence** | Rule-based payload lists | Context-aware mutation |
| **Use Case** | High-volume initial fuzzing | Intelligent follow-up |
| **Vuln Types** | XSS, SSRF, IDOR, LFI | SQLi, RCE, XXE, JWT, etc. |

For vulnerability classes with Go fuzzers, the typical flow is:
1. Go fuzzer does high-speed initial testing
2. AI agent analyzes fuzzer results
3. AI agent performs targeted follow-up with mutated payloads

---

**Parent**: [[BugTraceAI-CLI]]

**See also**: [[Scanning Pipeline]] | [[Queue and Event System]] | [[Validation System]]
