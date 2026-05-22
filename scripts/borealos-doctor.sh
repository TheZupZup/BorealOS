#!/usr/bin/env bash
#
# borealos-doctor.sh — check that the basic tooling for future BorealOS build
# work is available.
#
# This script is READ-ONLY: it only looks for commands on your PATH and never
# installs, removes, or changes anything on your system.
#
# Exit status:
#   0  all checked tools were found
#   1  one or more tools are missing
#
set -euo pipefail

# Tools BorealOS expects for future LineageOS/AOSP work. Each entry is
# "command|why it is needed" so the output can explain itself.
REQUIRED_TOOLS=(
  "git|version control, and the backend used by 'repo'"
  "repo|Android multi-repository tool (https://gerrit.googlesource.com/git-repo)"
  "python3|required by 'repo' and many Android build scripts"
  "java|AOSP/LineageOS build toolchain"
  "make|build orchestration"
  "gcc|host compiler toolchain"
  "curl|downloading tools and sources"
  "unzip|extracting downloaded archives"
)

passed=0
missing=0

printf 'BorealOS doctor — checking basic tooling\n'
printf 'This check is read-only and does not modify your system.\n\n'

for entry in "${REQUIRED_TOOLS[@]}"; do
  cmd="${entry%%|*}"
  why="${entry#*|}"
  if location="$(command -v "${cmd}" 2>/dev/null)"; then
    printf '  [PASS] %-8s %s\n' "${cmd}" "${location}"
    passed=$((passed + 1))
  else
    printf '  [FAIL] %-8s missing — needed for: %s\n' "${cmd}" "${why}"
    missing=$((missing + 1))
  fi
done

printf '\nSummary: %d present, %d missing.\n' "${passed}" "${missing}"

if [ "${missing}" -gt 0 ]; then
  printf '\nSome tools are missing. Install them with your distribution package\n'
  printf 'manager before starting LineageOS/AOSP work. This is only preparation:\n'
  printf 'BorealOS cannot be built or flashed yet.\n'
  exit 1
fi

printf '\nAll basic tools are present.\n'
printf 'Note: this does not mean BorealOS can be built yet — device bring-up and\n'
printf 'build support are not implemented.\n'
