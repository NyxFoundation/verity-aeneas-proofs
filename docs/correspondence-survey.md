---
title: Aeneas Correspondence Survey
last_updated: 2026-09-29
tags:
  - verification
  - aeneas
  - formal-leanspec
  - correspondence
---

# Aeneas Correspondence Survey

Which Verity items can be put in correspondence with a formal-leanSpec definition or
proposition, and which of those the Charon → Aeneas pipeline turns into Lean today. This is a
measurement, not a plan: every extractability verdict below comes from running the tools on
the real crates at `develop` HEAD, and every correspondence names the two definitions side by
side so a proof author can start from the row.

**Status.** Final correspondence ledger. Every domain row has exactly one final status, all
34 theorem propositions are accounted for, and each checked result names its Lean evidence.
No production Rust, pinned upstream source, or generated artifact was changed. Aeneas remains
a verification aid: the architecture's proof route is still formal-leanSpec compiled through
Lean's C backend ([architecture](https://github.com/NyxFoundation/verity/blob/develop/docs/src/reference/architecture.md)).

**Fixed correspondence inputs.** Verity `a9f3365`; formal-leanSpec `ba72845`; Aeneas
`nightly-2026.09.03-6852e64`. The historical inventory below was measured at Verity `develop`
`dff96ac`; formal-leanSpec `ba72845` (34 catalog theorem propositions in
[`docs/lean4-proof-propositions.md`](https://github.com/NyxFoundation/formal-leanSpec/blob/ba7284513031eac5c66bfb8221d27b6154cf240b/docs/lean4-proof-propositions.md));
leanSpec `08e1481a`; Charon `nightly-2026.09.02`; Aeneas
`nightly-2026.09.03-6852e64` (the pair `cargo-hax` 0.4.0 installs). The extraction branches
this continues are Verity PR #48 (hax) and PR #49 (raw Aeneas); they measured three
`verity-chain` modules at a 2026-09-12 revision. This survey re-measures all 51 modules of six
crates and, where it disagrees with what those branches recorded, says so.

## Method

Three inputs, combined by hand:

1. **Extraction runs.** For every module of `verity-types`, `verity-chain`,
   `verity-validator`, `verity-crypto`, `verity-db`, and `verity-p2p`, Charon was invoked with
   `--start-from <crate>::<module>` and its LLBC handed to Aeneas's Lean backend, one module per
   run. The four IO-shell crates (`verity-node`, `verity-rpc`, `verity-metrics`, `verity`)
   have no formal-leanSpec counterpart and were not run; the two of their items that do
   correspond (the sync state machine and the `BlocksByRange` responder) are read statically
   and marked as such. Commands and the memory discipline they need are in Appendix A.
2. **The Rust inventory**: every `pub` item of the six crates, with the constructs Aeneas is
   known to reject noted per function.
3. **The Lean inventory**: every definition and theorem of formal-leanSpec's 41 files, with the
   catalog ID each theorem discharges.

A refusal is classified as described in [the reproduction guide](reproduction.md): a tool
limitation is recorded and the implementation left alone; only a Verity defect would be fixed.
Every refusal in this survey is a tool limitation.

**Reading the verdicts.** Charon `pass` means the module compiled and reached LLBC; `oom`
means Charon was killed at the memory cap; `fail` means Charon itself panicked. Aeneas `pass`
means no error; `partial` means Aeneas reported errors but still wrote the Lean files, with
each refused function emitted as a `def` whose body is `sorry` (the count is the `sorry`
column); `crash` means Aeneas died on an uncaught exception and wrote nothing. `defs` and
`types` count the `def`s in `Funs.lean` and the `structure`/`inductive`s in `Types.lean`,
including the dependencies each module pulls in from `verity-types` and `libssz`.

## Extraction results

| Crate | Module | Charon | Aeneas | defs | sorry | types |
|---|---|---|---|---:|---:|---:|
| `verity-types` | `primitives` | pass | partial | 149 | 0 | 5 |
| `verity-types` | `config` | pass | pass | 9 | 0 | 0 |
| `verity-types` | `checkpoint` | pass | partial | 71 | 2 | 7 |
| `verity-types` | `validator` | pass | partial | 43 | 1 | 6 |
| `verity-types` | `attestation` | pass | partial | 143 | 6 | 11 |
| `verity-types` | `aggregation` | pass | partial | 45 | 1 | 7 |
| `verity-types` | `block` | pass | partial | 212 | 6 | 13 |
| `verity-types` | `state` | **oom** | — | — | — | — |
| `verity-chain` | `error` | pass | partial | 18 | 2 | 1 |
| `verity-chain` | `slot_clock` | pass | pass | 20 | 0 | 1 |
| `verity-chain` | `justification` | pass | pass | 9 | 0 | 3 |
| `verity-chain` | `proposer` | pass | pass | 1 | 0 | 1 |
| `verity-chain` | `merkle` | pass | pass | 2 | 0 | 2 |
| `verity-chain` | `view` | pass | crash | 0 | 0 | 0 |
| `verity-chain` | `state_transition` | pass | partial | 75 | 2 | 22 |
| `verity-chain` | `fork_choice` | pass | crash | 0 | 0 | 0 |
| `verity-chain` | `block_production` | pass | partial | 86 | 10 | 25 |
| `verity-validator` | `error` | pass | pass | 20 | 0 | 6 |
| `verity-validator` | `keys` | pass | partial | 44 | 19 | 17 |
| `verity-validator` | `duties` | pass | partial | 45 | 28 | 40 |
| `verity-validator` | `product` | pass | partial | 8 | 1 | 13 |
| `verity-validator` | `proofs` | pass | partial | 12 | 1 | 11 |
| `verity-validator` | `aggregation` | pass | crash | 0 | 0 | 0 |
| `verity-validator` | `prover` | pass | partial | 10 | 0 | 2 |
| `verity-crypto` | `error` | pass | pass | 51 | 0 | 4 |
| `verity-crypto` | `containers` | pass | partial | 178 | 4 | 13 |
| `verity-crypto` | `scheme` | pass | partial | 30 | 1 | 2 |
| `verity-crypto` | `key` | pass | partial | 69 | 1 | 37 |
| `verity-crypto` | `signature` | pass | partial | 76 | 0 | 41 |
| `verity-crypto` | `aggregate` | pass | crash | 40 | 67 | 80 |
| `verity-crypto` | `keystore` | pass | crash | 0 | 0 | 0 |
| `verity-db` | `error` | pass | partial | 62 | 9 | 4 |
| `verity-db` | `key` | pass | pass | 11 | 0 | 4 |
| `verity-db` | `column` | pass | partial | 24 | 2 | 1 |
| `verity-db` | `schema` | pass | partial | 65 | 1 | 26 |
| `verity-db` | `metadata` | pass | partial | 23 | 2 | 1 |
| `verity-db` | `diff` | **oom** | — | — | — | — |
| `verity-db` | `retention` | pass | partial | 37 | 2 | 16 |
| `verity-db` | `votes` | pass | pass | 4 | 0 | 4 |
| `verity-db` | `read` | **oom** | — | — | — | — |
| `verity-db` | `reconstruct` | **oom** | — | — | — | — |
| `verity-db` | `writer` | pass | partial | 162 | 9 | 55 |
| `verity-db` | `repository` | pass | partial | 91 | 5 | 40 |
| `verity-db` | `backend` | pass | crash | 0 | 0 | 0 |
| `verity-p2p` | `error` | pass | pass | 52 | 0 | 7 |
| `verity-p2p` | `config` | pass | pass | 9 | 0 | 1 |
| `verity-p2p` | `wire` | pass | partial | 25 | 4 | 6 |
| `verity-p2p` | `gossip` | pass | crash | 0 | 0 | 0 |
| `verity-p2p` | `reqresp` | pass | partial | 134 | 3 | 21 |
| `verity-p2p` | `behaviour` | **fail** | — | — | — | — |
| `verity-p2p` | `service` | **fail** | — | — | — | — |

Totals: 51 modules; Charon passes 45 (4 killed at the memory cap, 2 panics); of those 45,
Aeneas passes 11 clean, 27 with `sorry` bodies, and crashes on 7.

**What the refusals are made of.** Grouped by cause, because the causes are few:

| Cause | Where | Stage |
|---|---|---|
| **`State` / `StateDiff` decoding.** Charon's expansion of the derived `SszDecode` for any type holding `JustificationValidators` (`SszBitlist<2^30>`) grows without bound: 55 GB resident plus 40 GB swap before the kernel killed it uncapped | `verity-types::state`, `verity-db::{diff, read, reconstruct}` (the modules that *decode* those types; `writer`, which only encodes them, passes) | Charon oom |
| **libp2p derive and async swarm.** Charon panics at `src/ast/krate.rs:143` (`Option::unwrap` on `None`) | `verity-p2p::{behaviour, service}` | Charon fail |
| **`Iterator` trait signatures.** Aeneas raises an uncaught `CFailure` in `translate_fun_sigs` on `core::iter::traits::iterator::Iterator` (`impl Iterator` return types, iterator-adaptor chains over `HashMap`/`BTreeMap`) | `verity-chain::{fork_choice, view}`, `verity-validator::aggregation`, `verity-db::backend` | Aeneas crash |
| **`str` pattern APIs.** Same exception on `core::str::pattern` (`strip_prefix`, `split`) | `verity-p2p::gossip`, `verity-crypto::keystore` | Aeneas crash |
| **leanVM's `rec_aggregation` types.** Aeneas's `trait_impl_is_builtin` fails 709 times on Plonky3 trait impls, then crashes | `verity-crypto::aggregate` | Aeneas crash |
| **`libssz` derive-generated decode helpers.** `ssz_decode_fixed_vec` / `fixed_size` closures carry a higher-ranked-to-free lifetime constraint Aeneas has not implemented. The container *types* are unaffected | every `verity-types` container module, `verity-crypto::containers`, `verity-p2p::reqresp` (`Status`) | Aeneas partial |
| **Functions returning `&'static str`.** `as_str`, `name`, `as_bytes`, `file_infix`, `kind`, and every `Display::fmt` come out as `sorry` ("There should be no bottoms in the value" / "Unreachable") | `verity-chain::error`, `verity-db::{column, metadata, error}`, `verity-crypto::scheme`, `verity-validator::product` | Aeneas partial |
| **Closures over map iterators.** `HashSet` dedup closure and `BTreeMap` unpack | `verity-chain::state_transition` (the dedup closure inside `process_attestations_observed`, `JustificationState::unpack`), `verity-chain::block_production` (`select_votes` body ignored; `in_target_slot_order`, `union_of`, `select_proofs_for_coverage`, and the closures inside `trial_body`) | Aeneas partial |
| **Tuple-struct newtypes as root items.** `Slot(pub u64)` gives the type and its constructor one Lean name; Aeneas refuses to register it. Reached as a *dependency* from another module, the same newtype comes out as `def primitives.Slot := Std.U64` | `verity-types::primitives` | Aeneas partial |
| **async and tokio.** Every `async fn` is absent from the output; `tracing` macros and `JoinHandle` produce "could not lookup the translated function" cascades | `verity-validator::{duties, keys}`, `verity-p2p::{wire, reqresp}` (`read_framed`, `read_varint`, the codec) | Aeneas partial |
| **`Box<dyn Error>`** ("Dynamic trait types are not supported yet") | `verity-p2p::wire` (`io::Error` conversions) | Aeneas partial |

**Corrections to PR #48's record.** That branch reported `fork_choice` refused by Charon on
`HashMap`, `state_transition` refused by Aeneas on closures and a non-endable borrow, and
`block_production` refused on a `return` inside a nested loop. At these tool versions and this
revision: `fork_choice` passes Charon and crashes Aeneas on the `Iterator` trait instead;
`state_transition` translates in full but for two `sorry` bodies (the `HashSet` dedup closure
inside `process_attestations_observed` at `attestations.rs:70`, and `JustificationState::unpack`),
so the non-endable borrow is in a dedup step, not in the transition itself; `block_production`
translates `build_block`, `is_eligible`, `extended_chain_view`, and `trial_body`, and refuses
`select_votes`, `in_target_slot_order`, `union_of`, and `select_proofs_for_coverage`. The tool-limit classification stands; the boundary is just much further
in than the branch measured.

## Correspondence by catalog domain

Columns: the formal-leanSpec definition or theorem (with catalog ID), the Verity item that
plays the same role, whether that item's body reached Lean, what stands between the two,
and the final result. Every row has exactly one bold final status. "Extracts" is per item,
from the generated `Funs.lean`: `body` means a real definition, `sorry` means the signature
was emitted and the body refused, and `absent` means Aeneas produced nothing for it.

Final statuses are evaluated against the fixed correspondence input in `sources.lock`
(Verity `a9f3365`) and the checked-in generated artifact set. The broader Verity `dff96ac`
survey measurements above are reproducible supporting evidence, not a substitute for a
symbol missing from that fixed artifact set.

### SSZ and primitives (SSZ-1 … SSZ-7)

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `SSZ.Boolean.encode` / `decode`, `decode_encode` (SSZ-1) | none in Verity; `libssz` (external crate) implements `bool` | not attempted (external) | Verity owns no SSZ codec for primitives | **no-counterpart** — searched through `verity-types`; primitive Boolean coding ends at the external `libssz` boundary. |
| `SSZ.Uint64`, `range` (SSZ-2), `encode`/`decode`, `decode_encode`, `encode_size` (SSZ-3) | `verity_types::primitives::{Slot, ValidatorIndex, SubnetId, Interval}` newtypes with hand-written `SszEncode`/`SszDecode` forwarding to `u64` | the forwarding impls: body (149 defs); the newtypes themselves refused as root items (name clash) | Lean `Slot := UInt64` (an alias); Rust `Slot(u64)` (a newtype). From any other module the newtype arrives as `def primitives.Slot := Std.U64`, which is the alias | **partial** — `verityUint64_range` proves SSZ-2 after `toLeanUint64` in `proofs/VerityChain/PrimitiveCorrespondence.lean`. SSZ-3 is blocked reproducibly: Aeneas exits 1 with name clashes for all four tuple-newtype types/constructors; distinct generated constructor names are required. |
| `SSZ.Bytes32`, `size_eq_32` (SSZ-4) | `verity_types::primitives::Bytes32 = [u8; 32]` | body (as `Array U8 32`) | Lean is a subtype of `ByteArray`; Rust a fixed array. Both carry the length in the type | **proved** — `toLeanBytes32_size` after the explicit `toLeanBytes32` conversion in `proofs/VerityChain/PrimitiveCorrespondence.lean`. |
| `SSZ.SSZVector`, `sszvector_length` (SSZ-5) | `libssz_types::SszVector` (external); used by `verity_crypto::containers::{HashDigest, Parameter, Randomness}` | not attempted (external) | — | **no-counterpart** — no Verity-owned vector definition exists; the searched implementation boundary is `libssz_types::SszVector`. |
| `SSZ.Utils.getPowerOfTwoCeil`, `ceil_pow2_minimal` (SSZ-6) | none; merkleization lives in `libssz_merkle` | not attempted (external) | — | **no-counterpart** — Verity has no rounding helper; the searched boundary is external `libssz_merkle`. |
| `SSZ.HasHashTreeRoot`, axiom `collisionResistance` (SSZ-7) | `verity_chain::merkle::hash_tree_root<T: HashTreeRoot>` and `verity_db::merkle::hash_tree_root` | body, one trait-method call | The Lean side is an axiom, so the correspondence is "Rust calls the function the axiom is about". | **partial** — `hashTreeRoot_forwards` in `proofs/VerityChain/PrimitiveCorrespondence.lean` proves exact delegation. It deliberately does not transport collision resistance; its axiom audit exposes Aeneas's external SHA-256 hash assumption, while formal-leanSpec separately declares `HashTreeRoot.collisionResistance`. |
| `Forks.Lstar.Errors.STError` (29 constructors) | `verity_chain::error::RejectionReason` (33 variants) | the `inductive`: body; `as_str` and `Display`: sorry | Rust is a strict superset: `StateRootMismatch`, `AnchorStateRootMismatch`, `ValidatorNotInState`, `InvalidSignature` have no Lean constructor. Three are renamed: `invalidSlot` ↔ `BlockSlotMismatch`, `headerSlotNotNewer` ↔ `BlockOlderThanLatestHeader`, `proposerMismatch` ↔ `WrongProposer`. Lean constructors carry payloads (`slotNotInFuture (current target : Slot)`); Rust variants are unit | **partial** — `leanError_refines_rust` gives the payload-forgetting one-way refinement and `verityOnlyErrors_have_no_lean_counterpart` checks the exact four-variant gap in `proofs/VerityChain/ErrorCorrespondence.lean`; equality is false because Rust drops payloads and has four extra kinds. |

### Containers (CONT-1, CONT-2) and configuration

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `Checkpoint {root, slot}`, `LT` by slot, `checkpoint_lt_iff_slot_lt` (CONT-1) | `verity_types::checkpoint::Checkpoint {root, slot}` | `structure`: body; derived decode helper: sorry | Rust defines no order on `Checkpoint` (no `PartialOrd`); every comparison in Verity is written out as `a.slot.0 > b.slot.0`. CONT-1 is a statement about the Lean `LT` instance, so its Rust form is a property of `advance_checkpoint`, not of an operator | **proved** — `checkpointOrder_iff_slotOrder` proves exact slot-order agreement after `toLeanCheckpoint`; field preservation is checked by `toLeanCheckpoint_root` and `toLeanCheckpoint_slot` in `proofs/VerityChain/Correspondence.lean`. |
| `Checkpoint.advanceTo` | `verity_chain::justification::advance_checkpoint(current, candidate)` | body | Same rule (`candidate.slot > self.slot`), same tie-breaking | **proved** — `advanceCheckpoint_eq`, `advanceCheckpoint_corresponds`, and `advanceCheckpoint_refines` cover both branches and ties against the extracted `RustM` function. |
| `Slot.isJustifiableAfter finalized target` (CONT-2: `justifiable_iff`, `justifiable_before_finalized`) | `verity_chain::justification::is_justifiable_after(slot, finalized)` | body, as `RustM Bool`; correspondence proved here | Argument order is swapped. Lean computes on `Nat`; Rust widens to `u128` and returns `RustM Bool`. The handwritten model maps `u128::isqrt` to formal-leanSpec's proved `Slot.isqrt`; `isJustifiableAfter_eq` proves functional equality, `isJustifiableAfter_iff` transfers CONT-2 directly, and `isJustifiableAfter_before_finalized` covers the earlier-slot case. `#print axioms` reports no project-specific axiom, and the proofs contain no `sorry` | **proved** — those three theorems in `proofs/VerityChain/Correspondence.lean` cover the successful, characterized, and before-finalized cases. |
| `Slot.justifiedIndexAfter` | `justification::justified_index_after(slot, finalized)` | body, as `RustM (Option Usize)` | Same order swap; `Nat` vs `usize` | **partial** — `justifiedIndexAfter_eq` exactly characterizes every extracted result; `justifiedIndexAfter_corresponds` and `justifiedIndexAfter_refines` prove equality after conversion when the mathematical index fits Aeneas's platform-dependent `usize`. The missing part is an unconditional bridge from generic `usize` to unbounded `Nat`. |
| `Slot.immediateJustificationWindow = 5` | `justification::IMMEDIATE_JUSTIFICATION_WINDOW = 5` | body (`5#u64`) | — | **proved** — `immediateJustificationWindow_corresponds` checks the extracted constant against formal-leanSpec. |
| `JustifiedSlots.isSlotJustified` | `justification::is_slot_justified(justified_slots, finalized, slot)` | body, via axiom `SszBitlist.get` | Lean indexes an `Array Bool`; Rust a `SszBitlist<N>` whose `get` is opaque to Aeneas | **blocked** — the fixed external model declares `SszBitlist.get` as an unconstrained axiom. A stable `libssz_types` bit-indexing contract and a proved bitlist/array relation are required before a non-vacuous theorem is possible. |
| `JustifiedSlots.extendToSlot` | `justification::extend_justified_slots_to` | body, via axioms `SszBitlist.len`/`push`/`clone` | Same bitlist opacity; Rust returns `Result` (capacity), Lean is total | **blocked** — `SszBitlist.len`, `push`, and `clone` remain opaque; unblocking requires their stable contracts, a capacity invariant, and a proved bitlist/array relation covering the Rust error arm. |
| `ValidatorIndex.proposerForSlot slot n`, `proposer_index_round_robin` (VAL-1), `unique_proposer` (VAL-3) | `verity_chain::proposer::proposer_for_slot(slot, validator_count) -> Result` | body, as `RustM ValidatorIndex` | Lean takes `0 < n` as a hypothesis; Rust returns `EmptyValidatorRegistry` for 0. Otherwise `slot % n` on both sides. | **proved** — `proposerForSlot_zero`, `proposerForSlot_eq`, `proposerForSlot_roundRobin`, `proposerForSlot_uniqueOutput`, and `proposerForSlot_unique` prove the zero error, successful remainder, VAL-1 transport, and VAL-3 uniqueness. |
| `Interval.fromSlot slot = slot * INTERVALS_PER_SLOT` | `verity_chain::slot_clock::intervals_at_slot_start(slot)` | body, as `RustM Interval` | Rust checked multiplication can fail while formal-leanSpec constructs a wrapping `UInt64`. | **partial** — `intervalsAtSlotStart_eq`, `intervalsAtSlotStart_corresponds`, and `intervalsAtSlotStart_refines` prove exact successful correspondence under the necessary no-overflow bound; no equality is claimed for the Rust error case. |
| `Forks.Lstar.Config`: `MAX_ATTESTATIONS_DATA = 8`, `INTERVALS_PER_SLOT = 5`, `GOSSIP_DISPARITY_INTERVALS = 1`, `HISTORICAL_ROOTS_LIMIT = 2^18` | `verity_types::config` (same four values) | body; derived constants come out as `RustM` (`1#usize <<< 18#i32`) | Lean has no `SECONDS_PER_SLOT`, `MILLISECONDS_*`, `JUSTIFICATION_LOOKBACK_SLOTS`, `ATTESTATION_COMMITTEE_COUNT`, `VALIDATOR_REGISTRY_LIMIT`, `JUSTIFICATION_VALIDATORS_LIMIT`, `BYTE_LIST_512_KIB_LIMIT`, `GOSSIP_DIGEST` | **proved** — `intervalsPerSlot_corresponds`, `historicalRootsLimit_corresponds`, `maxAttestationsData_corresponds`, and `gossipDisparityIntervals_corresponds` check all four shared values. The last two are stable pinned-source literal models because they are absent from the fixed generated dependency set; unrelated Verity-only constants are outside the comparison. |
| `Attestation {validatorIndex, data}`, `AggregatedAttestation {aggregationBits, data}` | `verity_types::attestation::{Attestation, AggregatedAttestation}` | `structure`: body; derived decode: sorry | `AggregationBits` is `Array Bool` in Lean, `SszBitlist<VALIDATOR_REGISTRY_LIMIT>` in Rust | **blocked** — these types are absent from fixed `generated/VerityChain/Types.lean`; an approved extraction expansion plus the bitlist/array relation is required. |
| `AttestationData {slot, head, target, source}`, `liesOnChain` | `verity_types::checkpoint::AttestationData`; `verity_chain::state_transition::attestations::is_on_chain` (`pub(crate)`) | both body | Field order matches | **blocked** — neither symbol is in the fixed generated artifact; approving the focused state-transition extraction and defining root/checkpoint conversions are the exact prerequisites. |
| `SingleMessageAggregate {participants, proof}` | `verity_types::aggregation::SingleMessageAggregate {participants, proof}` | `structure`: body | Lean `proof : ByteArray`; Rust `ByteList512KiB` | **blocked** — the fixed artifact has no aggregate type, and a bounded-byte-list/`ByteArray` relation is required after extraction. |
| `MultiMessageAggregate {payload}` | `verity_types::aggregation::MultiMessageAggregate {proof}` | `structure`: body | **Field name differs**: Lean `payload`, Rust `proof`. leanSpec's container spells it `proof`; the Lean transcription is the odd one out | **blocked** — field renaming is not a semantic counterexample, but the aggregate type is absent from the fixed artifact. An approved type extraction and bounded-byte conversion would permit a field-preserving theorem. |
| `BlockBody`, `BlockHeader`, `Block`, `SignedBlock {block, proof}` | `verity_types::block::*` | `structure`: body; derived decode: sorry | Field names and order match | **blocked** — fixed generated types omit this family; an approved extraction plus list/bitlist/signature representation relations are required before shape and functional theorems can be named. |
| `GenesisConfig {genesisTime}`, `State` (10 fields) | `verity_types::state::{GenesisConfig, State}` | `State` reaches Lean as a dependency of `verity-chain` (22 types in `state_transition`); as a root module Charon is killed | Field order matches, including the consensus-critical `State` order. The `State` *structure* is fine; its derived decode is what Charon cannot expand | **blocked** — fixed generated types omit `State`; root extraction is killed while expanding `SszBitlist<2^30>` decode. A focused approved type extraction that excludes/refactors that derive is required. |
| `Validator {attestationPublicKey, proposalPublicKey, index}`, `Validators` | `verity_types::validator::{Validator, Validators}` | `structure`: body; derived decode: sorry | Lean keys are `ByteArray`; Rust `Bytes52` | **blocked** — the validator container is absent from the fixed artifact. An approved extraction and a length-preserving `Bytes52` conversion are required. |

### State transition (ST-1 … ST-7)

The Lean side lives in `StateTransition.lean`, `Reachable.lean`, `CheckpointForward.lean`, and
`HistoryAlignment.lean`. The Rust side is `verity_chain::state_transition`, which — contrary
to PR #48's record — translates: 75 definitions, two `sorry` bodies, both in the attestation
accounting.

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `State.generateGenesis genesisTime validators` | `state_transition::generate_genesis(genesis_time, validators)` | body | Straight-line; `hash_tree_root` is an axiom on the Lean side | **blocked** — `generate_genesis` is absent from the fixed checked-in extraction. Unblocking requires an approved expansion of that artifact plus a justified relation for the external hash-tree-root operation. |
| `State.processSlots`, `process_slots_advances` (ST-1) | `state_transition::process_slots(state, target_slot) -> Result` | body, as `RustM (Result State RejectionReason)` with the loop split into `process_slots_loop` / `_loop.body` | Lean is total with `termination_by`; the Rust loop becomes Aeneas's `divergent` recursion. | **blocked** — the fixed artifact has no `process_slots`; a usable extraction must additionally replace the opaque `State.clone` and establish termination of Aeneas's divergent loop before ST-1 can be transported. |
| `State.processBlockHeader`, `process_block_header_slot` (ST-2), `transition_header_slot` | `state_transition::process_block_header(state, block)` and private `validate`, `derive_header_checkpoints`, `record_parent_and_skipped_slots` | body (all four) | The `SszList::push` capacity failure is an extra `Err` arm Lean does not have. | **blocked** — these symbols are absent from the fixed artifact. Unblocking requires their approved extraction, state/block conversions, and a theorem that either excludes or relates the additional capacity-error arm. |
| `State.processAttestations`, `JFAcc`, `applyJustification`, `processAttestation`, `rootToSlot`, `noJustifiableBetween`, `unpackJustifications` | `state_transition::attestations::process_attestations_observed` and the private `JustificationState {unpack, apply, counts, justify, rebase_onto, repack}`, `index_chain_by_slot` | body for `process_attestations_observed`, `index_chain_by_slot`, `apply`, `counts`, `justify`, `rebase_onto`, `repack`, `voting_validator_indices`; **sorry** for `unpack` (BTreeMap build) and for the `HashSet` dedup closure inside `process_attestations_observed` (`attestations.rs:70`) | The Lean accumulator is an association list; Rust's is a `BTreeMap` whose operations are axioms (`BTreeMap.entry`, `retain`, `remove`). A refinement needs a map model. `noJustifiableBetween` is the `.all(\|slot\| …)` closure at `attestations.rs:237` and did translate. | **blocked** — the fixed artifact omits the entire module, and the broader extraction has two refused bodies. Unblocking requires Aeneas support for the non-endable dedup borrow and BTreeMap iterator build, then a proved finite-map relation for `entry`/`retain`/`remove`. |
| `State.processBlock`, `State.transition`, `state_transition_pure` (ST-5) | `state_transition::{process_block, state_transition}` and the `*_observed` forms | body; the observer generic becomes a typeclass argument `(observeTransitionObserverInst : TransitionObserver T0)` and the result carries the observer back as a pair | The `Unobserved` instance is a `structure` with a no-op `observe`, so the unobserved wrappers specialise cleanly. | **blocked** — no extracted `state_transition` symbol exists in the fixed artifact, so even the purity statement cannot name the implementation. Adding the generated module to the approved artifact set would make the reflexive purity theorem immediate. |
| `State.AnchorWF`, `Reachable`, `anchorWF_of_reachable` | none | — | Meta-level predicates over the Lean model; nothing to extract | **no-counterpart** — the searched Verity state-transition boundary has no runtime reachability or `AnchorWF` predicate. |
| `checkpoint_monotone` (ST-3), `justified_ge_finalized` (ST-4), `finalization_irreversible` (ST-6), `checkpoint_forward` (ST-7) | properties of `state_transition` | — | Gated on the two refused attestation bodies and on models for the `BTreeMap` axioms. | **blocked** — besides the fixed-artifact omission, these transports depend on the attestation map/dedup correspondence above and state-reachability relations; the exact unblocking work is to complete those models before applying the formal-leanSpec invariants. |
| `HistoryAlignment.transition_hist`, `transition_hist_size`, `transition_justified_on_chain` (FC-8 support) | properties of `process_block_header` / `process_attestations` | — | Same | **blocked** — the two implementation phases are absent from the fixed artifact, and attestation alignment still depends on the refused dedup/map semantics. |
| `Root.lexLe`, `byteListLe` | none by that name; Rust orders roots with `Ord` on `[u8; 32]` (`lmd_ghost_head`, `latest_votes`) | — | Same order, no named function on the Rust side | **no-counterpart** — the searched Rust boundary uses built-in array `Ord`; Verity exposes no named operation to relate. |

### Fork choice (FC-1 … FC-8)

Lean models the store as association lists (`blocks : List (Root × Block)`); Verity's `Store`
holds `HashMap`s. Aeneas crashes on `verity_chain::fork_choice` and on `view` (both at the
`Iterator` trait, before writing any file), so no row here has an extracted body. Charon passes
both, which PR #48 did not observe.

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `Store` structure, `Store.WellFormed` | `fork_choice::store::Store` | crash | Six `HashMap`/`HashSet` fields. `WellFormed` has no Rust mirror yet (the architecture calls for one; see the trust base in [formal verification](https://github.com/NyxFoundation/verity/blob/develop/docs/src/concepts/formal-verification.md)) | **blocked** — the fixed artifact has no Store type, Aeneas crashes in `translate_fun_sigs` on `Iterator`, and Verity has no `WellFormed` predicate. Unblocking FC-4 and the other Store invariants requires fixing that crash and defining/proving the Rust map representation invariant. |
| `getBlock?`, `getState?` | `Store.blocks.get`, `Store.states.get` | crash | `HashMap::get` is an axiom where it does get through (`state_transition` lists it in `FunsExternal`) | **blocked** — no fixed extracted Store/get symbols; after the iterator crash is fixed, a finite-map relation must justify `HashMap::get` rather than leave it as an unconstrained Aeneas axiom. |
| `ancestorWalk`, `checkpointIsAncestor`, `descendToSlot` | `Store::is_ancestor`, `Store::ancestor_at_slot` | crash | `while let … = map.get(…)` with `return` inside the loop (`ancestor_at_slot`). The same shape in `verity_db::retention::descends_from` translated, so the loop is not the obstacle | **blocked** — the upstream iterator-signature crash prevents output; unblocking then requires the map relation and a loop termination/walk correspondence. |
| `validateAttestation`, `attestation_topology` (FC-3) | `fork_choice::attestation::validate_attestation` and its private `validate_{availability,topology,ancestry,timing}` | crash | The checks themselves are straight-line. | **blocked** — FC-3 cannot name an extracted validator until the module-wide `Iterator` crash is fixed and the result is added to the approved artifact set. |
| `computeBlockWeights`, `accumulateAncestorWeights`, `creditChain`, `Weights` | `fork_choice::weights::{ancestor_weights, block_weights}` | crash | `HashMap<Bytes32, u64>` accumulator | **blocked** — no extracted body; fixing `Iterator` is necessary, followed by a proved accumulator-map relation and checked `u64` overflow behavior. |
| `extractAttestationsFromAggregatedPayloads`, `votePrecedence` | `weights::{participants, latest_votes}` | `participants` reached Lean via `block_production` as `sorry` (`impl Iterator` return) | The `impl Iterator` return type of `participants` is the likely crash site for the whole module | **blocked** — the fixed artifact has neither symbol, and Aeneas refuses `participants`' opaque iterator return. A concrete collection return or Aeneas `impl Iterator` support is required before vote extraction can be related. |
| `computeLmdGhostHead`, `ghostWalk`, `maxChild`, `childrenOf`, `beats` | `weights::lmd_ghost_head` | crash | Children map built as `HashMap<Bytes32, Vec<Bytes32>>`; `max_by_key` with a captured closure | **blocked** — iterator/closure translation and a children-map model are exact prerequisites; no generated symbol exists in the fixed artifact. |
| `updateHead`, `update_head_deterministic` (FC-1), `head_descends_from_justified` (FC-2), `updateHead_wellFormed` (FC-6) | `fork_choice::block::update_head` | crash | Composes the functions above | **blocked** — FC-1/2/6 depend on every blocked Store/weight operation above; `update_head` itself has no fixed generated body. |
| `onBlock`, `applyBlock`, `onBlock_wellFormed` (FC-7), `onBlock_invariants` (FC-8) | `fork_choice::block::on_block_observed` | crash | Also carries the observer generic and `&mut Store` through four callees | **blocked** — no generated body, and transport additionally requires the ST correspondence plus Store alignment/map relations; these are concrete semantic dependencies, not deferred lemmas. |
| `BlockProduction.selectionLoop`, `build_block_selection_terminates` (FC-5), `candidateEligible`, `buildBlockAttestations` | `block_production::build_block`, `is_eligible`, private `select_votes` | `build_block`, `is_eligible`, `extended_chain_view`, `trial_body`: body; `select_votes`: body ignored; `in_target_slot_order`, `union_of`, `select_proofs_for_coverage`: sorry | `select_votes` is the fixed-point loop FC-5 is about, and it is exactly the piece that did not come through. | **partial** — `ForkChoice.candidateEligible_eq` in `proofs/VerityChain/ForkChoiceStorage.lean` checks a line-by-line pure model of pinned `is_eligible` against `candidateEligible`. FC-5 remains blocked because Aeneas refuses `select_votes` with “Returns inside of nested loops are not supported yet” and emits no body for the fixed-point loop. |
| `Store.prune`, `prune_wellFormed` (#71) | none in `verity-chain` (blocks and states are never pruned in memory); `verity_db::retention::prune_block_proofs` prunes proofs on disk | `prune_block_proofs`: body | Different object: Lean prunes the store below the finalized root, Verity prunes persisted proofs by slot window and prunes votes (`prune_stale_attestation_data`) | **no-counterpart** — the searched in-memory fork-choice boundary never prunes Store blocks/states; database proof retention is a different operation. |
| `PruneHead.updateHead_prune` (#71), `IncrementalWeights` (#67) | none | — | Refinements of the Lean model; no Rust counterpart to relate | **no-counterpart** — neither refinement is implemented at the searched Verity fork-choice boundary. |
| — | `fork_choice::timeline::{on_tick, accept_new_attestations, update_safe_target}`, `fork_choice::duties::{attestation_target, attestation_data}`, `view::ChainView` | crash | No Lean counterpart: the catalog does not model the interval clock, the safe-target walk, or validator duty derivation | **no-counterpart** — formal-leanSpec's catalog boundary has no matching definitions or behavior. |

### Validator (VAL-1 … VAL-5)

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `proposerForSlot`, VAL-1, VAL-3 | `verity_chain::proposer::proposer_for_slot` | body | See the containers table | **proved** — the zero-error, round-robin, and uniqueness theorems are `proposerForSlot_zero`, `proposerForSlot_roundRobin`, and `proposerForSlot_unique` in `proofs/VerityChain/Correspondence.lean`. |
| `ValidatorRegistry`, `WellFormed`, `dual_key_distinct` (VAL-2), `addChecked` | `verity_crypto::keystore::load` and its private `load_validator`/`load_role`; `KeyLoadError::{DuplicateRoleKeys, PublicKeyMismatch}` | crash (`str` pattern APIs in the hex decoder) | Rust enforces the check at load time against the manifest; Lean models it as a registry predicate. The Rust path is file IO (`std::fs`, YAML), outside any extractor's subset by design | **partial** — `Validator.declaredRoleGate_isSome_iff` and `declaredRoleGate_distinct` in `proofs/VerityChain/ValidatorSync.lean` prove the exact source equality gate. End-to-end loader correspondence remains blocked by filesystem/YAML/hex parsing, opaque key decoding, and the `str::pattern` extraction crash. |
| `ValidatorService {attestedSlots}`, `attestationDutyStep`, `pruneAttested`, `ATTESTED_SLOT_RETENTION = 4`, `no_double_vote` (VAL-4) | `verity_validator::duties::DutyService.attested : BTreeSet<Slot>`, private `attest`, the `retain` closure at `duties.rs:317`, private `ATTESTED_SLOT_RETENTION = 4` | `attest`: absent (async); `DutyService`, `LagGate`: types body; 28 `sorry`s from `tracing` and closures | The gate itself (`contains` → skip, `insert` before effects, `retain` on the retention window) is four lines inside an async method. | **divergence** — `Validator.attestGate_rejects_remembered`, `attestGate_records_fired`, and `attestGate_no_double_vote_after` prove the non-overflowing source model, but `attestGate_wraparound_counterexample` checks that release-mode `u64::MAX + 4` wraps, removes the fired slot, and permits the same slot again (debug checks panic). Direct extraction is also blocked by async/tracing. |
| `Xmss.SecretKey`, `Scheme.preparedEnd`, `advancePreparation`, `advancePreparation_monotone` (VAL-5) | `verity_crypto::key::SecretKey::{prepared_interval, advance_preparation, advance_preparation_to}` | body (all three, including the `return`-inside-`loop` in `advance_preparation_to`); only `Debug::fmt` is `sorry` | The window arithmetic Lean proves monotone is inside leanSig, which Aeneas sees as opaque axioms (`XmssSecretKey` methods). | **blocked** — the fixed artifact has no key module; temporary extraction also has a `key.SecretKey` type/constructor name clash and declares leanSig preparation methods as axioms. Unblocking requires the name fix plus independently verified models for pinned leanSig commit `15cbdd43`; assuming monotonicity would be circular. |
| `Validator/Service.attestationDue` | `DutyService::serves_duties` / private `LagGate::admits` | absent / sorry | Different rule: Lean gates on `synced`; Verity gates on lag hysteresis and a network-stall threshold. | **divergence** — `Validator.dutyGate_allows_unsynced_counterexample` and `dutyGate_denies_synced_counterexample` check disagreement in both directions in `proofs/VerityChain/ValidatorSync.lean`. |
| `sign` / `verify` (not catalogued; the signature boundary) | `verity_crypto::signature::{sign, verify}` | body, as calls to leanSig axioms | The scheme is opaque to Aeneas, so nothing about signatures is provable about Verity alone | **blocked** — Aeneas exposes only leanSig call axioms; an independently verified sign/verify contract for the pinned external implementation is required before any implementation theorem. |

### Networking (NET-1, NET-2)

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `Networking.Config`: `MAX_REQUEST_BLOCKS = 2^10`, `MAX_PAYLOAD_SIZE = 10 MiB`, `MIN_SLOTS_FOR_BLOCK_REQUESTS = 3600` | `verity_p2p::config` (same three values); `verity_db::retention::MIN_SLOTS_FOR_BLOCK_REQUESTS` (duplicate) | body | Rust also has `MAX_ERROR_MESSAGE_SIZE`, `RESP_TIMEOUT`, `MESSAGE_DOMAIN_*` with no Lean counterpart | **proved** — `maxRequestBlocks_eq`, `maxPayloadSize_eq`, and `minSlotsForBlockRequests_eq` in `proofs/VerityP2P/Correspondence.lean` check the three shared pinned-source literals; Verity-only constants are outside the comparison. |
| `BlocksByRangeRequest {startSlot, count}`, `ResponseCode` (4 constructors) | `verity_p2p::reqresp::messages::{BlocksByRangeRequest, ErrorCode (3 variants) + RESPONSE_CODE_SUCCESS}`, `ErrorCode::{as_byte, from_byte}` | `structure`/`inductive`: body; `as_byte`, `from_byte`: body; derived `Eq` on the request: sorry | Lean folds `success` into the enum; Rust keeps it as a byte constant. `from_byte`'s range classification is `4..=127 → ServerError`, `128..=255 → InvalidRequest`. | **partial** — `errorCode_fromByte_eq`, `errorCode_fromByte_server_range`, and `errorCode_fromByte_invalid_range` prove exact behavior of a source-faithful pure model for all bytes. The request container and direct Aeneas method are absent from the fixed artifact; selecting the containing module triggers unrelated late-bound-region failures, so implementation-level naming remains blocked. |
| `handleBlocksByRange`, `blocks_by_range_bounded` (NET-1) | `verity_node::sync::responder::serve_range` (private; not in the surveyed crates) with `verity_db::retention::{can_serve_range, range_service_floor}` | not run (`verity-node`); `can_serve_range`, `range_service_floor`: body | The Lean function takes a lookup closure and returns `Except`; Rust reads through `Repository<B>`. NET-1's bound (`resp.length ≤ min count MAX_REQUEST_BLOCKS`) needs both the count gate and an iterator contract. | **blocked** — private generic `serve_range` is outside the fixed extraction. Unblocking requires an extracted pure boundary plus a `Repository::canonical_range` contract proving at most one result per half-open slot range; the count check alone is insufficient. |
| `readRequest`, `payload_size_bound` (NET-2), `compressed_size_bound` | `verity_p2p::wire::snappy::{decompress_block(max), read_framed}`, private `reqresp::codec::read_chunk_payload` | absent (async, and `decompress_block` behind `Box<dyn Error>` conversions) | The size checks are the same shape for the declared uncompressed length, but compressed allocation formulas differ. | **divergence** — the implementation payload theorem remains blocked because async `read_chunk_payload`/`read_framed` are absent; moreover `formalReader_accepts_above_verity_bound` is a checked model counterexample at declared length zero (33 bytes accepted by formal-leanSpec versus Verity's bound 32). Thus exact NET-2 reader correspondence is false even though its uncompressed-size claim is source-aligned. |
| `Allocation.varintSize`, `MAX_LENGTH_PREFIX_SIZE = 4`, `varintSize_le_prefix_bound` | `verity_p2p::wire::varint::{write_varint, read_varint, decode_varint}`, `MAX_VARINT_LEN = 10` | `write_varint`: body (with its `return` inside `loop`); `decode_varint`: sorry; `read_varint`: absent (async) | Lean proves a 4-byte prefix suffices for payloads ≤ 10 MiB; Rust accepts up to 10 bytes (the LEB128 maximum for `u64`). Consistent, not identical. | **partial** — `writeVarint_length` proves exact `varintSize value.toNat` output length for every `UInt64` in a source-faithful pure model. The fixed artifact has no P2P generated function, so direct extracted-function equality is not claimed. |
| `Allocation.MAX_COMPRESSED_PAYLOAD_SIZE = MAX_PAYLOAD_SIZE + MAX_PAYLOAD_SIZE / 6 + 1024` | `verity_p2p::config::max_compressed_len(u) = 32 + u + u / 6` | body | **Formulas differ.** Both bound snappy output; Rust's is the library's documented `max_compress_len`, Lean's adds 1024 slack. At 10 MiB Lean allows 992 bytes more. | **divergence** — `compressedBound_relation` proves the uniform 992-byte difference and `compressedBound_at_max_counterexample` checks `12,233,418 ≠ 12,234,410`; equality requires changing one side, which is outside this repository. |

### Storage (STOR-1, STOR-2)

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `Storage.insertBlock` (parent-gated), `parentsPresent_insertBlock`, `parent_exists_or_genesis` (STOR-1) | the `UnknownParentBlock` check in `fork_choice::block::on_block_observed`; `verity_db::writer::check_block` (`ParentMismatch`) | `on_block_observed`: crash; `check_block`: sorry (its `Display`-bearing error path) | Lean states the gate on the store; Verity has it twice, once in memory and once at commit | **blocked** — neither gate is in the fixed artifact; fork choice crashes on `Iterator`, while `check_block` is refused through its error/Display path. Unblocking requires one complete gate body plus a Store/database representation relation. |
| `insertBlock_slot_gap_bounded` (#1171: gap ≤ `HISTORICAL_ROOTS_LIMIT`) | the `BlockSlotGapTooLarge` check in `on_block_observed` | crash | Same bound | **blocked** — the check is trapped in the same absent/crashing `on_block_observed`; fixing the iterator extraction and approving that generated body is the exact prerequisite. |
| `Database`, `Write`, `batchWrite`, `batch_write_commits`, `batch_atomic` (STOR-2) | `verity_db::backend::{WriteBatch, Op, StorageBackend::write}`, `Repository::commit`; `MemoryBackend::write` (sequential `apply`), `RocksBackend::write` (RocksDB `WriteBatch`) | crash (`backend`; the `BTreeMap` range iterators) | Lean's `batchWrite` is all-or-nothing by construction; `MemoryBackend` applies ops one by one with no failure path, `RocksBackend` delegates atomicity to RocksDB. | **blocked** — the fixed artifact has no backend symbols and Aeneas crashes on BTreeMap range iterators. Memory needs a finite-map iterator model; RocksDB atomicity additionally remains an external stable-contract assumption. |
| `Database.get?`, `put`, `get?_put_self`, `get?_put_ne` | `StorageReader::get`, `MemoryBackend::apply` (`Op::Put`) | crash | Same module | **blocked** — these functions are absent with the backend crash; unblocking requires the same BTreeMap model and an approved backend extraction. |
| `votePrecedence` (fork choice, used by `Weights`) | `verity_db::votes::replaces(candidate, stored)` | body | Newer slot wins, tie broken by larger `hash_tree_root`; Rust's replacement relation is strict, while the Lean sorting comparator is non-strict | **divergence** — `ForkChoice.voteReplaces_newer`, `voteReplaces_older`, and `voteReplaces_tie` give the strongest branch-wise relation for a source-faithful pure model; `votePrecedence_self_counterexample` checks that replacing a vote with itself is false in Verity but true for Lean's reflexive comparator. See `proofs/VerityChain/ForkChoiceStorage.lean`. |
| — | `verity_db::writer::{canonical_switch, ancestry_to_canonical, queue_canonical_switch, queue_vote_merge, commit_tick, record_pending_votes}`, `retention::{prune_block_proofs, vote_is_relevant, descends_from}`, `key::*`, `schema::Identity`, `column::ColumnFamily` | body (the `&'static str` helpers and `ssz_schema_digest` are `sorry`) | No Lean counterpart; the catalog models storage as a key-value list and nothing more. These extract but have nothing to be related to | **no-counterpart** — the searched formal-leanSpec storage boundary has no matching definitions or behavior. |

### Sync (SYNC-1, SYNC-2)

Both Verity items live in `verity-node` (`src/sync/state.rs`). A focused extraction reproduces
mixed tracing/dynamic-trait failures, so checked results use the source-faithful pure model in
`proofs/VerityChain/ValidatorSync.lean`.

| formal-leanSpec | Verity | Extracts | Obstacle | Final result |
|---|---|---|---|---|
| `SyncState {idle, syncing, synced}` | `verity_node::sync::state::SyncState {Idle, Syncing, Synced}` | focused extraction partial; plain enum | Verity additionally uses `Option<SyncState>` with `None` externally visible as idle. | **partial** — `Sync.visibleState` gives the explicit representation relation used by every checked sync theorem; no usable generated enum/function is in the fixed artifact. |
| `canTransitionTo` (4 rules), `transitionTo`, `transition_sound` (SYNC-1) | `SyncMachine::observe(head_slot, network_finalized)` | not run; a `match` on `(Option<SyncState>, bool)` with `tracing` inside | Verity takes three of the four Lean transitions (`idle→syncing`, `syncing→synced`, `synced→syncing`) and never returns to `idle`, but method results include active-state stutters. | **partial** — `Sync.observe_stutter_or_transition` proves the strongest valid refinement and `observe_initial_ne_synced` excludes the forbidden shortcut. `syncing_stutter_counterexample` and `synced_stutter_counterexample` refute unconditional `transition_sound` because formal `canTransitionTo` has no active self-edge. |
| `acceptsGossip`, `accepts_gossip_iff` (SYNC-2) | network bridge forwarding behavior | absent | **Verity does not gate gossip on the sync state.** `verity_node::network` forwards every `NetworkEvent::Gossip`; the `synced` watch gates validator duties instead. | **divergence** — `Sync.gossipGate_idle_counterexample` checks the idle witness: Verity's source-faithful model attempts forwarding while formal-leanSpec rejects gossip. Queue saturation is state-independent and does not restore equivalence. |

## Catalog proposition accounting

The objective's 34 propositions are the catalog's 34 `[x]` theorem entries. Each has exactly
one implementation-correspondence status below. The additional `[axiom]` entry SSZ-7 is
accounted for separately after the table; it is not one of the 34 proved catalog entries.

| ID | Final status | Evidence or exact boundary |
|---|---|---|
| SSZ-1 | **no-counterpart** | Verity delegates primitive Boolean SSZ coding to external `libssz`; no Verity-owned function exists. |
| SSZ-2 | **partial** | `verityUint64_range` transports the range property through `toLeanUint64`; the tuple-newtype root extraction still fails. |
| SSZ-3 | **blocked** | Aeneas exits 1 on the `Slot`/`ValidatorIndex`/`SubnetId`/`Interval` type-constructor name clashes, so encode/decode cannot be named against fixed output. |
| SSZ-4 | **proved** | `toLeanBytes32_size` in `proofs/VerityChain/PrimitiveCorrespondence.lean`. |
| SSZ-5 | **no-counterpart** | The implementation is external `libssz_types::SszVector`, outside Verity's owned boundary. |
| SSZ-6 | **no-counterpart** | Verity has no power-of-two-ceiling helper; merkleization ends at external `libssz_merkle`. |
| CONT-1 | **proved** | `checkpointOrder_iff_slotOrder` plus `advanceCheckpoint_refines`. |
| CONT-2 | **proved** | `isJustifiableAfter_eq`, `isJustifiableAfter_iff`, and `isJustifiableAfter_before_finalized`. |
| ST-1 | **blocked** | Fixed output omits `process_slots`; focused temporary output is viable but requires an approved artifact update and loop/clone reasoning. |
| ST-2 | **blocked** | Fixed output omits `process_block_header`; successful correspondence additionally needs state/block conversions, Merkle relations, and the SSZ-list capacity-error arm. |
| ST-3 | **blocked** | Requires complete transition correspondence; attestation dedup and `BTreeMap` bodies are refused. |
| ST-4 | **blocked** | Requires a cross-language reachable-state relation after complete transition correspondence. |
| ST-5 | **blocked** | Fixed output has no `state_transition`; reflexivity is immediate only after an approved extraction and does not justify opaque attestation semantics. |
| ST-6 | **blocked** | Same transition and attestation prerequisites as ST-3. |
| ST-7 | **blocked** | Strict checkpoint-forward transport depends on the refused attestation semantics and state relation. |
| FC-1 | **blocked** | `update_head` is absent after Aeneas's `Iterator` signature crash; Store/map relations are also required. |
| FC-2 | **blocked** | Needs extracted ancestry walks and a proved Store map relation after the same crash is fixed. |
| FC-3 | **blocked** | `validate_attestation` has no generated body because the module-wide `Iterator` crash aborts output. |
| FC-4 | **blocked** | No extracted Store/parent walk and no Rust `WellFormed` mirror exist. |
| FC-5 | **blocked** | `candidateEligible_eq` proves a supporting helper, but Aeneas refuses the catalog's `select_votes` loop due to a return inside a nested loop. |
| FC-6 | **blocked** | Depends on absent `update_head`, Store invariants, ancestry, and finite-map semantics. |
| FC-7 | **blocked** | Depends on absent `on_block_observed`, the ST bridge, and Store alignment relations. |
| FC-8 | **blocked** | History alignment remains gated on header/attestation extraction and the quorum-level descent assumption. |
| VAL-1 | **proved** | `proposerForSlot_roundRobin` transports the extracted successful branch. |
| VAL-2 | **partial** | `Validator.declaredRoleGate_isSome_iff` and `declaredRoleGate_distinct` prove the pure load-time equality gate; filesystem/key decoding remains outside the extracted boundary. |
| VAL-3 | **proved** | `proposerForSlot_uniqueOutput` and `proposerForSlot_unique`. |
| VAL-4 | **divergence** | Non-overflowing gate safety is proved, but `Validator.attestGate_wraparound_counterexample` checks repeat admission at `u64::MAX` under release wrapping. |
| VAL-5 | **blocked** | Aeneas has a `SecretKey` name clash and leanSig preparation methods remain unconstrained external axioms. |
| NET-1 | **blocked** | Private generic `serve_range` is outside fixed extraction and needs a repository iterator cardinality contract. |
| NET-2 | **blocked** | The catalog's uncompressed payload bound is source-aligned but async reader functions are absent; the stronger exact compressed-reader relation separately diverges by `formalReader_accepts_above_verity_bound`. |
| STOR-1 | **blocked** | Both parent gates are absent/refused; extraction plus a Store/database representation relation is required. |
| STOR-2 | **blocked** | Backend extraction crashes on `BTreeMap` iterators; RocksDB atomicity also requires its stable external contract. |
| SYNC-1 | **partial** | `Sync.observe_stutter_or_transition` is the strongest relation; two checked self-edge counterexamples refute unconditional `transition_sound`. |
| SYNC-2 | **divergence** | `Sync.gossipGate_idle_counterexample` checks forwarding-at-idle against formal rejection. |

**SSZ-7 trust boundary (catalog `[axiom]`).** `hashTreeRoot_forwards` proves only that the
extracted wrapper delegates to its hash-tree-root operation. It deliberately does not prove
collision resistance. Its axiom audit exposes Aeneas's external SHA-256 hash operation;
formal-leanSpec's separate `HashTreeRoot.collisionResistance` remains a cryptographic
assumption.

## Divergences worth acting on

Found while aligning the two sides. None is an extraction concern; each is a place where the
Rust and the Lean say different things, which is what a correspondence table exists to surface.

1. **`MultiMessageAggregate` field name.** formal-leanSpec spells it `payload`; leanSpec
   (`08e1481a`) and Verity spell it `proof`. Report to formal-leanSpec.
2. **Compressed-size bound.** `verity_p2p::config::max_compressed_len` and formal-leanSpec's
   `MAX_COMPRESSED_PAYLOAD_SIZE` use different formulas (32 + n + n/6 versus n + n/6 + 1024).
   Neither is from leanSpec. Pick one.
3. **Gossip is not gated by sync state.** SYNC-2 says gossip is accepted only in
   `syncing`/`synced`; Verity accepts it in every state. `Idle` lasts only until the first peer
   status, so the window is small, but the property is unprovable as things stand.
4. **`RejectionReason` is a superset of `STError`** by four variants, and three names differ.
   Any refinement of the state transition has to map errors, not equate them.
5. **Duty and duplicate-gate boundaries.** Lean's `attestationDue` gates on `synced`; Verity's
   `LagGate` uses lag hysteresis and a stall threshold, with checked disagreement in both
   directions. Separately, VAL-4 holds for the non-overflowing duplicate gate but fails at
   `u64::MAX` under release wrapping (`attested + 4`).

## What this settles

- **Checked correspondences now cover every proof-ready fixed-input boundary.** These include
  SSZ range/length/delegation, error refinement, CONT-1/CONT-2, VAL-1/VAL-3, justification
  index, slot-clock/config arithmetic, candidate eligibility, vote replacement, response
  codes, varint length, networking constants, validator gates, and sync refinement.
- **Literal equality was not forced.** Checked weaker results retain `usize` and `u64`
  overflow preconditions; vote precedence, compressed bounds, duty scheduling, VAL-4 at
  `u64::MAX`, sync self-edges, and gossip-at-idle have concrete Lean counterexamples.
- **State transition is extractable only outside the fixed artifact.** Focused temporary output
  builds for genesis, slots, header, composition, and purity when attestation processing is
  opaque. Full output has two refused attestation bodies plus incompatible iterator methods;
  therefore no invariant is transported across an assumed attestation relation.
- **Fork choice and storage have reproducible extraction blockers.** Aeneas's uncaught
  `Iterator` signature failure prevents generated Store/backend bodies; finite-map and external
  RocksDB contracts remain semantic prerequisites even after that tool failure is fixed.
- **The remaining trust boundaries are explicit.** Source-faithful pure models are identified
  as models rather than generated functions, leanSig/libssz/RocksDB operations need stable
  external contracts, and the only nonstandard axiom in a checked implementation theorem is
  Aeneas's external SHA-256 hash operation used by delegation—not collision resistance.
- **Nothing here changes the architecture.** formal-leanSpec remains the executable formal
  specification; these proofs measure and narrow the implementation correspondence boundary.

## Appendix A: reproduction

Tools are the ones `cargo hax tools install` (cargo-hax 0.4.0) places under
`~/.cache/hax/tools`. From a checkout at `dff96ac`:

```sh
CHARON=~/.cache/hax/tools/charon/nightly-2026.09.02/charon
AENEAS=~/.cache/hax/tools/aeneas/nightly-2026.09.03-6852e64/aeneas
cd crates/verity-chain
systemd-run --user --scope -p MemoryMax=16G \
  "$CHARON" cargo --preset=aeneas --dest-file /tmp/out.llbc --start-from verity_chain::justification
systemd-run --user --scope -p MemoryMax=40G \
  "$AENEAS" -backend lean -dest /tmp/out -split-files /tmp/out.llbc
```

Substitute the crate directory and `<crate>::<module>` for each row of the results table.

- **Always cap Charon.** Uncapped, `--start-from verity_types::state` (and `verity_db::{diff,
  read, reconstruct}`) grows past physical memory and the kernel OOM killer takes unrelated
  processes with it. With `MemoryMax` the kill stays inside the scope and the module is simply
  recorded as `oom`.
- **Run Aeneas one module per invocation.** A crate-wide `--start-from` list is not a
  shortcut: one crashing module (`fork_choice`) aborts Aeneas before it writes anything for the
  others.
- Charon builds through cargo, so parallel Charon runs serialize on the build-directory lock;
  Aeneas runs are independent but each can need well over 12 GB, so five in parallel on a 60 GB
  host is the practical ceiling. Charon's own compile of `verity-crypto` and `verity-p2p` pulls
  leanVM/Plonky3 and libp2p respectively and takes several minutes each on first run.
- Aeneas leaves refused bodies as `def … := do sorry`, so `grep -c '^  sorry' Funs.lean` is the
  per-module refusal count, and the `[Error] … Source:` lines in its log name the Rust item.

## Appendix B: refusal log excerpts

Charon killed at the cap (uncapped it reached 55 GB resident, 39.7 GB swap):

```text
verity-aeneas-survey.scope: The kernel OOM killer killed some processes in this unit.
verity-aeneas-survey.scope: Failed with result 'oom-kill'.
Mem peak: 55G (swap: 39.7G)
```

Charon panic on `verity_p2p::{behaviour, service}`:

```text
thread 'main' panicked at src/ast/krate.rs:143:41:
called `Option::unwrap()` on a `None` value
ERROR Compilation panicked
```

Aeneas crash on `verity_chain::fork_choice` (also `view`, `verity_validator::aggregation`,
`verity_db::backend`):

```text
[Error] Internal error, please file an issue
Source: '/rustc/library/core/src/iter/traits/iterator.rs', lines 42:0-42:24
Uncaught exception:
  Aeneas.Errors.CFailure(_)
Called from Aeneas__SymbolicToPureTypes.translate_fun_sigs in file "symbolic/SymbolicToPureTypes.ml"
Called from Aeneas__Translate.translate_crate_to_pure.translate_method_sig in file "Translate.ml"
```

The two `verity_chain::state_transition` refusals:

```text
[Error] Can't end abstraction 4 as it is set as non-endable
Source: 'crates/verity-chain/src/state_transition/attestations.rs', lines 70:13-70:44
[Error] Internal error, please file an issue
Source: 'crates/verity-chain/src/state_transition/attestations.rs', lines 117:4-139:5
```

`libssz` derive decode helper (every container module):

```text
[Error] Unimplemented: found an occurrence of a lifetime constraint relating
         a higher-ranked lifetime to a free lifetime.
Source: 'crates/verity-types/src/checkpoint.rs', lines 12:70-12:79
```

Tuple-struct newtype as a root item:

```text
[Error] Name clash detected: the following identifiers are bound to the same name "primitives.Slot"
- type name: verity_types::primitives::Slot
  Source: 'crates/verity-types/src/primitives.rs', lines 26:8-26:34
```

`&'static str` return and `Display`:

```text
[Error] There should be no bottoms in the value
Source: 'crates/verity-chain/src/error.rs', lines 101:4-137:5
[Error] Unreachable
Source: 'crates/verity-chain/src/error.rs', lines 142:28-142:41
```

`Box<dyn Error>` and async cascades:

```text
[Error] Dynamic trait types are not supported yet
Source: '/rustc/library/alloc/src/io/error.rs', lines 42:4-44:53
[Error] Could not lookup the translated function, probably because of an error which happened before
Source: '/cargo/registry/src/index.crates.io-…/tracing-0.1.44/src/macros.rs', lines 902:13-914:13
```
