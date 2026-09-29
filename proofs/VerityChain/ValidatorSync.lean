import LeanSpec.Sync.States
import LeanSpec.Validator.Registry
import LeanSpec.Validator.Service
import Mathlib.Data.Finset.Basic

namespace verity_chain.correspondence.validator_sync

/-! Source-faithful pure models for the pinned Verity validator and sync code.

These models cover only branches that are pure in the Rust source. They do not
pretend to model filesystem I/O, async channels, or leanSig cryptography. -/

namespace Validator

/-- The equality gate at `verity_crypto::keystore::load_validator`: decoded
manifest public keys are accepted only when the two roles differ. -/
def declaredRoleGate {Key : Type} [DecidableEq Key]
    (attestation proposal : Key) : Option (Key × Key) :=
  if attestation = proposal then none else some (attestation, proposal)

/-- VAL-2's pure load-time gate accepts exactly distinct role keys. -/
theorem declaredRoleGate_isSome_iff {Key : Type} [DecidableEq Key]
    (attestation proposal : Key) :
    (declaredRoleGate attestation proposal).isSome = true ↔
      attestation ≠ proposal := by
  simp [declaredRoleGate]

/-- Any pair returned by the pinned load-time gate has distinct keys. -/
theorem declaredRoleGate_distinct {Key : Type} [DecidableEq Key]
    (attestation proposal loadedAttestation loadedProposal : Key)
    (h : declaredRoleGate attestation proposal =
      some (loadedAttestation, loadedProposal)) :
    loadedAttestation ≠ loadedProposal := by
  unfold declaredRoleGate at h
  split at h
  · simp at h
  · next hne =>
    injection h with hpair
    injection hpair with hatt hprop
    subst hatt
    subst hprop
    exact hne

/-- The pure state relevant to `DutyService::attest`. A `Finset` models the
membership and insertion behavior of Rust's `BTreeSet`; ordering is irrelevant
to the safety property. -/
structure AttestedState where
  slots : Finset Nat
  deriving DecidableEq

/-- Exact non-overflowing arithmetic of the pinned retain closure
`attested + 4 > slot`. Runtime slots are represented by their `u64` values. -/
def pruneAttested (slot : Nat) (slots : Finset Nat) : Finset Nat :=
  slots.filter fun attested => slot < attested + 4

/-- The pure prefix of the pinned async `attest` method. `true` means the method
passed the duplicate gate and recorded the slot before performing effects. -/
def attestGate (state : AttestedState) (slot : Nat) : AttestedState × Bool :=
  if slot ∈ state.slots then
    (state, false)
  else
    ({ slots := pruneAttested slot (insert slot state.slots) }, true)

/-- VAL-4: a remembered slot cannot pass the attestation gate. -/
theorem attestGate_rejects_remembered (state : AttestedState) (slot : Nat)
    (h : slot ∈ state.slots) :
    (attestGate state slot).2 = false := by
  simp [attestGate, h]

