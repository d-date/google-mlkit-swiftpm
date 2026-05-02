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
- `make run` — full pipeline: pod install → xcodebuild for both SDKs → inject Info.plists → create XCFrameworks → ar/ranlib FAT-object fix → zip everything into `GoogleMLKit/`
- `./build_with_asdf.sh` — same as `make run`, but sets up the asdf-shimmed Ruby first
- `./scripts/build_all.sh <version>` — bumps `Podfile` + `Resources/*-Info.plist`, runs `make run`, recomputes SHA256s, rewrites `Package.swift` binary target URLs/checksums, verifies
- `./scripts/batch_build.sh <v1> [v2] …` — sequential `build_all.sh` over multiple versions with auto commit + tag

### Inspect / verify

- `swift package dump-package` — validate `Package.swift` syntax (CI runs this too)
- `ruby scripts/verify_build.rb` — pre/post-flight (Info.plists present, `xcframework-maker` built, zips present, `Package.swift` parses)
- `./scripts/verify_runtime.sh <version>` — static checks on built XCFrameworks (architectures, embedded Info.plist, symbol table)
- `ruby scripts/check_mlkit_version.rb` — query the CocoaPods Trunk API for the latest GoogleMLKit version

### Targeted edits (used inside `build_all.sh`, runnable individually)

- `ruby scripts/update_version.rb <version>` — rewrite `Podfile` pod versions and `CFBundleShortVersionString` in every `Resources/*-Info.plist`
- `ruby scripts/update_checksums.rb <version>` — recompute SHA256 of every zip in `GoogleMLKit/`, rewrite each `binaryTarget(url:checksum:)` in `Package.swift`, and sync transitive Google deps from `Podfile.lock`
- `ruby scripts/update_package_dependencies.rb` — sync only the SwiftPM `dependencies:` block (GoogleDataTransport, GoogleUtilities, gtm-session-fetcher, promises, nanopb) from `Podfile.lock`
- `./scripts/upload_release.sh <version>` — upload `GoogleMLKit/*.xcframework.zip` to an existing GitHub Release (run `gh release create <version>` first if it doesn't exist)

### Example app

- `cd Example && open Example.xcworkspace` — SwiftUI demo app. Depends on the package via `path: "../../"` and is used for device validation. **Run on a real iOS device** — the simulator is not supported on Apple Silicon (see Gotchas).

### CI (GitHub Actions)

- `Build MLKit XCFrameworks` (`.github/workflows/build-mlkit.yml`) — manual `workflow_dispatch` with a `version` input. Runs `make run` + `update_checksums.rb` and creates/updates the GitHub Release. Preferred over local builds for shipping a version.
- `Check MLKit Updates` (`.github/workflows/check-mlkit-updates.yml`) — daily cron at 09:00 UTC. Opens an issue when CocoaPods has a newer version.

## Architecture / pipeline shape

The Makefile is the single source of truth for the build. Targets form a 6-stage flow — when something breaks, locate the right file by stage:

1. **`bootstrap-cocoapods`** — `bundle install` + `pod install` with `integrate_targets: false`. We only want the downloaded frameworks, not Xcode project integration.
2. **`bootstrap-builder`** — `swift build -c release` inside the `xcframework-maker/` git submodule. This tool wraps `xcodebuild -create-xcframework` and patches Info.plists for frameworks that ship without one.
3. **`build-cocoapods`** — runs `xcodebuild` against the generated `Pods.xcodeproj` for both `iphoneos` and `iphonesimulator` SDKs at iOS 12.0 deployment target.
4. **`prepare-info-plist`** — copies each `Resources/<Name>-Info.plist` template into `Pods/<Name>/Frameworks/<Name>.framework/Info.plist`. ML Kit pods ship without proper Info.plists; without this step the SwiftPM consumer crashes at launch with "The bundle doesn't contain…".
5. **`create-xcframework`** — calls `xcframework-maker/.build/release/make-xcframework` for every MLKit module, plus raw `xcodebuild -create-xcframework` for `GoogleToolboxForMac` and `SSZipArchive`. Output lands in `GoogleMLKit/`.
6. **`archive`** — for static frameworks shipped as FAT object files (BarcodeScanning, FaceDetection, ImageLabeling, LanguageID, Translate, SmartReply), runs `mv → ar r → ranlib` inside both slices to convert the Mach-O object into a real `ar` archive. Then `zip -r` every `.xcframework` and `GoogleMVFaceDetectorResources.bundle` into `GoogleMLKit/`.

### Module surface in `Package.swift`

- 17 `.library` products and ~30 `.binaryTarget` entries. Each binary target points at `https://github.com/d-date/google-mlkit-swiftpm/releases/download/<version>/<Name>.xcframework.zip` with a SHA256 checksum.
- One real `.target` named `Common` re-exports `MLKitCommon` and pulls in non-binary Google SwiftPM dependencies (GoogleUtilities, gtm-session-fetcher, GoogleDataTransport, nanopb, promises). Every public library composes its binary target with `Common`, so consumers don't have to wire these themselves.
- A block of commented-out `.binaryTarget(name:path:)` entries near the top is intentionally kept for local debugging — uncomment them (and comment the URL-based ones) to point SwiftPM at `GoogleMLKit/*.xcframework` directly.

## Gotchas

- **No arm64 iOS Simulator slice.** ML Kit's pre-built binaries don't include arm64 simulator. The Makefile only produces `arm64` for iphoneos and `x86_64` for iphonesimulator. Apple Silicon Macs cannot use the simulator — test on a real device.
- **Consumer linker flags.** Apps consuming this package must add `-ObjC` and `-all_load` to *Other Linker Flags*, otherwise they crash at runtime with `unrecognized selector`.
- **`MLKitFaceDetection` resource bundle.** `GoogleMVFaceDetectorResources.bundle` cannot ride along inside SwiftPM. It ships as a separate `.zip` on the GitHub Release; consumers must add it to their Xcode project manually.
- **Submodule + Ruby version mismatch.** `xcframework-maker/` is a git submodule (`git submodule update --init` required). `.tool-versions` pins Ruby 4.0.1 for local dev but CI workflows pin Ruby 3.3 — a recent regression (PR #86) was caused by Ruby 4.0 incompatibility on macos-15 runners. Don't bump CI back to 4.x without verifying.
- **Adding a new MLKit module is a multi-file change.** It touches `Podfile`, a new `Resources/<Name>-Info.plist` (copy from a sibling), the `Makefile` (`prepare-info-plist` + `create-xcframework` + `archive` zip list, plus the ar/ranlib block if it's static-only), `Package.swift` (new `.binaryTarget` and either a new `.library` or addition to an existing product's target list), and possibly `scripts/update_checksums.rb` if it enumerates frameworks.
- **Don't hand-edit Pods.** The Podfile's `post_install` strips `ARCHS` so the Makefile can drive architecture choice. Don't `pod install` outside `make bootstrap-cocoapods`.
- **`Package.swift` URLs/checksums are generated.** Run `scripts/update_checksums.rb` rather than editing checksum strings — the next release run will overwrite manual edits anyway.

## Conventions (from AGENTS.md, abbreviated)

- Swift tools `5.9`, iOS 15+ deployment target on `Package.swift`.
- No new third-party dependencies without asking first.
- Ruby scripts use the standard library only (no gems beyond CocoaPods).
