# Contributing to Boreal Setup

Thanks for helping out! Boreal Setup aims to stay small, boring and readable.

## Ground rules

- Target platform: Debian 13 (trixie) with KDE Plasma. Stay close to Debian stable.
- No `curl | bash` anywhere — users must be able to read what they run.
- Prefer official Debian packages. Use Flatpak (Flathub) for desktop apps missing
  from Debian. Add third-party APT repositories only when strictly necessary.
- One topic per PR. Small PRs get reviewed; huge ones rot.

## Shell style

- Bash only. Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Keep functions small and single-purpose, with descriptive names
  (`apt_install`, `prompt_confirm`, `profile_gaming_run`).
- Shared behavior belongs in `boreal_setup/lib/`; profile logic belongs in
  `boreal_setup/profiles/`. Avoid one huge script.
- Quote variable expansions and prefer `[[ ... ]]` over `[ ... ]`.
- All scripts must pass `scripts/check.sh`.

## Before you open a PR

1. Run `scripts/check.sh`. Install ShellCheck for full coverage:
   `sudo apt install shellcheck`.
2. If your change affects runtime behavior, test it on Debian 13 KDE — a virtual
   machine is fine.
3. Update the docs when behavior changes.

## Adding a new profile

1. Create `boreal_setup/profiles/<name>.sh`.
2. Define `profile_<name>_description` and `profile_<name>_run`.
3. Done — `main.sh` discovers profile files automatically.

See [profiles.md](profiles.md) for the full profile contract.

## Commits and PRs

- Write imperative, descriptive commit subjects ("Add TLP setup to laptop profile").
- Explain the *why* in the PR description, not just the *what*.
- Keep refactors separate from behavior changes.
