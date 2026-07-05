# Roadmap

Where Boreal Setup is heading, one small PR at a time. Guiding principles: stay close
to Debian stable, prefer boring solutions, keep every change reviewable.

## Phase 0 — Scaffold (done)

- [x] Project layout: `boreal_setup/` with `lib/` and `profiles/`
- [x] Interactive profile menu in `main.sh`
- [x] Helper libraries: logging, prompts, requirement checks, APT, Flatpak
- [x] `scripts/check.sh` for Bash syntax validation and ShellCheck
- [x] Docs: README, roadmap, contributing guide, profile documentation

## Phase 1 — Real profiles

Each profile is filled in by its own PR:

- [ ] `gaming`: Steam (with multiarch), GameMode, MangoHud
- [ ] `developer`: build-essential, git tooling, container runtime
- [ ] `laptop`: power management (TLP or power-profiles-daemon), firmware updates
- [ ] `privacy`: firewall defaults (ufw), privacy-friendly desktop defaults

## Phase 2 — Quality of life

- [ ] Non-interactive mode (for example `--profiles gaming,laptop`) for scripted runs
- [ ] Dry-run mode that shows what would change without changing it
- [x] Explicit Debian version check (warn when not on Debian 13/trixie)
- [ ] Write a run log to a file for easier troubleshooting
- [ ] CI that runs `scripts/check.sh` on every PR

## Phase 3 — Smarter setup

- [ ] Basic hardware detection (GPU vendor → driver suggestions) — explicitly out of
      scope until the profiles are solid
- [ ] KDE Plasma tweaks per profile
- [ ] Optional curated Flathub apps per profile

## Someday / maybe

Ideas, not commitments — and none of them are part of the current scope:

- BorealOS as an installable distribution (ISO, installer, branding)
- A custom package repository

Until any of that happens, Boreal Setup stays a post-install tool for stock Debian.
