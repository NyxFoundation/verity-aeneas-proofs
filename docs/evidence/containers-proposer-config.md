---
title: Containers, Proposer, and Configuration Evidence
last_updated: 2026-10-01
tags:
  - correspondence
  - formal-leanspec
  - lean
  - verification
---

# Containers, Proposer, and Configuration Evidence

> **Document role:** Domain evidence for the corresponding entries in the [public proposition inventory](../inventory/public-propositions.md) and [correspondence survey](../inventory/correspondence-survey.md). The inventories, not this report, define the cross-domain theorem list and final classifications.

## Pinned scope

The proofs compare the checked-in `VerityChain` Aeneas extraction of Verity
`a9f3365151a28784277ef31b89aa0092656d4f88` with formal-leanSpec
`ba7284513031eac5c66bfb8221d27b6154cf240b`. The generated files remain unchanged.

## Checked results

| Area | Public theorem | Status |
|---|---|---|
| VAL zero case | `proposerForSlot_zero` | Exact `EmptyValidatorRegistry` result |
| VAL implementation | `proposerForSlot_eq` | Exact extracted `u64` remainder result for a nonempty registry |
| VAL-1 | `proposerForSlot_roundRobin` | Returned remainder converts to `ValidatorIndex.proposerForSlot` |
| VAL-3 | `proposerForSlot_uniqueOutput`, `proposerForSlot_unique` | Unique extracted output is related to formal-leanSpec's unique `Fin n` proposer |
| Checkpoint shape | `toLeanCheckpoint_root`, `toLeanCheckpoint_slot` | Both extracted fields are preserved by conversion |
| CONT-1 | `checkpointOrder_iff_slotOrder` | Converted checkpoint order is exactly slot order |
| Checkpoint advance | `advanceCheckpoint_eq`, `advanceCheckpoint_corresponds`, `advanceCheckpoint_refines` | Exact extracted selection and direct `Checkpoint.advanceTo` witness, including ties |
| CONT-2 constant | `immediateJustificationWindow_corresponds` | Extracted and formal immediate windows both equal 5 |
| Justification index | `justifiedIndexAfter_eq` | Exact extracted `Option Usize` result for every input |
| CONT index transport | `justifiedIndexAfter_corresponds`, `justifiedIndexAfter_refines` | Converted result equals `Slot.justifiedIndexAfter` when the index fits Aeneas's platform `usize` |
| Slot clock | `intervalsAtSlotStart_eq`, `intervalsAtSlotStart_corresponds`, `intervalsAtSlotStart_refines` | Checked multiplication and `Interval.fromSlot` agree when the `u64` product does not overflow |
| Configuration | `intervalsPerSlot_corresponds`, `historicalRootsLimit_corresponds`, `maxAttestationsData_corresponds`, `gossipDisparityIntervals_corresponds` | Extracted/transcribed pinned-source values equal formal-leanSpec's `5`, `2^18`, `8`, and `1` |
| Configuration arithmetic | `millisecondsConfig_arithmetic` | `4000 = 5 * 800` for the three extracted slot-duration literals |

`lake build VerityChain` passes. `#print axioms` was run for every public theorem in
`VerityChain.Correspondence`; the results contain only Lean's standard logical axioms
`propext`, `Classical.choice`, and `Quot.sound`, with no project-specific axiom and no
`sorry`/`admit` dependency.

## Necessary bounds and trust boundaries

- `justifiedIndexAfter_corresponds` requires the mathematical index to fit
  `UScalarTy.Usize.numBits`. Aeneas models `usize` as platform-dependent (32 or 64 bits),
  while formal-leanSpec uses unbounded `Nat`; the unconditional theorem
  `justifiedIndexAfter_eq` still exactly characterizes the extracted result.
- `intervalsAtSlotStart_corresponds` requires the product to fit `u64`. Verity uses checked
  Rust multiplication, while formal-leanSpec constructs a wrapping `UInt64`; claiming equality
  after extracted overflow would be false.
- `INTERVALS_PER_SLOT`, `MILLISECONDS_PER_SLOT`, `MILLISECONDS_PER_INTERVAL`,
  `HISTORICAL_ROOTS_LIMIT`, `MAX_ATTESTATIONS_DATA`, and `GOSSIP_DISPARITY_INTERVALS` enter
  `VerityChain.FunsExternal` as definitions transcribed from the pinned `verity-types` literals.
  The proofs check those stable source definitions but do not independently authenticate the
  transcription; the latter two constants are absent from the fixed generated dependency set.
- Of the requested container shapes, the fixed extraction exposes `Checkpoint` directly.
  Attestation and aggregation containers are absent from `generated/VerityChain/Types.lean`, so
  no theorem is manufactured for unavailable generated types.

## Files

- `proofs/VerityChain/Correspondence.lean`
- `docs/evidence/containers-proposer-config.md`
