# BorealOS — Build Environment

This document describes how to prepare a Linux machine for the kind of
Android build work BorealOS expects to do in the future. It is written for
contributors who are new to large Android source builds and want to get their
environment ready ahead of time.

It complements the [Project Overview](OVERVIEW.md) and the
[LineageOS setup notes](LINEAGEOS_SETUP.md). For terminology, see the
[Android build notes](ANDROID_BUILD_NOTES.md).

> **Status:** BorealOS is in an early planning and research phase. Nothing in
> this document implies that BorealOS can be built or flashed today — it cannot.
> The guidance below is preparation only, so contributors can have a capable
> machine ready when build work begins. Exact versions and a full package list
> will be pinned in dedicated build documentation later.

## Table of contents

- [Recommended Linux distributions](#recommended-linux-distributions)
- [Hardware expectations](#hardware-expectations)
- [Filesystem considerations](#filesystem-considerations)
- [Java and OpenJDK](#java-and-openjdk)
- [Required packages](#required-packages)
- [Android source tree size](#android-source-tree-size)
- [Preparing your environment](#preparing-your-environment)
- [Related documentation](#related-documentation)

## Recommended Linux distributions

Android source builds are developed and tested primarily on Linux. A 64-bit
Linux installation is the expected and best-supported environment.

- **Ubuntu LTS** (for example, a recent long-term-support release) is the
  most widely documented path for AOSP and LineageOS work. If you are unsure
  what to use, this is the safest starting point.
- **Debian stable** is a close second and follows the same package
  conventions as Ubuntu.
- **Fedora, Arch, and openSUSE** can build Android, but package names differ
  and you may need to map dependencies yourself. These are reasonable for
  experienced users.

Notes on other platforms:

- **macOS** is not a supported target for this project's build work. Its
  default filesystem is case-insensitive (see
  [Filesystem considerations](#filesystem-considerations)), which breaks the
  Android source tree.
- **Windows** is not used directly. The Windows Subsystem for Linux (WSL2) can
  work for experimentation, but disk performance and storage limits often make
  a native Linux install the better choice.

We will document a known-good distribution and version once BorealOS reaches a
working build setup. Until then, prefer a mainstream, well-supported release.

## Hardware expectations

Building Android from source is resource-intensive. The figures below are
rough, industry-typical guidance for AOSP/LineageOS-style builds — they are
*not* measured BorealOS numbers, because no BorealOS build exists yet. Treat
them as a planning baseline, not a promise.

| Resource | Rough minimum | Comfortable | Notes |
| --- | --- | --- | --- |
| CPU | 4 cores | 8 or more cores | Builds parallelize well; more cores cut build time. |
| RAM | 16 GB | 32 to 64 GB | Linking and parallel jobs are memory-hungry; low RAM forces fewer parallel jobs and slower builds. |
| Free storage | 250 GB | 400 GB or more | A full source tree plus build output is large; see [Android source tree size](#android-source-tree-size). |
| Disk type | SSD | NVMe SSD | Spinning disks make source sync and builds painfully slow. |

A few practical points:

- **Cores matter most for build time.** A faster, higher-core CPU is the
  single biggest quality-of-life improvement once everything is set up.
- **RAM headroom prevents failures.** Builds can fail or thrash near the end
  (linking) on memory-constrained machines. More RAM lets you run more
  parallel jobs safely.
- **A build accelerator helps on repeat builds.** Tools such as `ccache` trade
  disk space for speed by caching compiled objects. Plan for extra storage if
  you enable one.

## Filesystem considerations

The Android source tree has strict expectations of the filesystem it lives on.

- **Case sensitivity is required.** Android source contains files whose names
  differ only by case. A case-insensitive filesystem (the macOS default, and
  exFAT/FAT/NTFS) will corrupt or refuse the checkout. On Linux, the common
  default filesystems are case-sensitive, so this usually takes care of itself.
- **`ext4` is the well-trodden choice.** It is the default on most
  recommended distributions and works reliably for large builds. `btrfs` and
  `xfs` also work; some contributors use `btrfs` with transparent compression
  to save space, at a possible cost to build performance.
- **Avoid `exFAT`/`FAT` entirely.** They lack the permissions and symbolic-link
  support the build relies on.
- **Avoid network and remote filesystems** (NFS, SMB, and similar) for the
  active tree. They are typically too slow and can mishandle the many small
  files a checkout contains. Build on local storage.
- **Pick the disk with the most free space.** The tree and its build output
  are large; see [Android source tree size](#android-source-tree-size).

## Java and OpenJDK

A common point of confusion is which Java Development Kit (JDK) to install.

- **Modern Android source trees bundle their own JDK.** Recent AOSP and
  LineageOS versions ship a prebuilt OpenJDK inside the source tree and use it
  automatically when you set up the build environment. In that case you do not
  need to match a specific *system* JDK version for the build itself.
- **Older advice is often out of date.** Guides that tell you to install one
  exact system JDK version usually predate the bundled-JDK approach. Be
  cautious with older tutorials.
- **A host JDK can still be useful** for editor tooling and small auxiliary
  utilities, so installing a current OpenJDK package is reasonable.
- **The exact version will be pinned later.** Once BorealOS settles on a target
  Android/LineageOS version, the build documentation will state the required
  JDK precisely. Until then, treat any version mentioned here or in scripts as
  a placeholder.

The read-only [`borealos-doctor.sh`](../scripts/borealos-doctor.sh) script
checks that a `java` command is present on your `PATH`. That is a basic sanity
check only — it does not verify that the right JDK is installed.

## Required packages

This is an overview of the *kinds* of packages an Android build environment
needs, not an authoritative, version-pinned list. The canonical list changes
with the Android version and lives in upstream AOSP and LineageOS
documentation; BorealOS will pin its own list when build work begins.

Typical categories:

- **Source management and sync:** `git`, the `repo` tool, `python3`, and
  `curl`.
- **Compilers and build tooling:** a host C/C++ toolchain (`gcc`, `g++`,
  `make`) — on Debian/Ubuntu this is provided by `build-essential`.
- **Archive utilities:** `zip` and `unzip`.
- **Build acceleration (optional):** `ccache`.
- **Assorted development libraries:** the full build also expects a number of
  `-dev` libraries (for example, compression and crypto libraries). The exact
  set depends on the Android version, so follow upstream docs for the complete
  list rather than copying a possibly stale one.

An illustrative starting point on Debian/Ubuntu — representative only, not the
complete dependency set:

```bash
sudo apt-get update
sudo apt-get install git python3 curl zip unzip build-essential ccache
```

The `repo` tool is sometimes available from your distribution's package
manager and otherwise installed from its upstream project; the BorealOS setup
scripts assume it is already on your `PATH`. You can confirm the basics with:

```bash
./scripts/borealos-doctor.sh
```

## Android source tree size

The single biggest surprise for newcomers is sheer size. Plan for it before
you start.

- **The download is large.** A `repo sync` of an AOSP/LineageOS tree pulls
  **tens of gigabytes** over the network and can take a long time on slower
  connections.
- **On-disk size is larger still.** After sync, the source tree commonly
  occupies well over 100 GB, and a build adds tens of gigabytes more of output
  on top of that.
- **Plan storage and bandwidth up front.** This is why
  [Hardware expectations](#hardware-expectations) recommends 250 GB or more of
  free space on fast local storage, and why a metered or slow connection makes
  the initial sync painful.
- **Never commit the tree.** The Android sources are fetched on demand into a
  local workspace and are deliberately excluded from this repository (see the
  project [`.gitignore`](../.gitignore)). Committing them would be both
  enormous and incorrect.

The BorealOS workspace scripts echo these warnings before any large operation
and default to a dry run. See
[Preparing your environment](#preparing-your-environment) below.

## Preparing your environment

You can get a machine ready today without building anything. The repository
ships small, safe helper scripts for exactly this:

1. **Check your tools.** Run the read-only environment check:

   ```bash
   ./scripts/borealos-doctor.sh
   ```

2. **Review the configuration.** Copy the example config and adjust the
   workspace path, target device, and branch placeholder to taste:

   ```bash
   cp config/borealos.env.example config/borealos.env
   ```

3. **Preview the workspace flow.** The
   [`init-lineageos-workspace.sh`](../scripts/init-lineageos-workspace.sh) and
   [`sync-lineageos.sh`](../scripts/sync-lineageos.sh) scripts default to a dry
   run and only print what they *would* do. They do not download or build
   anything unless you explicitly pass `--run`.

For how `repo init` and `repo sync` fit together, continue to the
[LineageOS setup notes](LINEAGEOS_SETUP.md).

## Related documentation

- [Project Overview](OVERVIEW.md) — goals, principles, and the
  [roadmap](OVERVIEW.md#roadmap).
- [LineageOS setup notes](LINEAGEOS_SETUP.md) — `repo`, workspace structure,
  and why BorealOS builds on LineageOS/AOSP.
- [Android build notes](ANDROID_BUILD_NOTES.md) — terminology and common
  beginner confusion points.
- [Early tooling](../README.md#early-tooling) — the helper scripts referenced
  above.
