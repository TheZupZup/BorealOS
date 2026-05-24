"""Make the ``borealos_cli`` package importable without installation.

The package lives under ``tools/`` (see pyproject.toml ``package-dir``), so add
that directory to ``sys.path`` for the test run.
"""

import sys
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parents[1] / "tools"
if str(TOOLS_DIR) not in sys.path:
    sys.path.insert(0, str(TOOLS_DIR))
