import pytest

from borealos_cli.cli import main


def test_doctor_runs_and_prints(capsys):
    rc = main(["doctor"])
    out = capsys.readouterr().out
    assert "BorealOS doctor" in out
    assert "read-only" in out
    # python3 is present, so it should pass.
    assert "[PASS] python3" in out
    assert rc in (0, 1)


def test_config_prints_defaults(capsys):
    rc = main(["config"])
    out = capsys.readouterr().out
    assert rc == 0
    assert "BOREALOS_DEVICE=" in out
    assert "LINEAGE_MANIFEST_URL=" in out


def test_workspace_status_runs(capsys):
    rc = main(["workspace", "status"])
    out = capsys.readouterr().out
    assert rc == 0
    assert "workspace status" in out
    assert "read-only" in out


def test_workspace_requires_subcommand(capsys):
    rc = main(["workspace"])
    out = capsys.readouterr().out
    assert rc == 2
    assert "requires a subcommand" in out


def test_no_command_prints_help(capsys):
    rc = main([])
    assert rc == 2
    out = capsys.readouterr().out
    assert "borealos" in out


def test_version(capsys):
    with pytest.raises(SystemExit) as exc:
        main(["--version"])
    assert exc.value.code == 0
    out = capsys.readouterr().out
    assert "borealos" in out
