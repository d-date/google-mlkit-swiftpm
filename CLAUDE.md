# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A SwiftPM binary-distribution wrapper around Google ML Kit. ML Kit ships only via CocoaPods, so this repo builds those pods into XCFrameworks with [swiftpods](https://github.com/d-date/swiftpods), publishes the zips as GitHub Release assets, and exposes 19 SwiftPM library products in `Package.swift` whose `binaryTarget`s point at those zips.

This is **not an app project**. The inputs are `Podfile.swift` and `Podfile.lock`; `Package.swift` and `Sources/Common/export.swift` are **generated** by `swiftpods package` — never edit them by hand, the next run overwrites them.

For deeper detail see `AGENTS.md` (short agent guide), `AUTOMATION.md` (automation reference), `TESTING.md` (test levels + known runtime issues), and `scripts/README.md` (per-script reference). Avoid duplicating their content here.

## Common commands

### Build / release (local)

swiftpods needs Xcode with Swift 6.4. Build it from a checkout of d-date/swiftpods with `swift build -c release --product swiftpods`.

- `swiftpods package --version <version>` — installs the pods per `Podfile.lock`, builds them for both SDKs, writes every `<Module>.xcframework.zip` and `<Bundle>.bundle.zip` to `build/distribution/`, regenerates `Package.swift` and `Sources/Common/export.swift`, and links every product on its own (simulator + device, `-ObjC -all_load`)
- `swiftpods update` — move `Podfile.lock` after raising the `GoogleMLKit/*` requirements in `Podfile.swift`
- `scripts/release.sh [--skip-package] <version>` — runs `swiftpods package` (unless skipped), refuses if a zip that `Package.swift` references is missing, points at another release or fails its checksum, or if the tag `<version>` on origin carries a different `Package.swift`; then creates the GitHub Release and uploads the referenced xcframework zips plus every `*.bundle.zip`. `SWIFTPODS` overrides the binary path.

Versions: major.minor follow ML Kit, the patch number counts wrapper releases (`9.0.4` repackages ML Kit `9.0.0`).

### Inspect / verify

- `./scripts/verify_local_archive.sh` — the pre-release gate. Repoints `Package.swift` at `build/distribution/` (via `scripts/use_local_binaries.swift`), unpacks the bundle zips into `build/bundles/`, **runs ML Kit on the arm64 Simulator** (`CameraTests`), **launches the app** there, archives for device, and asserts every model bundle reached the app, nothing ITMS-scanned is embedded, nothing is linked dynamically and the model data survived. The runtime steps are the only ones that catch a missing model bundle or a bad simulator slice — a linking check cannot.
- `./scripts/verify_app_store_upload.sh [--upload]` — archives with distribution signing, exports an App Store IPA, validates it with Apple and optionally delivers it. ITMS-91065 is raised by App Store Connect's post-upload processing, not by a local export or by `altool --validate-app`, so confirming that class of problem needs the `--upload` run.
- `swift package dump-package` — validate `Package.swift` (CI runs this too)
- `swift scripts/check_mlkit_version.swift` — compare the latest GoogleMLKit on the CocoaPods Trunk API with the requirement in `Podfile.swift`
- `swift scripts/use_local_binaries.swift` — repoint every `binaryTarget` at `build/distribution/*.xcframework`; undo with `git checkout Package.swift`

### Example app

- `cd Example && open Example.xcworkspace` — SwiftUI demo app depending on the package via `path: "../../"`. Runs on both a real device and the Apple Silicon simulator. It needs the resource bundles first: `./scripts/download_bundles.sh <version>`, or unzip `build/distribution/*.bundle.zip` into `Example/Example/Resources/Bundles/` after a local build.
- The app links **every** product at once, so it cannot catch a product that omits a transitive framework — `swiftpods package` links each product on its own for that.
- `Example/Package/Tests/CameraTests` holds the runtime smoke tests. They need `-Xlinker -ObjC -Xlinker -all_load` (declared on the test target) and the resource bundles staged into the built `.xctest`, which `verify_local_archive.sh` does — ML Kit resolves models against the main bundle, which for a SwiftPM test target is the test runner. Without `LatinOCRResources.bundle` in `CameraTests.xctest`, text recognition fails with "Invalid model path.".

### CI (GitHub Actions)

