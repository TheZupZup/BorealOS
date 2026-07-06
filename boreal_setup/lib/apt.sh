#!/usr/bin/env bash
#
# APT helpers. Privileged calls go through run_privileged (lib/require.sh).

set -euo pipefail

apt_update() {
  log_info "Refreshing APT package lists"
  run_privileged apt-get update
}

apt_install() {
  # $@: APT package names
  if [[ $# -eq 0 ]]; then
    log_warn "apt_install called without packages"
    return 0
  fi
  log_info "Installing APT packages: $*"
  run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install --yes "$@"
}

apt_package_installed() {
  # $1: package name. Returns 0 when the package is fully installed.
  local package_name="$1"
  local status
  status="$(dpkg-query --show --showformat='${db:Status-Status}' "${package_name}" 2>/dev/null)" || return 1
  [[ "${status}" == "installed" ]]
}

apt_package_available() {
  # $1: package name. Returns 0 when APT has an installation candidate.
  # Unknown packages and purely virtual packages have none. LC_ALL=C keeps
  # the "Candidate:" label parseable regardless of the system locale.
  local package_name="$1"
  local candidate
  candidate="$(env LC_ALL=C apt-cache policy "${package_name}" 2>/dev/null \
    | awk '/^  Candidate:/ { print $2 }')"
  [[ -n "${candidate}" && "${candidate}" != "(none)" ]]
}

apt_install_if_available() {
  # $@: APT package names. Installs the ones APT can find and warns about
  # the rest, so one unavailable package does not fail a whole profile.
  if [[ $# -eq 0 ]]; then
    log_warn "apt_install_if_available called without packages"
    return 0
  fi
  local package
  local -a available=() unavailable=()
  for package in "$@"; do
    if apt_package_available "${package}"; then
      available+=("${package}")
    else
      unavailable+=("${package}")
    fi
  done
  if [[ ${#unavailable[@]} -gt 0 ]]; then
    log_warn "Skipping packages with no installation candidate: ${unavailable[*]}"
  fi
  if [[ ${#available[@]} -gt 0 ]]; then
    apt_install "${available[@]}"
  fi
}
