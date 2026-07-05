#!/usr/bin/env bash
#
# Repository health check: validates Bash syntax for every shell script
# and additionally runs ShellCheck when it is installed.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

list_shell_scripts() {
  find . -path ./.git -prune -o -type f -name '*.sh' -print | sort
}

check_bash_syntax() {
  # $@: script paths. Fails when any script does not parse.
  local file failed=0
  echo "==> Validating Bash syntax"
  for file in "$@"; do
    if bash -n "${file}"; then
      echo "    ok ${file}"
    else
      echo "    syntax error in ${file}" >&2
      failed=1
    fi
  done
  return "${failed}"
}

run_shellcheck() {
  # $@: script paths. Skips quietly when ShellCheck is not installed.
  if ! command -v shellcheck >/dev/null 2>&1; then
    echo "==> ShellCheck not installed — skipping lint (try: sudo apt install shellcheck)"
    return 0
  fi
  echo "==> Running ShellCheck"
  shellcheck "$@"
}

main() {
  cd "${REPO_ROOT}"
  local -a scripts=()
  mapfile -t scripts < <(list_shell_scripts)
  if [[ ${#scripts[@]} -eq 0 ]]; then
    echo "No shell scripts found — nothing to check." >&2
    exit 1
  fi

  local failed=0
  check_bash_syntax "${scripts[@]}" || failed=1
  run_shellcheck "${scripts[@]}" || failed=1

  if [[ "${failed}" -ne 0 ]]; then
    echo "Checks failed." >&2
    exit 1
  fi
  echo "All checks passed."
}

main "$@"
