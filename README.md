# Google MLKit SwiftPM Wrapper

This is experimental project for building MLKit in Swift Package Manager.

**New:** This repository now includes automated tools to keep up-to-date with MLKit releases. See [AUTOMATION.md](AUTOMATION.md) for details.

## Requirements

- iOS 14 and later
- Xcode 13.2.1 and later

## Installation

### Use Swift Package Manager to install

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "9.0.0")
]
```

Then add the specific ML Kit modules you need to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitImageLabeling", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitObjectDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitPoseDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitSegmentationSelfie", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitLanguageID", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTranslate", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitSmartReply", package: "google-mlkit-swiftpm"),
    ]
)
```

### Add Linker flags

Add these flags to `Other Linker Flags` in Build Settings of your Xcode projects.

- `-ObjC`
- `-all_load`

### Link resource bundles to your project (if needed)

Some ML Kit modules require resource bundles. Currently:

#### Face Detection
The `MLKitFaceDetection` module requires `GoogleMVFaceDetectorResources.bundle`. Since bundles can't be automatically included via Swift Package Manager, you need to manually add it to your project.

Download `GoogleMVFaceDetectorResources.bundle` from [Release](https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0/GoogleMVFaceDetectorResources.bundle.zip) and add it to your Xcode project, ensuring it's included in your build target.

**Note**: Other modules (Text Recognition, Pose Detection, Object Detection, Selfie Segmentation, Translation) may also require resource bundles or downloaded models at runtime. Check the official [ML Kit documentation](https://developers.google.com/ml-kit) for specific requirements.

## Supported Features

This package supports the following Google ML Kit features:

### Vision APIs
- **Barcode Scanning** - Scan and decode barcodes
- **Face Detection** - Detect faces and facial features  
- **Text Recognition** - Recognize text in images (v2)
- **Image Labeling** - Identify objects, locations, activities, and more
- **Object Detection & Tracking** - Detect and track objects in images and video
- **Pose Detection** - Detect body poses and positions
- **Selfie Segmentation** - Segment people from the background

### Language APIs
- **Language Identification** - Identify the language of text
- **Translation** - Translate text between languages
- **Smart Reply** - Generate contextual reply suggestions

## Limitation

- Since pre-built MLKit binary missing `arm64` for iphonesimulator, this project enables to build in `arm64` for iphoneos and `x86_64` for iphonesimulator only.

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
