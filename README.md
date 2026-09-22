# Google MLKit SwiftPM Wrapper

This is experimental project for building MLKit in Swift Package Manager.

## Requirements

- iOS 15 and later
- Xcode 15 and later

## Installation

### Use Swift Package Manager to install

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "9.0.0")
]
```

> **Submitting to App Store?** The `9.0.0` zips embed Info.plist values like `1.0.0-beta16` for a few internal frameworks, which App Store Connect rejects. Pin the wrapper-only repackage instead:
>
> ```swift
> .package(url: "https://github.com/d-date/google-mlkit-swiftpm", exact: "9.0.0-1")
> ```
>
> `9.0.0-1` is a SemVer pre-release of the same upstream MLKit `9.0.0` build with the Info.plist regression fixed. SwiftPM's `from: "9.0.0"` excludes pre-release tags, so existing consumers stay on `9.0.0`; AppStore-blocked consumers opt in via `exact:`.

Then add the specific ML Kit modules you need to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MLKitBarcodeScanning", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
        .product(name: "MLKitTextRecognition", package: "google-mlkit-swiftpm"),
        // Also available: MLKitTextRecognitionChinese, MLKitTextRecognitionDevanagari,
        //                  MLKitTextRecognitionJapanese, MLKitTextRecognitionKorean
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

### Link resource bundles to your project

Every ML Kit module keeps its model in a resource bundle, and Swift Package
Manager cannot carry a resource bundle inside a binary target. Each bundle is
published as a separate release asset: download the ones your modules need, add
them to your Xcode project, and make sure they are in **Copy Bundle Resources**
of your app target. Without them the module throws at runtime -- text
recognition fails with `MLKTextRecognizerInternalErrorCreationFailure`,
"Invalid model path.".

`scripts/download_bundles.sh <version>` fetches all of them at once.

| Bundle | Needed by |
| --- | --- |
| `GoogleMVFaceDetectorResources.bundle` | `MLKitFaceDetection` |
| `LatinOCRResources.bundle` | `MLKitTextRecognition` |
| `ChineseOCRResources.bundle` | `MLKitTextRecognitionChinese` |
| `DevanagariOCRResources.bundle` | `MLKitTextRecognitionDevanagari` |
| `JapaneseOCRResources.bundle` | `MLKitTextRecognitionJapanese` |
| `KoreanOCRResources.bundle` | `MLKitTextRecognitionKorean` |
| `MLKitImageLabelingResources.bundle` | `MLKitImageLabeling` |
| `MLKitObjectDetectionResources.bundle` | `MLKitObjectDetection` |
| `MLKitObjectDetectionCommonResources.bundle` | `MLKitImageLabeling`, `MLKitImageLabelingCustom`, `MLKitObjectDetection`, `MLKitObjectDetectionCustom` |
| `MLKitPoseDetectionFastResources.bundle` | `MLKitPoseDetection` |
| `MLKitPoseDetectionAccurateResources.bundle` | `MLKitPoseDetectionAccurate` |
| `MLKitPoseDetectionCommonResources.bundle` | `MLKitPoseDetection`, `MLKitPoseDetectionAccurate` |
| `MLKitSegmentationSelfieResources.bundle` | `MLKitSegmentationSelfie` |
| `MLKitSegmentationCommonResources.bundle` | `MLKitSegmentationSelfie` |
| `MLKitXenoResources.bundle` | `MLKitPoseDetection`, `MLKitPoseDetectionAccurate`, `MLKitSegmentationSelfie` |
| `MLKitTranslate_resource.bundle` | `MLKitTranslate` |
| `PredictOnDeviceResource.bundle` | `MLKitSmartReply` |
| `PredictOnDevice_resource.bundle` | `MLKitSmartReply` (the spelling ML Kit nests inside its framework; earlier releases shipped this one) |

## Supported Features

This package supports the following Google ML Kit features:

### Vision APIs
- **Barcode Scanning** - Scan and decode barcodes
- **Face Detection** - Detect faces and facial features
- **Text Recognition** - Recognize text in images (v2) with variants for Chinese, Devanagari, Japanese, and Korean
- **Image Labeling** - Identify objects, locations, activities, and more (standard and custom models)
- **Object Detection & Tracking** - Detect and track objects in images and video (standard and custom models)
- **Pose Detection** - Detect body poses and positions (standard and accurate)
- **Selfie Segmentation** - Segment people from the background

### Language APIs
- **Language Identification** - Identify the language of text
- **Translation** - Translate text between languages
- **Smart Reply** - Generate contextual reply suggestions

## Limitation

- ML Kit's pre-built binaries carry no arm64 simulator code, so this project
  synthesises that slice from the device slice by rewriting the Mach-O platform
  (see `scripts/postprocess_xcframeworks.rb`). Published XCFrameworks therefore
  cover `arm64` for iphoneos and `arm64` + `x86_64` for iphonesimulator, and no
  `EXCLUDED_ARCHS` workaround is needed on Apple Silicon.
- Google ships ML Kit without dSYMs, so Xcode's archive step reports
  "Upload Symbols Failed" for each ML Kit framework. The frameworks are linked
  statically, so their symbols land in your app's own dSYM; the warnings are
  spurious and do not block submission.

## Example

Open `Example/Example.xcworkspace` and fixing code signing to yours.

## Automation

This repository includes automation tools for updating to new MLKit versions:

- **Automated Version Checking**: Daily checks for new MLKit releases via GitHub Actions
- **Build Automation**: Scripts to build and package new versions
- **GitHub Actions**: Workflows for automated builds and releases

For detailed information, see [AUTOMATION.md](AUTOMATION.md).

### Quick Start for Maintainers

To update to a new MLKit version:

```bash
# Check for updates
ruby scripts/check_mlkit_version.rb

# Build new version (replace with actual version)
./scripts/build_all.sh <version>
```

Or trigger the **Build MLKit XCFrameworks** workflow from the GitHub Actions tab.
