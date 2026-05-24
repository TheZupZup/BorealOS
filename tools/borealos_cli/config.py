"""Resolve BorealOS configuration.

Configuration mirrors the shell scripts: built-in defaults that can be
overridden by an optional ``config/borealos.env`` file at the repository root.
The file uses simple ``KEY=value`` lines (the same format the shell scripts
source), so a single file works for both the scripts and this CLI.

This module never writes anything; it only reads the optional env file.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

# Built-in defaults. These intentionally match config/borealos.env.example so
# the CLI and the shell scripts agree when no local config is present.
DEFAULTS: dict[str, str] = {
    "BOREALOS_WORKSPACE": str(Path.home() / "borealos-lineageos"),
    "BOREALOS_DEVICE": "husky",
    "LINEAGE_MANIFEST_URL": "https://github.com/LineageOS/android.git",
    "LINEAGE_BRANCH": "lineage-21.0",
}


def repo_root() -> Path:
    """Return the BorealOS repository root.

    The package lives at ``<root>/tools/borealos_cli``, so the root is two
    directories up from this file.
    """

    return Path(__file__).resolve().parents[2]


def config_path(root: Path | None = None) -> Path:
    """Return the expected path of the optional local config file."""

    return (root or repo_root()) / "config" / "borealos.env"


def parse_env_file(path: Path) -> dict[str, str]:
    """Parse a minimal ``KEY=value`` env file.

    Supports ``#`` comments, blank lines, an optional ``export`` prefix, and
    surrounding single or double quotes around values. Unparseable lines are
    skipped rather than raising, keeping the CLI forgiving of hand-edited
    files.
    """

    values: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[len("export ") :].lstrip()
        key, sep, value = line.partition("=")
        if not sep:
            continue
        key = key.strip()
        if not key:
            continue
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        values[key] = value
    return values


@dataclass
class Config:
    """Resolved BorealOS configuration and where each value came from."""

    values: dict[str, str]
    source: Path | None = None
    overridden_keys: list[str] = field(default_factory=list)

    @property
    def loaded_from_file(self) -> bool:
        return self.source is not None

    def __getitem__(self, key: str) -> str:
        return self.values[key]


def load_config(root: Path | None = None) -> Config:
    """Resolve configuration from defaults plus the optional local env file.

    Note: unlike the shell scripts, this does not read process environment
    variables, so that ``borealos config`` reports the same values the scripts
    would compute from defaults and ``config/borealos.env`` alone.
    """

    root = root or repo_root()
    values = dict(DEFAULTS)
    path = config_path(root)
    source: Path | None = None
    overridden: list[str] = []

    if path.is_file():
        source = path
        for key, value in parse_env_file(path).items():
            if key in values and values[key] != value:
                overridden.append(key)
            values[key] = value

    return Config(values=values, source=source, overridden_keys=overridden)
