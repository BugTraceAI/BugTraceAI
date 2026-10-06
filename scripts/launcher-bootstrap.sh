#!/usr/bin/env bash
# Compatibility bridge. Installation logic belongs to BugTraceAI-Launcher.
# Keep the copies in the product repositories identical to this file.
set -euo pipefail

profile="${1:-full}"
case "$profile" in
    terminal|web|full|server|terminal-server|api) ;;
    *) printf 'Unknown Launcher profile: %s\n' "$profile" >&2; exit 2 ;;
esac

minimum_launcher_version="3.3.14"
launcher_base_url="https://raw.githubusercontent.com/BugTraceAI/BugTraceAI-Launcher/main"
version_url="$launcher_base_url/VERSION"
bootstrap_url="$launcher_base_url/install.sh"
version_file="$(mktemp "${TMPDIR:-/tmp}/bugtraceai-launcher-version.XXXXXX")"
bootstrap_file="$(mktemp "${TMPDIR:-/tmp}/bugtraceai-bootstrap.XXXXXX")"
trap 'rm -f "$version_file" "$bootstrap_file"' EXIT

download_file() {
    local url="$1" destination="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --connect-timeout 15 --max-time 120 "$url" -o "$destination"
    elif command -v wget >/dev/null 2>&1; then
        wget -q --tries=2 --timeout=30 -O "$destination" "$url"
    else
        printf 'Install curl or wget, then rerun this entry point.\n' >&2
        return 127
    fi
}

launcher_version_at_least() {
    local actual="${1%%[-+]*}" required="$2"
    local actual_major actual_minor actual_patch required_major required_minor required_patch
    local semantic_version_pattern='^([0-9]+)\.([0-9]+)\.([0-9]+)$'
    [[ "$actual" =~ $semantic_version_pattern ]] || return 1
    actual_major="${BASH_REMATCH[1]}"
    actual_minor="${BASH_REMATCH[2]}"
    actual_patch="${BASH_REMATCH[3]}"
    IFS=. read -r required_major required_minor required_patch <<< "$required"
    [[ "$required_major" =~ ^[0-9]+$ && "$required_minor" =~ ^[0-9]+$ && "$required_patch" =~ ^[0-9]+$ ]] || return 1

    if (( 10#$actual_major != 10#$required_major )); then
        (( 10#$actual_major > 10#$required_major ))
    elif (( 10#$actual_minor != 10#$required_minor )); then
        (( 10#$actual_minor > 10#$required_minor ))
    else
        (( 10#$actual_patch >= 10#$required_patch ))
    fi
}

printf 'Opening the universal BugTraceAI Launcher (suggested profile: %s).\n' "$profile"
printf 'Review the products and runtime in its menu before installing.\n'
if ! download_file "$version_url" "$version_file" || [[ ! -s "$version_file" ]]; then
    printf 'Could not verify the public Launcher version. Check your connection; nothing was run.\n' >&2
    exit 1
fi

launcher_version="$(<"$version_file")"
if ! launcher_version_at_least "$launcher_version" "$minimum_launcher_version"; then
    launcher_version_pattern='^[0-9]+\.[0-9]+\.[0-9]+([-.+][[:alnum:].-]+)?$'
    if [[ "$launcher_version" =~ $launcher_version_pattern ]]; then
        printf 'This component needs BugTraceAI Launcher %s or newer; the public Launcher is %s. Nothing was installed.\n' \
            "$minimum_launcher_version" "$launcher_version" >&2
    else
        printf 'The public Launcher version is missing or invalid. Nothing was installed.\n' >&2
    fi
    printf 'Update the public Launcher release, then retry this entry point.\n' >&2
    exit 1
fi

if ! download_file "$bootstrap_url" "$bootstrap_file"; then
    printf 'Could not download the Launcher. Check your connection and retry.\n' >&2
    exit 1
fi
if [[ ! -s "$bootstrap_file" ]] || ! bash -n "$bootstrap_file"; then
    printf 'The downloaded Launcher bootstrap is empty or invalid; nothing was run.\n' >&2
    exit 1
fi
# A file, rather than curl | bash, keeps stdin available for the visual wizard.
export BUGTRACEAI_LAUNCHER_INITIAL_PROFILE="$profile"
bash "$bootstrap_file"
