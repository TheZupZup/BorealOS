# BorealOS CLI

The BorealOS CLI (`borealos`) is a small, dependency-free command-line tool
that consolidates the early BorealOS helper scripts into one maintainable entry
point. It is the first step in moving project tooling from separate shell
scripts toward a structured, contributor-friendly CLI.

Like the shell scripts it complements, the CLI is **safe and non-destructive**.
It does not build Android, flash devices, or download LineageOS/AOSP sources.
Every command listed here is read-only.

The existing scripts under [`scripts/`](../scripts) remain fully supported. The
CLI is additive: nothing has been removed, and you can keep using the scripts.

## Requirements

- Python 3.10 or newer.
- No external runtime dependencies — the CLI uses only the Python standard
  library.

## Running the CLI

You can run the CLI without installing anything by pointing Python at the
package:

```bash
python3 -m borealos_cli --help
```

from the repository root, with `tools/` on the import path:

```bash
PYTHONPATH=tools python3 -m borealos_cli --help
```

Or install it (which provides a `borealos` entry point):

```bash
pip install -e .
borealos --help
```

## Commands

### `borealos doctor`

Checks for the required host tools (`git`, `repo`, `python3`, `java`, `make`,
`gcc`, `curl`, `unzip`) and prints a clear pass/fail line for each. This is the
CLI equivalent of [`scripts/borealos-doctor.sh`](../scripts/borealos-doctor.sh).

- Read-only: it only looks for commands on your `PATH` and never installs,
  removes, or changes anything.
- Exits `0` when all tools are present, `1` when one or more are missing.

```bash
borealos doctor
```

### `borealos config`

Prints the resolved configuration. Defaults match
[`config/borealos.env.example`](../config/borealos.env.example). If an optional
local `config/borealos.env` file exists, its values are layered on top and any
overridden keys are marked.

```bash
borealos config
```

To override defaults, copy the example file and edit it:

```bash
cp config/borealos.env.example config/borealos.env
```

### `borealos workspace status`

Shows whether the configured workspace directory exists and whether it contains
a `.repo/` directory (the marker of an initialized `repo` workspace).

- Read-only: it does **not** run `repo init` or `repo sync`, and it does not
  create or modify any files.
- Use [`scripts/init-lineageos-workspace.sh`](../scripts/init-lineageos-workspace.sh)
  and [`scripts/sync-lineageos.sh`](../scripts/sync-lineageos.sh) (each with
  `--run`) when you are ready to perform those actions.

```bash
borealos workspace status
```

## Configuration

Configuration is resolved from two layers:

1. Built-in defaults baked into the CLI (kept in sync with the example file).
2. An optional `config/borealos.env` file at the repository root, parsed as
   simple `KEY=value` lines — the same file the shell scripts source.

The recognized keys are:

| Key                    | Meaning                                          |
| ---------------------- | ------------------------------------------------ |
| `BOREALOS_WORKSPACE`   | Absolute path to the LineageOS/AOSP workspace.   |
| `BOREALOS_DEVICE`      | Target device codename (the first target is `husky`). |
| `LINEAGE_MANIFEST_URL` | LineageOS `repo` manifest URL.                   |
| `LINEAGE_BRANCH`       | LineageOS branch to track (verify before syncing). |

## Tests

Basic unit tests live under [`tests/`](../tests) and can be run with `pytest`:

```bash
pip install pytest
python3 -m pytest
```

## Relationship to the shell scripts

The CLI currently mirrors the read-only behavior of the existing scripts. The
scripts are still the way to perform actions like `repo init` and `repo sync`
(both gated behind an explicit `--run`). As the CLI matures, more functionality
may move into it, but the scripts will not be removed without notice.
