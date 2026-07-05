#!/usr/bin/env bash
#
# System requirement checks and privilege helpers.

set -euo pipefail

require_command() {
  # $1: command that must exist on PATH
  local command_name="$1"
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    log_error "Required command is missing: ${command_name}"
    return 1
  fi
}

detect_os_id() {
  # Prints the ID field from /etc/os-release, or "unknown".
  if [[ ! -r /etc/os-release ]]; then
    echo "unknown"
    return 0
  fi
  # shellcheck disable=SC1091
  (source /etc/os-release && echo "${ID:-unknown}")
}

require_debian() {
  # Fails when the system does not identify itself as Debian.
  local os_id
  os_id="$(detect_os_id)"
  if [[ "${os_id}" != "debian" ]]; then
    log_error "Expected a Debian system, but detected: ${os_id}"
    return 1
  fi
}

run_privileged() {
  # Runs a command as root, going through sudo when necessary.
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    require_command sudo
    sudo "$@"
  fi
}
