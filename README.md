# verity-aeneas-proofs

Aeneas-generated Lean semantics for [Verity](https://github.com/NyxFoundation/verity), handwritten correspondence proofs against [formal-leanSpec](https://github.com/NyxFoundation/formal-leanSpec), and Verity-specific implementation properties.

This repository owns verification artifacts, not production consensus code. It was initialized from Verity PRs [#49](https://github.com/NyxFoundation/verity/pull/49) and [#56](https://github.com/NyxFoundation/verity/pull/56).

## Current result

The correspondence ledger classifies every surveyed Verity/formal-leanSpec boundary and all 34 theorem propositions in the formal catalog. Checked Lean results cover:

- SSZ ranges, byte lengths, hash delegation, and error refinement;
- checkpoint ordering/advancement, justification, proposer selection, slot-clock, and configuration arithmetic;
- fork-choice candidate eligibility and vote replacement, including a strict/non-strict counterexample;
- response codes, varint size, networking constants, and compressed-bound counterexamples;
- validator safety gates and sync-state refinement, with checked boundary divergences.

State transition, full fork choice/storage, async networking, and external crypto remain limited by the concrete extraction or contract boundaries recorded in [`docs/correspondence-survey.md`](docs/correspondence-survey.md). These results do not prove the whole client or protocol safety.

The same Lean implementation semantics can also support Verity-specific proofs without a formal-leanSpec counterpart. Checked examples include extracted configuration arithmetic and pure-model properties for key-role separation, duplicate-vote prevention within its non-overflowing domain, response-code ranges, and initial sync behavior.

## Proof architecture and current status

```mermaid
flowchart TB
    V["Verity Rust implementation<br/>pinned source"]
    C["Charon<br/>Rust to LLBC"]
    A["Aeneas<br/>LLBC to Lean"]
    G["Generated Lean semantics<br/>generated/"]
    M["Source-faithful pure models<br/>selected blocked boundaries"]

    V --> C --> A --> G
    V -. "explicit model path" .-> M

    S["Track 1 input: formal-leanSpec<br/>executable specification<br/>and 34 catalog propositions"]
    X["Specification correspondence<br/>equality, refinement, divergence,<br/>and explicit trust boundaries"]
    VS["Track 2 input: Verity-specific specs<br/>local contracts, safety invariants,<br/>and behavior with no formal counterpart"]
    L["Direct property proofs<br/>over generated semantics<br/>or an explicit pure model"]

    S --> X
    G --> X
    M --> X
    VS --> L
    G --> L
    M --> L

    Q["Lean theorems and counterexamples<br/>lake build and axiom audit"]
    X --> Q
    L --> Q

    Q --> CROSS["Correspondence checked now<br/>SSZ, checkpoints, justification,<br/>proposer, and selected fork-choice,<br/>network, validator, and sync behavior"]
    Q --> LOCAL["Verity-local properties checked now<br/>config arithmetic; response-code ranges;<br/>key-role, duplicate-vote, and<br/>initial-sync guards"]
    Q --> DIV["Cross-spec differences found<br/>vote strictness, compressed bounds,<br/>validator edge cases, and sync/gossip"]
    X --> OPEN["Open or blocked on either track<br/>state transition, full fork choice/storage,<br/>async networking, and external crypto"]
    L --> OPEN

    classDef source fill:#e0f2fe,stroke:#0369a1,color:#0c4a6e
    classDef proof fill:#ede9fe,stroke:#7e22ce,color:#581c87
    classDef proved fill:#dcfce7,stroke:#15803d,color:#14532d
    classDef partial fill:#fef3c7,stroke:#b45309,color:#78350f
    classDef divergence fill:#fee2e2,stroke:#b91c1c,color:#7f1d1d

    class V,C,A,G,M,S source
    class X,VS,L,Q proof
    class CROSS,LOCAL proved
    class OPEN partial
    class DIV divergence
```

The solid implementation path is the checked-in Charon/Aeneas translation. The dotted implementation path is used only for explicitly identified source-faithful models when extraction cannot expose a usable function. Track 1 compares Verity with formal-leanSpec; Track 2 states and proves properties owned by Verity itself, including behavior with no formal counterpart. A local model theorem is not automatically an extracted-function theorem, and neither track currently establishes whole-client correctness.

## Repository layout

| Path | Ownership |
|---|---|
| `generated/` | Charon/Aeneas output; never edit manually |
| `proofs/` | Handwritten external models, correspondence theorems, and Verity-specific properties |
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

`extract.sh` checks out the exact Verity revision from `sources.lock`, installs the pinned Charon and Aeneas binaries through cargo-hax, and replaces only `generated/`. `verify.sh` checks artifact integrity, rejects handwritten `sorry`/`admit`, builds every Lean target, verifies that every public correspondence theorem is listed in the axiom audit, and prints those dependencies.

GitHub Actions intentionally runs only the lightweight artifact-integrity check. Lean and Aeneas execution remains an explicit local operation because of its resource cost.

See [Reproduction and maintenance](docs/reproduction.md) for the update procedure and [the correspondence survey](docs/correspondence-survey.md) for the wider proof inventory.

## License

MIT © Nyx Foundation
