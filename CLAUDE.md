# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A SwiftPM binary-distribution wrapper around Google ML Kit. ML Kit ships only via CocoaPods, so this repo downloads those pods, rebuilds them with `xcodebuild`, converts them to XCFrameworks, zips them, publishes the zips as GitHub Release assets, and exposes 17 SwiftPM library products in `Package.swift` whose `binaryTarget`s point at those zips.

This is **not an app project**. Almost all maintenance work happens in the build pipeline (`Makefile`, `Podfile`, `Package.swift`, `Resources/*-Info.plist`, `scripts/*.rb`), not in Swift sources. The only first-party Swift file is `Sources/Common/export.swift` (`@_exported import MLKitCommon`).

For deeper detail see `AGENTS.md` (short agent guide), `AUTOMATION.md` (full automation reference), `TESTING.md` (manual test checklist + known runtime issues), and `scripts/README.md` (per-script reference). Avoid duplicating their content here.

## Common commands

### Build / release (local)

- `git submodule update --init` — required before first build (initialises `xcframework-maker/`)
- `make bootstrap-builder` — build the `xcframework-maker` tool only
- `make run` — full pipeline: pod install → xcodebuild for both SDKs → inject Info.plists → create XCFrameworks → post-process (arm64 simulator slice + static archives) → copy resource bundles → zip everything into `GoogleMLKit/`
- `./build_with_asdf.sh` — same as `make run`, but sets up the asdf-shimmed Ruby first
- `./scripts/build_all.sh <version>` — bumps `Podfile` + `Resources/*-Info.plist`, runs `make run`, recomputes SHA256s, rewrites `Package.swift` binary target URLs/checksums, verifies
- `./scripts/batch_build.sh <v1> [v2] …` — sequential `build_all.sh` over multiple versions with auto commit + tag

### Inspect / verify

