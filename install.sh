#!/usr/bin/env bash
# The ecosystem entry point delegates to the universal Launcher.
set -euo pipefail
installer_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "${1:-}" in
    '') exec bash "$installer_dir/scripts/launcher-bootstrap.sh" full ;;
    --help|-h)
        printf '%s\n' 'Usage: ./install.sh' \
            'Opens the universal Launcher with the full-platform profile suggested.' \
            'Choose terminal, WEB, API-target server, or a CLI API/MCP server in its menu.' \
            'Manual component installation: see INSTALLATION.md.' ;;
    *) printf 'Unknown option: %s. Run ./install.sh --help.\n' "$1" >&2; exit 2 ;;
esac
