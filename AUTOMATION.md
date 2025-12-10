# MLKit SwiftPM Automation Guide

This repository includes automation tools to keep the SwiftPM wrapper up-to-date with the latest MLKit releases.

## Background

MLKit is distributed exclusively via CocoaPods. This project converts MLKit frameworks to XCFramework format for SwiftPM compatibility. The process involves:

1. Using CocoaPods to download and build MLKit frameworks (without project integration)
2. Building for both `iphoneos` and `iphonesimulator` SDKs
3. Converting to XCFramework using `xcodebuild -create-xcframework`
4. Handling FAT object files that require archive conversion (`ar`, `ranlib`)
5. Publishing as binary targets in Package.swift

For technical details, see the original article: <https://zenn.dev/d_date/articles/cd4ce3b2b5c29d>

## Overview

The automation system consists of:

1. **Version Check Script** - Detects new MLKit releases from CocoaPods
2. **Build Scripts** - Automates the XCFramework build process
3. **Verification Script** - Validates build outputs
4. **GitHub Actions Workflows** - Orchestrates automated checks and builds

## Key Components

### xcframework-maker

This project uses a custom `xcframework-maker` tool (located in `xcframework-maker/`) to handle the conversion of frameworks to XCFrameworks. This tool:

- Properly handles static frameworks with FAT object files
- Adds arm64 simulator support where possible
- Manages Info.plist files for frameworks that lack them

The tool must be built before creating XCFrameworks:

```bash
make bootstrap-builder
```

### Info.plist Files

MLKit frameworks often lack proper Info.plist files. This project maintains template Info.plist files in the `Resources/` directory that are copied to frameworks during the build process (via the `prepare-info-plist` Makefile target).

## Automation Workflows

### 1. Check MLKit Updates (Scheduled)

**File:** `.github/workflows/check-mlkit-updates.yml`

- **Trigger:** Daily at 9:00 UTC (or manually via workflow_dispatch)
- **Purpose:** Checks if a new version of GoogleMLKit is available on CocoaPods
- **Action:** Creates a GitHub issue if a new version is found

### 2. Build MLKit XCFrameworks (Manual)

**File:** `.github/workflows/build-mlkit.yml`

- **Trigger:** Manual workflow dispatch
- **Purpose:** Builds XCFrameworks for a specific MLKit version
- **Steps:**
  1. Updates Podfile with the specified version
  2. Builds XCFrameworks using the existing Makefile
  3. Calculates checksums
  4. Updates Package.swift
  5. Creates a GitHub release with the built frameworks
  6. Closes the related issue

## Manual Usage

### Check for Updates

```bash
ruby scripts/check_mlkit_version.rb
```

This script will:

- Fetch the latest MLKit version from CocoaPods
- Compare it with the current version in Podfile
- Output whether an update is available

### Build a New Version

```bash
./scripts/build_all.sh <version>
```

Example:

```bash
./scripts/build_all.sh 7.0.0
```

This script will:

1. Update the Podfile and Info.plist files with the new version
2. Run the full build process (via `make run`)
3. Calculate checksums for all XCFrameworks
4. Update Package.swift with new URLs and checksums
5. Verify the build output

After running the script:

1. Review the changes in `Package.swift`, `Podfile`, and `Resources/`
2. Test the package: `swift package resolve`
3. Upload artifacts to an existing GitHub release (see below)
4. Commit the changes
5. Push to GitHub

### Upload Artifacts to GitHub Release

After building XCFrameworks, you can upload them to an existing GitHub release:

```bash
./scripts/upload_release.sh <version>
```

Example:

```bash
./scripts/upload_release.sh 7.0.0
```

This script will:

1. Check if the specified release exists
2. Delete old XCFramework assets from the release (if any)
3. Upload all newly built XCFramework zip files from `GoogleMLKit/`

**Note:** The release must already exist. Create it first using:

```bash
gh release create <version> --title "Release <version>" --notes "Updated to MLKit <version>"
```

Or let GitHub Actions create it automatically (see "Triggering a Build via GitHub Actions" below).

### Update Individual Components

#### Update Podfile Only

```bash
ruby scripts/update_version.rb <version>
```

This also updates the `CFBundleShortVersionString` in all Info.plist files in the `Resources/` directory.

#### Verify Build

Check if all required files and tools are present:

```bash
ruby scripts/verify_build.rb
```

This checks:

- Info.plist files in Resources/
- xcframework-maker is built
- XCFramework zip files exist (post-build)
- Package.swift syntax is valid

#### Update Checksums Only

After building XCFrameworks:

```bash
ruby scripts/update_checksums.rb <version>
```

### Understanding the Build Process

The build process follows these steps (as defined in the Makefile):

1. **bootstrap-cocoapods**: Install gems and run `pod install`
2. **bootstrap-builder**: Build the xcframework-maker tool
3. **build-cocoapods**: Build frameworks for both iphoneos and iphonesimulator
4. **prepare-info-plist**: Copy Info.plist files from Resources/ to frameworks
5. **create-xcframework**: Create XCFrameworks from built frameworks
6. **archive**: Convert FAT objects to archives and zip XCFrameworks

The automation scripts wrap these steps and add version management and verification.

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

1. Go to **Actions** tab in GitHub
2. Select **"Build MLKit XCFrameworks"** workflow
3. Click **"Run workflow"**
4. Enter the MLKit version (e.g., `5.1.0`)
5. Choose whether to create a release automatically
6. Click **"Run workflow"**

The workflow will:

- Build the XCFrameworks
- Update Package.swift
- Create a release (if selected)
- Close the related issue (if it exists)

## Troubleshooting

### Version Check Fails

If `check_mlkit_version.rb` fails to fetch version info:

- The script uses the CocoaPods Trunk API (`https://trunk.cocoapods.org/api/v1/pods/GoogleMLKit`)
- Check your internet connection
- Verify the CocoaPods Trunk API is accessible
- The API may be temporarily unavailable

### Build Fails

- Check Xcode version compatibility
- Verify CocoaPods dependencies are installed
- Check that the MLKit version exists in CocoaPods

### Checksum Mismatch

- Ensure XCFramework zip files are in `GoogleMLKit/` directory
- Verify the files are not corrupted
- Re-run the build process

### Release Creation Fails

- Check repository permissions
- Verify GITHUB_TOKEN has sufficient permissions
- Ensure the tag doesn't already exist

## Future Improvements

Possible enhancements:

1. **Fully Automated Releases**
   - Automatically trigger builds when new versions are detected
   - Require manual approval before creating releases

2. **Version Testing**
   - Add automated tests to verify the built frameworks work correctly
   - Test integration with sample projects

3. **Multi-Module Support**
   - Extend to support more MLKit modules beyond BarcodeScanning and FaceDetection

4. **Changelog Generation**
   - Automatically generate changelogs based on MLKit release notes

## Contributing

When adding new automation features:

1. Test scripts locally before committing
2. Use descriptive commit messages
3. Update this documentation
4. Consider adding error handling and logging
