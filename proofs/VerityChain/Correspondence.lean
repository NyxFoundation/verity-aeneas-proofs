import LeanSpec.Forks.Lstar.Containers.Checkpoint
import LeanSpec.Forks.Lstar.Containers.Identifiers
import LeanSpec.Forks.Lstar.Containers.Interval
import LeanSpec.Forks.Lstar.Slot
import VerityChain.Funs
import VerityChain.PrimitiveCorrespondence

open Aeneas Aeneas.Std RustM

namespace verity_chain.correspondence

/-- View the shared Aeneas `u64` conversion as formal-leanSpec's `Slot`. -/
abbrev toLeanSlot (slot : Std.U64) : LeanSpec.Slot :=
  toLeanUint64 slot

@[simp]
theorem toLeanSlot_toNat (slot : Std.U64) : (toLeanSlot slot).toNat = slot.val := by
  exact toLeanUint64_toNat slot

@[simp]
theorem toLeanSlot_lt_iff (left right : Std.U64) :
    toLeanSlot left < toLeanSlot right ↔ left.val < right.val := by
  rw [UInt64.lt_iff_toNat_lt]
  simp

def u64Difference (left right : Std.U64) : Std.U64 :=
  ⟨BitVec.ofNat 64 (left.val - right.val)⟩

@[simp]
theorem u64Difference_val (left right : Std.U64) :
    (u64Difference left right).val = left.val - right.val := by
  have hbound : left.val - right.val < 2 ^ 64 :=
    (Nat.sub_le left.val right.val).trans_lt left.hBounds
  change (BitVec.ofNat 64 (left.val - right.val)).toNat = left.val - right.val
  rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hbound]

theorem u64_sub_eq (left right : Std.U64) (h : right.val ≤ left.val) :
    left - right = ok (u64Difference left right) := by
  change UScalar.sub left right = _
  simp [UScalar.sub, u64Difference, Nat.not_lt.mpr h]

def u64Remainder (left right : Std.U64) : Std.U64 :=
  ⟨BitVec.umod left.bv right.bv⟩

@[simp]
theorem u64Remainder_val (left right : Std.U64) :
    (u64Remainder left right).val = left.val % right.val := by
  change (left.bv % right.bv).toNat = left.val % right.val
  rw [BitVec.toNat_umod]
  simp

theorem u64_rem_eq (left right : Std.U64) (h : right.val ≠ 0) :
    left % right = ok (u64Remainder left right) := by
  change UScalar.rem left right = _
  simp [UScalar.rem, u64Remainder, h]

