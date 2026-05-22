# BorealOS — LineageOS Setup Notes

This document explains, at a high level, how an AOSP/LineageOS source workspace
is assembled with the `repo` tool, what the resulting workspace looks like, and
why BorealOS plans to build on top of LineageOS and AOSP rather than from
scratch.

It is conceptual and onboarding-focused. It complements the
[Build Environment](BUILD_ENVIRONMENT.md) guide (how to prepare a machine) and
the [Android build notes](ANDROID_BUILD_NOTES.md) (terminology).

> **Status:** BorealOS is in an early planning and research phase. There are no
> BorealOS manifests, patches, or builds yet. This document describes the
> general LineageOS/AOSP workflow so contributors understand the shape of the
> work to come — it is not a step-by-step build guide, and following it will
> not produce a BorealOS image.

## Table of contents

- [Why BorealOS builds on LineageOS and AOSP](#why-borealos-builds-on-lineageos-and-aosp)
- [Understanding the repo tool](#understanding-the-repo-tool)
- [Initializing a workspace](#initializing-a-workspace)
- [Syncing the source](#syncing-the-source)
- [Workspace structure](#workspace-structure)
- [Where manifests and patches fit in](#where-manifests-and-patches-fit-in)
- [Preparing to sync](#preparing-to-sync)
- [Related documentation](#related-documentation)

## Why BorealOS builds on LineageOS and AOSP

Android is enormous. The Android Open Source Project (AOSP) is the open-source
base of Android, and LineageOS is a mature community distribution built on top
of AOSP that adds broad device support and ongoing maintenance.

BorealOS plans to start from that foundation rather than reinventing it,
because:

- **Focus.** Reusing a maintained base lets BorealOS spend its effort on its
  actual differentiators — privacy defaults, a curated system, and clear
  documentation — instead of re-implementing the entire Android stack.
- **Device support.** LineageOS already carries device-specific work for a wide
  range of hardware, which shortens the path to the first BorealOS target, the
  Google Pixel 8 Pro (`husky`).
- **Maintainability.** Tracking an upstream base is sustainable for a small
  community: security and platform updates flow from upstream, and BorealOS
  layers its changes on top.

This mirrors the project's stated [technical foundation](OVERVIEW.md#technical-foundation)
and [non-goals](OVERVIEW.md) — BorealOS is explicitly *not* trying to build a
new mobile OS from scratch.

## Understanding the repo tool

An Android source tree is not one Git repository — it is hundreds of them. To
manage that, Google created `repo`, a tool that sits on top of Git and
coordinates many repositories at once.

The key idea is the **manifest**: an XML file (itself stored in Git) that lists
every project to download, where each one comes from, and which branch or
revision to use. `repo` reads the manifest and then operates across all those
projects together.

You do not replace Git with `repo`; you use `repo` to fetch and update the
collection of Git repositories, and you still use ordinary Git inside any
individual project.

## Initializing a workspace

The first step is `repo init`. Conceptually, it:

- creates a control directory (`.repo`) inside an empty workspace folder,
- records which **manifest** to use and which **branch** to track, and
- prepares the workspace so a later sync knows what to download.

It does **not** download the full Android source. It is a fast, lightweight
setup step. A typical invocation looks like this (the manifest URL and branch
below are placeholders to be verified, matching
[`config/borealos.env.example`](../config/borealos.env.example)):

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0
```

Here `-u` points at the manifest repository and `-b` selects the branch.
BorealOS will eventually provide its own manifest (or a thin overlay on the
LineageOS one); see
[Where manifests and patches fit in](#where-manifests-and-patches-fit-in).

## Syncing the source

After initialization, `repo sync` does the heavy lifting:

- it reads the manifest,
- downloads every listed project into the workspace, and
- on later runs, updates them to match the manifest.

This is the step that transfers **tens of gigabytes** and can take a long time.
`repo` offers options to tune parallelism and reduce how much history it
downloads, and those specifics will be documented for BorealOS when a real
build flow exists. For now, the important thing to internalize is that
`repo sync` is the large, slow, network- and disk-heavy operation — plan for it
using the [Build Environment](BUILD_ENVIRONMENT.md#android-source-tree-size)
guidance.

## Workspace structure

Once synced, an AOSP/LineageOS workspace has a recognizable top-level shape.
The directories below are conceptual — exact contents vary by Android version:

```text
workspace/
├── .repo/        # repo's control data and the manifest (not your code)
├── build/        # the Soong/Make build system and core build logic
├── device/       # per-device configuration ("device trees")
├── kernel/       # kernel sources for supported devices
├── vendor/       # vendor-specific files, including LineageOS overlays
├── frameworks/   # core Android frameworks and system services
├── packages/     # system apps and providers
├── system/       # low-level system components
├── prebuilts/    # prebuilt toolchains and the bundled JDK
└── out/          # build output (created when you build; large)
```

A few orientation notes for newcomers:

- **`.repo` is infrastructure, not source you edit.** It holds the manifest and
  repo's bookkeeping.
- **`device/`, `kernel/`, and `vendor/` are where hardware-specific work
  lives.** These are the areas most relevant to bringing up a device like
  `husky`. See [device trees](ANDROID_BUILD_NOTES.md#device-trees) and
  [vendor blobs](ANDROID_BUILD_NOTES.md#vendor-blobs) for what they contain.
- **`out/` is generated.** It is created by a build, can grow very large, and
  is safe to delete to reclaim space.

## Where manifests and patches fit in

This is the part that does not exist yet, by design.

- **BorealOS manifests come later.** No `repo` manifest is checked into this
  repository today. When the build environment is established, BorealOS will
  add a manifest (or a thin overlay on the LineageOS manifest) that pins
  upstream branches and adds any BorealOS-specific projects. See
  [`manifests/README.md`](../manifests/README.md) for what is planned.
- **Patches come later, too.** BorealOS changes — privacy defaults, system
  curation, branding — are expected to be applied as **patches** layered on top
  of the upstream base, kept separate so they are easy to review and rebase
  onto new upstream versions.
- **The upstream source is never vendored here.** As described in the
  [Build Environment](BUILD_ENVIRONMENT.md#android-source-tree-size) notes and
  enforced by [`.gitignore`](../.gitignore), the large Android tree is fetched
  on demand into a local workspace, not committed to this repository.

Until those pieces land, the LineageOS manifest and branch referenced in this
project's scripts and config are **placeholders** you should verify against the
upstream project before relying on them.

## Preparing to sync

You can rehearse the whole flow safely today. The repository's helper scripts
default to a dry run and change nothing unless you pass `--run`:

1. Confirm tooling with the read-only check:

   ```bash
   ./scripts/borealos-doctor.sh
   ```

2. Preview the `repo init` flow (prints the intended commands only):

   ```bash
   ./scripts/init-lineageos-workspace.sh
   ```

3. Preview the `repo sync` flow (refuses to run outside an initialized
   workspace, and only prints in dry-run mode):

   ```bash
   ./scripts/sync-lineageos.sh
   ```

For the machine-side preparation these scripts assume — distribution, hardware,
filesystem, and packages — see the [Build Environment](BUILD_ENVIRONMENT.md)
guide.

## Related documentation

- [Build Environment](BUILD_ENVIRONMENT.md) — preparing a Linux machine for
  future builds.
- [Android build notes](ANDROID_BUILD_NOTES.md) — terminology such as device
  trees, vendor blobs, kernels, OTA, and signing.
- [Project Overview](OVERVIEW.md) — goals, principles, and the
  [roadmap](OVERVIEW.md#roadmap).
- [`manifests/README.md`](../manifests/README.md) — what will eventually live
  in the manifests directory.
