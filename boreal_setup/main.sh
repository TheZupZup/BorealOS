#!/usr/bin/env bash
#
# Boreal Setup — post-install setup tool for fresh Debian 13 KDE systems.
#
# Loads the helper libraries and setup profiles, then shows a small
# interactive menu asking which profiles to run.

set -euo pipefail

BOREAL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOREAL_LIB_DIR="${BOREAL_ROOT}/lib"
BOREAL_PROFILE_DIR="${BOREAL_ROOT}/profiles"

BOREAL_PROFILES=()
BOREAL_SELECTED_PROFILES=()

source_libraries() {
  local file
  shopt -s nullglob
  for file in "${BOREAL_LIB_DIR}"/*.sh; do
    # shellcheck source=/dev/null
    source "${file}"
  done
  shopt -u nullglob
  if ! declare -F log_info >/dev/null; then
    echo "error: helper libraries are missing from ${BOREAL_LIB_DIR}" >&2
    exit 1
  fi
}

source_profiles() {
  local file
  shopt -s nullglob
  for file in "${BOREAL_PROFILE_DIR}"/*.sh; do
    # shellcheck source=/dev/null
    source "${file}"
    BOREAL_PROFILES+=("$(basename "${file}" .sh)")
  done
  shopt -u nullglob
  if [[ ${#BOREAL_PROFILES[@]} -eq 0 ]]; then
    die "No profiles found in ${BOREAL_PROFILE_DIR}"
  fi
}

print_banner() {
  cat <<'BANNER'
------------------------------------------------------------
  Boreal Setup — Debian 13 KDE post-install tool
  Not a distro (yet). Read the scripts, then enjoy.
------------------------------------------------------------
BANNER
}

ensure_supported_system() {
  local os_id
  os_id="$(detect_os_id)"
  if [[ "${os_id}" == "debian" ]]; then
    return 0
  fi
  log_warn "Boreal Setup targets Debian 13 (trixie), but this system reports: ${os_id}"
  if ! prompt_confirm "Continue anyway?"; then
    log_info "Aborted — nothing was changed."
    exit 0
  fi
}

describe_profile() {
  # $1: profile name. Prints the profile's one-line menu description.
  local profile="$1"
  local describe_function="profile_${profile}_description"
  if declare -F "${describe_function}" >/dev/null; then
    "${describe_function}"
  else
    echo "(no description)"
  fi
}

print_profile_menu() {
  local index profile
  echo
  echo "Available profiles:"
  for index in "${!BOREAL_PROFILES[@]}"; do
    profile="${BOREAL_PROFILES[index]}"
    printf '  %d) %-10s %s\n' "$((index + 1))" "${profile}" "$(describe_profile "${profile}")"
  done
  echo
}

profile_already_selected() {
  local candidate="$1" selected
  for selected in "${BOREAL_SELECTED_PROFILES[@]}"; do
    if [[ "${selected}" == "${candidate}" ]]; then
      return 0
    fi
  done
  return 1
}

add_profile_selection() {
  # $1: 1-based menu number entered by the user
  local token="$1"
  if ! [[ "${token}" =~ ^[1-9][0-9]{0,2}$ ]] || ((token > ${#BOREAL_PROFILES[@]})); then
    log_warn "Not a valid choice: ${token}"
    return 1
  fi
  local profile="${BOREAL_PROFILES[token - 1]}"
  if ! profile_already_selected "${profile}"; then
    BOREAL_SELECTED_PROFILES+=("${profile}")
  fi
}

parse_profile_selection() {
  # $1: raw menu input. Fills BOREAL_SELECTED_PROFILES; fails on bad input.
  local raw="$1"
  local -a tokens=()
  local token
  BOREAL_SELECTED_PROFILES=()
  read -r -a tokens <<<"${raw//,/ }"
  if [[ ${#tokens[@]} -eq 0 ]]; then
    log_warn 'Nothing selected — enter numbers such as "1 3", "all", or "q" to quit.'
    return 1
  fi
  for token in "${tokens[@]}"; do
    case "${token}" in
      q | quit)
        log_info "Nothing to do — bye!"
        exit 0
        ;;
      a | all)
        BOREAL_SELECTED_PROFILES=("${BOREAL_PROFILES[@]}")
        return 0
        ;;
      *)
        add_profile_selection "${token}" || return 1
        ;;
    esac
  done
}

select_profiles() {
  local answer
  while true; do
    print_profile_menu
    answer="$(prompt_input 'Profiles to run ("1 3", "all", or "q" to quit):')" \
      || die "No input received."
    if ! parse_profile_selection "${answer}"; then
      continue
    fi
    if prompt_confirm "Run these profiles now: ${BOREAL_SELECTED_PROFILES[*]}?"; then
      return 0
    fi
  done
}

run_profile() {
  local profile="$1"
  local run_function="profile_${profile}_run"
  if ! declare -F "${run_function}" >/dev/null; then
    die "Profile '${profile}' does not define ${run_function}"
  fi
  echo
  log_info "Running profile: ${profile}"
  "${run_function}"
  log_success "Profile finished: ${profile}"
}

run_selected_profiles() {
  local profile
  for profile in "${BOREAL_SELECTED_PROFILES[@]}"; do
    run_profile "${profile}"
  done
}

main() {
  source_libraries
  source_profiles
  print_banner
  ensure_supported_system
  select_profiles
  run_selected_profiles
  echo
  log_success "Boreal Setup finished."
}

main "$@"
