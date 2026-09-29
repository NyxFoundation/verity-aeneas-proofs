# verity-aeneas-proofs

Aeneas-generated Lean semantics for [Verity](https://github.com/NyxFoundation/verity) and handwritten correspondence proofs against [formal-leanSpec](https://github.com/NyxFoundation/formal-leanSpec).

This repository owns verification artifacts, not production consensus code. It was initialized from Verity PRs [#49](https://github.com/NyxFoundation/verity/pull/49) and [#56](https://github.com/NyxFoundation/verity/pull/56).

## Current result

The first completed vertical slice is formal-leanSpec proposition **CONT-2**. For Verity's extracted `is_justifiable_after` predicate, the proofs establish that:

- at or after finalization, the extracted `RustM Bool` equals formal-leanSpec's `Slot.isJustifiableAfter`;
- it succeeds with `true` exactly when the slot distance is at most 5, a perfect square, or a pronic number;
- before finalization, it succeeds with `false`.

The correspondence uses a handwritten model of Rust's `u128::isqrt` backed by formal-leanSpec's proved square root. It does not prove the whole client or protocol safety.

## Repository layout

| Path | Ownership |
|---|---|
| `generated/` | Charon/Aeneas output; never edit manually |
| `proofs/` | Handwritten external models and correspondence theorems |
| `lean/` | Symlinked Lean module tree consumed by Lake |
| `docs/` | Extractability survey and reproduction notes |
| `scripts/` | Pinned source checkout, regeneration, integrity checks, and manual verification |
| `sources.lock` | Exact source, specification, and tool revisions |

## Reproduce

Prerequisites are Git, Python 3.11 or newer, Rust/Cargo, and cargo-hax 0.4.0:

```sh
cargo install cargo-hax --version 0.4.0 --locked
./scripts/bootstrap.sh
./scripts/extract.sh
git diff --exit-code -- generated artifacts.sha256
./scripts/verify.sh
```

`extract.sh` checks out the exact Verity revision from `sources.lock`, installs the pinned Charon and Aeneas binaries through cargo-hax, and replaces only `generated/`. `verify.sh` checks artifact integrity, builds the Lean package, and prints the axioms used by the three CONT-2 theorems.

GitHub Actions intentionally runs only the lightweight artifact-integrity check. Lean and Aeneas execution remains an explicit local operation because of its resource cost.

See [Reproduction and maintenance](docs/reproduction.md) for the update procedure and [the correspondence survey](docs/correspondence-survey.md) for the wider proof inventory.

## License

MIT © Nyx Foundation
