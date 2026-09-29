---
title: Validator and Sync Correspondence
last_updated: 2026-09-29
tags:
  - correspondence
  - lean
  - validator
  - sync
---

# Validator and Sync Correspondence

## Fixed inputs

- Verity: `a9f3365151a28784277ef31b89aa0092656d4f88`
- formal-leanSpec: `ba7284513031eac5c66bfb8221d27b6154cf240b`
- cargo-hax `0.4.0`, Charon `nightly-2026.09.02`, Aeneas
  `nightly-2026.09.03-6852e64`
- Checked-in `generated/` is unchanged. The focused extraction reproductions below wrote only
  to `/tmp/validator-sync-extraction`.

The checked pure models and proofs are in `VerityChain.ValidatorSync`. They cover only logic
visible in the pinned source; filesystem I/O, async channels, and external cryptography are not
modeled as pure functions.

## Classification

| Item | Classification | Checked evidence | Boundary |
|---|---|---|---|
| VAL-2 | **Pure gate proved; end-to-end correspondence blocked** | `declaredRoleGate_isSome_iff`, `declaredRoleGate_distinct` prove the exact equality branch at `keystore.rs:130` accepts only distinct decoded public keys. | `load` also performs YAML/filesystem reads, hex decoding, public-key parsing, and opaque secret-key decoding. No theorem identifies the model with an extracted Rust function. |
| VAL-4 | **Safety proved for the source-faithful non-overflowing gate model; direct extraction blocked** | `attestGate_rejects_remembered`, `attestGate_records_fired`, and `attestGate_no_double_vote_after` model `duties.rs:287-294`: contains, insert-before-effects, then retain. | Rust uses `u64` addition in the retain closure; the model is the exact arithmetic path while `slot + 4` does not overflow. The enclosing function is async and absent from usable extraction. |
| VAL-5 | **Blocked** | The wrapper bodies call leanSig's `get_prepared_interval` and `advance_preparation`, but the generated template declares both as axioms. The formal theorem therefore cannot be transferred without assuming the desired external semantics. | The pinned key extraction is partial and reports the `key.SecretKey` type/constructor name clash; even after that, leanSig methods require verified external models. |
| SYNC-1 | **Stuttering refinement proved; unconditional `transition_sound` correspondence refuted** | `observe_stutter_or_transition` proves every result is either unchanged or a formal permitted transition. `observe_initial_ne_synced` proves no idle-to-synced shortcut. | `syncing_stutter_counterexample` and `synced_stutter_counterexample` show Verity returns active-state self transitions, while formal `canTransitionTo` has neither self edge. |
| SYNC-2 | **Semantic divergence** | `gossipGate_idle_counterexample` proves the idle witness: the source-faithful model attempts forwarding, while formal `acceptsGossip idle = false`. | `network.rs:119` routes every `NetworkEvent::Gossip` to `forward`; `network.rs:162` has no sync-state input. Queue saturation may drop independently, but there is no sync gate. |

## Concrete duty-gate divergence

Verity does not use formal-leanSpec's Boolean `synced` input for validator duties. Its
`LagGate::admits` at `duties.rs:376-402` uses head lag, maximum-seen lag, hysteresis, and a
network-stall override. The pure transcription proves both directions of disagreement:

- `dutyGate_allows_unsynced_counterexample`: `(slot, head, maxSeen) = (0, 0, 0)` is admitted by
  Verity from an open gate, while formal `attestationDue` is false for `synced = false`.
- `dutyGate_denies_synced_counterexample`: `(9, 0, 9)` is denied by Verity from an open gate,
  while formal `attestationDue` is true for interval 1, an empty history, and `synced = true`.

This divergence does not invalidate VAL-4's duplicate-slot safety property; it invalidates an
equality claim between the two systems' complete duty predicates.

## SYNC-1 edge accounting

The pure `observe` model transcribes `sync/state.rs:72-96`, including internal `None` as visible
`Idle` and `network_finalized = None` as no state update. The non-stuttering edges are exactly
`idle → syncing`, `syncing → synced`, and `synced → syncing`. The unchanged match arms also
return `syncing → syncing` and `synced → synced`; those are method results but are not members
of formal `canTransitionTo`. Thus the strongest valid statement is
`next = current ∨ canTransitionTo current next`, not unconditional transition soundness.

