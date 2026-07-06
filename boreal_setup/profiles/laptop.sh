#!/usr/bin/env bash
#
# Profile: laptop
# Power management and sensor tools for laptop use, all from Debian main.
# Wi-Fi/Bluetooth firmware blobs (firmware-iwlwifi and friends) live in the
# non-free-firmware component and stay out of scope until a dedicated PR.

set -euo pipefail

profile_laptop_description() {
  echo "Laptop power management and sensor tools"
}

laptop_enable_service() {
  # $1: package that ships the unit, $2: systemd unit name.
  # Enables and starts the unit, but only when the package actually made it
  # onto the system and systemd is running (it is not in containers/chroots).
  local package="$1" unit="$2"
  if ! apt_package_installed "${package}"; then
    log_warn "${package} is not installed — not enabling ${unit}"
    return 0
  fi
  if [[ ! -d /run/systemd/system ]]; then
    log_warn "systemd is not running — not enabling ${unit}"
    return 0
  fi
  log_info "Enabling and starting service: ${unit}"
  # A unit that refuses to start (thermald on non-Intel hardware, for
  # example) should not abort the rest of the profile.
  run_privileged systemctl enable --now "${unit}" \
    || log_warn "Could not enable ${unit} — inspect it with: systemctl status ${unit}"
}

laptop_install_power_daemon() {
  # power-profiles-daemon integrates with KDE Plasma's battery applet. It
  # conflicts with TLP, so installing it would remove an existing TLP setup;
  # in that case keep the user's choice and skip it.
  if apt_package_installed tlp; then
    log_warn "TLP is already installed — skipping power-profiles-daemon (the two conflict)."
    return 0
  fi
  apt_install_if_available power-profiles-daemon
}

profile_laptop_run() {
  apt_update
  laptop_install_power_daemon
  # thermald only exists on Intel/x86 architectures, hence "if available".
  apt_install_if_available \
    thermald \
    upower \
    iio-sensor-proxy \
    brightnessctl \
    rfkill \
    fwupd
  laptop_enable_service power-profiles-daemon power-profiles-daemon.service
  laptop_enable_service thermald thermald.service
  log_info "Wi-Fi/Bluetooth firmware packages need the non-free-firmware component — planned for a later PR."
}
