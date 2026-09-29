---
title: Fork Choice and Storage Correspondence
last_updated: 2026-09-29
tags:
  - verification
  - aeneas
  - fork-choice
  - storage
---

# Fork Choice and Storage Correspondence

## Fixed inputs

- Verity: `a9f3365151a28784277ef31b89aa0092656d4f88` (`sources.lock`)
- formal-leanSpec: `ba7284513031eac5c66bfb8221d27b6154cf240b`
- Charon: `nightly-2026.09.02`
- Aeneas: `nightly-2026.09.03-6852e64`
- Lean: `v4.31.0`

The checked-in generated files are immutable inputs. They contain only the
`verity-chain` justification, proposer, slot-clock, and merkle roots; neither
`block_production::is_eligible` nor any `verity-db` item is present. All new Lean
results therefore use source-faithful pure models, while extraction was run only
under `/tmp` to determine exact tool boundaries.

## Checked Lean results

`proofs/VerityChain/ForkChoiceStorage.lean` adds:

- `candidateEligible_eq`: the pure model of pinned Rust
  `block_production::is_eligible` is definitionally equal to
  formal-leanSpec `BlockProduction.candidateEligible`. A Rust `HashSet` is
  represented extensionally by `List.contains`; all remaining branches use the
  corresponding formal pure functions.
- `voteReplaces_newer` and `voteReplaces_older`: the slot-order branches of
  `verity_db::votes::replaces` and `Store.votePrecedence` agree.
- `voteReplaces_tie`: reduces the equal-slot branch to the two exact root
  comparisons.
- `votePrecedence_self_counterexample`: a checked semantic counterexample to
  unconditional equality. Rust replacement is strict and returns false for the
  same stored vote; formal-leanSpec's merge-sort comparator uses `Root.lexLe`
  and returns true reflexively.

Build and trust check:

```text
$ lake build
Build completed successfully (1728 jobs).

$ lake env lean /tmp/PrintFcStor.lean
voteReplacesModel_none: no axioms
voteReplaces_newer: [propext]
voteReplaces_older: [propext, Quot.sound]
voteReplaces_tie: [propext, Classical.choice, Quot.sound]
votePrecedence_self_counterexample: [propext, Classical.choice, Quot.sound]
candidateEligible_eq: [propext]
```

No theorem depends on a project axiom, `sorry`, or `admit`.

## Catalog classification

| ID | Status | Correspondence evidence or exact blocker |
|---|---|---|
| FC-1 | extraction-blocked | `verity_chain::fork_choice` reaches LLBC (6,683,056 bytes), then Aeneas exits 2 in `translate_fun_sigs` on `core::iter::traits::iterator::Iterator` before generating Lean. `update_head` therefore has no body to relate to `Store.updateHead`. |
| FC-2 | extraction-blocked | Same module-wide pre-output crash; `lmd_ghost_head` / ancestry functions and the store maps are unavailable. This is not a proof-complexity classification. |
| FC-3 | extraction-blocked | Same crash prevents `validate_attestation` and its topology checks from being emitted. The formal theorem exists as `Store.attestation_topology`, but there is no fixed extracted Rust body. |
| FC-4 | extraction-blocked | Same crash prevents extraction of the store and parent walk used to state acyclicity. The Rust invariant is induced by strictly increasing accepted block slots; no extracted `Store` relation exists. |
| FC-5 | partial correspondence; catalog theorem extraction-blocked | `candidateEligible_eq` proves the viable per-candidate filter. For the catalog termination theorem, Aeneas explicitly ignores `select_votes` at pinned Rust lines 136–247: `Returns inside of nested loops are not supported yet`; a signature with no body cannot support the fixed-point proof. |
| FC-6 | extraction-blocked | Same `fork_choice` `Iterator` signature crash removes `update_head`, so invariant preservation cannot be stated over extracted code. |
| FC-7 | extraction-blocked | Same crash removes `on_block_observed` and its mutable `Store` flow before output. |
| FC-8 | extraction-blocked | The fork-choice half (`on_block_observed`) is absent due to the same crash. The checked-in extraction also does not contain the state-transition history functions needed by the combined property. |
| STOR-1 | extraction-blocked | The in-memory parent gate is in crashed `on_block_observed`. The second gate, `verity_db::writer::check_block`, reaches partial Lean only as `def ... := by sorry`; Aeneas reports `There should be no bottoms in the value` at pinned `writer.rs:501:0-523:1`. |
| STOR-2 | extraction-blocked / RocksDB trust boundary | `verity_db::backend` reaches LLBC (3,470,828 bytes), then Aeneas exits 2 on the same `Iterator` trait signature before output. Thus `MemoryBackend::write` is unavailable; `RocksBackend::write` would in any event delegate atomicity to RocksDB rather than prove it from Rust. |

`votes::replaces` is supporting fork-choice/storage logic rather than a catalog
ID. It extracts cleanly in isolation (168,464-byte LLBC, no Aeneas errors), but
its strict tie rule is not identical to formal-leanSpec's non-strict
`votePrecedence`; the Lean counterexample above is the exact semantic blocker.

## Reproduction

Set:

```sh
ROOT="$PWD"
VERITY="$ROOT/.cache/verity-a9f3365151a28784277ef31b89aa0092656d4f88"
CHARON="$HOME/.cache/hax/tools/charon/nightly-2026.09.02/charon"
AENEAS="$HOME/.cache/hax/tools/aeneas/nightly-2026.09.03-6852e64/aeneas"
PATH="$(dirname "$CHARON"):$PATH"
```

Run each root independently so one Aeneas crash cannot hide another:

```sh
cd "$VERITY/crates/verity-chain"
"$CHARON" cargo --preset=aeneas --dest-file /tmp/fork_choice.llbc \
  --start-from verity_chain::fork_choice
"$AENEAS" -backend lean -dest /tmp/fork-choice-lean -split-files \
  -gen-lib-entry /tmp/fork_choice.llbc

"$CHARON" cargo --preset=aeneas --dest-file /tmp/block_production.llbc \
  --start-from verity_chain::block_production
"$AENEAS" -backend lean -dest /tmp/block-production-lean -split-files \
  -gen-lib-entry /tmp/block_production.llbc

cd "$VERITY/crates/verity-db"
for module in votes backend writer; do
  "$CHARON" cargo --preset=aeneas --dest-file "/tmp/$module.llbc" \
    --start-from "verity_db::$module"
  "$AENEAS" -backend lean -dest "/tmp/$module-lean" -split-files \
    -gen-lib-entry "/tmp/$module.llbc"
done
```

Observed diagnostics:

```text
fork_choice (LLBC 6,683,056 bytes), backend (LLBC 3,470,828 bytes):
Source: '/rustc/library/core/src/iter/traits/iterator.rs', lines 42:0-42:24
Uncaught exception:
  Aeneas.Errors.CFailure(_)

block_production (LLBC 7,567,491 bytes):
[Error] Returns inside of nested loops are not supported yet
Source: 'crates/verity-chain/src/block_production.rs', lines 136:0-247:1
[Error] Ignoring the body of 'verity_chain::block_production::select_votes'

writer (LLBC 5,728,091 bytes):
[Error] There should be no bottoms in the value
Source: 'crates/verity-db/src/writer.rs', lines 501:0-523:1
Could not translate the body of function 'verity_db::writer::check_block'

votes (LLBC 168,464 bytes):
Aeneas exit 0; `votes.replaces` emitted with a real body and no `sorry`.
```