- `Build MLKit XCFrameworks` (`.github/workflows/build-mlkit.yml`) — manual `workflow_dispatch` with `version` and `create_release` inputs. Builds swiftpods from d-date/swiftpods at `SWIFTPODS_REF` (`main` until a tag is pinned), runs `swiftpods package`, commits `Podfile.swift`/`Podfile.lock`/`Package.swift`/`Sources/Common/export.swift` if changed, tags, pushes, and runs `scripts/release.sh --skip-package`. Preferred over local builds for shipping a version.
- `Check MLKit Updates` (`.github/workflows/check-mlkit-updates.yml`) — daily cron at 09:00 UTC. Opens an issue when CocoaPods has a newer version.
- `CI` (`.github/workflows/ci.yml`) — runs on every PR: type-checks the Swift scripts, checks shell syntax and `swift package dump-package`.

## What `Podfile.swift` sets

- `platform: .iOS("15.5")` — the minimum the ML Kit 9 pods declare; it becomes the `Package.swift` platform.
- `useFrameworks: .static` — keeps GoogleToolboxForMac and SSZipArchive, the only pods built from source, out of the consumer app's Frameworks directory (ITMS-91065, see Gotchas). swiftpods ships them as library XCFrameworks (`lib<Module>.a`).
- `installationOptions: .init(integrateTargets: false)` and one target `MLKit` — required by `swiftpods package`.
- `packages:` — the Google SwiftPM packages the pods are unified with. Two carry `overridingPodRequirements: .unsafe(reason:)`:
  - `gtm-session-fetcher` `3.5.0..<6.0.0` (pods require `>= 3.3.2, < 4.0`) — ABI checked by hand for Firebase 13 (#124, #125)
  - `nanopb` `2.30910.0..<2.30911.0` (pods require `~> 3.30910.0`) — Firebase 13.1.1 requires `2.30910.1`, a fork commit of the pods' `2.30910.0`

  `swiftpods package` keeps these declared ranges and starts `Package.swift` with one `#warning` per override, which `swift package resolve` prints to consumers.
- `distribution:` — package name and the repository URL the binary target URLs are built from (`<url>/releases/download/<version>/<Module>.xcframework.zip`).

### Module surface in `Package.swift`

- 19 `.library` products — one per declared `GoogleMLKit/*` subspec — and 33 `.binaryTarget` entries, derived by swiftpods from the pod graph.
- One source `.target` named `Common` re-exports the prebuilt frameworks every product needs and links the Google SwiftPM products (GoogleUtilities, gtm-session-fetcher, GoogleDataTransport, nanopb, promises) and the system frameworks the pods declare.

## Gotchas

- **Consumer linker flags.** Apps consuming this package must add `-ObjC` and `-all_load` to *Other Linker Flags*, otherwise they crash at runtime with `unrecognized selector` or a model that refuses to load.
- **Resource bundles are separate release assets.** SwiftPM cannot carry a bundle inside a binary target, so consumers add them by hand. A missing bundle builds and archives fine and only fails when inference runs: text recognition throws `MLKTextRecognizerInternalErrorCreationFailure`, "Invalid model path." (issues #106/#109). `release.sh` uploads every `*.bundle.zip` swiftpods wrote.
- **Framework binaries must be `ar` archives.** Xcode treats a framework whose binary is a bare Mach-O object as *dynamic* and relinks it, dead-stripping unreferenced data — `MLKitTextRecognitionCommon` came out as a ~33KB stub instead of ~58MB (issue #106). swiftpods converts them; `verify_local_archive.sh` checks the app binary size.
- **ITMS-91065 comes from embedding.** Xcode embeds a *stub* framework bundle into the consumer app for every static framework bundle it links. Apple's scanner flags an embedded GoogleToolboxForMac/SSZipArchive and demands a signature this repo cannot provide (issue #102). Library-type XCFrameworks are linked, never embedded.
- **The arm64 simulator slice is synthesised, not shipped by Google.** swiftpods makes it from the device slice; Xcode 26 dropped Rosetta simulators, so without it the package cannot run in the Simulator on Apple Silicon (issue #112).
- **A product only links the targets it lists.** The Example app depends on every product at once and cannot catch an omission (issue #110); `swiftpods package` links each product on its own and fails otherwise.
- **`Package.swift` dependency ranges are generated.** `renovate.json` disables the `swift` manager for the root `Package.swift`; widen a range in `Podfile.swift` instead, with an unsafe override only after checking the ABI.
- **Adding a new ML Kit module.** Add the `GoogleMLKit/<Subspec>` pod to `Podfile.swift`, run `swiftpods update`, then `swiftpods package`. Products, binary targets and bundles derive from the pod graph.

## Conventions (from AGENTS.md, abbreviated)

- iOS 15.5+ (from `Podfile.swift`); `Package.swift` is generated.
- No new third-party dependencies without asking first.
- Swift scripts run with `swift scripts/<name>.swift` and use Foundation only; the repository needs no Ruby.
