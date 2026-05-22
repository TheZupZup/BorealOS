# BorealOS manifests

This directory will hold the [`repo`](https://gerrit.googlesource.com/git-repo)
manifests used to assemble the BorealOS source tree on top of LineageOS/AOSP.

## Status

No manifests are checked in yet. They will be added once the build environment
is established (see the [project roadmap](../docs/OVERVIEW.md#roadmap)).

## What will live here

- A BorealOS `repo` manifest (or a thin overlay on the LineageOS manifest) that
  pins the upstream branches and adds any BorealOS-specific projects.
- Notes on which manifest and branch map to which target device, starting with
  the Google Pixel 8 Pro (`husky`).

## What does not live here

BorealOS does **not** vendor the full Android source tree. The AOSP/LineageOS
sources are very large and are fetched on demand with `repo` into a local
workspace; they are never committed to this repository.

For the intended workflow — preparing a workspace and running `repo init` /
`repo sync` — see the early tooling scripts in the
[`scripts/`](../scripts/borealos-doctor.sh) directory and the
["Early tooling" section of the README](../README.md#early-tooling).
