"""Module entry point so the CLI can run as ``python -m borealos_cli``."""

from __future__ import annotations

import sys

from .cli import main

if __name__ == "__main__":
    sys.exit(main())
