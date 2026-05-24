from borealos_cli.doctor import REQUIRED_TOOLS, check_tools


def test_check_tools_reports_known_present_tool():
    # python3 is always available in the test environment.
    results = check_tools([("python3", "needed for tests")])
    assert len(results) == 1
    assert results[0].name == "python3"
    assert results[0].found
    assert results[0].location


def test_check_tools_reports_missing_tool():
    results = check_tools([("definitely-not-a-real-tool-xyz", "imaginary")])
    assert len(results) == 1
    assert not results[0].found
    assert results[0].location is None


def test_default_tool_list_covers_expected_commands():
    names = {name for name, _ in REQUIRED_TOOLS}
    assert {"git", "repo", "python3", "java", "make", "gcc", "curl", "unzip"} <= names
