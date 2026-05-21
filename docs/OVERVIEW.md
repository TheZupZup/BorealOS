# BorealOS — Project Overview

BorealOS is a privacy-first, Android-based mobile operating system focused on
simplicity, transparency, and user control. This document gives a structured
overview of what the project is, the principles behind it, the technical
direction, and how it is expected to grow over time.

It is intended as the canonical starting point for new contributors and anyone
evaluating the project. It complements the top-level [README](../README.md),
which is kept short on purpose.

> **Status:** BorealOS is in an early planning and research phase. There are no
> flashable builds yet. Everything below describes intended direction and is
> subject to change as the project matures.

## Table of contents

- [What BorealOS is](#what-borealos-is)
- [Who it is for](#who-it-is-for)
- [Design principles](#design-principles)
- [Technical foundation](#technical-foundation)
- [Privacy approach](#privacy-approach)
- [App ecosystem](#app-ecosystem)
- [Device support](#device-support)
- [Repository structure](#repository-structure)
- [Roadmap](#roadmap)
- [How to contribute](#how-to-contribute)
- [Non-goals](#non-goals)
- [Glossary](#glossary)

## What BorealOS is

BorealOS is a custom Android distribution built on a mainstream open-source
Android foundation (see [Technical foundation](#technical-foundation)). The aim
is a clean, understandable mobile experience that respects the user by default,
ships without bloat, and avoids forced cloud integrations.

The project values:

- **Simplicity** — sensible defaults and an uncluttered system.
- **Transparency** — an open, documented build and release process.
- **User control** — the person holding the device decides how it behaves.

## Who it is for

BorealOS is built primarily with Linux, FOSS, and self-hosted users in mind —
people who already prefer open ecosystems and want their phone to follow the
same principles. It should also be approachable for privacy-conscious users who
are not developers, which is why friendly documentation is a first-class goal.

## Design principles

These principles guide day-to-day decisions about what goes into BorealOS:

1. **Privacy by default.** The out-of-the-box configuration should be the
   private one. Users should not have to hunt through settings to be protected.
2. **Minimal and legible.** Prefer a small set of well-understood components
   over a large, opaque system. Less surface area means fewer surprises.
3. **No forced cloud.** Cloud and account integrations are optional, never
   required to set up or use the device.
4. **FOSS-first.** Favor free and open-source software for both the system and
   the default app ecosystem.
5. **Transparent process.** Builds, changes, and releases should be documented
   and reproducible enough that others can follow and verify them.
6. **Long-term maintainability.** Choices should be sustainable for a small
   community to maintain over time, not just convenient today.

## Technical foundation

BorealOS will start from an established Android-based foundation such as
**LineageOS / AOSP** rather than building an OS from scratch. This keeps the
project focused on its differentiators — privacy defaults, a curated system,
and clear documentation — instead of re-implementing the entire Android stack.

Expected technical building blocks:

- An AOSP/LineageOS-derived source tree managed with **`repo`** and Android
  build **manifests**.
- Device-specific trees and kernel sources for supported hardware.
- A set of **patches** layered on top of the upstream base to apply BorealOS
  defaults and changes.
- **Scripts** to automate fetching sources, applying patches, and building
  images.
- A documented signing and **OTA** (over-the-air update) process for releases.

Specific tooling and versions will be pinned in build documentation as the
project moves from research into a working build environment.

## Privacy approach

Privacy work in BorealOS is expected to focus on:

- Shipping privacy-respecting defaults rather than relying on the user to
  configure them.
- Simplified, understandable privacy controls instead of deeply nested toggles.
- Minimizing preinstalled software and removing components that phone home
  unnecessarily.
- Being transparent about any network connections the system makes by default.

The exact mechanisms will be documented as they are designed and validated.

## App ecosystem

- **F-Droid first.** F-Droid is intended to be the primary, preinstalled app
  source, prioritizing free and open-source applications.
- **Optional Aurora Store.** For users who need apps from the Google Play
  catalog, Aurora Store support is planned as an opt-in addition.
- **Lightweight system apps.** Default system applications should be minimal and
  replaceable.

## Device support

The first target device is:

| Device          | Codename | Status              |
| --------------- | -------- | ------------------- |
| Google Pixel 8 Pro | `husky` | Initial bring-up target |

Pixel hardware is a practical first target because of its well-supported
bootloader unlocking and strong upstream Android support. Additional devices
may be considered once the build and release process is established and the
first target is stable.

## Repository structure

This repository will grow to hold the planning, research, and build assets for
BorealOS. The intended top-level layout:

```
BorealOS/
├── README.md            # Short project introduction
├── docs/                # Project documentation (this overview, guides, notes)
│   └── OVERVIEW.md
├── manifests/           # repo/AOSP build manifests (planned)
├── device/              # Device bring-up notes and trees (planned)
├── patches/             # Patches applied on top of the upstream base (planned)
├── scripts/             # Build, sync, and helper scripts (planned)
└── releases/            # Release planning and notes (planned)
```

Directories marked *planned* do not exist yet; they describe where future work
is expected to live so contributions land in a predictable place.

## Roadmap

The roadmap is intentionally high-level while the project is in research. It is
organized in phases rather than dates.

- **Phase 0 — Research & planning (current).** Define goals, document the
  intended architecture, and choose the upstream base and tooling.
- **Phase 1 — Build environment.** Stand up a reproducible build setup, sync
  the upstream source, and produce a first unofficial build.
- **Phase 2 — Device bring-up.** Get a bootable, usable image on the Pixel 8
  Pro (`husky`) and document the process.
- **Phase 3 — Privacy & curation.** Apply privacy defaults, curate system apps,
  and integrate the F-Droid-first ecosystem.
- **Phase 4 — Releases & OTA.** Establish signing, a transparent release
  process, and over-the-air updates.
- **Phase 5 — Community & expansion.** Improve documentation, onboard
  contributors, and evaluate additional devices.

## How to contribute

Early contributions are welcome, especially around:

- Documentation and writing (including improving this overview).
- Build research and tooling.
- Android development and device support.
- Privacy-focused UX ideas.

Because the architecture is still being defined, the most valuable early
contributions are research notes, documentation, and concrete proposals. If you
are unsure where something belongs, open an issue or a draft pull request to
start the discussion. Contribution guidelines will be formalized as the project
takes shape.

## Non-goals

To keep the project focused, BorealOS does **not** currently aim to:

- Build a new mobile OS from scratch instead of leveraging AOSP/LineageOS.
- Require any cloud account or proprietary service to set up or use a device.
- Maximize the number of supported devices before the first target is stable.
- Bundle large, opaque, or proprietary software by default.

These may be revisited later, but they are out of scope for the initial effort.

## Glossary

- **AOSP** — Android Open Source Project, the open-source base of Android.
- **LineageOS** — A popular community Android distribution derived from AOSP.
- **F-Droid** — A catalog and client for installing free and open-source
  Android apps.
- **Aurora Store** — An alternative client for downloading apps from the Google
  Play catalog without a Google account.
- **OTA** — Over-the-air update; system updates delivered to the device.
- **`repo`** — Google's tool for managing the many Git repositories that make up
  an Android source tree.
- **husky** — The device codename for the Google Pixel 8 Pro.
