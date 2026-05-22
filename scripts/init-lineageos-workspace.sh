#!/usr/bin/env bash
#
# init-lineageos-workspace.sh — prepare a workspace directory for a future
# LineageOS source checkout and document the intended 'repo init' flow.
#
# DRY-RUN BY DEFAULT: with no arguments this only prints the steps it would
# take and changes nothing. Pass --run to actually create the workspace and
# run 'repo init'.
#
# BorealOS cannot be built or flashed yet — this only prepares the ground for
# future build work.
#
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-lineageos-workspace.sh [--run] [--help]

Prepare a workspace for a future LineageOS checkout and show the intended
'repo init' command.

Options:
  --run     Actually create the workspace directory and run 'repo init'.
            Without this flag the script is a dry run and changes nothing.
  --help    Show this help and exit.

Configuration (override in config/borealos.env — copy the .example file):
  BOREALOS_WORKSPACE      Where the source tree will live.
  LINEAGE_MANIFEST_URL    The 'repo' manifest URL to init from.
  LINEAGE_BRANCH          The manifest branch to track (verify this!).
EOF
}

# --- Defaults (overridable via config/borealos.env) -------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BOREALOS_WORKSPACE="${HOME}/borealos-lineageos"
LINEAGE_MANIFEST_URL="https://github.com/LineageOS/android.git"
LINEAGE_BRANCH="lineage-21.0"

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

REPO_INIT_CMD="repo init -u ${LINEAGE_MANIFEST_URL} -b ${LINEAGE_BRANCH}"

printf 'BorealOS — initialize LineageOS workspace\n\n'
printf '  Workspace : %s\n' "${BOREALOS_WORKSPACE}"
printf '  Manifest  : %s\n' "${LINEAGE_MANIFEST_URL}"
printf '  Branch    : %s\n\n' "${LINEAGE_BRANCH}"

if [ "${DRY_RUN}" -eq 1 ]; then
  printf 'DRY RUN — no changes will be made. Steps that --run would perform:\n\n'
  printf '  1. mkdir -p %q\n' "${BOREALOS_WORKSPACE}"
  printf '  2. cd %q\n' "${BOREALOS_WORKSPACE}"
  printf '  3. %s\n\n' "${REPO_INIT_CMD}"
  printf 'Re-run with --run to perform these steps.\n'
  printf 'WARNING: a later "repo sync" can download a VERY LARGE source tree\n'
  printf '(tens of gigabytes). Make sure you have the disk space and bandwidth.\n'
  exit 0
fi

# --- Real run ---------------------------------------------------------------
printf 'WARNING: this initializes a LineageOS workspace. A later "repo sync"\n'
printf 'can download a VERY LARGE source tree (tens of gigabytes). Ensure you\n'
printf 'have enough disk space and bandwidth before syncing.\n\n'

if ! command -v repo >/dev/null 2>&1; then
  printf "error: 'repo' is not installed or not on PATH.\n" >&2
  printf "Install it first (see scripts/borealos-doctor.sh) then re-run.\n" >&2
  exit 1
fi

mkdir -p "${BOREALOS_WORKSPACE}"
cd "${BOREALOS_WORKSPACE}"
printf 'Running: %s\n' "${REPO_INIT_CMD}"
repo init -u "${LINEAGE_MANIFEST_URL}" -b "${LINEAGE_BRANCH}"

printf '\nWorkspace initialized at %s\n' "${BOREALOS_WORKSPACE}"
printf 'Next: fetch the sources with scripts/sync-lineageos.sh --run\n'
