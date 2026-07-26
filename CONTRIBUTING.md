# Contributing to BugTraceAI

Thanks for your interest in contributing to BugTraceAI! This document provides guidelines for contributing to the project.

## Project Structure

BugTraceAI is organized as a monorepo. The three primary components are the CLI, WEB, and Launcher; a dedicated practice target and an MCP agent framework round out the ecosystem:

- **BugTraceAI-CLI** — Core scanning engine and API server
- **BugTraceAI-WEB** — React web dashboard
- **BugTraceAI-Launcher** — Docker-based installer
- **reconftw-mcp** — MCP agent framework with integrated Kali Linux and ReconFTW agents
- **BugStore** — Deliberately vulnerable practice target used in demos and testing

## Getting Started

1. Fork the relevant repository
2. Clone your fork locally
3. Create a feature branch: `git checkout -b feat/your-feature`
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## Development Setup

```bash
# Clone with submodules
git clone --recursive https://github.com/BugTraceAI/BugTraceAI.git
cd BugTraceAI

# Start with Docker (recommended)
cd BugTraceAI-Launcher
./launcher.sh
```

## Pull Request Guidelines

- Keep PRs focused on a single change
- Write clear commit messages following conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- Include tests for new functionality
- Update documentation if needed

## Reporting Bugs

Use [GitHub Issues](https://github.com/BugTraceAI/BugTraceAI/issues) to report bugs. Include:

- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version, browser)

## Security Vulnerabilities

**Do not open public issues for security vulnerabilities.** Instead, please refer to our [Security Policy](https://github.com/BugTraceAI/BugTraceAI-CLI/security/policy).

## License

By contributing, you agree that your contributions will be licensed under the [AGPL-3.0 License](LICENSE).
