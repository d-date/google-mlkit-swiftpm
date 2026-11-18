# MLKit SwiftPM Automation Guide

This repository includes automation to keep the SwiftPM wrapper up to date with the latest ML Kit releases.

## Background

ML Kit is distributed exclusively via CocoaPods. This project builds those pods into XCFrameworks with
[swiftpods](https://github.com/d-date/swiftpods) and publishes them as binary targets of `Package.swift`.

`swiftpods package --version <version>` reads `Podfile.swift` and, in one run:

1. installs the pods (keeping the versions in `Podfile.lock`) and builds them for `iphoneos` and `iphonesimulator`
2. turns them into XCFrameworks: adds an `Info.plist` where a prebuilt framework lacks one, synthesises the
   arm64 simulator slice, converts object-file binaries into `ar` archives, and builds the two source pods
   (GoogleToolboxForMac, SSZipArchive) as library XCFrameworks
3. writes `<Module>.xcframework.zip` and `<Bundle>.bundle.zip` to `build/distribution/`
4. regenerates `Package.swift` (products, binary target URLs and checksums, dependency ranges) and
   `Sources/Common/export.swift`
5. links every product on its own for the simulator and the device

See the swiftpods README, section "Distributing pods as a Swift package", for the details.

## Versioning

Release tags are `major.minor.patch`: major and minor follow ML Kit, the patch number counts wrapper
releases (`9.0.4` repackages ML Kit `9.0.0`). The ML Kit version itself is the `GoogleMLKit/*` requirement in
`Podfile.swift`.

## Automation Workflows

### 1. Check MLKit Updates (Scheduled)

**File:** `.github/workflows/check-mlkit-updates.yml`

- **Trigger:** Daily at 9:00 UTC (or manually via workflow_dispatch)
- **Purpose:** Compares the latest GoogleMLKit version on CocoaPods with the requirement in `Podfile.swift`
  (`scripts/check_mlkit_version.rb`)
- **Action:** Creates a GitHub issue if a new version is found

### 2. Build MLKit XCFrameworks (Manual)

**File:** `.github/workflows/build-mlkit.yml`

- **Trigger:** Manual workflow dispatch with `version` and `create_release` inputs
- **Steps:**
  1. Builds swiftpods from `d-date/swiftpods` at `SWIFTPODS_REF` (currently `main`; to be pinned to a tag)
  2. Runs `swiftpods package --version <version>` and `swift package dump-package`
  3. With `create_release`: commits `Podfile.swift`, `Podfile.lock`, `Package.swift` and
     `Sources/Common/export.swift` if they changed, tags `<version>`, pushes both, runs
     `scripts/release.sh --skip-package <version>` and closes the related issue
  4. Without `create_release`: uploads the zips and the generated `Package.swift` as a workflow artifact

### 3. CI

**File:** `.github/workflows/ci.yml` — on every PR and push to `main`: Ruby and shell syntax of `scripts/`,
and `swift package dump-package`.

## Manual Usage

### Check for Updates

```bash
ruby scripts/check_mlkit_version.rb
```

### Move to a New ML Kit Version

1. Raise the `GoogleMLKit/*` requirements in `Podfile.swift`
2. Run `swiftpods update` to move `Podfile.lock`
3. Commit both, then release as below

### Build and Release Locally

```bash
swiftpods package --version <version>
./scripts/verify_local_archive.sh
scripts/release.sh <version>
```

`scripts/release.sh` runs `swiftpods package` itself, then checks that every `*.xcframework.zip` that
`Package.swift` references exists in `build/distribution/`, points at `<version>` and matches its checksum,
and that the tag `<version>` on origin carries the same `Package.swift`. If the tag does not exist yet it stops;
commit `Podfile.swift`, `Podfile.lock`, `Package.swift` and `Sources/Common/export.swift`, tag `<version>`, push
the branch and the tag, then run `scripts/release.sh --skip-package <version>`. It creates the GitHub Release
(a prerelease when the tag has a `-` suffix) if needed and uploads those xcframework zips plus every
`*.bundle.zip` in `build/distribution/`, replacing assets of the same name.

Set `SWIFTPODS` to the swiftpods binary if it is not on `PATH`.

## GitHub Actions Setup

### Required Secrets

No additional secrets are required. The workflows use the default `GITHUB_TOKEN` for:

- Creating issues
- Creating releases
- Pushing commits

### Permissions

Ensure the repository has the following workflow permissions enabled:

- Read and write permissions for workflows
- Allow GitHub Actions to create and approve pull requests

You can configure this in: **Settings → Actions → General → Workflow permissions**

## Triggering a Build via GitHub Actions

1. Go to the **Actions** tab in GitHub
2. Select the **"Build MLKit XCFrameworks"** workflow
3. Click **"Run workflow"**
4. Enter the release version (e.g., `9.0.4`)
5. Choose whether to create a release automatically
6. Click **"Run workflow"**

## Troubleshooting

### Version Check Fails

If `check_mlkit_version.rb` fails to fetch version info:

- The script uses the CocoaPods Trunk API (`https://trunk.cocoapods.org/api/v1/pods/GoogleMLKit`)
- Check your internet connection
- The API may be temporarily unavailable

### Build Fails

- swiftpods needs Xcode with Swift 6.4
- Check that the ML Kit version exists in CocoaPods
- `swiftpods package` fails when a product does not link on its own (verification)

### Release Refused

`scripts/release.sh` names each zip that is missing, points at another release or does not match its
checksum. Re-run `swiftpods package --version <version>` and commit the regenerated `Package.swift` before
tagging.
