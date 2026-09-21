# sm-import-test

Minimal Lean 4 project that imports [secure-messaging](https://github.com/Beneficial-AI-Foundation/secure-messaging), used to test that [`probe merge`](https://github.com/Beneficial-AI-Foundation/probe) combines call-graph atoms from two Lean projects where one imports the other. `SmImportTest.lean` defines three declarations referencing `SecureMessaging.ErasureCode.Defs`; merging the two probe-lean extracts yields a single graph with cross-project dependency edges.

- Browsable merged call graph: https://beneficial-ai-foundation.github.io/sm-import-test/
- Graph JSONs and how to regenerate them: [`.verilib/probes/README.md`](.verilib/probes/README.md)
- Pages deployment: [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml)
