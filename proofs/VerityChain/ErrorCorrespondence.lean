import LeanSpec.Forks.Lstar.Errors
import VerityChain.Types

namespace verity_chain.correspondence

open LeanSpec.Forks.Lstar

/-- Forget formal-leanSpec error payloads and retain the Verity rejection kind.

Verity's extracted `RejectionReason` variants are units, while formal-leanSpec records
contextual payloads. Therefore this direction is canonical; equality of the two error types
is not.
-/
def fromLeanError : STError → error.RejectionReason
  | .slotNotInFuture _ _ => .BlockSlotNotInFuture
  | .invalidSlot _ _ => .BlockSlotMismatch
  | .headerSlotNotNewer => .BlockOlderThanLatestHeader
  | .emptyValidatorRegistry => .EmptyValidatorRegistry
  | .parentRootMismatch _ _ => .ParentRootMismatch
  | .proposerMismatch _ _ => .WrongProposer
  | .tooManyAttestationData _ _ => .TooManyAttestationData
  | .emptyAggregationBits => .EmptyAggregationBits
  | .validatorIndexOutOfRange => .ValidatorIndexOutOfRange
  | .justifiedSlotOutOfRange _ _ => .JustifiedSlotOutOfRange
  | .zeroHashJustificationRoot => .ZeroHashJustificationRoot
  | .justificationVotesLengthMismatch _ _ => .JustificationVotesLengthMismatch
  | .unknownSourceBlock _ => .UnknownSourceBlock
  | .unknownTargetBlock _ => .UnknownTargetBlock
  | .unknownHeadBlock _ => .UnknownHeadBlock
  | .sourceAfterTarget _ _ => .SourceAfterTarget
  | .headOlderThanTarget _ _ => .HeadOlderThanTarget
  | .sourceSlotMismatch _ _ => .SourceSlotMismatch
  | .targetSlotMismatch _ _ => .TargetSlotMismatch
  | .headSlotMismatch _ _ => .HeadSlotMismatch
  | .sourceNotAncestorOfTarget => .SourceNotAncestorOfTarget
  | .targetNotAncestorOfHead => .TargetNotAncestorOfHead
  | .headNotDescendantOfFinalized => .HeadNotDescendantOfFinalized
  | .attestationSlotBeforeHead _ _ => .AttestationSlotBeforeHead
  | .attestationTooFarInFuture _ _ => .AttestationTooFarInFuture
  | .unknownParentBlock _ => .UnknownParentBlock
  | .blockSlotGapTooLarge _ _ => .BlockSlotGapTooLarge
  | .blockTooFarInFuture _ _ => .BlockTooFarInFuture
  | .duplicateAttestationData => .DuplicateAttestationData

/-- A payload-carrying formal-leanSpec error refines a Verity unit error by kind. -/
def errorKindCorresponds (rust : error.RejectionReason) (spec : STError) : Prop :=
  fromLeanError spec = rust

@[simp]
theorem leanError_refines_rust (spec : STError) :
    errorKindCorresponds (fromLeanError spec) spec := by
  rfl

/-- The four Verity-only rejection kinds are outside formal-leanSpec's error surface. -/
theorem verityOnlyErrors_have_no_lean_counterpart (spec : STError) :
    fromLeanError spec ≠ .StateRootMismatch ∧
    fromLeanError spec ≠ .AnchorStateRootMismatch ∧
    fromLeanError spec ≠ .ValidatorNotInState ∧
    fromLeanError spec ≠ .InvalidSignature := by
  cases spec <;> simp [fromLeanError]

end verity_chain.correspondence
