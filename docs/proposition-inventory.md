---
title: Public Proposition Inventory
last_updated: 2026-10-01
tags:
  - correspondence
  - formal-verification
  - lean
  - propositions
  - verity
---

# Public Proposition Inventory

This inventory groups every public theorem audited by `proofs/AxiomAudit.lean` into a semantic proposition. It covers the theorems that exist in this repository; it does not list blocked or planned obligations from the wider 34-proposition formal-leanSpec catalog.

The grouping is intentionally not one theorem per formal-leanSpec proposition. A semantic proposition may need several conversion, implementation-characterization, refinement, and boundary theorems. Conversely, one Verity function may support more than one formal proposition.

## Classification

- **Correspondence propositions** state a relationship with a formal-leanSpec type, definition, theorem, constant, or behavior. Equality is not required: refinements, explicit differences, and counterexamples are correspondence results.
- **Verity-specific propositions** state a property of the extracted Verity semantics or an explicit source-faithful Verity model without requiring a protocol-level counterpart in their conclusion.
- **Aeneas** evidence targets checked-in generated definitions or their fixed external models.
- **Pure model** evidence targets a handwritten, source-faithful model because the implementation boundary is not available as usable checked-in Aeneas output.
- **Mixed** evidence combines generated definitions with pinned-source transcriptions or handwritten representation relations.

The theorem names below omit these namespace prefixes:

- `VC`: `verity_chain.correspondence`
- `VS`: `verity_chain.correspondence.validator_sync`
- `P2P`: `verity_p2p.correspondence`

## Correspondence propositions

| ID | Semantic proposition | formal-leanSpec anchor | Evidence basis | Public Lean theorems |
|---|---|---|---|---|
| CORR-01 | Aeneas `u64`, slot, and checkpoint values preserve their mathematical values, ordering, and fields under the explicit LeanSpec conversions. | `SSZ.Uint64`, `Slot`, `Checkpoint` | Aeneas + conversion | `VC.toLeanUint64_toNat`, `VC.toLeanSlot_toNat`, `VC.toLeanSlot_lt_iff`, `VC.toLeanCheckpoint_root`, `VC.toLeanCheckpoint_slot`, `VC.checkpointOrder_iff_slotOrder` |
| CORR-02 | Converted Verity `u64` values satisfy the formal Uint64 range, and converted Rust `[u8; 32]` values satisfy the formal Bytes32 length. | SSZ-2, SSZ-4 | Aeneas + conversion | `VC.verityUint64_range`, `VC.toLeanBytes32_size` |
| CORR-03 | Verity's extracted justifiability predicate agrees with formal-leanSpec after the finalized boundary and transfers the immediate/square/pronic characterization. | CONT-2 | Aeneas | `VC.isPerfectSquare_eq`, `VC.isJustifiableAfter_eq`, `VC.isJustifiableAfter_iff` |
| CORR-04 | A successful Verity proposer selection is the formal round-robin proposer and represents the unique in-registry proposer. | VAL-1, VAL-3 | Aeneas | `VC.proposerForSlot_roundRobin`, `VC.proposerForSlot_unique` |
| CORR-05 | Verity checkpoint advancement agrees with formal `Checkpoint.advanceTo`, including tie behavior. | CONT-1 support | Aeneas | `VC.advanceCheckpoint_corresponds`, `VC.advanceCheckpoint_refines` |
| CORR-06 | Verity and formal-leanSpec use the same immediate-justification window. | CONT-2 support | Aeneas | `VC.immediateJustificationWindow_corresponds` |
| CORR-07 | Verity's successful justification index equals formal `Slot.justifiedIndexAfter` after converting a fitting platform `usize` to `Nat`. | `Slot.justifiedIndexAfter` | Aeneas | `VC.justifiedIndexAfter_corresponds`, `VC.justifiedIndexAfter_refines` |
| CORR-08 | Verity's successful slot-clock multiplication equals formal `Interval.fromSlot` when the `u64` product is in range. | `Interval.fromSlot` | Aeneas | `VC.intervalsAtSlotStart_corresponds`, `VC.intervalsAtSlotStart_refines` |
| CORR-09 | Shared Verity and formal-leanSpec configuration constants have equal values. | Lstar configuration | Mixed | `VC.intervalsPerSlot_corresponds`, `VC.historicalRootsLimit_corresponds`, `VC.maxAttestationsData_corresponds`, `VC.gossipDisparityIntervals_corresponds` |
| CORR-10 | Every formal state-transition error maps to the corresponding Verity rejection kind after forgetting payloads, while four Verity rejection kinds have no formal counterpart. | `STError` | Aeneas type + conversion | `VC.leanError_refines_rust`, `VC.verityOnlyErrors_have_no_lean_counterpart` |
| CORR-11 | Verity's strict vote-replacement relation and formal-leanSpec's non-strict vote precedence agree on newer/older branches, expose the exact tie relation, and disagree on self-replacement. | `Store.votePrecedence` | Pure model | `VC.ForkChoice.voteReplaces_newer`, `VC.ForkChoice.voteReplaces_older`, `VC.ForkChoice.voteReplaces_tie`, `VC.ForkChoice.votePrecedence_self_counterexample` |
| CORR-12 | The pure Verity candidate-eligibility model is definitionally equal to formal block-production eligibility. | FC-5 supporting definition | Pure model | `VC.ForkChoice.candidateEligible_eq` |
| CORR-13 | Verity's lag-based validator duty gate differs from formal `attestationDue` in both directions. | Validator duty behavior | Pure model | `VS.Validator.dutyGate_allows_unsynced_counterexample`, `VS.Validator.dutyGate_denies_synced_counterexample` |
| CORR-14 | Verity sync observation is a stuttering refinement of the formal transition relation; active self-edges and idle gossip expose the exact differences. | SYNC-1, SYNC-2 | Pure model | `VS.Sync.observe_stutter_or_transition`, `VS.Sync.syncing_stutter_counterexample`, `VS.Sync.synced_stutter_counterexample`, `VS.Sync.gossipGate_idle_counterexample` |
| CORR-15 | Verity response-byte decoding agrees with the formal four-constructor response-code view. | Networking response codes | Pure model | `P2P.errorCode_fromByte_eq` |
| CORR-16 | Verity's `u64` varint writer emits exactly formal `varintSize` bytes. | NET-2 allocation support | Pure model | `P2P.writeVarint_length` |
| CORR-17 | Verity and formal-leanSpec share the request-block, payload-size, and history-window constants. | Networking configuration | Pure model | `P2P.maxRequestBlocks_eq`, `P2P.maxPayloadSize_eq`, `P2P.minSlotsForBlockRequests_eq` |
| CORR-18 | The two compressed-size formulas have a fixed difference, differ at the common maximum, and admit a concrete reader-level counterexample to exact correspondence. | NET-2 | Pure model | `P2P.compressedBound_relation`, `P2P.compressedBound_at_max_counterexample`, `P2P.formalReader_accepts_above_verity_bound` |

