---
name: mlkit-release
description: Use when triaging incoming issues or PRs for google-mlkit-swiftpm, or when cutting a release. Covers the four failure modes consumers keep reporting (undefined symbols, "Invalid model path.", ITMS-91065, no arm64 simulator), how to tell them apart, and the build → verify → publish sequence.
---

# ML Kit SwiftPM triage and release

Read `CLAUDE.md` for the pipeline shape first. This skill is the procedure; that
file is the reference.

## Triage: match the report to a known mechanism

Almost every consumer report is one of these four. Identify the mechanism before
changing anything — three of the four are invisible when building the Example
app, because it links every product at once.

| Symptom | Mechanism | Check with |
| --- | --- | --- |
| `Undefined symbols … _OBJC_CLASS_$_MLKXeno*` when adopting one product | The `.library` product omits a transitive framework. A product links only the targets it lists. | `ruby scripts/check_product_closure.rb` |
| `MLKTextRecognizerInternalErrorCreationFailure "Invalid model path."`, or a framework binary that is ~33KB in the app | The framework binary is a bare Mach-O object, so Xcode relinks it as a dylib and dead-strips the model data | `file GoogleMLKit/<name>.xcframework/*/<name>.framework/<name>` — must say `ar archive` |
| `ITMS-91065: Missing signature` on upload | A framework bundle on Apple's commonly-used-SDK list is embedded in the app. Xcode embeds a stub bundle for every static framework bundle it links. | `./scripts/verify_local_archive.sh` |
| Cannot build for the Simulator on Apple Silicon | The simulator slice has no arm64. Xcode 26 dropped Rosetta simulators, so an x86_64-only slice is unusable. | `lipo -archs` on the simulator slice |

Reports about **missing dSYMs** are expected and harmless: Google ships no
DWARF, the frameworks are static, and their symbols land in the consumer's own
dSYM. Close with that explanation.

## Triage: dependency PRs

- `Package.swift` dependency pins are **generated** from `Podfile.lock` by
  `scripts/update_package_dependencies.rb`. `renovate.json` disables the `swift`
  manager for the root `Package.swift`; close any PR that still slips through,
  and never merge one that breaks a pod constraint (e.g. `GTMSessionFetcher`
  is pinned `< 4.0`).
- Ruby major upgrades are blocked on purpose: Ruby 4.0 broke CocoaPods on the
  macOS runners.
- Anything touching `Example/` only is safe to merge on a green CI run.

## Fix, then verify before publishing

```bash
make run                          # full pipeline into GoogleMLKit/
make verify                       # closure + artifacts + Package.swift parse
./scripts/verify_local_archive.sh # builds for arm64 Simulator, archives for device
```

`verify_local_archive.sh` is the gate. It repoints `Package.swift` at the local
XCFrameworks, builds and archives, and fails if an ITMS-scanned SDK is embedded,
if anything is linked dynamically, or if the app binary is too small to still
contain the ML Kit model data. Never publish without a green run.

To reproduce a consumer's single-product setup, the static closure check is
enough — do not rely on the Example app.

## Publish

```bash
ruby scripts/update_version.rb <version>      # only when bumping the pod version
gh release create <version> --prerelease      # prerelease when the tag has a suffix
./scripts/upload_release.sh <version>         # uploads *.xcframework.zip and *.bundle.zip
ruby scripts/update_checksums.rb <version>    # rewrites Package.swift URLs + SHA256s
swift package dump-package > /dev/null
```

Prefer the **Build MLKit XCFrameworks** workflow for a normal version bump; do
it locally only when the pipeline itself changed, since that is what needs
verifying. Resource bundles must be uploaded too — consumers add them by hand,
and `scripts/download_bundles.sh` fetches them from the release.

After publishing, reply on each issue the release fixes with the tag and the
manual steps it still requires (bundles, `-ObjC -all_load`).

## When adding a module

`Podfile` → `Resources/<Name>-Info.plist` → `MLKIT_MODULES` in the `Makefile` →
`Package.swift` (`.binaryTarget` plus product wiring). Everything else derives
from those. Finish with `ruby scripts/check_product_closure.rb`.
