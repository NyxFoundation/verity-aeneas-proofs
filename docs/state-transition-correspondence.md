---
title: State-transition correspondence status
last_updated: 2026-09-29
tags:
  - aeneas
  - correspondence
  - lean
  - state-transition
---

# State-transition correspondence status

## Scope and pinned inputs

This report evaluates ST-1 through ST-7 and the `HistoryAlignment` support lemmas without changing the fixed generated artifacts.

| Input | Revision / version |
|---|---|
| Repository base | `f3fb9b4261d8c7cc626cb817e4128d8aedb8e88f` |
| Verity | `a9f3365151a28784277ef31b89aa0092656d4f88` |
| formal-leanSpec | `ba7284513031eac5c66bfb8221d27b6154cf240b` |
| Charon | `nightly-2026.09.02` (`fea3fc68d445181cf4ce094855a43a17192a2b12`) |
| Aeneas | `nightly-2026.09.03-6852e64` |
| Lean | `leanprover/lean4:v4.31.0` |

The fixed extraction files are `generated/VerityChain/{Types,Funs,TypesExternal_Template,FunsExternal_Template}.lean`. They pass `scripts/check-artifacts.sh`, contain no `sorry`, and contain zero occurrences of `state_transition`, `generate_genesis`, `process_slots`, or `process_block_header`. Therefore no theorem in this repository can currently mention an extracted state-transition definition.

## Status by proposition

“Formal pass” means the pinned formal-leanSpec theorem builds. “Correspondence blocked” means the Rust-side symbol is absent from the fixed generated input; it does not mean that the Rust source or formal theorem is defective.

| ID | Formal theorem | Status | Strongest admissible Rust-side statement and blocker |
|---|---|---|---|
| ST-1 | `State.process_slots_advances` | **Formal pass; correspondence blocked** | For successful Rust `process_slots`, the returned state's slot should equal the target. A focused temporary extraction produces the full body, but the fixed `Funs.lean` has no symbol to state the theorem against. Whole-function equality is false: formal `processSlots` is total and hash-free, while Rust rejects non-future/oversized gaps and caches a state root. |
| ST-2 | `State.process_block_header_slot` | **Formal pass; correspondence blocked** | A successful Rust `process_block_header` constructs `latest_block_header.slot = block.slot`; the focused temporary body makes this the next viable proof. Whole-function equality is false without a hash relation because Rust validates the hashed parent and computes the body root, while formal-leanSpec substitutes the parent root and zero body root. |
| ST-3 | `State.checkpoint_monotone` | **Formal pass; transport blocked** | Transport must follow a transition correspondence. Rust attestation processing is not available as a sound buildable extracted body, so transporting monotonicity now would assume the result to be proved. |
| ST-4 | `justified_ge_finalized` over `Reachable` | **Formal pass; transport blocked** | `Reachable` is a formal meta-level closure, not a Rust function. A Rust/formal transition relation is required before defining and proving preservation for corresponding reachable states. |
| ST-5 | `State.state_transition_pure` | **Formal pass; extracted theorem blocked** | Purity of any Lean `def` is reflexive, and the focused extraction emits `state_transition.state_transition`. The fixed extraction omits it. Treating the opaque attestation boundary as semantic correspondence would be unjustified; only the noninterference/reflexivity statement is viable after an approved artifact update. |
| ST-6 | `State.finalization_irreversible` | **Formal pass; transport blocked** | This is the finalized half of ST-3 and has the same prerequisite: correspondence for the complete successful transition, including attestations. |
| ST-7 | `State.checkpoint_forward` | **Formal pass; transport blocked** | Strictly-forward root/slot replacement depends on the attestation implementation. The two failed attestation translations and missing collection models prevent transport. |

## Supporting definitions