theorem u64_mul_eq (left right : Std.U64)
    (h : left.val * right.val < 2 ^ UScalarTy.U64.numBits) :
    left * right = ok (UScalar.ofNatCore (left.val * right.val) h) := by
  change UScalar.mul left right = _
  have h' : left.val * right.val < 18446744073709551616 := by
    norm_num [UScalarTy.U64_numBits_eq] at h ⊢
    exact h
  simp [UScalar.mul, UScalar.tryMk, UScalar.tryMkOpt, UScalar.check_bounds, h']

def u128RemainderTwo (value : Std.U128) : Std.U128 :=
  ⟨BitVec.umod value.bv (2#u128).bv⟩

@[simp]
theorem u128RemainderTwo_val (value : Std.U128) :
    (u128RemainderTwo value).val = value.val % 2 := by
  change (value.bv % (2#u128).bv).toNat = value.val % 2
  rw [BitVec.toNat_umod]
  simp

theorem u128_rem_two_eq (value : Std.U128) :
    value % 2#u128 = ok (u128RemainderTwo value) := by
  change UScalar.rem value 2#u128 = _
  simp [UScalar.rem, u128RemainderTwo]

@[simp]
theorem u128RemainderTwo_eq_one_iff (value : Std.U128) :
    u128RemainderTwo value = 1#u128 ↔ value.val % 2 = 1 := by
  constructor
  · intro heq
    have hval := congrArg UScalar.val heq
    simpa using hval
  · intro hval
    apply Std.U128.bv_eq_imp_eq
    apply BitVec.eq_of_toNat_eq
    simpa using hval

theorem u128_add_eq (left right : Std.U128)
    (h : left.val + right.val < 2 ^ UScalarTy.U128.numBits) :
    left + right = ok (UScalar.ofNatCore (left.val + right.val) h) := by
  change UScalar.add left right = _
  have h' : left.val + right.val < 340282366920938463463374607431768211456 := by
    norm_num [UScalarTy.U128_numBits_eq] at h ⊢
    exact h
  simp [UScalar.add, UScalar.tryMk, UScalar.tryMkOpt, UScalar.check_bounds, h']

theorem u128_mul_eq (left right : Std.U128)
    (h : left.val * right.val < 2 ^ UScalarTy.U128.numBits) :
    left * right = ok (UScalar.ofNatCore (left.val * right.val) h) := by
  change UScalar.mul left right = _
  have h' : left.val * right.val < 340282366920938463463374607431768211456 := by
    norm_num [UScalarTy.U128_numBits_eq] at h ⊢
    exact h
  simp [UScalar.mul, UScalar.tryMk, UScalar.tryMkOpt, UScalar.check_bounds, h']

/-- The extracted perfect-square helper computes with formal-leanSpec's square root. -/
theorem isPerfectSquare_eq (value : Std.U128) :
    justification.is_perfect_square value =
      ok (decide (LeanSpec.Slot.isqrt value.val * LeanSpec.Slot.isqrt value.val = value.val)) := by
  simp [justification.is_perfect_square, core.num.U128.isqrt, models.u128Isqrt]
  rw [u128_mul_eq]
  · simp
    constructor
    · intro heq
      have hval := congrArg UScalar.val heq
      simpa using hval
    · intro hval
      apply Std.U128.bv_eq_imp_eq
      apply BitVec.eq_of_toNat_eq
      simpa using hval
  · exact (LeanSpec.Slot.isqrt_le value.val).trans_lt value.hBounds

private theorem pronicBranch_eq (delta : Std.U64) :
    (do
      let i2 ← 4#u128 * core.convert.num.FromU128U64.from delta
      let discriminant ← i2 + 1#u128
      let isSquare ← justification.is_perfect_square discriminant
      if isSquare = true then do
        let root ← core.num.U128.isqrt discriminant
        let parity ← root % 2#u128
        ok (decide (parity = 1#u128))
      else ok false) =
    ok ((LeanSpec.Slot.isqrt (4 * delta.val + 1) *
        LeanSpec.Slot.isqrt (4 * delta.val + 1) == 4 * delta.val + 1) &&
      (LeanSpec.Slot.isqrt (4 * delta.val + 1) % 2 == 1)) := by
  rw [u128_mul_eq]
  · rw [bind_tc_ok, u128_add_eq]
    · rw [bind_tc_ok, isPerfectSquare_eq, bind_tc_ok]
      simp
      by_cases hSquare : LeanSpec.Slot.isqrt (4 * delta.val + 1) *
          LeanSpec.Slot.isqrt (4 * delta.val + 1) = 4 * delta.val + 1
      · rw [if_pos hSquare]
        simp [core.num.U128.isqrt, models.u128Isqrt, hSquare]
        rw [u128_rem_two_eq, bind_tc_ok]
        simp
        exact (Bool.beq_eq_decide_eq
          (LeanSpec.Slot.isqrt (4 * delta.val + 1) % 2) (1 : Nat)).symm
      · rw [if_neg hSquare]
        simp [hSquare]
    · simp
      have hdelta := delta.hBounds
      norm_num [UScalarTy.U64_numBits_eq, UScalarTy.U128_numBits_eq] at hdelta ⊢
      omega
  · simp
    have hdelta := delta.hBounds
    norm_num [UScalarTy.U64_numBits_eq, UScalarTy.U128_numBits_eq] at hdelta ⊢
    omega

/-- The extracted Rust predicate agrees with formal-leanSpec after finalization. -/
theorem isJustifiableAfter_eq
    (slot finalized : Std.U64) (h : finalized.val ≤ slot.val) :
    justification.is_justifiable_after slot finalized =
      ok (LeanSpec.Slot.isJustifiableAfter (toLeanSlot finalized) (toLeanSlot slot)) := by
  have hnot : ¬ slot.val < finalized.val := by omega
  have hnotScalar : ¬slot < finalized := by
    simpa [UScalar.lt_equiv] using hnot
  have hleanNot : ¬toLeanSlot slot < toLeanSlot finalized := by
    simpa using hnot
  rw [show LeanSpec.Slot.isJustifiableAfter (toLeanSlot finalized) (toLeanSlot slot) =
      LeanSpec.Slot.justifiableDelta (slot.val - finalized.val) by
    unfold LeanSpec.Slot.isJustifiableAfter
    rw [if_neg hleanNot]
    simp]
  unfold justification.is_justifiable_after
  rw [if_neg hnotScalar, u64_sub_eq slot finalized h, bind_tc_ok]
  have hWindow :
      u64Difference slot finalized ≤ justification.IMMEDIATE_JUSTIFICATION_WINDOW ↔
        slot.val - finalized.val ≤ 5 := by
    rw [UScalar.le_equiv]
    simp [justification.IMMEDIATE_JUSTIFICATION_WINDOW]
  by_cases hImmediate : slot.val - finalized.val ≤ 5
  · rw [if_pos (hWindow.mpr hImmediate)]
    simp [LeanSpec.Slot.justifiableDelta, LeanSpec.Slot.immediateJustificationWindow,
      hImmediate]
  · rw [if_neg (fun hWindowValue => hImmediate (hWindow.mp hWindowValue))]
    simp only [lift]
    rw [bind_tc_ok, isPerfectSquare_eq, bind_tc_ok]
    simp [LeanSpec.Slot.justifiableDelta, LeanSpec.Slot.immediateJustificationWindow,
      hImmediate]
    by_cases hSquare :
        LeanSpec.Slot.isqrt (slot.val - finalized.val) *
          LeanSpec.Slot.isqrt (slot.val - finalized.val) = slot.val - finalized.val
    · rw [if_pos hSquare]
      simp [hSquare]
    · rw [if_neg hSquare, pronicBranch_eq]
      rw [show (LeanSpec.Slot.isqrt (slot.val - finalized.val) *
          LeanSpec.Slot.isqrt (slot.val - finalized.val) ==
            slot.val - finalized.val) = false by
        exact beq_eq_false_iff_ne.mpr hSquare]
      simp

/-- CONT-2 for the extracted Rust predicate: after finalization, a slot is
    justifiable exactly when its distance is immediate, square, or pronic. -/
theorem isJustifiableAfter_iff
    (slot finalized : Std.U64) (h : finalized.val ≤ slot.val) :
    justification.is_justifiable_after slot finalized = ok true ↔
      (let δ := slot.val - finalized.val
       δ ≤ 5 ∨ (∃ k, δ = k * k) ∨ (∃ k, δ = k * (k + 1))) := by
  rw [isJustifiableAfter_eq slot finalized h]
  have hslots : toLeanSlot finalized ≤ toLeanSlot slot := by
    rw [UInt64.le_iff_toNat_le]
    simpa using h
  simpa using LeanSpec.Slot.justifiable_iff
    (toLeanSlot finalized) (toLeanSlot slot) hslots

/-- The extracted Rust predicate rejects slots before the finalized boundary. -/
theorem isJustifiableAfter_before_finalized
    (slot finalized : Std.U64) (h : slot.val < finalized.val) :
    justification.is_justifiable_after slot finalized = ok false := by
  unfold justification.is_justifiable_after
  rw [if_pos (by simpa [UScalar.lt_equiv] using h)]

/-! ## VAL-1 and VAL-3: proposer selection -/

/-- An empty validator registry takes Verity's explicit error branch. -/
theorem proposerForSlot_zero (slot : Std.U64) :
    proposer.proposer_for_slot slot 0#u64 =
      ok (.Err error.RejectionReason.EmptyValidatorRegistry) := by
  simp [proposer.proposer_for_slot]

/-- On a nonempty registry, the extracted function returns the `u64` remainder. -/
theorem proposerForSlot_eq (slot validatorCount : Std.U64)
    (h : 0 < validatorCount.val) :
    proposer.proposer_for_slot slot validatorCount =
      ok (.Ok (u64Remainder slot validatorCount)) := by
  have hne : validatorCount ≠ 0#u64 := by
    intro heq
    have hval := congrArg UScalar.val heq
    simp at hval
    omega
  unfold proposer.proposer_for_slot
  rw [if_neg hne, u64_rem_eq slot validatorCount (by omega), bind_tc_ok]

/-- VAL-1 transport: Verity's successful proposer is formal-leanSpec's
    round-robin proposer after the shared `u64` conversion. -/
theorem proposerForSlot_roundRobin (slot validatorCount : Std.U64)
    (h : 0 < validatorCount.val) :
    proposer.proposer_for_slot slot validatorCount =
        ok (.Ok (u64Remainder slot validatorCount)) ∧
      toLeanUint64 (u64Remainder slot validatorCount) =
        LeanSpec.Forks.Lstar.ValidatorIndex.proposerForSlot
          (toLeanSlot slot) validatorCount.val := by
  refine ⟨proposerForSlot_eq slot validatorCount h, ?_⟩
  apply (UInt64.toNat_inj).mp
  simp only [toLeanUint64_toNat, u64Remainder_val,
    LeanSpec.Forks.Lstar.ValidatorIndex.proposerForSlot]
  rw [UInt64.toNat_ofNat_of_lt']
  exact (Nat.mod_le slot.val validatorCount.val).trans_lt slot.hBounds

/-- The successful extracted proposer result is unique. -/
theorem proposerForSlot_uniqueOutput (slot validatorCount : Std.U64)
    (h : 0 < validatorCount.val) :
    ∃! selected : Std.U64,
      proposer.proposer_for_slot slot validatorCount = ok (.Ok selected) := by
  refine ⟨u64Remainder slot validatorCount, proposerForSlot_eq slot validatorCount h, ?_⟩
  intro other hother
  rw [proposerForSlot_eq slot validatorCount h] at hother
  simpa using hother.symm

/-- VAL-3 transport: Verity's selected value represents formal-leanSpec's
    unique in-registry proposer. -/
theorem proposerForSlot_unique (slot validatorCount : Std.U64)
    (h : 0 < validatorCount.val) :
    ∃ (selected : Std.U64) (vid : Fin validatorCount.val),
      proposer.proposer_for_slot slot validatorCount = ok (.Ok selected) ∧
      selected.val = vid.val ∧
      LeanSpec.Forks.Lstar.ValidatorIndex.isProposerFor vid (toLeanSlot slot) ∧
      (∀ other : Fin validatorCount.val,
        LeanSpec.Forks.Lstar.ValidatorIndex.isProposerFor other (toLeanSlot slot) →
          other = vid) := by
  obtain ⟨vid, hvid, hunique⟩ :=
    LeanSpec.Forks.Lstar.ValidatorIndex.unique_proposer
      (toLeanSlot slot) validatorCount.val h
  refine ⟨u64Remainder slot validatorCount, vid,
    proposerForSlot_eq slot validatorCount h, ?_, hvid, hunique⟩
  rw [u64Remainder_val]
  simpa using hvid.symm

/-! ## CONT-1: checkpoint shape and advancement -/

/-- Field-preserving conversion of the extracted Verity checkpoint container. -/
def toLeanCheckpoint (checkpoint : verity_types.checkpoint.Checkpoint) :
    LeanSpec.Forks.Lstar.Checkpoint := {
  root := toLeanBytes32 checkpoint.root
  slot := toLeanSlot checkpoint.slot
}

@[simp]
theorem toLeanCheckpoint_root (checkpoint : verity_types.checkpoint.Checkpoint) :
    (toLeanCheckpoint checkpoint).root = toLeanBytes32 checkpoint.root := rfl

@[simp]
theorem toLeanCheckpoint_slot (checkpoint : verity_types.checkpoint.Checkpoint) :
    (toLeanCheckpoint checkpoint).slot = toLeanSlot checkpoint.slot := rfl

/-- Select the later extracted checkpoint, retaining the current value on a tie. -/
def laterCheckpoint (current candidate : verity_types.checkpoint.Checkpoint) :
    verity_types.checkpoint.Checkpoint :=
  if current.slot.val < candidate.slot.val then candidate else current

/-- CONT-1 transport: converted checkpoint order is exactly extracted slot order. -/
theorem checkpointOrder_iff_slotOrder
    (current candidate : verity_types.checkpoint.Checkpoint) :
    toLeanCheckpoint current < toLeanCheckpoint candidate ↔
      current.slot.val < candidate.slot.val := by
  exact toLeanSlot_lt_iff current.slot candidate.slot

/-- The extracted checkpoint advance computes the slot-based selection. -/
theorem advanceCheckpoint_eq
    (current candidate : verity_types.checkpoint.Checkpoint) :
    justification.advance_checkpoint current candidate =
      ok (laterCheckpoint current candidate) := by
  unfold justification.advance_checkpoint laterCheckpoint
  by_cases h : current.slot.val < candidate.slot.val
  · rw [if_pos (by simpa [UScalar.lt_equiv] using h), if_pos h]
  · rw [if_neg (by simpa [UScalar.lt_equiv] using h), if_neg h]

/-- Verity's checkpoint advance agrees with formal-leanSpec's `advanceTo`,
    including its keep-current tie behavior. -/
theorem advanceCheckpoint_corresponds
    (current candidate : verity_types.checkpoint.Checkpoint) :
    toLeanCheckpoint (laterCheckpoint current candidate) =
      (toLeanCheckpoint current).advanceTo (toLeanCheckpoint candidate) := by
  unfold laterCheckpoint LeanSpec.Forks.Lstar.Checkpoint.advanceTo
  change toLeanCheckpoint (if current.slot.val < candidate.slot.val then candidate else current) =
    if toLeanSlot current.slot < toLeanSlot candidate.slot
    then toLeanCheckpoint candidate else toLeanCheckpoint current
  by_cases h : current.slot.val < candidate.slot.val
  · rw [if_pos h, if_pos (toLeanSlot_lt_iff _ _ |>.mpr h)]
  · rw [if_neg h, if_neg (fun hlt => h (toLeanSlot_lt_iff _ _ |>.mp hlt))]

/-- Direct correspondence witness for `advance_checkpoint` and `advanceTo`. -/
theorem advanceCheckpoint_refines
    (current candidate : verity_types.checkpoint.Checkpoint) :
    ∃ selected,
      justification.advance_checkpoint current candidate = ok selected ∧
      toLeanCheckpoint selected =
        (toLeanCheckpoint current).advanceTo (toLeanCheckpoint candidate) := by
  exact ⟨laterCheckpoint current candidate,
    advanceCheckpoint_eq current candidate,
    advanceCheckpoint_corresponds current candidate⟩

/-! ## CONT-2: justification index -/

/-- The extracted immediate-justification window equals formal-leanSpec's value. -/
theorem immediateJustificationWindow_corresponds :
    justification.IMMEDIATE_JUSTIFICATION_WINDOW.val =
      LeanSpec.Slot.immediateJustificationWindow := by
  norm_num [justification.IMMEDIATE_JUSTIFICATION_WINDOW,
    LeanSpec.Slot.immediateJustificationWindow]

/-- The extracted later-slot index before it is wrapped in `Option`. -/
def justifiedIndexValue (slot finalized : Std.U64) : Std.Usize :=
  UScalar.cast .Usize (u64Difference (u64Difference slot finalized) 1#u64)

/-- The `u64`-to-`usize` cast preserves the mathematical index when it fits
    the platform-dependent Aeneas `usize` width. -/
theorem justifiedIndexValue_val (slot finalized : Std.U64)
    (hfit : slot.val - finalized.val - 1 < 2 ^ UScalarTy.Usize.numBits) :
    (justifiedIndexValue slot finalized).val = slot.val - finalized.val - 1 := by
  rw [show UScalarTy.Usize.numBits = System.Platform.numBits from rfl] at hfit
  simp only [justifiedIndexValue, UScalar.cast_val_eq, u64Difference_val]
  exact Nat.mod_eq_of_lt hfit

/-- Exact extracted result, including the at-or-before-finalization branch. -/
def justifiedIndexResult (slot finalized : Std.U64) : Option Std.Usize :=
  if slot.val ≤ finalized.val then none else some (justifiedIndexValue slot finalized)

/-- The extracted implementation computes `justifiedIndexResult` without
    relying on any external model axiom. -/
theorem justifiedIndexAfter_eq (slot finalized : Std.U64) :
    justification.justified_index_after slot finalized =
      ok (justifiedIndexResult slot finalized) := by
  by_cases hle : slot.val ≤ finalized.val
  · unfold justification.justified_index_after justifiedIndexResult
    rw [if_pos (by simpa [UScalar.le_equiv] using hle), if_pos hle]
  · rw [justifiedIndexResult, if_neg hle]
    have hlt : finalized.val < slot.val := Nat.lt_of_not_ge hle
    have hsub : finalized.val ≤ slot.val := Nat.le_of_lt hlt
    have hone : 1 ≤ slot.val - finalized.val := by omega
    unfold justification.justified_index_after
    rw [if_neg (by simpa [UScalar.le_equiv] using hle)]
    rw [u64_sub_eq slot finalized hsub, bind_tc_ok]
    rw [u64_sub_eq (u64Difference slot finalized) 1#u64 (by simpa using hone), bind_tc_ok]
    simp [justifiedIndexValue, Std.lift]

/-- After mapping `usize` to `Nat`, the extracted index is formal-leanSpec's
    `justifiedIndexAfter`. The fit hypothesis is necessary in Aeneas's
    platform-generic model because `usize` may be 32-bit. -/
theorem justifiedIndexAfter_corresponds (slot finalized : Std.U64)
    (hfit : slot.val - finalized.val - 1 < 2 ^ UScalarTy.Usize.numBits) :
    (justifiedIndexResult slot finalized).map (fun index => index.val) =
      LeanSpec.Slot.justifiedIndexAfter (toLeanSlot finalized) (toLeanSlot slot) := by
  by_cases hle : slot.val ≤ finalized.val
  · unfold justifiedIndexResult LeanSpec.Slot.justifiedIndexAfter
    rw [if_pos hle, if_pos (by
      rw [UInt64.le_iff_toNat_le]
      simpa using hle)]
    rfl
  · have hlt : finalized.val < slot.val := Nat.lt_of_not_ge hle
    rw [justifiedIndexResult, if_neg hle]
    simp only [Option.map_some]
    unfold LeanSpec.Slot.justifiedIndexAfter
    rw [if_neg (by
      rw [UInt64.le_iff_toNat_le]
      simp
      omega)]
    simp [justifiedIndexValue_val slot finalized hfit]

/-- Direct correspondence witness for the extracted and formal justification index. -/
theorem justifiedIndexAfter_refines (slot finalized : Std.U64)
    (hfit : slot.val - finalized.val - 1 < 2 ^ UScalarTy.Usize.numBits) :
    ∃ result,
      justification.justified_index_after slot finalized = ok result ∧
      result.map (fun index => index.val) =
        LeanSpec.Slot.justifiedIndexAfter (toLeanSlot finalized) (toLeanSlot slot) := by
  exact ⟨justifiedIndexResult slot finalized,
    justifiedIndexAfter_eq slot finalized,
    justifiedIndexAfter_corresponds slot finalized hfit⟩

/-! ## Slot-clock and extracted configuration arithmetic -/

/-- The non-overflowing extracted interval value at a slot boundary. -/
def startIntervalValue (slot : Std.U64)
    (h : slot.val * LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT <
      2 ^ UScalarTy.U64.numBits) : Std.U64 :=
  UScalar.ofNatCore (slot.val * LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT) h

/-- The extracted slot-clock multiplication succeeds whenever its `u64`
    product is in range. -/
theorem intervalsAtSlotStart_eq (slot : Std.U64)
    (h : slot.val * LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT <
      2 ^ UScalarTy.U64.numBits) :
    slot_clock.intervals_at_slot_start slot = ok (startIntervalValue slot h) := by
  have hfive : LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT = 5 := rfl
  unfold slot_clock.intervals_at_slot_start verity_types.config.INTERVALS_PER_SLOT
  rw [bind_tc_ok]
  change UScalar.mul slot 5#u64 >>= (fun result => ok result) = _
  have hmul : slot.val * (5#u64).val < 2 ^ UScalarTy.U64.numBits := by
    simpa [hfive] using h
  rw [show UScalar.mul slot 5#u64 =
    ok (UScalar.ofNatCore (slot.val * (5#u64).val) hmul) from
      u64_mul_eq slot 5#u64 hmul, bind_tc_ok]
  simp [startIntervalValue, hfive]

/-- The successful extracted slot-clock result is formal-leanSpec's
    `Interval.fromSlot`; both enforce `INTERVALS_PER_SLOT = 5`. -/
theorem intervalsAtSlotStart_corresponds (slot : Std.U64)
    (h : slot.val * LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT <
      2 ^ UScalarTy.U64.numBits) :
    toLeanUint64 (startIntervalValue slot h) =
      LeanSpec.Forks.Lstar.Interval.fromSlot (toLeanSlot slot) := by
  apply (UInt64.toNat_inj).mp
  simp only [toLeanUint64_toNat, startIntervalValue, UScalar.ofNatCore_val_eq,
    LeanSpec.Forks.Lstar.Interval.fromSlot]
  rw [UInt64.toNat_ofNat_of_lt']
  simpa using h

/-- Direct correspondence witness for the extracted slot-clock computation. -/
theorem intervalsAtSlotStart_refines (slot : Std.U64)
    (h : slot.val * LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT <
      2 ^ UScalarTy.U64.numBits) :
    ∃ interval,
      slot_clock.intervals_at_slot_start slot = ok interval ∧
      toLeanUint64 interval =
        LeanSpec.Forks.Lstar.Interval.fromSlot (toLeanSlot slot) := by
  exact ⟨startIntervalValue slot h, intervalsAtSlotStart_eq slot h,
    intervalsAtSlotStart_corresponds slot h⟩

/-- The extracted interval constant equals formal-leanSpec's constant. -/
theorem intervalsPerSlot_corresponds :
    verity_types.config.INTERVALS_PER_SLOT = ok 5#u64 ∧
      (5#u64).val = LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT := by
  simp [verity_types.config.INTERVALS_PER_SLOT,
    LeanSpec.Forks.Lstar.INTERVALS_PER_SLOT]

/-- The extracted historical-roots limit equals `2^18` in formal-leanSpec. -/
theorem historicalRootsLimit_corresponds :
    verity_types.config.HISTORICAL_ROOTS_LIMIT = ok 262144#usize ∧
      (262144#usize).val = LeanSpec.Forks.Lstar.HISTORICAL_ROOTS_LIMIT := by
  norm_num [verity_types.config.HISTORICAL_ROOTS_LIMIT,
    LeanSpec.Forks.Lstar.HISTORICAL_ROOTS_LIMIT]

/-- The transcribed attestation-data cap equals formal-leanSpec's value. -/
theorem maxAttestationsData_corresponds :
    verity_types.config.MAX_ATTESTATIONS_DATA = ok 8#u8 ∧
      (8#u8).val = LeanSpec.Forks.Lstar.MAX_ATTESTATIONS_DATA := by
  norm_num [verity_types.config.MAX_ATTESTATIONS_DATA,
    LeanSpec.Forks.Lstar.MAX_ATTESTATIONS_DATA]

/-- The transcribed gossip-disparity interval equals formal-leanSpec's value. -/
theorem gossipDisparityIntervals_corresponds :
    verity_types.config.GOSSIP_DISPARITY_INTERVALS = ok 1#u64 ∧
      (1#u64).val = LeanSpec.Forks.Lstar.GOSSIP_DISPARITY_INTERVALS := by
  norm_num [verity_types.config.GOSSIP_DISPARITY_INTERVALS,
    LeanSpec.Forks.Lstar.GOSSIP_DISPARITY_INTERVALS]

/-- Verity's three available slot-duration literals satisfy
    `milliseconds-per-slot = intervals-per-slot * milliseconds-per-interval`. -/
theorem millisecondsConfig_arithmetic :
    verity_types.config.MILLISECONDS_PER_SLOT = ok 4000#u64 ∧
    verity_types.config.INTERVALS_PER_SLOT = ok 5#u64 ∧
    verity_types.config.MILLISECONDS_PER_INTERVAL = ok 800#u64 ∧
    (4000#u64).val = (5#u64).val * (800#u64).val := by
  norm_num [verity_types.config.MILLISECONDS_PER_SLOT,
    verity_types.config.INTERVALS_PER_SLOT,
    verity_types.config.MILLISECONDS_PER_INTERVAL]

end verity_chain.correspondence
