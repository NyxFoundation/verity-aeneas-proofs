#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
find generated -type f -name '*.lean' -print0 \
  | sort -z \
  | xargs -0 -r sha256sum > artifacts.sha256