| Definition / support | Status | Evidence |
|---|---|---|
| `State.generateGenesis` / Rust `generate_genesis` | **Formal pass; correspondence blocked** | A focused extraction emits a straight-line Rust body. Full-state equality is not the right theorem: Rust sets `body_root = hash_tree_root(empty body)`, while formal-leanSpec intentionally uses zero. The strongest future theorem is fieldwise refinement with an explicit Merkle-root relation. |
| `State.processSlots` / Rust `process_slots` | **Body viable only in temporary focused extraction** | The focused extraction builds when attestation processing is opaque. A proof may then establish successful-result slot equality and unchanged checkpoint/history fields, but cannot be committed against the fixed artifact. |
| `State.processBlockHeader` / Rust `process_block_header` | **Body viable only in temporary focused extraction** | The focused extraction builds. Successful-result header-slot equality is viable; exact state equality additionally needs SSZ-list capacity and Merkle-root relations. |
| Rust `state_transition` purity | **Definition viable only in temporary focused extraction** | Its extracted body builds with one explicit opaque `process_attestations` declaration and no `sorry`. Reflexivity does not establish semantic agreement of that opaque stage. |
| `HistoryAlignment.transition_hist` | **Formal pass; transport blocked** | Requires `process_block_header` history correspondence and an `SszList` model. |
| `HistoryAlignment.transition_hist_size` | **Formal pass; transport blocked** | Depends on `transition_hist` plus the same representation relation. |
| `HistoryAlignment.transition_justified_on_chain` | **Formal pass; transport blocked** | Depends on attestation correspondence, which is the extraction boundary below. |

## Reproduced extraction boundary

A full temporary extraction added `--start-from verity_chain::state_transition` to the pinned Charon invocation. Charon succeeded. Aeneas exited `1`, emitted partial files, and reported exactly two failed bodies:

1. `process_attestations`' deduplication closure at `state_transition/attestations.rs:55:13-55:44`: `Can't end abstraction 4 as it is set as non-endable`.
2. `JustificationState::unpack` at `state_transition/attestations.rs:102:4-124:5`: `Internal error, please file an issue`.

The result contained two `sorry` bodies. With the generated external templates installed in an isolated copy, `lake build VerityChain.Funs` also failed because Aeneas emitted methods (`count`, `zip`, `map`, `filter`, `skip`, `collect`, `all`, and `any`) that are not fields of the pinned Lean backend's `Iterator` model, together with array-`Eq` and mutable-closure shape errors. Consequently the full output is not a sound import candidate even if the two `sorry`s were tolerated.

A second temporary extraction selected only `generate_genesis`, `process_slots`, `process_block_header`, `process_block`, and `state_transition`, while marking `process_attestations` opaque. It produced zero `sorry` bodies and an isolated `lake build VerityChain.Funs` passed, but its external template necessarily contained:

```lean
axiom state_transition.attestations.process_attestations :
  verity_types.state.State →
  Slice verity_types.attestation.AggregatedAttestation →
  RustM (Result verity_types.state.State error.RejectionReason)
```

That focused output establishes that genesis, slot advancement, header processing, composition, and syntactic purity are extractable. It does not justify ST-3, ST-4, ST-6, ST-7, or justified-history transport, because the opaque function is exactly the stage that changes justification and finalization.

Temporary focused artifact hashes were:

```text
d282526e3c3cc9e5bd5de24ef33ae168b710b8458165b147691eb49c29bc106b  Funs.lean
e8a60467d247467cd200ef98e7101cd4a5b7a4842f18ba55faf5c36050ef1621  FunsExternal_Template.lean
b09c26e6b8723278c23302e8045b939262b7ca2af538c5502e4ab77836b95f37  Types.lean
6b77f70ee956c93d7a8de7c7f995f40600cf4cbc1766d1ae3c0401039aa2cd42  TypesExternal_Template.lean
```

## Verification

The fixed repository passes:

```text
scripts/check-artifacts.sh
lake build
```

The pinned formal modules `Reachable`, `CheckpointForward`, and `HistoryAlignment` also build. `#print axioms` reports only Lean's standard logical axioms (`propext`, `Quot.sound`, and, for `transition_justified_on_chain`, `Classical.choice`) for the ST-1 through ST-7 and history theorems; there are no project `sorry`, `admit`, or new axioms.

No invariant was transported across languages: doing so before a complete transition relation would be circular. The next sound step is an explicitly approved generated-artifact update using the focused extraction, followed by ST-1, ST-2, genesis-field, and purity proofs; attestation correspondence and the remaining invariant transport must wait for the two Aeneas failures and collection models to be resolved.
