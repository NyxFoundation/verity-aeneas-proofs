import LeanSpec.SSZ.Bytes32
import LeanSpec.SSZ.Hash
import LeanSpec.SSZ.Uint64
import VerityChain.Funs

open Aeneas Aeneas.Std RustM

namespace verity_chain.correspondence

/-- Convert Aeneas's fixed-width `u64` model to formal-leanSpec's `Uint64`. -/
def toLeanUint64 (value : Std.U64) : LeanSpec.SSZ.Uint64 :=
  UInt64.ofNat value.val

@[simp]
theorem toLeanUint64_toNat (value : Std.U64) :
    (toLeanUint64 value).toNat = value.val := by
  simp [toLeanUint64]

/-- SSZ-2 for every Verity `u64` newtype after Aeneas erases the transparent wrapper. -/
theorem verityUint64_range (value : Std.U64) :
    (toLeanUint64 value).toNat < 2 ^ 64 := by
  exact LeanSpec.SSZ.Uint64.range (toLeanUint64 value)

/-- Convert Aeneas's Rust `[u8; 32]` model to formal-leanSpec's `Bytes32`. -/
def toLeanBytes32 (bytes : Array Std.U8 32#usize) : LeanSpec.SSZ.Bytes32 :=
  ⟨⟨(bytes.val.map (fun byte => UInt8.ofNat byte.val)).toArray⟩, by
    rw [ByteArray.size, List.size_toArray, List.length_map]
    simp [bytes.property]⟩

/-- SSZ-4: the conversion from Verity's extracted `[u8; 32]` always has size 32. -/
theorem toLeanBytes32_size (bytes : Array Std.U8 32#usize) :
    (toLeanBytes32 bytes).size = 32 := by
  exact LeanSpec.SSZ.Bytes32.size_eq_32 (toLeanBytes32 bytes)

/-- The extracted Verity Merkle wrapper delegates unchanged to its Rust trait operation.

This is the strongest implementation statement available for SSZ-7. Collision resistance
remains formal-leanSpec's explicit cryptographic axiom and is not claimed for an arbitrary
Aeneas `HashTreeRoot` instance.
-/
theorem hashTreeRoot_forwards
    {T : Type} (hashTreeRootInst : libssz_merkle.HashTreeRoot T) (value : T) :
    merkle.hash_tree_root hashTreeRootInst value =
      hashTreeRootInst.hash_tree_root
        libssz_merkle.Sha2Hasher.Insts.Libssz_merkleSha256Hasher value () := by
  rfl

end verity_chain.correspondence
