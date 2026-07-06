# Profiles

A profile is a themed set of post-install steps — for example "make this machine
nice for gaming". Users pick any combination of profiles from the menu in
`boreal_setup/main.sh`.

## How profiles are loaded

Every `*.sh` file in `boreal_setup/profiles/` is sourced by `main.sh` and appears
in the menu automatically. The file name (without `.sh`) is the profile name, so
`profiles/gaming.sh` becomes the `gaming` profile.

## Profile contract

Each profile file must define two functions:

| Function                       | Purpose                                          |
| ------------------------------ | ------------------------------------------------ |
| `profile_<name>_description`   | Prints the one-line description shown in the menu |
| `profile_<name>_run`           | Performs the actual setup steps                  |

Profiles run with the helper libraries already loaded, so they can use
`log_info`/`log_warn`/`log_error`, `prompt_confirm`, `apt_install`,
`flatpak_install` and friends instead of raw commands.

## Rules for profile code

- Be idempotent: running a profile twice must be safe.
- Stay close to Debian stable; prefer official packages, then Flathub.
- No `curl | bash` and no third-party APT repositories unless strictly necessary.
- Ask first (`prompt_confirm`) before anything opinionated or hard to undo.
- Keep steps small and readable — a profile should be skimmable in one screen.

## Current profiles

| Profile     | Status      | Scope                                                |
| ----------- | ----------- | ---------------------------------------------------- |
| `gaming`    | placeholder | Steam, GameMode, MangoHud                             |
| `developer` | placeholder | build-essential, git tooling, container runtimes      |
| `laptop`    | implemented | Power management and sensor tools (see below)         |
| `privacy`   | placeholder | Firewall defaults, privacy-friendly desktop settings  |

Placeholder profiles log what they will eventually do and change nothing. Real
contents arrive in profile-specific PRs (see [roadmap.md](roadmap.md)).

### laptop

Installs laptop tooling from Debian main and enables the related services:

- `power-profiles-daemon` — power profiles, integrates with KDE Plasma's battery
  applet (service enabled). Skipped when TLP is already installed, since the two
  packages conflict and installing one removes the other.
- `thermald` — Intel thermal management (service enabled). Only exists on
  Intel/x86 architectures, so it is installed via `apt_install_if_available`.
- `upower` — battery status and statistics.
- `iio-sensor-proxy` — ambient light and screen rotation sensors.
- `brightnessctl` — backlight control from the command line.
- `rfkill` — enable/disable Wi-Fi and Bluetooth radios.
- `fwupd` — firmware updates via the Linux Vendor Firmware Service.

Services are only enabled when the owning package is installed and systemd is
running, and every step is safe to rerun. Wi-Fi/Bluetooth firmware blobs
(`firmware-iwlwifi` and friends) live in the `non-free-firmware` component and
need APT source handling, so they are future work.
