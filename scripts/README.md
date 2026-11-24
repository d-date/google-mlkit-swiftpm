# Scripts

The XCFrameworks, resource bundle zips and `Package.swift` are built by
`swiftpods package --version <version>` (see the top-level README). The scripts
here cover what swiftpods does not: publishing, the update check and runtime
verification.

## release.sh

Publishes a release built by swiftpods.

**Usage:**
```bash
scripts/release.sh [--skip-package] <version>
```

**What it does:**

1. Runs `swiftpods package --version <version>` (skipped with `--skip-package`;
   set `SWIFTPODS` if the binary is not on `PATH`)
2. Refuses if any `*.xcframework.zip` that `Package.swift` references is
   missing from `build/distribution/`, points at another release, or does not
   match its checksum
3. Refuses unless the tag `<version>` exists on origin and carries the same
   `Package.swift`
4. Creates the GitHub Release `<version>` with `gh` (a prerelease when the
   version has a `-` suffix), or reuses an existing one
5. Uploads the referenced xcframework zips and every `*.bundle.zip` in
   `build/distribution/`, replacing assets of the same name

The build workflow calls it with `--skip-package` after it has packaged,
committed, tagged and pushed. Locally, commit `Podfile.swift`, `Podfile.lock`,
`Package.swift` and `Sources/Common/export.swift`, tag and push before the
upload step.

## check_mlkit_version.swift

Checks for new ML Kit versions on CocoaPods. Used by
`.github/workflows/check-mlkit-updates.yml`.

**Usage:**
```bash
swift scripts/check_mlkit_version.swift
```

**Output:**
- Current version from the `GoogleMLKit/BarcodeScanning` requirement in `Podfile.swift`
- Latest version from the CocoaPods Trunk API
- `UPDATE_AVAILABLE=true|false` (and `NEW_VERSION=` when true)

## download_bundles.sh

Downloads the resource bundles of a release into
`Example/Example/Resources/Bundles/` for the Example app.

```bash
./scripts/download_bundles.sh <version>
```

## use_local_binaries.swift

Rewrites every `.binaryTarget` in `Package.swift` to point at
`build/distribution/*.xcframework` instead of a release asset, so the package
can be built before anything is published. Undo with
`git checkout Package.swift`.

## verify_local_archive.sh

The pre-release gate. Repoints `Package.swift` at `build/distribution/`,
unpacks the bundle zips into `build/bundles/`, runs the `CameraTests` on the
arm64 Simulator with the bundles copied into the test bundle, launches the
Example app, archives it for device, and fails if an SDK on Apple's
commonly-used list is embedded (ITMS-91065), if anything is linked
dynamically, if a model bundle is missing from the app, or if the app binary
is too small to still contain the ML Kit model data. Restores `Package.swift`
on exit.

## verify_app_store_upload.sh

Archives the Example app with distribution signing against
`build/distribution/`, exports an App Store IPA, validates it with Apple and,
with `--upload`, delivers it to App Store Connect. See the header of the
script for the account setup it needs.

## Requirements

- Xcode with Swift 6.4 and swiftpods (for `release.sh` without `--skip-package`)
- GitHub CLI (`gh`), authenticated, for `release.sh`
- Swift (Xcode's toolchain) for the `.swift` scripts
- `asc` for `verify_app_store_upload.sh`
