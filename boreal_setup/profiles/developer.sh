#!/usr/bin/env bash
#
# Profile: developer
# Future scope: build tools, git tooling and container runtimes.
# Placeholder in this PR — it deliberately installs nothing yet.

set -euo pipefail

profile_developer_description() {
  echo "Development tools (placeholder — installs nothing yet)"
}

profile_developer_run() {
  log_info "The developer profile is a placeholder for now."
  log_info "Planned next: build-essential, git tooling and container runtimes."
}
