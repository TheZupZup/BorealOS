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
