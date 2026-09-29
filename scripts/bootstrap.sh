#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/scripts/lock_value.py"
VERITY_REPO="$($LOCK correspondence.verity_repository)"
VERITY_REV="$($LOCK correspondence.verity_revision)"
HAX_VERSION="$($LOCK tools.cargo_hax_version)"
CHARON_VERSION="$($LOCK tools.charon_version)"
AENEAS_VERSION="$($LOCK tools.aeneas_version)"
SOURCE="$ROOT/.cache/verity-$VERITY_REV"

if [ "$VERITY_REPO" != "https://github.com/NyxFoundation/verity.git" ]; then
  echo "unexpected Verity repository in sources.lock" >&2
  exit 1
fi
if ! printf '%s\n' "$VERITY_REV" | grep -Eq '^[0-9a-f]{40}$'; then
  echo "invalid Verity revision in sources.lock" >&2
  exit 1
fi

if [ ! -d "$SOURCE/.git" ]; then
  mkdir -p "$SOURCE"
  git -C "$SOURCE" init --quiet
  git -C "$SOURCE" remote add origin "$VERITY_REPO"
  git -C "$SOURCE" fetch --quiet --depth=1 origin "$VERITY_REV"
  git -C "$SOURCE" checkout --quiet --detach FETCH_HEAD
fi

if [ "$(git -C "$SOURCE" remote get-url origin)" != "$VERITY_REPO" ] ||
    [ "$(git -C "$SOURCE" rev-parse HEAD)" != "$VERITY_REV" ]; then
  echo "cached Verity checkout does not match sources.lock: $SOURCE" >&2
  exit 1
fi

HAX_INFO="$(cargo hax --version 2>/dev/null || true)"
if ! printf '%s\n' "$HAX_INFO" | grep -qx "version=$HAX_VERSION"; then
  echo "cargo-hax $HAX_VERSION is required" >&2
  echo "install with: cargo install cargo-hax --version $HAX_VERSION --locked" >&2
  exit 1
fi

cargo hax tools install "charon@$CHARON_VERSION"
cargo hax tools install "aeneas@$AENEAS_VERSION"
printf 'Verity source: %s\n' "$SOURCE"
