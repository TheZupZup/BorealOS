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

All profiles are placeholders right now: they log what they will eventually do and
change nothing. Real contents arrive in profile-specific PRs (see
[roadmap.md](roadmap.md)).

| Profile     | Planned scope                                       |
| ----------- | ---------------------------------------------------- |
| `gaming`    | Steam, GameMode, MangoHud                             |
| `developer` | build-essential, git tooling, container runtimes      |
| `laptop`    | Power management, battery-friendly defaults           |
| `privacy`   | Firewall defaults, privacy-friendly desktop settings  |
