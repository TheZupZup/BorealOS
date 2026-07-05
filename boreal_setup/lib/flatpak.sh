#!/usr/bin/env bash
#
# Flatpak helpers: keep Flathub available and install apps from it.

set -euo pipefail

BOREAL_FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

flatpak_ensure_installed() {
  if command -v flatpak >/dev/null 2>&1; then
    return 0
  fi
  log_info "Flatpak is missing — installing it via APT"
  apt_install flatpak
}

flatpak_ensure_flathub() {
  flatpak_ensure_installed
  log_info "Making sure the Flathub remote is configured"
  run_privileged flatpak remote-add --if-not-exists flathub "${BOREAL_FLATHUB_URL}"
}

flatpak_install() {
  # $@: Flatpak application ids (for example org.mozilla.firefox)
  if [[ $# -eq 0 ]]; then
    log_warn "flatpak_install called without application ids"
    return 0
  fi
  flatpak_ensure_flathub
  log_info "Installing Flatpak apps: $*"
  run_privileged flatpak install --noninteractive flathub "$@"
}
