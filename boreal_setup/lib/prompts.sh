#!/usr/bin/env bash
#
# Small interactive prompt helpers used by the menu in main.sh.

set -euo pipefail

prompt_input() {
  # $1: message shown to the user. Prints the reply; fails on end of input.
  local message="$1"
  local reply=""
  if ! read -r -p "${message} " reply; then
    return 1
  fi
  printf '%s\n' "${reply}"
}

prompt_confirm() {
  # $1: yes/no question. Returns 0 only when the user answers yes.
  local question="$1"
  local reply=""
  read -r -p "${question} [y/N] " reply || true
  [[ "${reply}" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}
