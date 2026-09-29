import LeanSpec.Networking.Config

namespace verity_p2p.model

/-- Pure transcription of Verity's three non-success response codes. -/
inductive ErrorCode where
  | invalidRequest
  | serverError
  | resourceUnavailable
  deriving DecidableEq, Repr

/-- Pure transcription of `ErrorCode::from_byte` at the pinned Verity revision. -/
def ErrorCode.fromByte (byte : UInt8) : Option ErrorCode :=
  let value := byte.toNat
  if value = 0 then none
  else if value = 1 then some .invalidRequest
  else if value = 2 then some .serverError
  else if value = 3 then some .resourceUnavailable
  else if value ≤ 127 then some .serverError
  else some .invalidRequest

/-- Recursive natural-number core of Verity's unsigned LEB128 writer. -/
def writeVarintNat (value : Nat) : List UInt8 :=
  let byte := UInt8.ofNat (value % 128)
  if value < 128 then
    [byte]
  else
    UInt8.ofNat (value % 128 + 128) :: writeVarintNat (value / 128)
  decreasing_by
    exact Nat.div_lt_self (Nat.lt_of_lt_of_le (by omega) (Nat.le_of_not_lt ‹¬value < 128›))
      (by omega)

/-- Pure transcription of Verity's `u64` LEB128 writer. -/
def writeVarint (value : UInt64) : List UInt8 :=
  writeVarintNat value.toNat

/-- `verity_p2p::config::MAX_REQUEST_BLOCKS`. -/
def MAX_REQUEST_BLOCKS : Nat := 1024

/-- `verity_p2p::config::MAX_PAYLOAD_SIZE`. -/
def MAX_PAYLOAD_SIZE : Nat := 10 * 1024 * 1024

/-- `verity_p2p::config::MIN_SLOTS_FOR_BLOCK_REQUESTS`. -/
def MIN_SLOTS_FOR_BLOCK_REQUESTS : Nat := 3600

/-- Pure transcription of `verity_p2p::config::max_compressed_len`. -/
def maxCompressedLen (uncompressed : Nat) : Nat :=
  32 + uncompressed + uncompressed / 6

end verity_p2p.model