## Reproducible extraction blockers

Run from the pinned Verity checkout, with outputs outside this repository:

```sh
CHARON="$HOME/.cache/hax/tools/charon/nightly-2026.09.02/charon"
AENEAS="$HOME/.cache/hax/tools/aeneas/nightly-2026.09.03-6852e64/aeneas"
OUT=/tmp/validator-sync-extraction
mkdir -p "$OUT"

cd crates/verity-crypto
systemd-run --user --scope -p MemoryMax=16G "$CHARON" cargo --preset=aeneas \
  --dest-file "$OUT/keystore.llbc" --start-from verity_crypto::keystore
"$AENEAS" -backend lean -dest "$OUT/keystore-lean" -split-files "$OUT/keystore.llbc"
# Fails in translate_fun_sigs: Unimplemented, core/src/str/pattern.rs.

systemd-run --user --scope -p MemoryMax=16G "$CHARON" cargo --preset=aeneas \
  --dest-file "$OUT/key.llbc" --start-from verity_crypto::key
"$AENEAS" -backend lean -dest "$OUT/key-lean" -split-files "$OUT/key.llbc"
# Produces partial files: name clash for key.SecretKey. The external template
# declares leanSig get_prepared_interval and advance_preparation as axioms.

cd ../verity-validator
systemd-run --user --scope -p MemoryMax=16G "$CHARON" cargo --preset=aeneas \
  --dest-file "$OUT/duties.llbc" --start-from verity_validator::duties
"$AENEAS" -backend lean -dest "$OUT/duties-lean" -split-files "$OUT/duties.llbc"
# Produces partial files; async attest is absent, and tracing/mixed declarations
# make LagGate::admits and related bodies unusable.

cd ../verity-node
systemd-run --user --scope -p MemoryMax=16G "$CHARON" cargo --preset=aeneas \
  --dest-file "$OUT/sync-state.llbc" --start-from verity_node::sync::state
"$AENEAS" -backend lean -dest "$OUT/sync-state-lean" -split-files "$OUT/sync-state.llbc"
# Produces partial files; tracing introduces mixed declaration groups and
# dynamic trait types, and observe has no usable body.
```

## Exact unblocking actions

- **VAL-2:** move the decoded-public-key equality check into a synchronous pure helper whose
  inputs are two `PublicKey` values; keep YAML, filesystem, and hex parsing in the caller.
  Extract that helper and prove it equal to `declaredRoleGate`. Model secret-key decoding only
  if an end-to-end loader theorem, rather than dual-key safety, is required.
- **VAL-4:** move `contains`/`insert`/`retain` into a synchronous pure helper returning the
  updated set and a fire/skip verdict, call it before the async effects, and extract it. State
  an explicit `slot ≤ u64::MAX - 4` precondition or replace the addition with subtraction so
  retention semantics are total at the `u64` boundary.
- **VAL-5:** first resolve the Aeneas `SecretKey` name clash. Then extract pinned leanSig's
  preparation methods or supply handwritten external definitions plus independent proofs that
  they implement leanSig commit `15cbdd43`; merely postulating monotonicity would be circular.
- **SYNC-1:** isolate the match that computes `next` from tracing in a pure helper and extract
  it. Compare only state changes to `canTransitionTo`, or extend the formal relation with
  explicit self loops if method returns are intended to count as transitions.
- **SYNC-2:** either add a sync-state receiver and an idle check before `NetworkBridge::forward`
  (or before verification), or change formal `acceptsGossip` to describe unconditional ingress.
  An equality theorem is impossible until one side changes.

## Verification

```sh
lake build VerityChain.ValidatorSync
lake env lean /tmp/validator-sync-axioms.lean
```

The second file imports `VerityChain.ValidatorSync` and runs `#print axioms` for all theorem
names in the classification table. The concrete `decide` counterexamples report no axioms;
the remaining proofs report only Lean's foundational `propext` and, for `Finset`, `Quot.sound`.
None reports `sorryAx` or a domain-specific axiom.
