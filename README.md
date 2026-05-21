# BorealOS

[![Docs CI](https://github.com/TheZupZup/BorealOS/actions/workflows/docs.yml/badge.svg)](https://github.com/TheZupZup/BorealOS/actions/workflows/docs.yml)

BorealOS is a privacy-first Android-based mobile operating system focused on simplicity, transparency, and user control.

The project targets Linux, FOSS, and self-hosted users who want a clean mobile experience without unnecessary bloat or forced cloud integrations.

## Documentation

For a structured introduction to the project — design principles, technical
direction, planned repository layout, and roadmap — see the
[Project Overview](docs/OVERVIEW.md).

## Goals

- Fast and transparent updates
- F-Droid-first ecosystem
- Clean and minimal UI
- Friendly developer experience
- Open-source and community-driven
- Privacy-first defaults
- Long-term maintainability

## Current Status

Early development and research phase.

The first supported device target is:

- Google Pixel 8 Pro (`husky`)

## Planned Features

- Preinstalled F-Droid
- Optional Aurora Store support
- Simplified privacy controls
- Lightweight system apps
- Fast OTA updates
- Linux-inspired workflow and tooling

## Philosophy

BorealOS aims to make mobile devices feel more open, understandable, and user-controlled again.

## Contributing

Documentation and early planning contributions are welcome while the project architecture is being defined.

## Continuous integration

While BorealOS is documentation- and research-first, CI keeps the docs healthy
rather than building Android. On every pull request and on pushes to `main`, a
lightweight [Docs CI](.github/workflows/docs.yml) workflow runs three checks:

- **Markdown linting** with `markdownlint-cli2` for consistent formatting.
- **Link checking** with `lychee` in offline mode, which verifies that relative
  links and in-document heading anchors resolve. External links are not fetched
  over the network, keeping CI fast and free of flaky failures.
- **YAML linting** with `yamllint` for workflow and configuration files.

There is no Android, AOSP, or LineageOS build step yet; that will be added once
the build environment is established (see the [roadmap](docs/OVERVIEW.md#roadmap)).

To run the same checks locally:

```bash
npx markdownlint-cli2 "**/*.md"
yamllint .
# Link checking uses the lychee binary (https://github.com/lycheeverse/lychee):
lychee --offline --include-fragments "**/*.md"
```
