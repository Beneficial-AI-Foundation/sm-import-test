# sm-import-test

Minimal Lean 4 project that imports [secure-messaging](https://github.com/Beneficial-AI-Foundation/secure-messaging), used to test that [`probe merge`](https://github.com/Beneficial-AI-Foundation/probe) combines call-graph atoms from two Lean projects where one imports the other.

`SmImportTest.lean` defines three declarations (`constCode`, `constCode_encode`, `constCode_decode`) that reference `SecureMessaging.ErasureCode.Defs`. Extracting both projects with probe-lean and merging the two extracts yields a single graph in which the atoms of this project have dependency edges resolving to secure-messaging atoms.

## Committed artifacts

- `.verilib/probes/lean_SmImportTest_0.1.0.json` — probe-lean extract of this project (3 atoms).
- `.verilib/probes/lean_SecureMessaging_d5dbd6e.json` — probe-lean extract of secure-messaging at commit `d5dbd6e` (1543 atoms; copied here for reproducibility).
- `.verilib/probes/merged_smimporttest_securemessaging.json` — `probe merge` output: 1546 atoms, schema `probe/merged-atoms` 3.0, both sources recorded under `inputs`. External dependency edges of this project's atoms (e.g. `probe:ErasureCode.encode`) resolve to atom keys present in the merged graph.

## Reproducing

Prerequisites:

- A sibling checkout of secure-messaging at `../secure-messaging`, on commit `d5dbd6e`, fully built (`lake build`) with Lean `v4.33.1`.
- `probe-lean` v0.14.0 built for Lean `v4.33.1` (probe-lean binaries must match the target project's toolchain; see the [probe-lean releases](https://github.com/Beneficial-AI-Foundation/probe-lean/releases)).
- The `probe` hub CLI (v0.4.0) for the merge step.

Steps:

```bash
# 1. Build this project. Finishes in seconds: all dependency artifacts
#    (mathlib etc.) are reused from the secure-messaging checkout.
lake build

# 2. Extract atoms from both projects.
probe-lean extract . -l SmImportTest
probe-lean extract ../secure-messaging -l SecureMessaging

# 3. Merge the two extracts.
probe merge \
  .verilib/probes/lean_SmImportTest_0.1.0.json \
  ../secure-messaging/.verilib/probes/lean_SecureMessaging_d5dbd6e.json \
  -o .verilib/probes/merged_smimporttest_securemessaging.json
```
