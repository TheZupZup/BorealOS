#!/usr/bin/env bash
#
# sync-lineageos.sh — run 'repo sync' inside an already-initialized LineageOS
# workspace.
#
# DRY-RUN BY DEFAULT: with no arguments this only prints what it would do and
# changes nothing. Pass --run to actually run 'repo sync'.
#
# The workspace must already be initialized (see init-lineageos-workspace.sh);
# this script refuses to run if it does not find a '.repo' directory.
#
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-lineageos.sh [--run] [--help]

Run 'repo sync' inside an initialized LineageOS workspace.

Options:
  --run     Actually run 'repo sync'. Without this flag the script is a dry
            run and changes nothing.
  --help    Show this help and exit.

Configuration (override in config/borealos.env — copy the .example file):
  BOREALOS_WORKSPACE   The initialized workspace to sync.
EOF
}

# --- Defaults (overridable via config/borealos.env) -------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BOREALOS_WORKSPACE="${HOME}/borealos-lineageos"

ENV_FILE="${REPO_ROOT}/config/borealos.env"
if [ -f "${ENV_FILE}" ]; then
  # shellcheck source=/dev/null
  . "${ENV_FILE}"
fi

# --- Argument parsing -------------------------------------------------------
DRY_RUN=1
for arg in "$@"; do
  case "${arg}" in
    --run) DRY_RUN=0 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'error: unknown argument: %s\n\n' "${arg}" >&2
      usage >&2
      exit 2
      ;;
  esac
done

printf 'BorealOS — sync LineageOS workspace\n\n'
printf '  Workspace : %s\n\n' "${BOREALOS_WORKSPACE}"

# An initialized workspace always contains a '.repo' directory.
if [ ! -d "${BOREALOS_WORKSPACE}/.repo" ]; then
  printf 'error: no initialized workspace found at %s\n' "${BOREALOS_WORKSPACE}" >&2
  printf "(expected a '.repo' directory there)\n" >&2
  printf 'Run scripts/init-lineageos-workspace.sh --run first.\n' >&2
  exit 1
fi

if [ "${DRY_RUN}" -eq 1 ]; then
  printf 'DRY RUN — no changes will be made. Steps that --run would perform:\n\n'
  printf '  1. cd %q\n' "${BOREALOS_WORKSPACE}"
  printf '  2. repo sync\n\n'
  printf 'Re-run with --run to perform the sync.\n'
  printf 'WARNING: "repo sync" can download a VERY LARGE source tree (tens of\n'
  printf 'gigabytes) and may take a long time.\n'
  exit 0
fi

# --- Real run ---------------------------------------------------------------
if ! command -v repo >/dev/null 2>&1; then
  printf "error: 'repo' is not installed or not on PATH.\n" >&2
  printf 'Install it first (see scripts/borealos-doctor.sh) then re-run.\n' >&2
  exit 1
fi

printf 'WARNING: "repo sync" can download a VERY LARGE source tree (tens of\n'
printf 'gigabytes) and may take a long time.\n\n'

cd "${BOREALOS_WORKSPACE}"
printf 'Running: repo sync\n'
repo sync
printf '\nSync complete in %s\n' "${BOREALOS_WORKSPACE}"
