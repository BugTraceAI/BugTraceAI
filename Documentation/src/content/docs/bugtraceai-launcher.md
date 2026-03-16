---
title: Bugtraceai Launcher
---

# BugTraceAI-Launcher

BugTraceAI-Launcher is a one-command Docker deployment wizard that handles the complete setup and lifecycle management of the BugTraceAI platform. It automates dependency detection, port management, service configuration, and container orchestration.

**Repository**: [github.com/BugTraceAI/BugTraceAI-Launcher](https://github.com/BugTraceAI/BugTraceAI-Launcher)

---

## Overview

The Launcher eliminates the complexity of manually deploying and configuring BugTraceAI components. A single command handles everything:

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

The interactive wizard guides you through:
1. Selecting a deployment mode
2. Checking system requirements
3. Pulling and building Docker images
4. Configuring environment variables
5. Starting all services
6. Running health checks
7. Displaying access URLs

---

## Features

| Feature | Description |
|---------|-------------|
| **Interactive Wizard** | Step-by-step guided setup |
| **Auto-Dependency Detection** | Checks for Docker, Git, and system requirements |
| **Port Management** | Detects port conflicts and suggests alternatives |
| **Three Deployment Modes** | Full Platform, Standalone WEB, Standalone CLI |
| **Service Lifecycle** | Start, stop, restart, update, uninstall |
| **Health Checks** | Verifies all services are running correctly |
| **Log Access** | View logs from any service |

---

## Installation

### Requirements

- Docker 24.0 or higher
- Git
- 4 GB RAM minimum (8 GB recommended)
- 10 GB disk space
- OpenRouter API key (for AI functionality)

### Quick Start

```bash
git clone https://github.com/BugTraceAI/BugTraceAI-Launcher.git
cd BugTraceAI-Launcher
./launcher.sh
```

The Launcher installs to `~/bugtraceai/` by default. No `sudo` required -- only Docker group permissions are needed.

---

## Commands

| Command | Description |
|---------|-------------|
| `./launcher.sh` | Launch the interactive setup wizard |
| `./launcher.sh status` | Show status of all services |
| `./launcher.sh start` | Start all services |
| `./launcher.sh stop` | Stop all services |
| `./launcher.sh restart` | Restart all services |
| `./launcher.sh update` | Pull latest images and restart |
| `./launcher.sh uninstall` | Remove all containers, images, and data |
| `./launcher.sh logs` | View logs from all services |
| `./launcher.sh logs <service>` | View logs from a specific service |

---

## Deployment Modes

The Launcher supports three deployment modes. See [Deployment Modes](/deployment-modes) for detailed descriptions.

| Mode | Components | Best For |
|------|-----------|----------|
| **Full Platform** | WEB + CLI (auto-connected) | Complete scanning platform |
| **Standalone WEB** | Dashboard only | AI analysis tools, no active scanning |
| **Standalone CLI** | Headless API server | CI/CD, scripted scanning, API-only |

### Full Platform Mode

The recommended mode. Deploys both WEB and CLI, automatically configures the connection between them (CORS, `VITE_CLI_API_URL`), and starts all services.

```bash
./launcher.sh
# Select: Full Platform
```

Services started:
- BugTraceAI-CLI (FastAPI on port 8000)
- BugTraceAI-WEB Frontend (Nginx on port 6869)
- BugTraceAI-WEB Backend (Express on port 3001)
- PostgreSQL (port 5432, internal)

### Standalone Modes

Each standalone mode runs its own Docker Compose project:

```bash
./launcher.sh
# Select: Standalone WEB  (or)  Standalone CLI
```

---

## Architecture

```
+-------------------------------------------------------+
|                  BugTraceAI-Launcher                   |
|                                                        |
|  +------------------+                                  |
|  | launcher.sh      |  Interactive wizard              |
|  +--------+---------+                                  |
|           |                                            |
|           v                                            |
|  +------------------+                                  |
|  | Docker Compose   |  Container orchestration         |
|  +--------+---------+                                  |
|           |                                            |
|     +-----+-----+-----+-----+                         |
|     |           |           |                          |
|     v           v           v                          |
|  +------+   +------+   +------+                       |
|  | CLI  |   | WEB  |   | WEB  |                       |
|  | :8000|   | :6869|   | :3001|                       |
|  +------+   +------+   +------+                       |
|                            |                           |
|                            v                           |
|                      +----------+                      |
|                      | Postgres |                      |
|                      | :5432    |                      |
|                      +----------+                      |
+-------------------------------------------------------+
```

---

## Configuration

### Auto-Configuration

In Full Platform mode, the Launcher automatically configures:
- `VITE_CLI_API_URL`: Points the WEB frontend to the CLI API
- CORS settings: Allows the WEB to communicate with the CLI
- PostgreSQL connection: Configures the WEB backend database
- Docker networking: Sets up inter-container communication

### Environment Variables

The Launcher generates a `.env` file during setup:

```bash
# Generated by BugTraceAI-Launcher
OPENROUTER_API_KEY=sk-or-v1-...
DB_PASSWORD=<generated>
CLI_API_URL=http://btai-cli:8000
VITE_CLI_API_URL=http://localhost:8000
```

### Custom Configuration

After initial setup, edit `~/bugtraceai/.env` to customize settings, then restart:

```bash
./launcher.sh restart
```

---

## Updating

```bash
./launcher.sh update
```

This pulls the latest Docker images, rebuilds if necessary, and restarts all services with zero-downtime where possible.

---

## Troubleshooting

### Check Service Status

```bash
./launcher.sh status
```

### View Logs

```bash
# All services
./launcher.sh logs

# Specific service
./launcher.sh logs cli
./launcher.sh logs web
```

### Port Conflicts

If a required port is already in use, the Launcher will detect the conflict and suggest alternatives. You can also manually change ports in the `.env` file.

### Docker Permissions

If you encounter Docker permission errors, ensure your user is in the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for the change to take effect
```

---

## Uninstalling

```bash
./launcher.sh uninstall
```

This removes:
- All BugTraceAI Docker containers
- All BugTraceAI Docker images
- The `~/bugtraceai/` installation directory
- Generated configuration files

It does **not** remove Docker itself or other unrelated containers.

---

## Sub-Pages

| Page | Description |
|------|-------------|
| [Deployment Modes](/deployment-modes) | Detailed comparison of Full Platform, Standalone WEB, and Standalone CLI modes |

---

**See also**: [Getting Started](/getting-started) | [Architecture](/architecture) | [Deployment Modes](/deployment-modes)
