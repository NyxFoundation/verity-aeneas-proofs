---
title: Reproduction and Maintenance
last_updated: 2026-09-29
tags:
  - aeneas
  - reproducibility
  - verification
---

# Reproduction and Maintenance

## Pinned inputs

`sources.lock` is the source of truth for:

- the Verity commit whose Rust is extracted;
- the formal-leanSpec commit used by correspondence proofs;
- the survey's separate Verity and leanSpec revisions;
- cargo-hax, Charon, Aeneas, and Lean versions.

Generated files are committed so extraction changes remain reviewable. `artifacts.sha256` binds every generated Lean file to its checked-in contents.

## First-time setup

Install cargo-hax at the pinned version, then bootstrap the source and managed tools:

```sh
cargo install cargo-hax --version 0.4.0 --locked
./scripts/bootstrap.sh
```

The Verity checkout is stored under `.cache/verity-<revision>/`. It is disposable and must not be edited.

## Regenerate

```sh
./scripts/extract.sh
git diff -- generated artifacts.sha256
```

The extraction selects `verity_chain::{justification,proposer,slot_clock,merkle}`. It replaces these generated modules:

- `Funs.lean`
- `FunsExternal_Template.lean`
- `Types.lean`
- `TypesExternal_Template.lean`

The handwritten `FunsExternal.lean`, `TypesExternal.lean`, and `Correspondence.lean` files are never overwritten.

## Verify manually

```sh
./scripts/verify.sh
```

This performs the lightweight checks, runs `lake build`, and prints the axioms used by:

- `isJustifiableAfter_eq`
- `isJustifiableAfter_iff`
- `isJustifiableAfter_before_finalized`

A completed proof must contain no `sorry` and must not gain a project-specific axiom dependency.

## Update an input

1. Replace the complete commit SHA or tool version in `sources.lock`.
2. Keep `lakefile.toml`, `lean-toolchain`, and `hax.toml` synchronized with the lock.
3. Run `./scripts/extract.sh`.
4. Review the generated templates before changing handwritten models.
5. Repair the correspondence proofs when the generated semantics or formal specification changed.
6. Run `./scripts/verify.sh` and inspect the axiom report.
7. Commit the lock, generated artifacts, manifest, models, and proofs together.

An extraction or proof failure is not automatically a Verity defect. Classify it first as a tool limitation, an incorrect external model, a theorem/precondition problem, an incomplete proof, or a concrete implementation/specification mismatch. Change production Rust only after confirming the last category with a reproducible counterexample.

## Full survey

The 51-module survey in `correspondence-survey.md` is not part of routine regeneration. Some targets exceed GitHub-hosted runner memory: Charon exceeded 55 GB resident memory on derived SSZ decoding, and individual Aeneas runs can exceed 12 GB. Re-run those measurements manually with the memory caps documented in the survey.
