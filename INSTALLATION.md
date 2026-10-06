# BugTraceAI installation

## Universal Launcher (recommended)

Install any BugTraceAI product through the same visual menu:

```bash
curl -fsSL https://raw.githubusercontent.com/BugTraceAI/BugTraceAI-Launcher/main/install.sh | bash
```

From a cloned ecosystem repository, run `./install.sh`. From a CLI, WEB or API
checkout, `./install.sh` opens the same menu with that product suggested.
Review the included products and runtime, then choose **Install selection**.
The suggestion never starts installation automatically. Current component entry
points require Launcher 3.3.14+; they check its published version and stop before
running an older installer. Installation and menu text are in English.

| Profile | Products | Runtime |
| --- | --- | --- |
| `terminal` | CLI engine and terminal TUI | Local Python or Docker |
| `web` | WEB/database, CLI web-scanning API/MCP and BugTraceAI-API | Docker |
| `full` | WEB, both scanning engines and CLI terminal TUI | Docker |
| `server` | CLI web-scanning REST API + MCP | Local Python or Docker |
| `terminal-server` | CLI TUI and web-scanning API/MCP | Local Python or Docker |
| `api` | Independent API-target engine over REST + MCP | Docker |

The Launcher TUI needs Python 3.10+; its Textual dependencies are isolated in
a user cache. Local CLI runtime uses its own Python environment. Docker keeps
product dependencies inside containers. The API-target image currently packages
Linux amd64 tool binaries; check the API guide before selecting it on ARM.
Native system password prompts stay in your terminal. npm is not required for
the Launcher or for Docker-based WEB installation.

Selected products and ports are saved by the Launcher. Use its `status`,
`update` and `repair` commands to manage that installation. Global `btai` is
offered for profiles with the CLI terminal TUI; it opens the installed local or
Docker workspace. Opening the workspace does not start a scan.

See the [Launcher guide](https://github.com/BugTraceAI/BugTraceAI-Launcher#quick-start)
for system dependencies, macOS runtimes, configuration and service management.

## Direct component installation

Direct installation is available for developers, scripts and coding agents.
It keeps the selected component in its own checkout. It is distinct from a
Launcher-managed installation under the platform installation directory.

| Component | Direct path | Guide |
| --- | --- | --- |
| CLI | `./scripts/install-runtime.sh --interface tui\|api\|both --runtime local\|docker` | [CLI INSTALLATION.md](https://github.com/BugTraceAI/BugTraceAI-CLI/blob/main/INSTALLATION.md) |
| WEB | Configure `.env.docker`, then `./scripts/install-runtime.sh` | [WEB INSTALLATION.md](https://github.com/BugTraceAI/BugTraceAI-WEB/blob/main/INSTALLATION.md#option-2-standalone-docker) |
| API-target engine | Configure `.env`, then `./scripts/install-runtime.sh` | [API README](https://github.com/BugTraceAI/BugTraceAI-API#standalone-docker-compose) |

Only the universal Launcher presents an installation menu. Component
`install.sh` scripts are compatibility entries; explicit old flags still route
to the corresponding runtime backend. The backends have no selection menus
and preserve existing configuration. API `setup.sh` also preserves its service
management commands. Direct agents can use the documented commands or manage
Python/Docker themselves.

The CLI's API/MCP backend scans web applications. BugTraceAI-API is a separate
API-target scanner. Direct WEB can run its dashboard and analysis tools without
either engine, but scans need the corresponding backend connected separately.
Provider keys are configured locally and may be skipped during installation;
add one before starting AI-powered scans. Target authentication is a separate
setting. Installation validation should not start a target scan.

## Install with your AI coding agent

Copy this prompt to an agent with local terminal access. Replace the product
choice before running it:

```text
Install BugTraceAI. My product choice is: [terminal / WEB / full platform /
CLI web-scanning API-MCP server / independent API-target server].

Read the ecosystem README.md and INSTALLATION.md and the selected product's
guide first. Use the universal BugTraceAI Launcher by default. Preview the
matching profile with launcher.sh plan before deployment. If I explicitly ask
for direct component installation, use that component's documented standalone
path in its own checkout instead. Do not use private development repositories.

Preserve existing configuration, credentials, database volumes and uncommitted
files. Resolve only the dependencies needed for my choice. Keep provider keys
and native privilege/password prompts in the local setup flow, not chat output.

Verify the actual selected products, configured ports, service health and MCP
endpoints. For terminal profiles, verify TUI startup/quit and btai registration
in a fresh shell when an interactive terminal is available. Do not launch a
scan as part of installation. Report any check that could not be performed.

Finish with the installation directory, selected products/runtime, local URLs,
checks performed and exact commands to open or manage the installation.
```

## Updates and compatible versions

For Launcher-managed installations, use Launcher 3.3.14+ and review
`./launcher.sh update --plan` before `./launcher.sh update`. The visual menu also
has **Update installation**. Source tags come from one compatible release
manifest; preparation finishes before activation, and saved settings/data remain
in place. Use `./launcher.sh update --recover` for an interrupted activation.

See the [release and recovery guide](https://github.com/BugTraceAI/BugTraceAI-Launcher/blob/main/RELEASES.md).
Direct component checkouts keep their explicit runtime backend. Choose tagged
versions deliberately, retain local configuration and data, and rerun that
backend; a development checkout is not silently moved to a public release.
