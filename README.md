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

To check the result, confirm the merged file contains atoms from both packages and that the cross-project edges resolve:

```bash
python3 - <<'EOF'
import json
d = json.load(open('.verilib/probes/merged_smimporttest_securemessaging.json'))
data = d['data']
print(len(data), 'atoms;', 'inputs:', [i['source']['package'] for i in d['inputs']])
a = data['probe:constCode_encode']
ext = a['term-dependencies-external'] + a['type-dependencies-external']
print('resolved cross-project deps:', sorted({e for e in ext if e in data}))
EOF
```

Expected output: `1546 atoms; inputs: ['SmImportTest', 'SecureMessaging']` and `['probe:ErasureCode.encode']`.

## How the dependency reuse works

Both toolchains must match exactly (`leanprover/lean4:v4.33.1`, see `lean-toolchain`) for `.olean` compatibility. Two tricks make the build near-instant instead of rebuilding mathlib:

- `lakefile.toml` sets `packagesDir = "../secure-messaging/.lake/packages"`, so lake looks for dependency clones (mathlib, VCVio, ...) where secure-messaging already has them built.
- `lake-manifest.json` is a copy of secure-messaging's manifest with the root renamed to `SmImportTest`, all git packages marked `inherited`, and `SecureMessaging` appended as a path package. Pinning the same revs prevents lake from touching the existing clones or re-resolving anything.

If secure-messaging moves to a new commit or toolchain, rebuild it there first, regenerate this project's `lake-manifest.json` from its manifest the same way, and update `lean-toolchain` to match.

## Background

The motivating case is [SparsePostQuantumRatchet-verify](https://github.com/Beneficial-AI-Foundation/SparsePostQuantumRatchet-verify) importing secure-messaging models directly instead of vendoring them (see its PR #503). That import is currently blocked on toolchains: spqr-verify pins Lean `v4.31.0` because Aeneas (including current main) pins `v4.31.0`, while secure-messaging is on `v4.33.1`. This dummy project exercises the same probe-lean extract + `probe merge` path without that constraint; once Aeneas reaches `v4.33.1`, the same steps apply to spqr-verify directly.
