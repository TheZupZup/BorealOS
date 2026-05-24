"""Inspect the configured LineageOS workspace.

Strictly read-only: this reports whether the workspace and its ``.repo/``
directory exist. It never creates directories, runs ``repo init``, or runs
``repo sync`` — those remain the job of the shell scripts (and, deliberately,
require an explicit ``--run``).
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass
class WorkspaceStatus:
    path: Path
    exists: bool
    repo_dir_exists: bool

    @property
    def initialized(self) -> bool:
        """An initialized workspace always contains a ``.repo`` directory."""

        return self.exists and self.repo_dir_exists


def workspace_status(workspace: str | Path) -> WorkspaceStatus:
    """Compute the status of the configured workspace. Does not modify files."""

    path = Path(workspace).expanduser()
    exists = path.is_dir()
    repo_dir_exists = (path / ".repo").is_dir()
    return WorkspaceStatus(path=path, exists=exists, repo_dir_exists=repo_dir_exists)
