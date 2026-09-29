import LeanSpec.Networking.Allocation
import VerityP2P.Model

namespace verity_p2p.correspondence

open LeanSpec.Networking

/-- Bridge Verity's `None = SUCCESS` representation to formal-leanSpec's
four-constructor response code. -/
def toResponseCode : Option model.ErrorCode → ResponseCode
  | none => .success
  | some .invalidRequest => .invalidRequest
  | some .serverError => .serverError
  | some .resourceUnavailable => .resourceUnavailable

/-- Exact response-code classification shared by the pinned Rust implementation
and formal-leanSpec's response-code representation. -/
def decodeResponseCode (byte : UInt8) : ResponseCode :=
  let value := byte.toNat
  if value = 0 then .success
  else if value = 1 then .invalidRequest
  else if value = 2 then .serverError
  else if value = 3 then .resourceUnavailable
  else if value ≤ 127 then .serverError
  else .invalidRequest

/-- The transcribed `ErrorCode::from_byte` agrees exactly with the formal
four-constructor response-code view for every wire byte. -/
theorem errorCode_fromByte_eq (byte : UInt8) :
    toResponseCode (model.ErrorCode.fromByte byte) = decodeResponseCode byte := by
  by_cases h0 : byte.toNat = 0
  · simp [model.ErrorCode.fromByte, decodeResponseCode, toResponseCode, h0]
  by_cases h1 : byte.toNat = 1
  · simp [model.ErrorCode.fromByte, decodeResponseCode, toResponseCode, h1]
  by_cases h2 : byte.toNat = 2
  · simp [model.ErrorCode.fromByte, decodeResponseCode, toResponseCode, h2]
  by_cases h3 : byte.toNat = 3
  · simp [model.ErrorCode.fromByte, decodeResponseCode, toResponseCode, h3]
  by_cases h127 : byte.toNat ≤ 127
  · simp [model.ErrorCode.fromByte, decodeResponseCode, toResponseCode, h0, h1, h2, h3,
      h127]
  · simp [model.ErrorCode.fromByte, decodeResponseCode, toResponseCode, h0, h1, h2, h3,
      h127]

/-- Unknown response bytes 4 through 127 degrade to `SERVER_ERROR`. -/
theorem errorCode_fromByte_server_range (byte : UInt8)
    (hlower : 4 ≤ byte.toNat) (hupper : byte.toNat ≤ 127) :
    model.ErrorCode.fromByte byte = some .serverError := by
  have h0 : byte.toNat ≠ 0 := by omega
  have h1 : byte.toNat ≠ 1 := by omega
  have h2 : byte.toNat ≠ 2 := by omega
  have h3 : byte.toNat ≠ 3 := by omega
  simp [model.ErrorCode.fromByte, h0, h1, h2, h3, hupper]

/-- Unknown response bytes 128 through 255 degrade to `INVALID_REQUEST`. -/
theorem errorCode_fromByte_invalid_range (byte : UInt8)
    (hlower : 128 ≤ byte.toNat) :
    model.ErrorCode.fromByte byte = some .invalidRequest := by
  have h0 : byte.toNat ≠ 0 := by omega
  have h1 : byte.toNat ≠ 1 := by omega
  have h2 : byte.toNat ≠ 2 := by omega
  have h3 : byte.toNat ≠ 3 := by omega
  have h127 : ¬byte.toNat ≤ 127 := by omega
  simp [model.ErrorCode.fromByte, h0, h1, h2, h3, h127]

private theorem writeVarintNat_length : ∀ value : Nat,
    (model.writeVarintNat value).length = varintSize value
  | value => by
    rw [model.writeVarintNat.eq_def, varintSize.eq_def]
    split
    · rfl
    · simp only [List.length_cons]
      rw [writeVarintNat_length]
      omega

/-- Verity's `u64` LEB128 writer emits exactly formal-leanSpec's
`varintSize` bytes. -/
theorem writeVarint_length (value : UInt64) :
    (model.writeVarint value).length = varintSize value.toNat := by
  exact writeVarintNat_length value.toNat

/-- The request-block cap is identical on both sides. -/
theorem maxRequestBlocks_eq :
    model.MAX_REQUEST_BLOCKS = MAX_REQUEST_BLOCKS := by
  rfl

/-- The uncompressed payload cap is identical on both sides. -/
theorem maxPayloadSize_eq :
    model.MAX_PAYLOAD_SIZE = MAX_PAYLOAD_SIZE := by
  rfl

/-- The minimum served history window is identical on both sides. -/
theorem minSlotsForBlockRequests_eq :
    model.MIN_SLOTS_FOR_BLOCK_REQUESTS = MIN_SLOTS_FOR_BLOCK_REQUESTS := by
  rfl

/-- Verity's compressed bound is uniformly 992 bytes below the formula used by
formal-leanSpec's allocation model. -/
theorem compressedBound_relation (uncompressed : Nat) :
    model.maxCompressedLen uncompressed + 992 =
      uncompressed + uncompressed / 6 + 1024 := by
  simp [model.maxCompressedLen]
  omega

/-- The distinct formulas give distinct bounds at the common 10 MiB cap. -/
theorem compressedBound_at_max_counterexample :
    model.maxCompressedLen model.MAX_PAYLOAD_SIZE = 12233418 ∧
      MAX_COMPRESSED_PAYLOAD_SIZE = 12234410 ∧
      model.maxCompressedLen model.MAX_PAYLOAD_SIZE ≠ MAX_COMPRESSED_PAYLOAD_SIZE := by
  decide

private def thirtyThreeBytes : ByteArray :=
  ⟨Array.replicate 33 0⟩

private def emptyDecompressor : ByteArray → Option ByteArray :=
  fun _ => some ByteArray.empty

/-- Checked model counterexample: formal-leanSpec's abstract reader accepts 33
compressed bytes for a declared empty payload, while Verity's bound is 32. -/
theorem formalReader_accepts_above_verity_bound :
    model.maxCompressedLen 0 < thirtyThreeBytes.size ∧
      readRequest emptyDecompressor 0 thirtyThreeBytes = some ByteArray.empty := by
  decide

end verity_p2p.correspondence
