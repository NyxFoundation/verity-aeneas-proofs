#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"

"$ROOT/scripts/check-artifacts.sh"

if grep -REn --include='*.lean' \
    '(^|[[:space:]])(sorry|admit)([[:space:]]|$)' "$ROOT/proofs"; then
  echo "handwritten Lean proofs contain sorry or admit" >&2
  exit 1
fi

cd "$ROOT"
python3 - <<'PY'
import re
from pathlib import Path

audit = Path("proofs/AxiomAudit.lean").read_text()
proofs = sorted(Path("proofs/VerityChain").glob("*.lean"))
proofs += sorted(Path("proofs/VerityP2P").glob("*.lean"))
missing = []
for proof in proofs:
    for line in proof.read_text().splitlines():
        match = re.match(r"(?:@\[[^]]+\]\s+)?theorem\s+([A-Za-z0-9_.]+)", line)
        if match and f".{match.group(1)}" not in audit:
            missing.append(f"{proof}:{match.group(1)}")
if missing:
    raise SystemExit("public theorem missing from axiom audit:\n" + "\n".join(missing))
PY

lake build
lake env lean proofs/AxiomAudit.lean
