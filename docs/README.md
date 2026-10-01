---
title: Documentation
last_updated: 2026-10-01
tags:
  - documentation
  - formal-verification
  - navigation
---

# Documentation

Start with the repository [README](../README.md) for the proof architecture and project-level result. Use this index to find the authoritative inventory, supporting evidence, and maintenance procedures without treating domain reports as competing sources of truth.

## Recommended reading order

1. [Public proposition inventory](inventory/public-propositions.md) — every audited public Lean theorem, grouped into correspondence and Verity-specific propositions.
2. [Correspondence survey](inventory/correspondence-survey.md) — the complete Verity/formal-leanSpec boundary ledger, including blocked, divergent, no-counterpart, and `pending-external` items.
3. The relevant [domain evidence](#domain-evidence) report — detailed source observations, extraction experiments, counterexamples, and trust boundaries.
4. [Reproduction and maintenance](operations/reproduction.md) — regenerate and verify the checked-in artifacts.

## Authoritative inventories

| Document | Responsibility | Update when |
|---|---|---|
| [Public proposition inventory](inventory/public-propositions.md) | Source of truth for the semantic grouping of every theorem audited by `proofs/AxiomAudit.lean` | A public theorem is added, removed, renamed, or reclassified |
| [Correspondence survey](inventory/correspondence-survey.md) | Source of truth for catalog-wide correspondence classifications, extraction boundaries, and the external-dependency work-priority overlay | A formal proposition, Verity counterpart, extraction result, final classification, or work-priority decision changes |

## Domain evidence

Domain reports explain why an inventory entry has its stated result. They preserve reproducible observations and exact trust boundaries; they do not replace the inventories above.

| Domain | Evidence report |
|---|---|
| Containers, proposer selection, slot clock, and configuration | [Containers, proposer, and configuration](evidence/containers-proposer-config.md) |
| State transition and history alignment | [State transition](evidence/state-transition.md) |
| Fork choice and storage | [Fork choice and storage](evidence/fork-choice-storage.md) |
| Networking and allocation bounds | [Networking](evidence/networking.md) |
| Validator gates and sync behavior | [Validator and sync](evidence/validator-sync.md) |

## Operations

- [Reproduction and maintenance](operations/reproduction.md) defines the routine bootstrap, extraction, verification, and pinned-input update workflow.
- `sources.lock` remains the source of truth for revisions and tool versions.
- `scripts/verify.sh` remains the executable verification entry point.

## Maintenance rules

- Link to an inventory instead of copying its complete table into another document.
- Keep experiment commands and raw diagnostics in the relevant domain evidence report.
- Identify handwritten pure models explicitly; never describe them as Aeneas-generated implementation semantics.
- Update `last_updated` whenever non-whitespace document content changes.
- Add every new document to this index and link back to this page from the document's role note.
