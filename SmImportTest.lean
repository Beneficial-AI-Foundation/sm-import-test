import SecureMessaging.ErasureCode.Defs

/-!
# SmImportTest

Minimal project importing secure-messaging, used to test that `probe merge`
combines atoms from two Lean projects where one imports the other.
-/

/-- A degenerate erasure code over `Bool` with a single chunk position:
encoding returns the sole message symbol, decoding always fails. -/
def constCode : ErasureCode Bool where
  N := 1
  N_pos := Nat.one_pos
  nchunk := 1
  nchunk_pos := Nat.one_pos
  nchunk_le_N := Nat.le_refl 1
  encode := fun m _ => m 0
  decode := fun _ => none

/-- `constCode` encodes every message to its sole symbol. -/
theorem constCode_encode (m : Fin 1 → Bool) (i : Fin 1) :
    constCode.encode m i = m 0 := rfl

/-- `constCode` never decodes. -/
theorem constCode_decode (L : Finset (Fin constCode.N × Bool)) :
    constCode.decode L = none := rfl

/-- Honest chunks of `constCode` at all positions are decodable. The proof
applies secure-messaging's `decodable_encodeChunks_of_nchunk_le_card`, so the
call graph has a theorem-to-theorem edge across the two projects. -/
theorem constCode_decodable_univ (m : Fin 1 → Bool) :
    ErasureCode.Decodable constCode.nchunk (constCode.encodeChunks m Finset.univ) :=
  constCode.decodable_encodeChunks_of_nchunk_le_card m Finset.univ
    (by simpa [constCode] using Finset.univ_nonempty)
