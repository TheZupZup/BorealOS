# BorealOS — Android Build Notes

This document is a plain-language reference for the terminology and concepts
that come up in Android/LineageOS build work. It is aimed at contributors who
are new to the Android platform and want a map of the vocabulary before diving
in.

It pairs with the [Build Environment](BUILD_ENVIRONMENT.md) guide (how to
prepare a machine) and the [LineageOS setup notes](LINEAGEOS_SETUP.md) (how the
source workspace is assembled).

> **Status:** BorealOS is in an early planning and research phase. This is
> background reading, not instructions. BorealOS cannot be built or flashed
> yet, and none of the commands shown here will produce or install a BorealOS
> image. Where exact values would normally appear, they are deliberately left
> as concepts to avoid implying precision the project does not yet have.

## Table of contents

- [How to use this document](#how-to-use-this-document)
- [Glossary](#glossary)
- [Device trees](#device-trees)
- [Vendor blobs](#vendor-blobs)
- [Kernels](#kernels)
- [Over-the-air updates](#over-the-air-updates)
- [Signing](#signing)
- [Fastboot and ADB](#fastboot-and-adb)
- [Common beginner confusion points](#common-beginner-confusion-points)
- [Related documentation](#related-documentation)

## How to use this document

Skim the [Glossary](#glossary) first for quick definitions, then read the
sections that interest you for a little more depth. You do not need to memorize
any of this; it is here so that when these terms appear in issues, scripts, or
upstream documentation, they are not a barrier.

## Glossary

- **AOSP** — the Android Open Source Project, the open-source base of Android.
- **LineageOS** — a community Android distribution built on top of AOSP, adding
  device support and maintenance.
- **`repo`** — Google's tool for managing the many Git repositories that make
  up an Android source tree (see the
  [LineageOS setup notes](LINEAGEOS_SETUP.md#understanding-the-repo-tool)).
- **Manifest** — an XML file that tells `repo` which projects to fetch and at
  which revisions.
- **Device tree** — the per-device configuration that describes a phone's
  hardware and how to build for it (see [Device trees](#device-trees)).
- **Vendor blobs** — proprietary, closed-source binaries a device needs that
  are not part of AOSP (see [Vendor blobs](#vendor-blobs)).
- **Kernel** — the Linux kernel that runs underneath Android on the device.
- **HAL** — Hardware Abstraction Layer, the interface between Android and
  device-specific hardware drivers.
- **Partition / image** — a section of device storage (such as `boot` or
  `system`) and the file that is written to it.
- **OTA** — an over-the-air update delivered to a device (see
  [Over-the-air updates](#over-the-air-updates)).
- **Recovery** — a small separate environment used to repair or update a
  device outside of normal Android.
- **Bootloader** — low-level firmware that starts the device and can hand off
  to Android, recovery, or `fastboot`.
- **`fastboot`** — a protocol and tool for talking to the bootloader, used to
  flash images (see [Fastboot and ADB](#fastboot-and-adb)).
- **`adb`** — the Android Debug Bridge, used to talk to a running Android
  system or recovery.
- **Codename** — the engineering name for a device; the first BorealOS target,
  the Google Pixel 8 Pro, has the codename `husky`.

## Device trees

A **device tree** is the collection of configuration files that teach the build
system everything specific to one device: its hardware, partition layout,
default settings, and which components to include. It is "configuration as
code" for a particular phone.

In a synced workspace these typically live under `device/<vendor>/<codename>/`
and include build files (for example, board and product configuration) plus
device-specific resources. Device trees are usually maintained per device and
shared within the LineageOS ecosystem, which is part of why building on top of
LineageOS shortens device bring-up.

For BorealOS, device-tree work is part of future bring-up for the Pixel 8 Pro
(`husky`); none of it is implemented yet.

## Vendor blobs

A device needs more than open-source code to function. **Vendor blobs** (also
called proprietary blobs) are closed-source binaries — firmware, hardware
drivers, and HAL implementations — that the manufacturer provides and that
cannot be rebuilt from AOSP source.

A few things newcomers should know:

- **They are obtained, not written.** Blobs are usually extracted from an
  existing device or an official factory image, or pulled from a maintained
  collection, rather than authored by the OS project.
- **They are version-sensitive.** Blobs generally need to match the Android
  version and device they came from; mismatches cause subtle hardware failures.
- **They carry licensing constraints.** Because they are proprietary, how they
  may be redistributed is restricted. BorealOS will treat blob handling as a
  topic to document carefully when device bring-up begins.

## Kernels

The **kernel** is the Linux kernel that sits beneath Android and drives the
hardware. On most devices it ships as part of the boot image.

Two broad approaches exist:

- **Use a prebuilt kernel** that comes with the device tree — simplest, and
  common for getting a device booting.
- **Build the kernel from source** — needed when changes to low-level behavior
  or drivers are required, and more involved.

Kernel sources for supported hardware appear under `kernel/` in a synced
workspace. For BorealOS, kernel choices are a future bring-up decision, not
something settled today.

## Over-the-air updates

An **OTA** (over-the-air) update is how a finished system delivers updates to a
device without a cable. Conceptually:

- **Full vs. incremental.** A full OTA contains everything; an incremental OTA
  contains only the differences from a known previous version, so it is
  smaller.
- **A/B (seamless) updates.** Many modern devices, including recent Pixels,
  have two copies of key partitions. An update is written to the inactive set
  and activated on reboot, which makes updates safer and less disruptive.
- **Updates are verified.** Devices check that an update is properly
  [signed](#signing) before applying it, which is why signing and OTA are
  tightly linked.

BorealOS lists a transparent release and OTA process as a later roadmap phase;
there is no OTA mechanism yet.

## Signing

**Signing** is how a device decides whether to trust software. Builds and
update packages are signed with cryptographic keys, and the device checks those
signatures.

Key points to understand early:

- **Test keys vs. release keys.** Source builds default to publicly known
  *test keys*, which are fine for development but must never be used for real
  releases. Real releases use private *release keys* that only the project
  controls.
- **Keys must be kept secret and stable.** Release signing keys are sensitive
  and must be protected. They also need to stay consistent over time, because
  an [OTA](#over-the-air-updates) is only accepted if it is signed with the key
  the device already trusts.
- **Verified boot.** Android verifies the boot chain at startup; signing is
  what makes that verification meaningful.

When BorealOS reaches the release stage, the signing approach will be
documented in detail. For now this is conceptual background only.

## Fastboot and ADB

Two tools come up constantly. They run on your computer and talk to a connected
device, but they operate in different modes.

- **`adb` (Android Debug Bridge)** talks to a device that is running Android
  (or its recovery). It is used for inspecting the device, copying files, and
  debugging. A first command newcomers run is:

  ```bash
  adb devices
  ```

- **`fastboot`** talks to the device's **bootloader**, a low-level mode used to
  flash partition images. Its discovery command mirrors `adb`:

  ```bash
  fastboot devices
  ```

On Pixel hardware, flashing a custom OS first requires **unlocking the
bootloader**, which is an intentional safety gate. Be aware:

- **Unlocking erases the device.** Bootloader unlocking wipes user data by
  design, so back up anything important first.
- **It can affect device security state.** Unlocking changes verified-boot
  state and may carry warranty or security implications depending on the
  device.

Because BorealOS has nothing to flash yet, these tools are listed here for
familiarity only — there is no BorealOS flashing procedure to follow.

## Common beginner confusion points

A short list of things that trip people up early:

- **"Build" is not "flash."** Building produces image files on your computer;
  flashing writes images onto a device. They are separate steps, and BorealOS
  supports neither yet.
- **Codename vs. marketing name.** Hardware is referred to by codename in build
  work. `husky` *is* the Google Pixel 8 Pro — they are the same device under
  two names.
- **`repo` is not Git, but uses Git.** `repo` coordinates hundreds of Git
  repositories; you still use ordinary Git inside any single project.
- **`adb` vs. `fastboot` vs. recovery.** `adb` talks to running Android,
  `fastboot` talks to the bootloader, and recovery is yet another mode. Using
  the wrong one is a common early mistake.
- **AOSP vs. LineageOS vs. vendor.** AOSP is the base, LineageOS adds device
  support and maintenance on top, and vendor blobs supply the closed-source
  pieces. BorealOS will add its own layer above all of these.
- **The JDK question.** Modern Android trees bundle their own JDK, so you
  usually do not need to hand-pick a system Java version; see the
  [Build Environment](BUILD_ENVIRONMENT.md#java-and-openjdk) notes.
- **Test keys are not for releases.** A build signed with default test keys is
  not a secure release build; see [Signing](#signing).
- **Source size is real.** The Android tree is genuinely huge; do not start a
  sync without the disk space and bandwidth described in the
  [Build Environment](BUILD_ENVIRONMENT.md#android-source-tree-size) guide.

## Related documentation

- [Build Environment](BUILD_ENVIRONMENT.md) — preparing a Linux machine for
  future builds.
- [LineageOS setup notes](LINEAGEOS_SETUP.md) — `repo`, workspace structure,
  and why BorealOS builds on LineageOS/AOSP.
- [Project Overview](OVERVIEW.md) — goals, principles, and the
  [roadmap](OVERVIEW.md#roadmap).
