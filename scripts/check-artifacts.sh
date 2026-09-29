#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/scripts/lock_value.py"
ACTUAL="$(mktemp)"
trap 'rm -f "$ACTUAL"' EXIT

[ "$($LOCK format_version)" = "1" ]
for key in correspondence.verity_revision correspondence.formal_leanspec_revision \
  survey.verity_revision survey.leanspec_revision; do
  value="$($LOCK "$key")"
  if ! printf '%s\n' "$value" | grep -Eq '^[0-9a-f]{40}$'; then
    echo "lock value is not a full Git revision: $key" >&2
    exit 1
  fi
done

FORMAL_REV="$($LOCK correspondence.formal_leanspec_revision)"
LEAN_VERSION="$($LOCK tools.lean_toolchain)"
CHARON_VERSION="$($LOCK tools.charon_version)"
AENEAS_VERSION="$($LOCK tools.aeneas_version)"
grep -Fqx "rev = \"$FORMAL_REV\"" "$ROOT/lakefile.toml"
grep -Fqx "$LEAN_VERSION" "$ROOT/lean-toolchain"
grep -Fqx "charon = \"$CHARON_VERSION\"" "$ROOT/hax.toml"
grep -Fqx "aeneas = \"$AENEAS_VERSION\"" "$ROOT/hax.toml"

cd "$ROOT"
sha256sum --check artifacts.sha256
find generated -type f -name '*.lean' -print0 \
  | sort -z \
  | xargs -0 -r sha256sum > "$ACTUAL"
if ! cmp -s artifacts.sha256 "$ACTUAL"; then
  echo "artifacts.sha256 does not list exactly the generated Lean files" >&2
  diff -u artifacts.sha256 "$ACTUAL" || true
  exit 1
fi

if grep -R -n -E '(^|[[:space:]])sorry([[:space:]]|$)' proofs --include='*.lean'; then
  echo "handwritten proofs must not contain sorry" >&2
  exit 1
fi

if [ -n "$(find -L lean -type l -print)" ]; then
  echo "lean module tree contains a broken symlink" >&2
  exit 1
fi
