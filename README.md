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

## Early tooling

Before any device flashing or Android build work begins, the repository ships a
few small, safe helper scripts that prepare a future LineageOS/AOSP workflow.
**None of them build BorealOS or flash a device** — that work does not exist
yet. The build-related scripts default to a dry run and only print what they
would do unless you pass `--run`.

- [`scripts/borealos-doctor.sh`](scripts/borealos-doctor.sh) — a read-only check
  for basic tools (`git`, `repo`, `python3`, `java`, `make`, `gcc`, `curl`,
  `unzip`). It never modifies your system.
- [`scripts/init-lineageos-workspace.sh`](scripts/init-lineageos-workspace.sh)
  — documents and, with `--run`, prepares a workspace and the intended
  `repo init` flow. A later sync can download **tens of gigabytes**.
- [`scripts/sync-lineageos.sh`](scripts/sync-lineageos.sh) — runs `repo sync`
  (with `--run`) only inside an already-initialized workspace.

Editable defaults — workspace path, target device (`husky`), and a LineageOS
branch placeholder — live in
[`config/borealos.env.example`](config/borealos.env.example). Copy it and adjust
the values:

```bash
cp config/borealos.env.example config/borealos.env
```

A good first step is the environment check:

```bash
./scripts/borealos-doctor.sh
```

Manifests are not vendored in this repository; see
[`manifests/README.md`](manifests/README.md) for details.

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
