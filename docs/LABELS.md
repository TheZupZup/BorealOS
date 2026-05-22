# BorealOS Labels

This document describes the recommended GitHub labels for BorealOS and when to
use them. It is a lightweight guide for maintainers and contributors triaging
issues and pull requests as the project grows — for example, as people arrive
through GitHub and [CodeTriage](https://www.codetriage.com/).

BorealOS is in an early planning and research phase, so the label set is kept
small and practical. It will evolve as the project moves toward a working build
environment (see the [roadmap](OVERVIEW.md#roadmap)).

## How labels are organized

Labels fall into a few simple groups:

- **Contribution signals** tell newcomers where to start.
- **Issue types** describe the kind of work an issue represents.
- **Topic areas** describe the part of the project an issue touches.

You can apply more than one label. Most issues have a type plus one or more
topic areas — for example, `research` + `android` + `pixel-8-pro`.

## Recommended labels

| Label | Suggested color | When to use |
| ----- | --------------- | ----------- |
| `good first issue` | `#7057FF` | Small, well-scoped tasks suitable for first-time contributors. |
| `help wanted` | `#008672` | Tasks where maintainers would welcome outside help. |
| `documentation` | `#0075CA` | Overviews, guides, notes, READMEs, and wording fixes. |
| `research` | `#D876E3` | Open questions and investigation tasks (Android, LineageOS, devices). |
| `android` | `#3DDC84` | AOSP/Android platform topics: framework, device trees, vendor blobs. |
| `build-system` | `#FBCA04` | `repo`/AOSP build tooling, manifests, sync, and build scripts. |
| `privacy` | `#5319E7` | Privacy defaults, controls, telemetry review, and related UX. |
| `pixel-8-pro` | `#1D76DB` | Anything specific to the Pixel 8 Pro (`husky`) target. |
| `roadmap` | `#C2E0C6` | Planning items and milestones tied to the project roadmap. |
| `tooling` | `#BFD4F2` | Helper scripts, developer experience, and repository tooling. |
| `ci` | `#EDEDED` | Continuous integration: Docs CI, linting, and future build CI. |

Colors are suggestions to keep the set visually consistent; adjust them freely.

## Built-in GitHub labels

GitHub creates a few default labels that BorealOS keeps using. The issue forms
apply two of them automatically:

- `bug` — applied by the bug report form.
- `enhancement` — applied by the feature request form.

Other defaults (`duplicate`, `invalid`, `question`, `wontfix`) can be used as
needed during triage.

## Suggested triage flow

1. Confirm the issue is not a duplicate.
2. Add one **type** label — `documentation`, `research`, or `roadmap`, or a
   built-in such as `bug` or `enhancement`.
3. Add one or more **topic** labels — `android`, `build-system`, `privacy`,
   `pixel-8-pro`, `tooling`, or `ci`.
4. If the work is approachable, add `good first issue` and/or `help wanted` to
   invite contributors.

## Creating these labels

Labels can be created in the repository under **Issues → Labels** in the web UI,
or with the [GitHub CLI](https://cli.github.com/). For example:

```bash
gh label create "research" --color D876E3 \
  --description "Investigation and open questions"
gh label create "pixel-8-pro" --color 1D76DB \
  --description "Specific to the Pixel 8 Pro (husky)"
```

Repeat for each label above, using the suggested colors and a short description.
