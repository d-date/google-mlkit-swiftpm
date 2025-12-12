# Google MLKit SwiftPM Wrapper

This is experimental project for building MLKit in Swift Package Manager.

**New:** This repository now includes automated tools to keep up-to-date with MLKit releases. See [AUTOMATION.md](AUTOMATION.md) for details.

## Requirements

- iOS 14 and later
- Xcode 13.2.1 and later

## Installation

### Use Swift Package Manager to install

```swift
    .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "9.0.0")
```

### Add Linker flags

Add these flags to `Other Linker Flags` in Build Settings of your Xcode projects.

- `-ObjC`
- `-all_load`

### Link `.bundle` to your project

The `MLKitFaceDetection` contains `GoogleMVFaceDetectorResources.bundle`. Since the bundle can't be introduced via Swift PM, you need to link to your project by yourself.

Download `GoogleMVFaceDetectorResources.bundle` from [Release](https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/GoogleMVFaceDetectorResources.bundle.zip) and add to your Xcode project and make it available in your build target.

## Limitation

- Since pre-built MLKit binary missing `arm64` for iphonesimulator, this project enables to build in `arm64` for iphoneos and `x86_64` for iphonesimulator only.
- Only supported `Face Detection` and `Barcode Scanning` right now.

## Example

Open `Example/Example.xcworkspace` and fixing code signing to yours.

## Automation

This repository includes automation tools for updating to new MLKit versions:

- **Automated Version Checking**: Daily checks for new MLKit releases
- **Build Automation**: Scripts to build and package new versions
- **GitHub Actions**: Workflows for automated builds and releases

For detailed information, see [AUTOMATION.md](AUTOMATION.md).

### Quick Start for Maintainers

To update to a new MLKit version:

```bash
# Check for updates
ruby scripts/check_mlkit_version.rb

# Build new version (replace 5.1.0 with actual version)
./scripts/build_all.sh 5.1.0
```

Or use the GitHub Actions workflow for fully automated builds.
