#!/usr/bin/env bash
#
# System requirement checks, OS detection and privilege helpers.

set -euo pipefail

# os-release file consulted by the detect_os_* helpers below. Overridable so
# the detection logic can be exercised against fixture files.
BOREAL_OS_RELEASE_FILE="${BOREAL_OS_RELEASE_FILE:-/etc/os-release}"

require_command() {
  # $1: command that must exist on PATH
  local command_name="$1"
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    log_error "Required command is missing: ${command_name}"
    return 1
  fi
}

read_os_release_field() {
  # $1: field name from the os-release file (ID, VERSION_ID, ...).
  # Prints its value, or "unknown" when the file is missing, unreadable,
  # malformed or does not define the field.
  local field="$1"
  local value=""
  if [[ -r "${BOREAL_OS_RELEASE_FILE}" ]]; then
    # shellcheck disable=SC1090
    value="$(source "${BOREAL_OS_RELEASE_FILE}" 2>/dev/null && printf '%s' "${!field:-}")" || value=""
  fi
  printf '%s\n' "${value:-unknown}"
}

detect_os_id() {
  # Prints the ID field (e.g. "debian"), or "unknown".
  read_os_release_field ID
}

detect_os_version_id() {
  # Prints the VERSION_ID field (e.g. "13"), or "unknown".
  read_os_release_field VERSION_ID
}

detect_os_codename() {
  # Prints the VERSION_CODENAME field (e.g. "trixie"), or "unknown".
  read_os_release_field VERSION_CODENAME
}

detect_os_pretty_name() {
  # Prints the PRETTY_NAME field (e.g. "Debian GNU/Linux 13 (trixie)"),
  # or "unknown".
  read_os_release_field PRETTY_NAME
}

is_debian_trixie() {
  # Succeeds only when the system identifies as Debian 13 (trixie).
  [[ "$(detect_os_id)" == "debian" ]] || return 1
  [[ "$(detect_os_codename)" == "trixie" || "$(detect_os_version_id)" == "13" ]]
}

describe_debian_release() {
  # Prints "Debian <version> (<codename>)", degrading gracefully when the
  # os-release file omits fields.
  local version codename pretty
  version="$(detect_os_version_id)"
  codename="$(detect_os_codename)"
  pretty="$(detect_os_pretty_name)"
  if [[ "${version}" != "unknown" && "${codename}" != "unknown" ]]; then
    echo "Debian ${version} (${codename})"
  elif [[ "${codename}" != "unknown" ]]; then
    echo "Debian ${codename}"
  elif [[ "${version}" != "unknown" ]]; then
    echo "Debian ${version}"
  elif [[ "${pretty}" != "unknown" ]]; then
    # Debian testing/unstable may omit both version fields; PRETTY_NAME
    # still carries something useful, e.g. "Debian GNU/Linux trixie/sid".
    echo "${pretty}"
  else
    echo "Debian (unrecognized release)"
  fi
}

describe_detected_os() {
  # Prints a short human-readable description of the detected system,
  # e.g. "Debian 12 (bookworm)" or "Ubuntu 24.04.4 LTS".
  local os_id pretty
  os_id="$(detect_os_id)"
  if [[ "${os_id}" == "debian" ]]; then
    describe_debian_release
    return 0
  fi
  pretty="$(detect_os_pretty_name)"
  if [[ "${pretty}" != "unknown" ]]; then
    echo "${pretty}"
  else
    echo "${os_id}"
  fi
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
