from pathlib import Path

from borealos_cli.config import DEFAULTS, load_config, parse_env_file


def test_load_config_defaults_when_no_file(tmp_path: Path):
    config = load_config(root=tmp_path)
    assert not config.loaded_from_file
    assert config.source is None
    assert config["BOREALOS_DEVICE"] == DEFAULTS["BOREALOS_DEVICE"]
    assert config.overridden_keys == []


def test_load_config_reads_local_env(tmp_path: Path):
    cfg_dir = tmp_path / "config"
    cfg_dir.mkdir()
    (cfg_dir / "borealos.env").write_text(
        "# comment\n"
        'BOREALOS_DEVICE="bluejay"\n'
        "export LINEAGE_BRANCH=lineage-22.0\n"
        "\n"
        "GARBAGE LINE WITHOUT EQUALS\n",
        encoding="utf-8",
    )

    config = load_config(root=tmp_path)
    assert config.loaded_from_file
    assert config["BOREALOS_DEVICE"] == "bluejay"
    assert config["LINEAGE_BRANCH"] == "lineage-22.0"
    assert "BOREALOS_DEVICE" in config.overridden_keys
    # Unchanged keys keep their defaults and are not flagged as overridden.
    assert config["BOREALOS_WORKSPACE"] == DEFAULTS["BOREALOS_WORKSPACE"]
    assert "BOREALOS_WORKSPACE" not in config.overridden_keys


def test_parse_env_file_strips_quotes_and_comments(tmp_path: Path):
    path = tmp_path / "borealos.env"
    path.write_text(
        "FOO='single'\n"
        'BAR="double"\n'
        "BAZ=plain\n"
        "  # indented comment\n",
        encoding="utf-8",
    )
    parsed = parse_env_file(path)
    assert parsed == {"FOO": "single", "BAR": "double", "BAZ": "plain"}
