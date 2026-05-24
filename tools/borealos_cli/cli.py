"""Command-line interface for BorealOS tooling.

Subcommands:

* ``doctor``            — read-only check for required host tools.
* ``config``            — print resolved configuration defaults.
* ``workspace status``  — report whether the workspace and ``.repo/`` exist.

Every command here is non-destructive. Nothing builds Android, flashes a
device, or downloads sources.
"""

from __future__ import annotations

import argparse
from typing import Sequence

from . import __version__
from .config import config_path, load_config
from .doctor import check_tools
from .workspace import workspace_status


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="borealos",
        description=(
            "BorealOS project CLI — small, safe, read-only helpers for early "
            "tooling. Does not build Android, flash devices, or download sources."
        ),
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"borealos {__version__}",
    )

    subparsers = parser.add_subparsers(dest="command", metavar="<command>")

    doctor_parser = subparsers.add_parser(
        "doctor",
        help="check for required host tools (read-only)",
    )
    doctor_parser.set_defaults(func=_cmd_doctor)

    config_parser = subparsers.add_parser(
        "config",
        help="print resolved configuration defaults",
    )
    config_parser.set_defaults(func=_cmd_config)

    workspace_parser = subparsers.add_parser(
        "workspace",
        help="inspect the configured workspace (read-only)",
    )
    workspace_sub = workspace_parser.add_subparsers(
        dest="workspace_command", metavar="<subcommand>"
    )
    status_parser = workspace_sub.add_parser(
        "status",
        help="show whether the workspace and .repo/ exist",
    )
    status_parser.set_defaults(func=_cmd_workspace_status)
    workspace_parser.set_defaults(func=_cmd_workspace_default)

    return parser


def _cmd_doctor(_args: argparse.Namespace) -> int:
    print("BorealOS doctor — checking basic tooling")
    print("This check is read-only and does not modify your system.\n")

    results = check_tools()
    passed = 0
    missing = 0
    for result in results:
        if result.found:
            print(f"  [PASS] {result.name:<8} {result.location}")
            passed += 1
        else:
            print(f"  [FAIL] {result.name:<8} missing — needed for: {result.why}")
            missing += 1

    print(f"\nSummary: {passed} present, {missing} missing.")

    if missing > 0:
        print(
            "\nSome tools are missing. Install them with your distribution "
            "package\nmanager before starting LineageOS/AOSP work. This is only "
            "preparation:\nBorealOS cannot be built or flashed yet."
        )
        return 1

    print(
        "\nAll basic tools are present.\nNote: this does not mean BorealOS can be "
        "built yet — device bring-up and\nbuild support are not implemented."
    )
    return 0


def _cmd_config(_args: argparse.Namespace) -> int:
    config = load_config()

    print("BorealOS — resolved configuration\n")
    if config.loaded_from_file:
        print(f"Local config loaded from: {config.source}")
    else:
        print(
            f"No local config found at {config_path()}\n"
            "Using built-in defaults. Copy config/borealos.env.example to "
            "config/borealos.env to override."
        )
    print()

    for key in sorted(config.values):
        marker = " (overridden)" if key in config.overridden_keys else ""
        print(f"  {key}={config.values[key]}{marker}")

    return 0


def _cmd_workspace_status(_args: argparse.Namespace) -> int:
    config = load_config()
    status = workspace_status(config["BOREALOS_WORKSPACE"])

    print("BorealOS — workspace status\n")
    print(f"  Workspace : {status.path}")
    print(f"  Exists    : {'yes' if status.exists else 'no'}")
    print(f"  .repo/     : {'yes' if status.repo_dir_exists else 'no'}")
    print()

    if status.initialized:
        print(
            "Workspace looks initialized. This command does not run 'repo sync'; "
            "use scripts/sync-lineageos.sh --run when you are ready."
        )
    elif status.exists:
        print(
            "Workspace directory exists but is not initialized (no .repo/). "
            "Run scripts/init-lineageos-workspace.sh --run to initialize it."
        )
    else:
        print(
            "Workspace does not exist yet. Run "
            "scripts/init-lineageos-workspace.sh --run to create and initialize it."
        )

    print(
        "\nThis command is read-only: it does not create, modify, or sync "
        "anything."
    )
    return 0


def _cmd_workspace_default(_args: argparse.Namespace) -> int:
    print("usage: borealos workspace status")
    print("\nThe 'workspace' command requires a subcommand. Try 'workspace status'.")
    return 2


def main(argv: Sequence[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    func = getattr(args, "func", None)
    if func is None:
        parser.print_help()
        return 2

    return func(args)
