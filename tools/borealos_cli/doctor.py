"""Read-only host tooling checks.

Mirrors ``scripts/borealos-doctor.sh``: it only looks for commands on PATH and
never installs, removes, or changes anything.
"""

from __future__ import annotations

import shutil
from dataclasses import dataclass

# Tools BorealOS expects for future LineageOS/AOSP work, paired with why each
# one is needed so the output can explain itself. Kept in sync with the shell
# doctor script.
REQUIRED_TOOLS: list[tuple[str, str]] = [
    ("git", "version control, and the backend used by 'repo'"),
    ("repo", "Android multi-repository tool (https://gerrit.googlesource.com/git-repo)"),
    ("python3", "required by 'repo' and many Android build scripts"),
    ("java", "AOSP/LineageOS build toolchain"),
    ("make", "build orchestration"),
    ("gcc", "host compiler toolchain"),
    ("curl", "downloading tools and sources"),
    ("unzip", "extracting downloaded archives"),
]


@dataclass
class ToolResult:
    name: str
    why: str
    location: str | None

    @property
    def found(self) -> bool:
        return self.location is not None


def check_tools(tools: list[tuple[str, str]] | None = None) -> list[ToolResult]:
    """Return the presence/location of each required tool. Read-only."""

    results: list[ToolResult] = []
    for name, why in tools or REQUIRED_TOOLS:
        results.append(ToolResult(name=name, why=why, location=shutil.which(name)))
    return results
