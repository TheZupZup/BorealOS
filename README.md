# Boreal Setup

A post-install setup tool for fresh **Debian 13 (trixie) + KDE Plasma** installations.

Boreal Setup is the first building block of the BorealOS project. It is **not a Linux
distribution** — at least not yet. There is no ISO, no installer, no custom kernel and
no custom package repositories. It is a small collection of readable Bash scripts that
take a stock Debian 13 KDE system and prepare it for everyday desktop use.

## Why

Debian stable is a great, boring base — in the best sense of the word. But a fresh
install still needs a pile of manual steps before it is comfortable for gaming,
development, laptop use or privacy-minded workflows. Boreal Setup automates those
steps while staying as close to stock Debian as possible.

## Status: early scaffold

The project structure, interactive menu and helper libraries are in place. The
profiles themselves are still placeholders: they print what they will eventually do
and change nothing. Real profile contents land in small, focused PRs — see
[docs/roadmap.md](docs/roadmap.md).

## Profiles

| Profile     | What it will cover                                        |
| ----------- | --------------------------------------------------------- |
| `gaming`    | Steam, GameMode, MangoHud (planned)                        |
| `developer` | Build tools, git tooling, container runtimes (planned)     |
| `laptop`    | Power management and battery-friendly defaults (planned)   |
| `privacy`   | Firewall and privacy-friendly desktop defaults (planned)   |

## Requirements

- A fresh Debian 13 (trixie) installation with KDE Plasma
- A user account with `sudo` access
- `git` to clone the repository (`sudo apt install git`)

## Getting started

There is intentionally no `curl | bash` one-liner. Clone the repository and read the
scripts before running them — they are short on purpose:

```sh
git clone https://github.com/TheZupZup/BorealOS.git
cd BorealOS
bash boreal_setup/main.sh
```

Run it as your normal user. The menu asks which profiles to run and confirms your
selection before doing anything; privileged steps go through `sudo` only when needed.

## Repository layout

```text
boreal_setup/
  main.sh        Entry point: loads libs + profiles, shows the menu
  lib/           Shared helpers (logging, prompts, checks, APT, Flatpak)
  profiles/      One file per setup profile, discovered automatically
docs/            Roadmap, contributing guide, profile documentation
scripts/
  check.sh       Bash syntax validation + ShellCheck (when installed)
```

## Development

Run the checks before opening a PR:

```sh
scripts/check.sh
```

See [docs/contributing.md](docs/contributing.md) for the shell style rules,
[docs/profiles.md](docs/profiles.md) for how profiles work, and
[docs/roadmap.md](docs/roadmap.md) for where the project is heading.

## License

[MPL-2.0](LICENSE)