## Verity-specific propositions

| ID | Semantic proposition | Verity obligation | Evidence basis | Public Lean theorems |
|---|---|---|---|---|
| LOCAL-01 | The Aeneas finite-width scalar operations used by the extracted proofs have the stated natural-number values and succeed under their explicit nonzero or no-overflow conditions. | Arithmetic bridge soundness | Aeneas model | `VC.u64Difference_val`, `VC.u64_sub_eq`, `VC.u64Remainder_val`, `VC.u64_rem_eq`, `VC.u64_mul_eq`, `VC.u128RemainderTwo_val`, `VC.u128_rem_two_eq`, `VC.u128RemainderTwo_eq_one_iff`, `VC.u128_add_eq`, `VC.u128_mul_eq` |
| LOCAL-02 | Verity rejects a candidate slot before the finalized boundary as not justifiable. | Justification boundary behavior | Aeneas | `VC.isJustifiableAfter_before_finalized` |
| LOCAL-03 | Verity returns the empty-registry error at zero; otherwise the extracted proposer result is the remainder and is unique. | Proposer branch behavior | Aeneas | `VC.proposerForSlot_zero`, `VC.proposerForSlot_eq`, `VC.proposerForSlot_uniqueOutput` |
| LOCAL-04 | The extracted checkpoint advancement computes the later-by-slot selection and retains the current checkpoint on ties. | Checkpoint implementation behavior | Aeneas | `VC.advanceCheckpoint_eq` |
| LOCAL-05 | The extracted justification-index implementation exactly computes its optional finite-width result, and the `usize` cast preserves the mathematical index when it fits. | Justification-index implementation behavior | Aeneas | `VC.justifiedIndexValue_val`, `VC.justifiedIndexAfter_eq` |
| LOCAL-06 | The extracted slot-clock multiplication succeeds with the expected interval value whenever the product fits in `u64`. | Slot-clock checked arithmetic | Aeneas | `VC.intervalsAtSlotStart_eq` |
| LOCAL-07 | Verity's slot-duration constants satisfy `milliseconds per slot = intervals per slot × milliseconds per interval`. | Configuration consistency | Pinned-source transcription | `VC.millisecondsConfig_arithmetic` |
| LOCAL-08 | An absent stored vote is replaceable under Verity's vote-replacement rule. | Vote-store initialization behavior | Pure model | `VC.ForkChoice.voteReplacesModel_none` |
| LOCAL-09 | Verity's extracted Merkle wrapper forwards its input unchanged to the configured Rust hash-tree-root trait operation. | External hash delegation | Aeneas + external contract | `VC.hashTreeRoot_forwards` |
| LOCAL-10 | Verity's validator-key loading gate accepts exactly distinct role keys, and every returned pair has distinct keys. | Proposal/attestation key separation | Pure model | `VS.Validator.declaredRoleGate_isSome_iff`, `VS.Validator.declaredRoleGate_distinct` |
| LOCAL-11 | A remembered attestation slot is rejected; a successful non-overflowing gate records the slot and prevents the next duplicate, while release-mode `u64` wraparound gives a concrete counterexample to the unconditional claim. | Duplicate-vote gate safety and boundary | Pure model | `VS.Validator.attestGate_rejects_remembered`, `VS.Validator.attestGate_records_fired`, `VS.Validator.attestGate_no_double_vote_after`, `VS.Validator.attestGate_wraparound_counterexample` |
| LOCAL-12 | Verity's initial sync observation never jumps directly to `synced`. | Sync initialization safety | Pure model | `VS.Sync.observe_initial_ne_synced` |
| LOCAL-13 | Unknown response bytes are classified as server errors for 4–127 and invalid requests for 128–255. | Wire response-code classification | Pure model | `P2P.errorCode_fromByte_server_range`, `P2P.errorCode_fromByte_invalid_range` |

## Audit boundary

`proofs/AxiomAudit.lean` is the source of truth for the public theorem set. It imports both proof roots and runs `#print axioms` for every theorem named above. `scripts/verify.sh` additionally rejects handwritten `sorry` and `admit`, builds every Lean target, and verifies that every public correspondence theorem appears in the audit.

Pure-model propositions prove the behavior of the named model, not automatically the corresponding Rust function. Their source relationship and extraction boundary are documented in the domain reports and in [the correspondence survey](correspondence-survey.md).
