#!/usr/bin/env python3
"""Read one dotted key from sources.lock."""

import sys
import tomllib
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: lock_value.py section.key", file=sys.stderr)
        return 2

    lock_path = Path(__file__).resolve().parent.parent / "sources.lock"
    with lock_path.open("rb") as lock_file:
        value = tomllib.load(lock_file)

    for component in sys.argv[1].split("."):
        if not isinstance(value, dict) or component not in value:
            print(f"missing lock key: {sys.argv[1]}", file=sys.stderr)
            return 1
        value = value[component]

    if not isinstance(value, (str, int)):
        print(f"lock key is not scalar: {sys.argv[1]}", file=sys.stderr)
        return 1

    print(value)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
