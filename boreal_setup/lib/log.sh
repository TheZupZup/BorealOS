#!/usr/bin/env bash
#
# Logging helpers. Colors are enabled only when writing to a terminal
# and can be turned off with the NO_COLOR environment variable.

set -euo pipefail

BOREAL_LOG_COLOR_INFO=""
BOREAL_LOG_COLOR_WARN=""
BOREAL_LOG_COLOR_ERROR=""
BOREAL_LOG_COLOR_SUCCESS=""
BOREAL_LOG_COLOR_RESET=""

boreal_log_enable_colors() {
  BOREAL_LOG_COLOR_INFO=$'\e[1;34m'
  BOREAL_LOG_COLOR_WARN=$'\e[1;33m'
  BOREAL_LOG_COLOR_ERROR=$'\e[1;31m'
  BOREAL_LOG_COLOR_SUCCESS=$'\e[1;32m'
  BOREAL_LOG_COLOR_RESET=$'\e[0m'
}

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  boreal_log_enable_colors
fi

log_info() {
  printf '%s[info]%s %s\n' "${BOREAL_LOG_COLOR_INFO}" "${BOREAL_LOG_COLOR_RESET}" "$*"
}

log_warn() {
  printf '%s[warn]%s %s\n' "${BOREAL_LOG_COLOR_WARN}" "${BOREAL_LOG_COLOR_RESET}" "$*" >&2
}

log_error() {
  printf '%s[error]%s %s\n' "${BOREAL_LOG_COLOR_ERROR}" "${BOREAL_LOG_COLOR_RESET}" "$*" >&2
}

log_success() {
  printf '%s[ok]%s %s\n' "${BOREAL_LOG_COLOR_SUCCESS}" "${BOREAL_LOG_COLOR_RESET}" "$*"
}

die() {
  log_error "$*"
  exit 1
}
