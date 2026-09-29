import LeanSpec.Forks.Lstar.Store.BlockProduction
import LeanSpec.Forks.Lstar.Store.Store

namespace verity_chain.correspondence

open LeanSpec
open LeanSpec.Forks.Lstar

namespace ForkChoice

/-- Pure model of `verity_db::votes::replaces` over the formal-leanSpec
    representation. `Root.lexLe` models Rust's lexicographic array order. -/
def voteReplacesModel [SSZ.HasHashTreeRoot AttestationData]
    (candidate : AttestationData) : Option AttestationData → Bool
  | none => true
  | some stored =>
      decide (stored.slot < candidate.slot) ||
      (candidate.slot == stored.slot &&
        !(Root.lexLe (SSZ.hashTreeRoot candidate) (SSZ.hashTreeRoot stored)))

private theorem byteListLe_refl (bytes : List UInt8) :
    byteListLe bytes bytes = true := by
  induction bytes with
  | nil => rfl
  | cons byte bytes ih => simp [byteListLe, ih]

private theorem rootLexLe_refl (root : Root) :
    Root.lexLe root root = true := by
  simp [Root.lexLe, byteListLe_refl]

/-- Rust deliberately treats an absent vote-map row as replaceable. -/
@[simp]
theorem voteReplacesModel_none [SSZ.HasHashTreeRoot AttestationData]
    (candidate : AttestationData) :
    voteReplacesModel candidate none = true := rfl

/-- A newer candidate has precedence in both Verity's replacement rule and
    formal-leanSpec's merge-sort comparator. -/
theorem voteReplaces_newer [SSZ.HasHashTreeRoot AttestationData]
    (candidate stored : AttestationData)
    (hnewer : stored.slot < candidate.slot) :
    voteReplacesModel candidate (some stored) = true ∧
      Store.votePrecedence (candidate, []) (stored, []) = true := by
  simp [voteReplacesModel, Store.votePrecedence, hnewer]

/-- An older candidate has precedence in neither rule. -/
theorem voteReplaces_older [SSZ.HasHashTreeRoot AttestationData]
    (candidate stored : AttestationData)
    (holder : candidate.slot < stored.slot) :
    voteReplacesModel candidate (some stored) = false ∧
      Store.votePrecedence (candidate, []) (stored, []) = false := by
  have hnotNewer : ¬stored.slot < candidate.slot := by
    rw [UInt64.lt_iff_toNat_lt]
    have := UInt64.lt_iff_toNat_lt.mp holder
    omega
  have hne : candidate.slot ≠ stored.slot := by
    intro heq
    have := UInt64.lt_iff_toNat_lt.mp holder
    rw [heq] at this
    omega
  simp [voteReplacesModel, Store.votePrecedence, hnotNewer, hne, hne.symm]

/-- On equal slots, the two rules expose their exact comparison boundary:
    Rust replacement is strict, while `votePrecedence` uses non-strict order. -/
theorem voteReplaces_tie [SSZ.HasHashTreeRoot AttestationData]
    (candidate stored : AttestationData)
    (htie : candidate.slot = stored.slot) :
    voteReplacesModel candidate (some stored) =
        !(Root.lexLe (SSZ.hashTreeRoot candidate) (SSZ.hashTreeRoot stored)) ∧
      Store.votePrecedence (candidate, []) (stored, []) =
        Root.lexLe (SSZ.hashTreeRoot stored) (SSZ.hashTreeRoot candidate) := by
  simp [voteReplacesModel, Store.votePrecedence, htie]

/-- Checked counterexample to unconditional `replaces = votePrecedence`:
    replacing a vote with itself is false in Verity but the non-strict
    merge-sort comparator is true on the same vote. -/
theorem votePrecedence_self_counterexample
    [SSZ.HasHashTreeRoot AttestationData] (vote : AttestationData) :
    voteReplacesModel vote (some vote) = false ∧
      Store.votePrecedence (vote, []) (vote, []) = true := by
  simp [voteReplacesModel, Store.votePrecedence, rootLexLe_refl]

/-- Pure model of pinned Rust `block_production::is_eligible`. Hash-set
    membership is represented extensionally by `knownRoots.contains`; the
    remaining calls are the corresponding formal-leanSpec pure functions. -/
def candidateEligibleModel (data : AttestationData)
    (knownRoots : List Root) (chainView : Array Root)
    (justified : Checkpoint) (justifiedSlots : JustifiedSlots)
    (finalizedSlot : Slot) : ST.Result Bool :=
  if !(knownRoots.contains data.head.root) then .ok false
  else if data.source.slot ≠ justified.slot then .ok false
  else if !(data.liesOnChain chainView) then .ok false
  else
    match JustifiedSlots.isSlotJustified justifiedSlots finalizedSlot
        data.source.slot with
    | .error error => .error error
    | .ok false => .ok false
    | .ok true =>
      if data.source.slot == 0 && data.target.slot == 0 then .ok true
      else
        match JustifiedSlots.isSlotJustified justifiedSlots finalizedSlot
            data.target.slot with
        | .error error => .error error
        | .ok targetJustified => .ok !targetJustified

/-- The pure Rust model is definitionally equal to formal-leanSpec's
    `candidateEligible`; fields used only by the selection loop are irrelevant. -/
theorem candidateEligible_eq (data : AttestationData)
    (knownRoots : List Root) (chainView : Array Root)
    (justified : Checkpoint) (justifiedSlots : JustifiedSlots)
    (finalizedSlot : Slot) (processedCount : Nat)
    (attestations : List AggregatedAttestation)
    (signatures : List SingleMessageAggregate) :
    candidateEligibleModel data knownRoots chainView justified justifiedSlots
        finalizedSlot =
      BlockProduction.candidateEligible chainView knownRoots {
        justifiedCheckpoint := justified
        justifiedSlots := justifiedSlots
        finalizedSlot := finalizedSlot
        processedCount := processedCount
        attestations := attestations
        signatures := signatures
      } data := rfl

end ForkChoice
end verity_chain.correspondence