- `make verify` — closure check + `verify_build.rb` + `swift package dump-package`
- `ruby scripts/check_product_closure.rb` — asserts every `.library` product lists the full transitive framework set from `Podfile.lock` (catches the issue #110 class, which building the Example app cannot)
- `./scripts/verify_local_archive.sh` — the pre-release gate. Repoints `Package.swift` at `GoogleMLKit/`, **runs ML Kit on the arm64 Simulator** (text recognition, barcode, language ID), archives for device, and asserts nothing ITMS-scanned is embedded, nothing is linked dynamically and the model data survived. The runtime step is the only one that catches a missing model bundle or a bad simulator slice — a linking check cannot.
- `ruby scripts/test_patch_macho_platform.rb` — self-check for the hand-written `ar`/Mach-O parser
- `swift package dump-package` — validate `Package.swift` syntax (CI runs this too)
- `ruby scripts/verify_build.rb` — pre/post-flight (Info.plists present, `xcframework-maker` built, zips present, `Package.swift` parses)
- `./scripts/verify_runtime.sh <version>` — static checks on built XCFrameworks (architectures, embedded Info.plist, symbol table)
- `ruby scripts/check_mlkit_version.rb` — query the CocoaPods Trunk API for the latest GoogleMLKit version

### Targeted edits (used inside `build_all.sh`, runnable individually)

- `ruby scripts/update_version.rb <version>` — rewrite `Podfile` pod versions and `CFBundleShortVersionString` in every `Resources/*-Info.plist`
- `ruby scripts/update_checksums.rb <version>` — recompute SHA256 of every zip in `GoogleMLKit/`, rewrite each `binaryTarget(url:checksum:)` in `Package.swift`, and sync transitive Google deps from `Podfile.lock`
- `ruby scripts/update_package_dependencies.rb` — sync only the SwiftPM `dependencies:` block (GoogleDataTransport, GoogleUtilities, gtm-session-fetcher, promises, nanopb) from `Podfile.lock`
- `ruby scripts/postprocess_xcframeworks.rb [dir]` — inject the arm64 simulator slice and convert object-file binaries to `ar` archives (run by `make postprocess`)
- `ruby scripts/use_local_binaries.rb` — repoint every `binaryTarget` at `GoogleMLKit/*.xcframework`; undo with `git checkout Package.swift`
- `./scripts/upload_release.sh <version>` — upload `GoogleMLKit/*.xcframework.zip` to an existing GitHub Release (run `gh release create <version>` first if it doesn't exist)

### Example app

- `cd Example && open Example.xcworkspace` — SwiftUI demo app depending on the package via `path: "../../"`. Runs on both a real device and the Apple Silicon simulator. It needs the resource bundles first: `./scripts/download_bundles.sh <version>`, or `cp -rf GoogleMLKit/*.bundle Example/Example/Resources/Bundles/` after a local build.
- The app links **every** product at once, so it cannot catch a product that omits a transitive framework — that is what `check_product_closure.rb` is for.
- `Example/Package/Tests/CameraTests` holds the runtime smoke tests. They need `-Xlinker -ObjC -Xlinker -all_load` (declared on the test target) and the resource bundles staged into the built `.xctest`, which `verify_local_archive.sh` does — ML Kit resolves models against the main bundle, which for a SwiftPM test target is the test runner.

### CI (GitHub Actions)

- `Build MLKit XCFrameworks` (`.github/workflows/build-mlkit.yml`) — manual `workflow_dispatch` with a `version` input. Runs `make run` + `update_checksums.rb` and creates/updates the GitHub Release. Preferred over local builds for shipping a version.
- `Check MLKit Updates` (`.github/workflows/check-mlkit-updates.yml`) — daily cron at 09:00 UTC. Opens an issue when CocoaPods has a newer version.
- `CI` (`.github/workflows/ci.yml`) — runs on every PR: Ruby/shell syntax, `swift package dump-package`, the product-closure check and the Mach-O patcher self-check.

## Architecture / pipeline shape

The Makefile is the single source of truth for the build. Targets form a 7-stage
flow driven by the `MLKIT_MODULES` / `SOURCE_MODULES` lists at the top of the
Makefile — when something breaks, locate the right file by stage:

1. **`bootstrap-cocoapods`** — `bundle install` + `pod install` with `integrate_targets: false`. We only want the downloaded frameworks, not Xcode project integration. The Podfile uses `use_frameworks! :linkage => :static` so the two source pods don't ship as dynamic frameworks (see Gotchas, ITMS-91065).
2. **`bootstrap-builder`** — `swift build -c release` inside the `xcframework-maker/` git submodule. This tool wraps `xcodebuild -create-xcframework` and patches Info.plists for frameworks that ship without one.
3. **`build-cocoapods`** — runs `xcodebuild` against the generated `Pods.xcodeproj` for both `iphoneos` and `iphonesimulator` SDKs at `IPHONEOS_DEPLOYMENT_TARGET` (15.0 — Xcode 26 rejects anything lower).
4. **`prepare-info-plist`** — copies each `Resources/<Name>-Info.plist` template into `Pods/<Name>/Frameworks/<Name>.framework/Info.plist`. ML Kit pods ship without proper Info.plists; without this step the SwiftPM consumer crashes at launch with "The bundle doesn't contain…".
5. **`create-xcframework`** — `make-xcframework` for every `MLKIT_MODULES` entry, plus raw `xcodebuild -create-xcframework` for `SOURCE_MODULES` (`GoogleToolboxForMac`, `SSZipArchive`). Output lands in `GoogleMLKit/`.
6. **`postprocess`** — `scripts/postprocess_xcframeworks.rb` injects the arm64 simulator slice and converts every object-file binary into an `ar` archive. This replaced ~150 lines of hardcoded `mv → ar r → ranlib` blocks; the script detects what needs converting instead of naming modules, so the list cannot drift.
7. **`copy-resource-bundle`** + **`archive`** — copies *every* `.bundle` nested in a pod framework out to `GoogleMLKit/` (discovered with `find`, not listed), then `zip -qr` each `.xcframework` and `.bundle`.

### Module surface in `Package.swift`

- 17 `.library` products and ~30 `.binaryTarget` entries. Each binary target points at `https://github.com/d-date/google-mlkit-swiftpm/releases/download/<version>/<Name>.xcframework.zip` with a SHA256 checksum.
- One real `.target` named `Common` re-exports `MLKitCommon` and pulls in non-binary Google SwiftPM dependencies (GoogleUtilities, gtm-session-fetcher, GoogleDataTransport, nanopb, promises). Every public library composes its binary target with `Common`, so consumers don't have to wire these themselves.
- To point SwiftPM at `GoogleMLKit/*.xcframework` for local debugging, run `ruby scripts/use_local_binaries.rb`.

## Gotchas

- **The arm64 simulator slice is synthesised, not shipped by Google.** `scripts/postprocess_xcframeworks.rb` copies the device arm64 binary and rewrites the Mach-O platform to `PLATFORM_IOSSIMULATOR` (7). For `ar` archives the platform field is patched **in place** — extracting and repacking collapses ML Kit's duplicate member names (three `globals.o` in MLKitCommon) into ~115 duplicate symbols at link time. Four binaries (`MLKitBarcodeScanning`, `MLKitFaceDetection`, `MLKitTextRecognitionCommon`, `MLKitVisionKit`) declare no platform at all; xcframework-maker gives them an `LC_VERSION_MIN_IPHONEOS`, which `vtool -set-build-version 7 … -replace` can swap. `vtool` cannot add a load command to a bare object file ("not enough space to hold load commands"), which is why the in-place path exists.
- **Consumer linker flags.** Apps consuming this package must add `-ObjC` and `-all_load` to *Other Linker Flags*, otherwise they crash at runtime with `unrecognized selector`.
- **`Pods/<module>/Resources/<Name>/` is the authoritative bundle list, not the framework-nested copies.** Each podspec declares these as `resource_bundles`; the contents are identical to the nested copies where both exist, but ten bundles exist *only* under `Resources/` -- every OCR model, both pose detection models and both selfie segmentation models. Shipping only the nested copies is what left text recognition throwing `MLKTextRecognizerInternalErrorCreationFailure`, "Invalid model path." (issues #106/#109): `LatinOCRResources.bundle` had simply never been published. `copy-resource-bundle` scans both places (ML Kit nests SmartReply's bundle under a different name than the podspec key), so a new bundle needs no Makefile edit.
- **Framework binaries must end up as `ar` archives.** Xcode treats a framework whose binary is a bare Mach-O object as *dynamic* and relinks it, dead-stripping unreferenced data -- `MLKitTextRecognitionCommon` came out as a ~33KB stub instead of ~58MB. `postprocess` converts all of them. This is a separate defect from the missing bundle above; both had to be fixed.
- **ITMS-91065 comes from embedding.** Xcode embeds a *stub* framework bundle (~33KB, zero exported symbols) into the consumer app for every static framework bundle it links, even though the real code is linked into the app binary. Apple's scanner still sees `Frameworks/GoogleToolboxForMac.framework/GoogleToolboxForMac` and demands a signature this repo cannot provide (issue #102). Hence `SOURCE_MODULES` ship as **library-type** XCFrameworks (`.a` + headers): a library slice is linked, never embedded. The ML Kit frameworks keep their bundles — they need their module maps — and are not on Apple's commonly-used-SDK list.
- **A product only links the targets it lists.** The Example app depends on every product at once, so a framework missing from one product's `targets:` is still pulled in by another and the build passes — while a consumer adopting that single product gets undefined symbols (issue #110). `scripts/check_product_closure.rb` derives the correct closure from `Podfile.lock`; run it after any `Package.swift` product edit.
- **Submodule + Ruby version mismatch.** `xcframework-maker/` is a git submodule (`git submodule update --init` required). `.tool-versions` pins Ruby 4.0.1 for local dev but CI workflows pin Ruby 3.3 — a recent regression (PR #86) was caused by Ruby 4.0 incompatibility on macos-15 runners. Don't bump CI back to 4.x without verifying.
- **Adding a new MLKit module.** Touch `Podfile`, add `Resources/<Name>-Info.plist` (copy from a sibling), add the name to `MLKIT_MODULES` in the `Makefile`, and add the `.binaryTarget` plus product wiring in `Package.swift`. The Info.plist glob, the zip list, the ar conversion and the resource-bundle copy all derive from those, so nothing else needs editing. Finish with `ruby scripts/check_product_closure.rb`.
- **Don't hand-edit Pods.** The Podfile's `post_install` strips `ARCHS` so the Makefile can drive architecture choice. Don't `pod install` outside `make bootstrap-cocoapods`.
- **`Package.swift` URLs/checksums are generated.** Run `scripts/update_checksums.rb` rather than editing checksum strings — the next release run will overwrite manual edits anyway. The `dependencies:` pins are generated too (from `Podfile.lock`), so `renovate.json` disables the `swift` manager for the root `Package.swift`.
- **To build against local XCFrameworks**, run `ruby scripts/use_local_binaries.rb` and undo with `git checkout Package.swift`. The block of commented-out `path:`-based targets that used to live in `Package.swift` is gone.

## Conventions (from AGENTS.md, abbreviated)

- Swift tools `5.9`, iOS 15+ deployment target on `Package.swift`.
- No new third-party dependencies without asking first.
- Ruby scripts use the standard library only (no gems beyond CocoaPods).
