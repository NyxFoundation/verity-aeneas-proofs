#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/scripts/lock_value.py"
VERITY_REV="$($LOCK correspondence.verity_revision)"
CHARON_VERSION="$($LOCK tools.charon_version)"
AENEAS_VERSION="$($LOCK tools.aeneas_version)"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
CHARON="$CACHE_HOME/hax/tools/charon/$CHARON_VERSION/charon"
AENEAS="$CACHE_HOME/hax/tools/aeneas/$AENEAS_VERSION/aeneas"
SOURCE="$ROOT/.cache/verity-$VERITY_REV"
OUTPUT="$(mktemp -d)"
trap 'rm -rf "$OUTPUT"' EXIT

"$ROOT/scripts/bootstrap.sh"
PATH="$(dirname "$CHARON"):$PATH"
export PATH

cd "$SOURCE/crates/verity-chain"
"$CHARON" cargo --preset=aeneas \
  --dest-file "$OUTPUT/verity_chain.llbc" \
  --start-from verity_chain::justification \
  --start-from verity_chain::proposer \
  --start-from verity_chain::slot_clock \
  --start-from verity_chain::merkle

"$AENEAS" -backend lean -dest "$OUTPUT/lean" -split-files -gen-lib-entry \
  "$OUTPUT/verity_chain.llbc"

for file in Funs.lean FunsExternal_Template.lean Types.lean TypesExternal_Template.lean; do
  if [ ! -f "$OUTPUT/lean/$file" ]; then
    echo "Aeneas did not generate $file" >&2
    exit 1
  fi
  install -m 0644 "$OUTPUT/lean/$file" "$ROOT/generated/VerityChain/$file"
done

"$ROOT/scripts/update-manifest.sh"
echo "Regenerated Lean from Verity $VERITY_REV"