/-- A slot that passes the gate is retained by that same step. This uses exact
integer arithmetic; in Rust it applies while `slot + 4` does not overflow. -/
theorem attestGate_records_fired (state state' : AttestedState) (slot : Nat)
    (h : attestGate state slot = (state', true)) :
    slot ∈ state'.slots := by
  unfold attestGate at h
  split at h
  · simp at h
  · injection h with hstate
    subst hstate
    simp [pruneAttested]

/-- VAL-4, sharpened: after a successful gate step, the next pass for the same
slot is rejected. Signing and channel failures cannot reopen the gate because
Verity inserts before either effect. -/
theorem attestGate_no_double_vote_after
    (state state' : AttestedState) (slot : Nat)
    (h : attestGate state slot = (state', true)) :
    (attestGate state' slot).2 = false :=
  attestGate_rejects_remembered state' slot
    (attestGate_records_fired state state' slot h)

/-- Finite-width version of the attested-slot state, used to expose Rust's
release-mode `u64` wraparound boundary. -/
structure AttestedStateU64 where
  slots : Finset UInt64
  deriving DecidableEq

/-- Exact release-mode arithmetic of the pinned retain closure. -/
def pruneAttestedU64 (slot : UInt64) (slots : Finset UInt64) : Finset UInt64 :=
  slots.filter fun attested => slot < attested + UInt64.ofNat 4

/-- Exact finite-width duplicate gate around `pruneAttestedU64`. -/
def attestGateU64 (state : AttestedStateU64) (slot : UInt64) :
    AttestedStateU64 × Bool :=
  if slot ∈ state.slots then
    (state, false)
  else
    ({ slots := pruneAttestedU64 slot (insert slot state.slots) }, true)

/-- Boundary counterexample for an unconditional VAL-4 claim: at `u64::MAX`,
the release-mode retention addition wraps, immediately forgets the fired slot,
and lets the next identical duty through. Debug overflow checks panic instead. -/
theorem attestGate_wraparound_counterexample :
    let max := UInt64.ofNat 18446744073709551615
    let first := attestGateU64 ⟨∅⟩ max
    first.2 = true ∧ max ∉ first.1.slots ∧
      (attestGateU64 first.1 max).2 = true := by
  decide

/-- The state bit used by Verity's lag/hysteresis duty gate. -/
structure LagGate where
  closed : Bool
  deriving DecidableEq, Repr

/-- The pinned `LagGate::admits` transition, using natural subtraction for
Rust's `saturating_sub`. The result is the updated gate and its verdict. -/
def lagGateAdmits (gate : LagGate) (slot headSlot maxSeen : Nat) :
    LagGate × Bool :=
  let headLag := slot - headSlot
  let networkLag := slot - maxSeen
  let closed :=
    if networkLag > 8 then false
    else if gate.closed then decide (headLag > 2)
    else decide (headLag > 4)
  ({ closed }, !closed)

/-- Concrete duty-gate divergence: at genesis Verity serves duties even though
formal-leanSpec's explicit `synced` input can be false. -/
theorem dutyGate_allows_unsynced_counterexample :
    (lagGateAdmits ⟨false⟩ 0 0 0).2 = true ∧
    LeanSpec.Validator.ValidatorService.attestationDue
      ⟨[]⟩ (UInt64.ofNat 0) (UInt64.ofNat 1) false = false := by
  decide

/-- The converse divergence: a caught-up verdict does not make Verity serve
when the local head is stale and the observed network is still moving. -/
theorem dutyGate_denies_synced_counterexample :
    (lagGateAdmits ⟨false⟩ 9 0 9).2 = false ∧
    LeanSpec.Validator.ValidatorService.attestationDue
      ⟨[]⟩ (UInt64.ofNat 9) (UInt64.ofNat 1) true = true := by
  decide

end Validator

namespace Sync

abbrev State := LeanSpec.Sync.SyncState

/-- `None` is Verity's internal representation of the externally visible idle
state before the first peer observation. -/
def visibleState : Option State → State
  | none => .idle
  | some state => state

/-- Pure transcription of `SyncMachine::observe`. `none` means no peer has
answered; `some behind` is the comparison `head_slot < network_finalized`. -/
def observe (state : Option State) (behind : Option Bool) : Option State :=
  match behind with
  | none => state
  | some behind =>
      some <| match state, behind with
      | none, _ => .syncing
      | some .syncing, false => .synced
      | some .synced, true => .syncing
      | some current, _ => current

/-- The state returned by the Rust method after applying `observe`. -/
def observeResult (state : Option State) (behind : Option Bool) : State :=
  visibleState (observe state behind)

/-- SYNC-1's strongest valid refinement: each observation either stutters or
takes one of formal-leanSpec's permitted transitions. -/
theorem observe_stutter_or_transition (state : Option State)
    (behind : Option Bool) :
    observeResult state behind = visibleState state ∨
      LeanSpec.Sync.SyncState.canTransitionTo
        (visibleState state) (observeResult state behind) := by
  cases state with
  | none =>
    cases behind with
    | none => exact .inl rfl
    | some behind =>
      cases behind <;>
        exact .inr LeanSpec.Sync.SyncState.canTransitionTo.idle_to_syncing
  | some state =>
    cases state with
    | idle =>
      cases behind with
      | none => exact .inl rfl
      | some behind => cases behind <;> exact .inl rfl
    | syncing =>
      cases behind with
      | none => exact .inl rfl
      | some behind =>
        cases behind
        · exact .inr LeanSpec.Sync.SyncState.canTransitionTo.syncing_to_synced
        · exact .inl rfl
    | synced =>
      cases behind with
      | none => exact .inl rfl
      | some behind =>
        cases behind
        · exact .inl rfl
        · exact .inr LeanSpec.Sync.SyncState.canTransitionTo.synced_to_syncing

/-- An initial observation never shortcuts idle directly to synced. -/
theorem observe_initial_ne_synced (behind : Option Bool) :
    observeResult none behind ≠ .synced := by
  cases behind with
  | none => simp [observeResult, observe, visibleState]
  | some behind => cases behind <;> simp [observeResult, observe, visibleState]

/-- Verity returns a syncing self-transition when an observation still says it
is behind; formal `canTransitionTo` has no syncing self-edge. -/
theorem syncing_stutter_counterexample :
    observeResult (some .syncing) (some true) = .syncing ∧
    ¬LeanSpec.Sync.SyncState.canTransitionTo .syncing .syncing := by
  constructor
  · rfl
  · intro h
    cases h

/-- Verity returns a synced self-transition when an observation still says it
is caught up; formal `canTransitionTo` has no synced self-edge. -/
theorem synced_stutter_counterexample :
    observeResult (some .synced) (some false) = .synced ∧
    ¬LeanSpec.Sync.SyncState.canTransitionTo .synced .synced := by
  constructor
  · rfl
  · intro h
    cases h

/-- The pinned network bridge attempts to forward every gossip event without
consulting sync state. Queue saturation is a later, state-independent drop. -/
def attemptsGossipForward (_ : State) : Bool := true

/-- SYNC-2 divergence at idle: Verity attempts forwarding while the formal
state gate rejects gossip. -/
theorem gossipGate_idle_counterexample :
    attemptsGossipForward .idle = true ∧
      LeanSpec.Sync.SyncState.acceptsGossip .idle = false := by
  decide

end Sync

end verity_chain.correspondence.validator_sync
