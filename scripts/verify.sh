#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
AUDIT="$(mktemp --suffix=.lean)"
trap 'rm -f "$AUDIT"' EXIT

"$ROOT/scripts/check-artifacts.sh"
cd "$ROOT"
lake build
cat > "$AUDIT" <<'EOF'
import VerityChain.Correspondence
#print axioms verity_chain.correspondence.isJustifiableAfter_eq
#print axioms verity_chain.correspondence.isJustifiableAfter_iff
#print axioms verity_chain.correspondence.isJustifiableAfter_before_finalized
EOF
lake env lean "$AUDIT"
