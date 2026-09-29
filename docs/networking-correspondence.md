---
title: Networking Correspondence Evidence
last_updated: 2026-09-29
tags:
  - aeneas
  - correspondence
  - networking
  - verification
---

# Networking Correspondence Evidence

## Scope and fixed inputs

This report covers NET-1, NET-2, response-code decoding, unsigned LEB128 size, the three shared networking constants, and the compressed-size formulas at the revisions pinned in `sources.lock`:

- Verity `a9f3365151a28784277ef31b89aa0092656d4f88`;
- formal-leanSpec `ba7284513031eac5c66bfb8221d27b6154cf240b`.

The committed files under `generated/` are fixed inputs and contain only `verity-chain`. No generated file or upstream source was changed. `VerityP2P.Model` is therefore an explicit handwritten pure transcription, not a claim that the new theorems target committed Aeneas output.

## Checked results

| Candidate | Status | Checked evidence |
|---|---|---|
| `ErrorCode::from_byte` | Model correspondence proved | `errorCode_fromByte_eq` proves exact agreement with formal-leanSpec's four response constructors; `errorCode_fromByte_server_range` and `errorCode_fromByte_invalid_range` prove the two unknown-byte ranges. |
| `write_varint` / `varintSize` | Model correspondence proved | `writeVarint_length` proves exact output length for every Rust-domain `UInt64`, compared with `varintSize value.toNat`. |
| Networking constants | Model correspondence proved | `maxRequestBlocks_eq`, `maxPayloadSize_eq`, and `minSlotsForBlockRequests_eq` are definitional equalities. |
| Compressed bound | Exact equality disproved | `compressedBound_relation` proves Verity's formula is uniformly 992 bytes smaller. `compressedBound_at_max_counterexample` checks `12,233,418 ≠ 12,234,410`. |
| NET-1 | Source-aligned, implementation correspondence blocked | Both sides reject counts outside `1..=1024` and return at most one block per visited slot. The actual private generic `serve_range` is outside the fixed extraction, so no theorem here is stated about its database iterator. |
| NET-2 payload bound | Source-aligned, implementation correspondence blocked | Verity checks the declared length before `read_framed`, and the framed decoder checks the exact decompressed length. Both functions are async and absent from the fixed extraction. |
| NET-2 compressed/model equality | Disproved | `formalReader_accepts_above_verity_bound` checks that formal-leanSpec's abstract reader accepts 33 compressed bytes for declared length zero with a valid abstract decompressor, while Verity's formula permits only 32. |

The checked counterexample does not say Verity accepts malformed Snappy. It shows that formal-leanSpec's parameterized reader and `+1024` allocation formula are strictly more permissive than Verity's framed reader and `+32` formula, so an exact reader correspondence is false.

## Actual source and extraction evidence

At the pinned Verity revision:

- `crates/verity-p2p/src/reqresp/messages.rs:150-158` implements the six response-code cases proved by the model;
- `crates/verity-p2p/src/wire/varint.rs:16-26` emits one 7-bit group per loop iteration;
- `crates/verity-p2p/src/config.rs:16-46` defines the three constants and `32 + n + n / 6`;
- `crates/verity-node/src/sync/responder.rs:151-180` contains NET-1's private `serve_range` count gate and database loop;
- `crates/verity-p2p/src/reqresp/codec.rs:115-130` checks NET-2's declared length before reading frames;
- `crates/verity-p2p/src/wire/snappy.rs:82-135` enforces the compressed cap and exact decompressed length.

A temporary extraction of the constants, compressed formula, and varint writer succeeds with bodies:

```sh
ROOT=$PWD
REV=$(./scripts/lock_value.py correspondence.verity_revision)
CHARON=$HOME/.cache/hax/tools/charon/$(./scripts/lock_value.py tools.charon_version)/charon
AENEAS=$HOME/.cache/hax/tools/aeneas/$(./scripts/lock_value.py tools.aeneas_version)/aeneas
OUT=$(mktemp -d)
cd "$ROOT/.cache/verity-$REV/crates/verity-p2p"
PATH="$(dirname "$CHARON"):$PATH" "$CHARON" cargo --preset=aeneas \
  --dest-file "$OUT/verity_p2p.llbc" \
  --start-from verity_p2p::config::MAX_REQUEST_BLOCKS \
  --start-from verity_p2p::config::MAX_PAYLOAD_SIZE \
  --start-from verity_p2p::config::MIN_SLOTS_FOR_BLOCK_REQUESTS \
  --start-from verity_p2p::config::max_compressed_len \
  --start-from verity_p2p::wire::varint::write_varint
"$AENEAS" -backend lean -dest "$OUT/lean" -split-files -gen-lib-entry \
  "$OUT/verity_p2p.llbc"
grep -nE 'MAX_REQUEST|MAX_PAYLOAD|MIN_SLOTS|max_compressed|write_varint' \
  "$OUT/lean/Funs.lean"
```

`ErrorCode::from_byte` also has a transparent LLBC body. A direct method start currently leaves the method out of Charon's `ordered_decls`; selecting the containing `messages` module orders it, but Aeneas then reports unrelated late-bound-region errors from the SSZ decode derives and emits only partial files. This is the concrete reason the checked proof uses the separately identified pure transcription rather than adding generated output.

## NET-1 and NET-2 classification

NET-1 remains **unproved for the implementation**, not disproved. A proof needs an extracted pure boundary for `serve_range` plus a specification of `Repository::canonical_range` guaranteeing at most one entry per half-open slot range. The count check alone does not justify that iterator contract.

NET-2's uncompressed payload claim remains **unproved for the implementation but source-aligned**. Its exact compressed-allocation correspondence is **disproved** by the checked formula and reader-model counterexamples. Alignment requires changing either formal-leanSpec's `n + n / 6 + 1024` abstract bound or Verity's `32 + n + n / 6` framed bound; this repository does not alter either side.

## Verification

```sh
lake build VerityP2P
lake build
lake env lean lean/VerityP2P/Correspondence.lean
```

The axiom check is expected to report only Lean's standard proof principles (for example, quotient and propositional extensionality), never a project-specific axiom:

```lean
#print axioms verity_p2p.correspondence.errorCode_fromByte_eq
#print axioms verity_p2p.correspondence.writeVarint_length
#print axioms verity_p2p.correspondence.compressedBound_relation
#print axioms verity_p2p.correspondence.formalReader_accepts_above_verity_bound
```
