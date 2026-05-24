"""BorealOS project CLI.

A small, dependency-free command-line tool that consolidates the early
BorealOS helper scripts into one maintainable entry point. Everything here is
safe and non-destructive: nothing builds Android, flashes a device, or
downloads sources.

The existing shell scripts under ``scripts/`` remain fully supported; this CLI
is an additive, gradual replacement.
"""

__version__ = "0.1.0"

__all__ = ["__version__"]
