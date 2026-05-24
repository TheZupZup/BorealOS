from pathlib import Path

from borealos_cli.workspace import workspace_status


def test_missing_workspace(tmp_path: Path):
    status = workspace_status(tmp_path / "does-not-exist")
    assert not status.exists
    assert not status.repo_dir_exists
    assert not status.initialized


def test_workspace_without_repo_dir(tmp_path: Path):
    ws = tmp_path / "ws"
    ws.mkdir()
    status = workspace_status(ws)
    assert status.exists
    assert not status.repo_dir_exists
    assert not status.initialized


def test_initialized_workspace(tmp_path: Path):
    ws = tmp_path / "ws"
    (ws / ".repo").mkdir(parents=True)
    status = workspace_status(ws)
    assert status.exists
    assert status.repo_dir_exists
    assert status.initialized
